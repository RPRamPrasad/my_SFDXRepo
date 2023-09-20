/**
 * @description Class that used to process catastrophe (CAT) requests, such as retrieving the name of the US States with open catastrophes and retrieving billing 
 * accounts with open catastrophes. The logic for mathching catastrophes depends on the policy type. illing accounts for Auto policies are shown 
 * if there is an open catastrophe record in the state address of the insurance policy. The Auto insurance policy state address is encoded in the
 *  policy account number. Billing accounts for Fire, Life, and Health Policies are shown if there is an open catastrophe record in the billing 
 * state address of the customer (Account).
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.1, 05/02/23
 * @see {@link https://sf-pcu-knowledge.custhelp.com/app/knowledge/content/1027158} 
 * @since 1.0
*/
public with sharing class CatastropheRequests {

    // Message word to be used in thrown exception messages
    private static final String MESSAGE_TEXT = '. Message: ';
    private static Set<String> billingAccNumbs = new Set<String>();
    private static Set<String> stateCodesWithOpenCatsSet = stateCodesWithOpenCats();
	private static Boolean accBillAddrWithOpenCatsBool;
    
    /**
     * @description Static method that finds all the SF billing accounts of a customer (account) and returns those that are impacted by an open catastrophe.
     * To determine which billing accounts impacted by an open catastrophe the method looks at the policy type (Auto, Fire, Life, and Health).
     *   
     * @param accountId the id of the customer (Account) whose billing accounts we want to retrieve
     * @return List<String> - a set of billing account numbers with open catastrophes of the customer (Account)
     * @throws AuraHandledException if the user calling the method does not have sufficient permissions
     * @see {@link https://sf-pcu-knowledge.custhelp.com/app/knowledge/content/1027158}
     */ 
    @AuraEnabled
    public static List<String> billAccsWithOpenCats(Id accountId) {
        List<String> accountIds = new List<String>();
        List<Account> householdMembers = new List<Account>();
        List<Account> secureAccounts = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, IsPersonAccount, Primary_Household__pc FROM Account WHERE Id = :accountId]).getRecords();
        if (secureAccounts[0].IsPersonAccount == True) {
            accountIds.add(accountId);
        } else {
            householdMembers = Security.stripInaccessible(AccessType.READABLE, [SELECT Id FROM Account WHERE Primary_Household__pc = :accountId]).getRecords();
            for (Account householdMember : householdMembers) {
                accountIds.add(householdMember.Id);
            }
        }
        List<BillingAccountData> billAccounts = BillingTabController.getBillingAccounts(accountIds);
        // Check if the billing state address of account passed has an open catastrophe 
        accBillAddrWithOpenCatsBool = accBillAddrWithOpenCats(accountId);
        for(BillingAccountData billAccount : billAccounts) {
            billAccsWithOpenCatsHelper(billAccount);
        }
        if(billingAccNumbs.isEmpty()){
            billingAccNumbs.add('No Billing Accounts Found');
        }
        return new List<String>(billingAccNumbs);
    }
    
      /**
     * @description Private helper method that takes a billing account, searches its related insurance policy type, and saves the account number in set
     * if it has an open catastrophe.
     * 
     * @param billAccount a billing account instance with Insurance Policy nested info
     * @throws AuraHandledException if the user calling the method does not have sufficient permissions
     */ 
    private static void billAccsWithOpenCatsHelper(BillingAccountData billAccount) {
        for (BillingTabModels.InsurancePolicyData insurancePolicy : billAccount.insurancePolicies) {
            if (insurancePolicy.policyActive.get(billAccount.billingAccountId) == true) {
                String policyType = getPolicyType(insurancePolicy.insurancePolicyUrl.substring(1));
                // Add to set if state matches open cats (Auto, Fire, Life, Health)
                if (policyType == 'Auto' && stateCodesWithOpenCatsSet.contains(insurancePolicy.insurancePolicyNumber.right(2))) {
                    billingAccNumbs.add(billAccount.billingAccountNumber);
                } else if (accBillAddrWithOpenCatsBool && (policyType == 'Fire' || policyType == 'Life' || policyType == 'Health')) {
                    billingAccNumbs.add(billAccount.billingAccountNumber);
                }
            }
        }
    }

     /**
     * @description Private helper method that takes a billing account, searches its related insurance policy type, and saves the account number in set
     * if it has an open catastrophe.
     * 
     * @param insurancePolicy a billing account instance with Insurance Policy nested info
     * @throws AuraHandledException if the user calling the method does not have sufficient permissions
     * @return String - 
     */ 
    private static String getPolicyType(Id insurancePolicy) {
        String policyType;
            try {
                policyType = [SELECT PolicyType FROM InsurancePolicy WHERE Id =:insurancePolicy WITH SECURITY_ENFORCED LIMIT 1].PolicyType; 
            } catch(QueryException qe) {
                throw new AuraHandledException('Innacessible Billing Policy or Billing Participant fields:' + MESSAGE_TEXT + qe.getMessage());
            }
        return policyType;
    }

    /**
     * @description Helper method that returns true if there is an open catastrophe record in the state address of a particular customer (Account). 
     *   
     * @param accoountId the id of the customer (Account) has that we want to find for open catastrophe records
     * @return Boolean - {@code true} if the there are open catastrophes in the billing state address of the customer (Account), {@code false} otherwise
     * @throws AuraHandledException if the user calling the method does not have sufficient permissions to query the account object
     */ 
    public static Boolean accBillAddrWithOpenCats(Id accoountId) {
        // get billing address state of account
        String accBillingAddrState;
        try {
            accBillingAddrState = [SELECT BillingState FROM Account WHERE Id = :accoountId WITH SECURITY_ENFORCED LIMIT 1].BillingState;
        } catch(QueryException qe) {
            // Handle inaccessible fields
            Map<String, Set<String>> inaccessible = qe.getInaccessibleFields();
            Set<String> inaccessAccFields = inaccessible.get('Account'); 
            throw new AuraHandledException('Innacessible fields: ' + inaccessAccFields + MESSAGE_TEXT + qe.getMessage());
        }
        // get list of states with open cats
        List<String> openCatStatesLs = statesWithOpenCats();
        Set<String> openCatStates = new Set<String>(openCatStatesLs);
        return openCatStates.contains(accBillingAddrState);
    }
    
    /**
     * @description Method used to find a list of states with open (Active) catastrophe records. States returned are abbreviations (i.e: IL, KS, ...)
     *   
     * @return List<String> - a list of state abbreviations that have open (Active) catastrophe records
     * @throws AuraHandledException if the user calling the method does not have sufficient permissions to query the Catastrophe object
     */ 
    public static List<String> statesWithOpenCats() {
        List<String> openCatStates = new List<String>();
        AggregateResult[] openCatStatesAr;
        try {
            openCatStatesAr = [SELECT State__c FROM Catastrophe__c WHERE Cat_Status__c = 'Active' WITH SECURITY_ENFORCED GROUP BY State__c];
        } catch(QueryException qe) {
            // Handle inaccessible fields
            Map<String, Set<String>> inaccessible = qe.getInaccessibleFields();
            Set<String> inaccessCatFields = inaccessible.get('Catastrophe__c'); 
            throw new AuraHandledException('Innacessible fields: ' + inaccessCatFields + MESSAGE_TEXT + qe.getMessage());
        }
        for(AggregateResult openCatAr : openCatStatesAr) {
            openCatStates.add((String)openCatAr.get('State__c'));
        }
        return openCatStates;
    }

    /**
     * @description Method used to find a list of state codes with open (Active) catastrophe records. The state abbreviation - state code mapping can be found in the 
     * "CM US StateCode Mapping" Custom Metadata Type in ECRM. For example, the state code of IL is 13.
     *   
     * @return Set<String> - a list of state codes that have open (Active) catastrophe records
     * @throws AuraHandledException if the user calling the method does not have sufficient permissions
     */ 
    public static Set<String> stateCodesWithOpenCats() { 
        List<String> openCatStates = statesWithOpenCats();
        Set<String> openCatStateCode = new Set<String>();
        List<CM_USStateCodeMapping__mdt> stateCodesMdt;
        try {
            stateCodesMdt = [SELECT StateCode__c FROM CM_USStateCodeMapping__mdt WHERE State__c = :openCatStates WITH SECURITY_ENFORCED];
        } catch(QueryException qe) {
            // Handle inaccessible fields 
            throw new AuraHandledException('Innacessible Fields: ' + qe.getInaccessibleFields() + MESSAGE_TEXT + qe.getMessage());
        }
        for(CM_USStateCodeMapping__mdt stateCodeMdt : stateCodesMdt) {
            openCatStateCode.add(stateCodeMdt.StateCode__c);
        }
        return openCatStateCode;
    }
}
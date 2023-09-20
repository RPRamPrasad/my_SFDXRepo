/**
 * @description Class with invocable method that returns the SF Billing Accounts associated with a given billing account.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 06/15/23
 * @since 1.0
*/
public with sharing class GetBillingAccountsFlowHandler {
    
      /**
     * @description Static invocable method that takes a list of InputVariables static nested classes containing an Account id, calls
     * the BillingTabController.getBillingAccounts() method passing the Account Id, and returns a list of SF Billing Accounts 
     * associated with the passed account.
     *   
     * @param request : A list of InputVariables static nested classes that must contain exactly one Account Id
     * @return List<Id> the list of SF Billing Accounts assotiated with the passsed Account Id
     * @see InputVariables
     * @see OutputVariables
     */ 
    @InvocableMethod(label='Get SF Billing Accounts' description='Get the list of SF Billing Accounts of given an account id')
    public static List<OutputVariables> sfBillingAccounts(List<InputVariables> request) {
        Id accountId = request.get(0).accountId;
        List<Id> accountIds = new List<Id>();
        List<Account> householdMembers = new List<Account>();
        List<Id> billingAccounts = new List<Id>();
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
        for(BillingAccountData billAccount : billAccounts) {
            if (billAccount.billingAccountId != Null) {
                billingAccounts.add(billAccount.billingAccountId);
            }
		}
        OutputVariables outputVariables = new OutputVariables();
        outputVariables.billingAccountIds = billingAccounts;
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        outputVariablesList.add(outputVariables);
        return outputVariablesList;  // The list of sf billing account id of the given account
    }
    
    /**
     * @description Inner class used to provive the input parameter value to this class sfBillingAccounts() invocable method.
    */
    public class InputVariables {
        @InvocableVariable(required=true description='The ECRM account id')
        public Id accountId;
    }
    
    /**
     * @description Inner class used to provive the output parameter value to this class sfBillingAccounts() invocable method.
    */
    public class OutputVariables {
        @InvocableVariable(required=true description='List of SF Billing account IDs')
        public List<Id> billingAccountIds;
    }
}
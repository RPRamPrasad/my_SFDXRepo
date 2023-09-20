/**
* Author : Team LHIPS/GlitterCloud
* Date Created : 30/12/2022
* @description : Ha4cWebController class that sets up url to call HA4C Necho
*/
public with sharing class Ha4cWebController {
    
    private static final string ADD_VEHICLE_REQ = 'Add Vehicle/Request';
    private static final string ADD_VEHICLE_PRI_PASS = 'Add Vehicle - Private Passenger';
    private static final string ADD_VEHICLE_MOTOR = 'Add Vehicle - Motorcycle';
    
    /**
     * @description getPolicyDetailsParmHA4C
     * @param caseId 
     * @return  `String`
     */
    @AuraEnabled(cacheable=true)
    public static String getPolicyDetailsParmHA4C(String caseId) {
               
        string localCaseID = caseId;
        Case caseRef;
        User loggedInUser;
        User agentProxy;
        Id accountId;
        String policyIdentifier;
        String caseLob;
        String assocId;
        String caseOwnerId;
        String clientIdentifier;
        String policyDetailsParmHA4C;
        String policyNumber;
        String requestType;
        String selPolOpt ='2';
        String policyNumberToLaunch;
        
        caseRef = getCaseRecord(caseId);
        accountId = caseRef.AccountId;
        
        policyNumber = caseRef.PolicyNumber__c;
        if(!String.isBlank(policyNumber)){
            policyNumber = policyNumber.trim();
        }
        policyIdentifier = caseRef.Policy_Identifier__c;
        if(!String.isBlank(policyIdentifier)){
            policyIdentifier = policyIdentifier.trim();
        }

        
        requestType = caseRef.Request_Type__c;
        if(requestType.contains(ADD_VEHICLE_REQ) || requestType.contains(ADD_VEHICLE_PRI_PASS) || requestType.contains(ADD_VEHICLE_MOTOR)){
            selPolOpt ='6';
        }
        
        caseLob = caseRef.LOB__c.substring(0, 1);   
        
        // For Auto 
        if(('A'.equalsIgnoreCase(caseLob)) && (!isValidFormat(policyNumber,policyIdentifier,accountId))){
            
            selPolOpt = ' ';
            localCaseID = ' ';
        }
        
        
        loggedInUser = getUserRecord();
        assocId = loggedInUser.Servicing_Agent_Associate_ID__c;
        
        // Not an agent or ATM
        if (String.isEmpty(assocId)) {
            // Get Case owner id
            caseOwnerId = caseRef.ownerId;
            
            // Use case owner id to get associated agent
            agentProxy = getAgentOwnerAssociatedToPolicy(caseOwnerId);
            assocId = agentProxy.Servicing_Agent_Associate_ID__c;
        }
        
        clientIdentifier = getClientIdentifier(accountId);
        
        // Get instance of url through Custom Setting to set nechoUrl based on ENVs 
        
        String nechoDomain = getnechoURL();
		
        policyNumberToLaunch = getPolicyNumberToLaunch(policyNumber,policyIdentifier);
        
        policyDetailsParmHA4C = nechoDomain +'/nechoLauncher/launchHA4C?'+
            'selPolicy=' +
            policyNumberToLaunch +
            '&selPolOpt=' +
            selPolOpt +
            '&lob=' +
            caseLob +
            '&caseID=' +
            localCaseID +
            '&associateID=' +
            assocId +
            '&clientID=' +
            clientIdentifier;
        
        return policyDetailsParmHA4C;
    }
    
    /**
     * @description getPolicyNumberToLaunch
     * @param policyNumber 
     * @param policyIdentifier 
     * @return  `string`
     */
	 public static string getPolicyNumberToLaunch(String policyNumber,String policyIdentifier){
		
         if (String.isBlank(policyNumber)){  
			return policyIdentifier;
         }
         return policyNumber;
         
     }

     /**
      * @description isValidFormat
      * @param policyNumber 
      * @param policyIdentifier 
      * @param accountId 
      * @return  `boolean`
      */
    public static boolean isValidFormat(String policyNumber,String policyIdentifier, Id accountId){
        string autoVehicleType;
        boolean result = true;
        
        if (String.isBlank(policyNumber)){              
            // Use the base 7 policy identifier when full policy number not available ..
            // Assuming Single record from getAutoVehicleType method because we are using accID to filter
            autoVehicleType = getAutoVehicleType(policyIdentifier,accountId);
            
            // If the policy is multicar, then we should return false
            if(('Multiple Vehicle'.equalsIgnoreCase(autoVehicleType)) || ('Fleet'.equalsIgnoreCase(autoVehicleType))){
                result = false;
            }
        } else {
            autoVehicleType = getAutoVehicleTypeMultiOrFleet(policyNumber,accountId);
            // If the policy is multicar, then we should blank out caseID and pselpol
            if(('Multiple Vehicle'.equalsIgnoreCase(autoVehicleType)) || ('Fleet'.equalsIgnoreCase(autoVehicleType))){
                string lastThreePolicyNumber = policyNumber.right(3);
                // if Last 3 numbers of Policy is not Numeric we are returning false
                if(!lastThreePolicyNumber.isNumeric()){
                    result = false;
                }
            }
        } 
        return result;
    }
    
    /**
     * @description getnechoURL
     * @return  `string`
     */
    public static string getnechoURL(){
        CS_Ha4cNechoURL__c ha4cNechoURL = CS_Ha4cNechoURL__c.getInstance('Ha4cNechoURL');        
        return ha4cNechoURL.Ha4cNechoURL__c;
    }
    
    /**
* @description method to get the autoVehicleType
* @param policyIdentifier id of case policyIdentifier
* @param accountId
* @return current case Policy AutoVehicleType
*/
    
    public static string getAutoVehicleType(String policyIdentifier,Id accountId) {
        
		String policyName;
        String policyIdentifierWithSpace = policyIdentifier.substring(0,3) + ' ' + policyIdentifier.substring(3)+'%';
        try
        {
            List<InsurancePolicy> ipRecords = Security.stripInaccessible(AccessType.READABLE,
                                                                         [SELECT  PolicyName FROM InsurancePolicy WHERE NameInsuredId =:accountId and Name Like : policyIdentifierWithSpace LIMIT 1]).getRecords();

            if(!ipRecords.isEmpty()) {
                policyName = ipRecords.get(0).PolicyName;
            }
        } catch(Exception e){
            LoggingService.logHandledException(e, 'Ha4cWebController', 'getAutoVehicleType', System.LoggingLevel.ERROR);
        }
        
        return policyName;
    }
    
    /**
     * @description getAutoVehicleTypeMultiOrFleet
     * @param policyNumber 
     * @param accountId 
     * @return  `string`
     */
    public static string getAutoVehicleTypeMultiOrFleet(String policyNumber,Id accountId) {
        
        String policyName;
        string policyNumberOrFleet = policyNumber.deleteWhitespace();        
        policyNumberOrFleet = policyNumberOrFleet.substring(0,3) + ' ' + policyNumberOrFleet.substring(3)+'%';
        
        try 
        {
            List<InsurancePolicy> ipRecords = Security.stripInaccessible(AccessType.READABLE,
                                                                         [SELECT  PolicyName FROM InsurancePolicy WHERE NameInsuredId =:accountId and Name Like : policyNumberOrFleet LIMIT 1]).getRecords();
            
            if(!ipRecords.isEmpty()) {
                policyName = ipRecords.get(0).PolicyName;
            }
        }    catch(Exception e){
            LoggingService.logHandledException(e, 'Ha4cWebController', 'getAutoVehicleTypeMultiOrFleet', System.LoggingLevel.ERROR);
        }
        return policyName;

    }
    
    
    /**
* @description method to get the case record
* @param caseId id of case related to policy
* @return current case user is working
*/
    public static Case getCaseRecord(String caseId){
        Case cRec;
        UTIL_ParameterValidator objectNameValidator  = UTIL_ParameterValidationFactory.getParameterValidator(ParameterType.SOBJECT_NAME);
        try {
            objectNameValidator.validateParameter('caseId',caseId);  
            List <Case> caseRecs = Security.stripInaccessible(AccessType.READABLE, [
                SELECT id, LOB__c, PolicyNumber__c,Policy_Identifier__c, accountId, ProductDescription__c, Reason, RecordType.Name, ownerId,Request_Type__c FROM Case 
                where Id = : caseId
            ]).getRecords();
            cRec = new Case();
            
            if(!caseRecs.isEmpty()) {
                cRec = caseRecs.get(0);
            }
            
        } catch(Exception e){
            LoggingService.logHandledException(e, 'Ha4cWebController', 'getCaseRecs', System.LoggingLevel.ERROR); 
        }
        return cRec;
    }
    
    /**
     * @description getUserRecord
     * @return  `User`
     */
    public static User getUserRecord() {
        return [Select id, Alias, Servicing_Agent_Associate_ID__c from User Where id =: UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1];  
    } 
    
    /**
     * @description getAgentOwnerAssociatedToPolicy
     * @param ownerId 
     * @return  `User`
     */
    public static User getAgentOwnerAssociatedToPolicy(String ownerId) {
        String servicingAgentExternalId = [SELECT Id, Servicing_Agent_External_ID__c FROM User WHERE id =: ownerId WITH SECURITY_ENFORCED Limit 1].Servicing_Agent_External_ID__c;
        return [SELECT Id, Servicing_Agent_Associate_ID__c, State_Agent_Code__c, UserExternalID__c FROM User WHERE UserExternalID__c =: servicingAgentExternalId WITH SECURITY_ENFORCED Limit 1];
    }
    
    
    /**
* @description method to get the account client identifier
* @param accountId id of case related account
* @return current account user is working
*/
    public static String getClientIdentifier(String accountId) {
        Account aRec;
        UTIL_ParameterValidator objectNameValidator  = UTIL_ParameterValidationFactory.getParameterValidator(ParameterType.SOBJECT_NAME);
        
        try {
            objectNameValidator.validateParameter('accountId',accountId); 
            List <Account> acctRecs = Security.stripInaccessible(AccessType.READABLE, [Select ClientIdentifier__c from Account 
                                                                                       where Id = : accountId]).getRecords();
            aRec = new Account();
            if (!acctRecs.isEmpty()) {
                aRec = acctRecs.get(0);
            }
        } catch(Exception e) {
            LoggingService.logHandledException(e, 'Ha4cWebController', 'getAccountRecs', System.LoggingLevel.ERROR);
        }
        return aRec.ClientIdentifier__c;
    }
}
/**
* Author : Team Poseidon
* Date Created : 11/18/2020
* Modified by Team STIA 5/14/2021
* @description : This Apex Class is used to gather parameters to call HATS application through Canvas.
*/
public with sharing class LTG_HATSNecho_Controller {
    public static Boolean isProd = false;
    private static final String S1_BASE_URL = 'S1BaseUrl';
    private static final String SCHEME = 'https://';
    private static final String STATE_FARM = 'statefarm';
    private static final String PERF_STATE_FARM = 'statefarm--pfpbfarcus';
    private static final String DOT = '.';
    private static final String LIGHTNING = 'lightning';
    private static final String FORCE = 'force';
    private static final String EXTENSION = 'com';
    private static final String PERF_BASE_URL = SCHEME + PERF_STATE_FARM + DOT + LIGHTNING + DOT + FORCE + DOT + EXTENSION;
    private static final String PROD_BASE_URL = SCHEME + STATE_FARM + DOT + LIGHTNING + DOT + FORCE + DOT + EXTENSION;
    private static String testAppRegionCode = '01';
    private static Map<String, String> stAgtCdToROMap = new Map<String, String> {
        '01' => '09', 
            '02' => '15', 
            '03' => '24', 
            '04' => '22', 
            '05' => '02', 
            '06' => '20', 
            '07' => '28', 
            '08' => '21', 
            '09' => '21', 
            '11' => '27', 
            '12' => '15', 
            '13' => '01', 
            '14' => '18', 
            '15' => '06', 
            '16' => '26', 
            '17' => '11', 
            '18' => '22',
            '19' => '28', 
            '20' => '21', 
            '21' => '28', 
            '22' => '04',
            '23' => '05', 
            '24' => '09',
            '25' => '14',
            '26' => '15', 
            '27' => '06', 
            '28' => '24', 
            '29' => '28', 
            '30' => '17', 
            '31' => '24', 
            '32' => '17', 
            '33' => '07', 
            '34' => '06', 
            '35' => '16', 
            '36' => '26',
            '37' => '15', 
            '38' => '13', 
            '39' => '28', 
            '40' => '27', 
            '41' => '06', 
            '42' => '11', 
            '43' => '08', 
            '44' => '20', 
            '45' => '28', 
            '46' => '07', 
            '47' => '15', 
            '48' => '21', 
            '49' => '05', 
            '50' => '20', 
            '51' => '15', 
            '52' => '28', 
            '53' => '25', 
            '55' => '12', 
            '59' => '19', 
            '75' => '23'
            };
              private static Map<String,List<String>> roToAppIdMap = new Map<String,List<String>>{
                    '01' => new List<String> {'A', 'E01IBMVIPA1'},
                        '02' => new List<String> {'B', 'E02IBMVIPA1'},
                            '03' => new List<String> {'C', 'E03IBMVIPA1'},
                                '04' => new List<String> {'D', 'E04IBMVIPA1'},
                                    '05' => new List<String> {'E', 'E05IBMVIPA1'},
                                        '06' => new List<String> {'F', 'E06IBMVIPA1'},
                                            '07' => new List<String> {'G', 'E07IBMVIPA1'},
                                                '08' => new List<String> {'H', 'E08IBMVIPA1'},
                                                    '09' => new List<String> {'I', 'E09IBMVIPA1'},
                                                        '11' => new List<String> {'K', 'E11IBMVIPA1'},
                                                            '12' => new List<String> {'L', 'E12IBMVIPA1'},
                                                                '13' => new List<String> {'M', 'E13IBMVIPA1'},
                                                                    '14' => new List<String> {'N', 'E14IBMVIPA1'},
                                                                        '15' => new List<String> {'O', 'E15IBMVIPA1'},
                                                                            '16' => new List<String> {'P', 'E16IBMVIPA1'},
                                                                                '17' => new List<String> {'Q', 'E17IBMVIPA1'},
                                                                                    '18' => new List<String> {'R', 'E18IBMVIPA1'},
                                                                                        '19' => new List<String> {'S', 'E19IBMVIPA1'},
                                                                                            '20' => new List<String> {'T', 'E20IBMVIPA1'},
                                                                                                '21' => new List<String> {'U', 'E21IBMVIPA1'},
                                                                                                    '22' => new List<String> {'V', 'E22IBMVIPA1'},
                                                                                                        '23' => new List<String> {'W', 'E23IBMVIPA1'},
                                                                                                            '24' => new List<String> {'X', 'E24IBMVIPA1'},
                                                                                                                '25' => new List<String> {'Y', 'E25IBMVIPA1'},
                                                                                                                    '26' => new List<String> {'Z', 'E26IBMVIPA1'},
                                                                                                                        '27' => new List<String> {'1', 'E27IBMVIPA1'},
                                                                                                                            '28' => new List<String> {'2', 'E28IBMVIPA1'}
                }; 
    
    /**
     * @description nechoAppId
     */
    public static String nechoAppId {get; set;}    
    /**
     * @description selectedNechoAppId
     */
    public static String selectedNechoAppId {get;set;}
    /**
     * @description loggedInUser
     */
    public static User loggedInUser {get; set;}
    /**
     * @description policyNum
     */
    public static String policyNum {get; set;}
    /**
     * @description policyIdentifier
     */
    public static String policyIdentifier {get; set;}
    /**
     * @description accountId
     */
    public static String accountId {get; set;}
    /**
     * @description caseLob
     */
    public static String caseLob {get; set;}
    /**
     * @description caseOwnerId
     */
    public static String caseOwnerId {get; set;}
    /**
     * @description policyDetailsJson
     */
    public static String policyDetailsJson {get; set;}
    /**
     * @description transactionType
     */
    public static String transactionType {get; set;}
    /**
     * @description host
     */
    public static String host {get; set;}
   /**
    * @description method to get the user record
    * @return user the logged on user
    */
    @AuraEnabled
    public static User getUserRecord() {
        loggedInUser = [Select id, Alias, State_Agent_Code__c, Servicing_Agent_Associate_ID__c, WorkstationID__c from User Where id =: UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1];
        return loggedInUser;
    }    
    
    /**
    * @description method to pull case info and dynamically build HATS URL
    * @param caseId id of case related to policy data
    * @return JSON string to pass to the canvas lifecycle handler
    */
    @AuraEnabled
    public static String getPolicyDetailsJson(String caseId) {
        String appIDWEL = 'L NESAE0S1'; // NEVAE0S1
        String workstationIDWEL = 'WPWFQD0T';
        String selectionNumWEL = '1';
        String accessAgentCodeWEL = '132364'; // 132375
        String clientIdentifier;
        String assocId;
        String policyDescription;
        
        // Get the StateAgentCode to get the RO
        User loggedInUser = getUserRecord();
        String regionOfficeCode;
        workstationIDWEL = loggedInUser.WorkstationID__c;
        Case caseRef = getCaseRecord(caseId);

        // Getting case reason and record type
        String caseReason = caseRef.Reason;
        String caseRecordType = caseRef.RecordType.Name;

        caseLob = caseRef.LOB__c.substring(0,1);
        
        policyIdentifier = caseRef.Policy_Identifier__c ;

       	//if policyNum is null then assign policyIdentifier as policy number
        policyNum =(String.isNotEmpty(caseRef.PolicyNumber__c) ? caseRef.PolicyNumber__c : policyIdentifier);
        
        accountId = caseRef.AccountId;
        policyDescription = caseRef.ProductDescription__c;

        // If policy description has special characters, replace with empty
        if (String.isNotEmpty(policyDescription)) {
            policyDescription = policyDescription.replaceAll('[^a-zA-Z0-9\\s]', '');    
        }
        
        transactionType = '2';
        clientIdentifier = getClientIdentifier(accountId);
        assocId = loggedInUser.Servicing_Agent_Associate_ID__c;
        accessAgentCodeWEL = loggedInUser.State_Agent_Code__c;

        // Not an agent or ATM
        if (String.isEmpty(accessAgentCodeWEL) && String.isEmpty(assocId)) {
            // Get Case owner id
            String caseOwnerId = caseRef.ownerId;

            // Use case owner id to get associated agent
            User agentProxy = getAgentOwnerAssociatedToPolicy(caseOwnerId);

            accessAgentCodeWEL = agentProxy.State_Agent_Code__c;
            assocId = agentProxy.Servicing_Agent_Associate_ID__c;
        }

        accessAgentCodeWEL = accessAgentCodeWEL.replace('-', '');

        // Get instance of url through Custom Setting to set isProd for prod logic, else it is test env
        CS_EnvironmentURLCustomSetting__c sfdcBaseUrl = CS_EnvironmentURLCustomSetting__c.getInstance(S1_BASE_URL);
        String baseUrlValue = sfdcBaseUrl.Value__c;
        
        if (baseUrlValue.equalsIgnoreCase(PROD_BASE_URL)) {
            isProd = true;
        }
        
        if (isProd) {
            // Use the given regionOfficeCode to get the AppId in Prod
            regionOfficeCode = getROCode(accessAgentCodeWEL);
            getProdAppId(regionOfficeCode);
            appIDWEL = nechoAppId;
        } else if (baseUrlValue.equalsIgnoreCase(PERF_BASE_URL)) {
            accessAgentCodeWEL = loggedInUser.State_Agent_Code__c;
            accessAgentCodeWEL = accessAgentCodeWEL.replace('-', '');
            
            // Use the given regionOfficeCode to get the AppId in Perf
            appIDWEL = getPerfAppId();
        } else {
            // Use the given regionOfficeCode to get the AppId in Test
            appIDWEL = getTestAppId(testAppRegionCode);
        }
        
        // Build JSON to call HATS
        policyDetailsJson = '{"appIDWEL":"'+appIDWEL+'","caseId":"'+ caseId +'","reason":"'+ caseReason +'","recordType":"'+ caseRecordType +'","workstationIDWEL":"'+ workstationIDWEL +'","selectionNumWEL":"'+selectionNumWEL+'","accessAgentCodeWEL":"'+accessAgentCodeWEL+'","lob":"'+caseLob+'","policyNum":"'+policyNum+'","transactionType":"'+transactionType+'","ownerAssociateId":"'+assocId+'","clientId":"'+clientIdentifier+'","policyDescription":"'+policyDescription+'","env":"'+baseUrlValue+'"}';
          
        String encodedParams = EncodingUtil.urlEncode(policyDetailsJson, 'UTF-8');
        
        return encodedParams;
    }
    
    /**
    * @description method to get the case record
    * @param caseId id of case related to policy data
    * @return current case user is working with
    */
    @AuraEnabled
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
                LoggingService.logHandledException(e, 'LTG_HATSNecho_Controller', 'getCaseRecs', System.LoggingLevel.ERROR); 
            }
        return cRec;
    }

    /**
    * @description method to get the account client identifier
    * @param accountId id of account
    * @return current account user is working on
    */
    @AuraEnabled
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
          LoggingService.logHandledException(e, 'LTG_HATSNecho_Controller', 'getAccountRecs', System.LoggingLevel.ERROR);
        }
        
        return aRec.ClientIdentifier__c;
    }
    
    /**
    * @description method to get the host that corresponds to NECHO host
    * @return host user will login to
    */
    @AuraEnabled
    public static String getHost() {
        return host;
    }
    
    private static String getROCode(String stateAgentCode) {
        return stAgtCdToROMap.get(stateAgentCode.left(2));
    }
    
    private static String getTestAppId(String regionalOffice) {
        String nechoAppIdIL = 'L NESAE0S1'; // L NEVAE0S1
        String nechoAppIdSFPP = 'L NETAE0S1';
        
        if (testAppRegionCode.equals(regionalOffice) && caseLob.equalsIgnoreCase('s')) {
            selectedNechoAppId = nechoAppIdSFPP;
        }
        else{
            selectedNechoAppId = nechoAppIdIL;
        }
        
        // Keeping this as 'testing' until proper lookup is implemented
        host = 'testing';
        return selectedNechoAppId;
    }

    private static String getPerfAppId() {
        String nechoAppId = 'L CICS66TG';
        // Keeping this as 'testing' until proper lookup is implemented
        host = 'testing';
        selectedNechoAppId = nechoAppId;
        return selectedNechoAppId;
    }
    
    private static void getProdAppId(String regionalOffice) {
        nechoAppId = 'L CICSE*TG';
        List<String> replaceCharList = roToAppIdMap.get(regionalOffice);
        nechoAppId = nechoAppId.replace('*', replaceCharList[0]);
        host       = replaceCharList[1];

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
}
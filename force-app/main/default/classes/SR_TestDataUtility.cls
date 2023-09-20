@isTest
(seeAllData=false)
public class SR_TestDataUtility {

    @TestVisible private static final String ACCOUNT_CLIENT_ID = 'MANDO-2346';
    @TestVisible private static final String SECONDARY_ACCOUNT_CLIENT_ID = 'BYODA-2346';
    @TestVisible private static final String OWNER_ASSOCAITE_ID = 'SKYWALK122';
    @TestVisible private static String policyId = '2345678A';
    @TestVisible private static String vehicleId = '2345678';
    @TestVisible private static String policyDesc = '2020 Tesla Model Y';
    @TestVisible private static final String PNI_PRIMARY_ACCOUNT_CLIENT_ID = '0QVTV2LG002';
    @TestVisible private static final String PNI_SECONDARY_ACCOUNT_CLIENT_ID = 'R1ZLM0D3002';
    @TestVisible private static final String PNI_SFDC_POLICY_NUM_SEARCH_KEY = '0581250F705B';
    @TestVisible private static final String AGREEMENT_INDEX_ID = '91929577';
    @TestVisible private static final String POLICY_ID = '0581250';
    @TestVisible private static final String MATCH_PARAM = '{"matchParams" :{"clientId" : "';
    @TestVisible private static final String RECORD_TYPE_NAME = '", "recordTypeName":"';
    @TestVisible private static final String OWNER_ASSOCIATE_ID = '", "ownerassociateid":"';
    @TestVisible private static final String AUTO = 'Auto';
    public static boolean isQueueTest = false;
    /**
     * @description SR_TestDataUtilityWrapper
     */
    public class SR_TestDataUtilityWrapper{
            public User owner; 
            public Account acct;
            public Integer tierLevel;
            public Id recordTypeId;
            public Boolean hasTask;
    }
    
    @TestVisible    
    private static void insertCustomSetting(){
        CS_SR_Config__c	criteria1 = new CS_SR_Config__c();
        criteria1.SR_Inner_Case_Query_Limit__c = 15;
        criteria1.SR_Case_Created_Day_Range__c = 30;
        criteria1.SR_Account_Query_Limit__c = 1250;
        insert criteria1;
        
        CS_SR_Matching_Config__c criteria2 = new CS_SR_Matching_Config__c();
        criteria2.Inner_Case_Query_Limit__c = 15;
        criteria2.Case_Created_Day_Range__c = 30;
        criteria2.Account_Query_Limit__c = 1250;
        criteria2.Name = 'Policy_Change';
        insert criteria2;
        
        CS_SR_Matching_Config__c criteria3 = new CS_SR_Matching_Config__c();
        criteria3.Inner_Case_Query_Limit__c = 15;
        criteria3.Case_Created_Day_Range__c = 65;
        criteria3.Account_Query_Limit__c = 1250;
        criteria3.Name = 'Enrollment_Case';
        insert criteria3;
    }
    
    @TestVisible
    private static Map<String, SR_Payload> getClientToPayloadMap(){
        Map<String, SR_Payload> clientToPayloadMap = new Map<String, SR_Payload>();
        clientToPayloadMap.put(ACCOUNT_CLIENT_ID, getBasicPayload());
        return clientToPayloadMap;
    }

	@TestVisible    
    private static SR_Payload getTier2Payload(String clientId, String ownerAssociateId, String recordTypeName){
        String jsonString = MATCH_PARAM +clientId+OWNER_ASSOCIATE_ID+ownerAssociateId+RECORD_TYPE_NAME+recordTypeName+'", "caseId":"", "policyId":"'+policyId+'", "vehicleId": "'+vehicleId+'", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"},"numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }
    
    @TestVisible    
    private static SR_Payload getTier3Payload(String clientId, String ownerAssociateId, String recordTypeName){
        String jsonString = MATCH_PARAM +clientId+OWNER_ASSOCIATE_ID+ownerAssociateId+RECORD_TYPE_NAME+recordTypeName+'", "caseId":"", "policyId":"'+policyId+'", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"},"numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }
    
    @TestVisible
    private static SR_Payload getTier4Payload(String clientId, String ownerAssociateId, String recordTypeName){
        String jsonString = MATCH_PARAM +clientId+OWNER_ASSOCIATE_ID+ownerAssociateId+RECORD_TYPE_NAME+recordTypeName+'", "caseId":"", "policyId":"", "policyDescription":"'+policyDesc+'"}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"}, "numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }
    
    @TestVisible
    private static SR_Payload getTier5Payload(String clientId, String ownerAssociateId, String recordTypeName){
        String jsonString = MATCH_PARAM +clientId+OWNER_ASSOCIATE_ID+ownerAssociateId+RECORD_TYPE_NAME+recordTypeName+'", "caseId":"", "policyId":"", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"}, "numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }
    
    @TestVisible    
    private static SR_Payload getClosedStatusPayload(String clientId, String ownerAssociateId, String recordTypeName){
        String jsonString = MATCH_PARAM +clientId+OWNER_ASSOCIATE_ID+ownerAssociateId+RECORD_TYPE_NAME+recordTypeName+'", "caseId":"", "policyId":"'+policyId+'", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "Status":"Closed"},"numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }
    
    @TestVisible
    private static SR_Payload getBasicPayload(){
        String jsonString = MATCH_PARAM+ACCOUNT_CLIENT_ID+OWNER_ASSOCIATE_ID+OWNER_ASSOCAITE_ID+'", "recordTypeName":"Policy_Change", "caseId":"", "policyId":"", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"}, "numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }

    @TestVisible
    private static SR_Payload getBasicPayload(String recordTypeName){
        String jsonString = MATCH_PARAM+ACCOUNT_CLIENT_ID+OWNER_ASSOCIATE_ID+OWNER_ASSOCAITE_ID+RECORD_TYPE_NAME+recordTypeName+'", "caseId":"", "policyId":"", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"}, "numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }
    
    @TestVisible
    private static SR_Payload getInvalidPayload(){
        String jsonString = '{"matchParams" :{"ownerAssociateId":"'+OWNER_ASSOCAITE_ID+'", "recordTypeName":"Policy_Change", "caseId":"", "policyId":"", "policyDescription":""}, "caseRecord":{"Subject" : "Apex Testing", "IsEscalated":true, "Status":"Agent Review"}, "numberOfTimesThroughProcess" : 0}';
        return (SR_Payload)JSON.deserializeStrict(jsonString, SR_Payload.class);
    }

    @TestVisible
    private static List<SR_Payload> getBasicPayloadList(Integer listSize){
        List<SR_Payload> payloads = new List<SR_Payload>();
        for(Integer i=0; i<listSize; i++){
            SR_Payload payload = getBasicPayload();  
            payloads.add(payload);
        }
        return payloads;
    }
    
    @TestVisible
    private static SR_MatchParams getBasicMatchParams(User owner, Account acct){
        SR_MatchParams matchParams = new SR_MatchParams();
        matchParams.clientId = acct.ClientIdentifier__c;
        matchParams.ownerAssociateId = owner.UserExternalID__c;
        matchParams.recordTypeName = 'Policy_Change';
        return matchParams;
    }

    @TestVisible
    private static Case createExistingCase(SR_TestDataUtilityWrapper wrapper){
        Case caseRecord = new Case();
        caseRecord.OwnerId = wrapper.owner.Id;
        caseRecord.AccountId = wrapper.acct.Id;
        caseRecord.Policy_Identifier__c = (wrapper.tierLevel == 2) ? policyId : null;
        caseRecord.ProductDescription__c = (wrapper.tierLevel == 3) ? policyDesc : null;
        caseRecord.Issued__c = true;
        caseRecord.isEscalated = true;
        caseRecord.RecordTypeId = wrapper.recordTypeId;
        caseRecord.Event_Id__c = 'MOCK_EVENT_ID';
        caseRecord.Follow_up_Date__c = (wrapper.hasTask) ? Date.today() : null;
        Database.SaveResult sr =  Database.insert(caseRecord);
        return [SELECT Id, Policy_Identifier__c, OwnerId, ProductDescription__c FROM Case WHERE Id =: sr.getId()];
    }
    
    @TestVisible
    private static Case getNewCase(){
        Case caseRecord = new Case();
		caseRecord.Subject = 'Testing Case';
        caseRecord.Issued__c = false;
        caseRecord.isEscalated = false;
        return caseRecord;
    }
    
    @TestVisible
    private static Task buildSupportingTask(){
        Task taskRecord = new Task();
        taskRecord.Subject = 'Supporting Task';
        taskRecord.ActivityDate = Date.today();
        taskRecord.Description = 'Supporting Task';
        taskRecord.Status = 'Not Started';
        return taskRecord; 
    }
    
    @TestVisible private static void createAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',BillingAddressType__c='US',BillingCity='Phoenix',ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }
    
    @TestVisible private static void createSecondaryAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName2',LastName='lstName2',BillingAddressType__c='US',BillingCity='Phoenix',ClientIdentifier__c=SECONDARY_ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
    }

    @TestVisible private static Account getSecondaryAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :SECONDARY_ACCOUNT_CLIENT_ID];
    }
    
    @TestVisible
    private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole; 
    }
    
    @TestVisible private static PermissionSet getSOEDelegatePermset(){
        return [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_SOEDELEGATE_PermSetPID'];
    }

    @TestVisible private static PermissionSet getFSCInsurancePermSet(){
        return [SELECT Id FROM PermissionSet WHERE Name = 'FSCInsurance'];
    }
    
    @TestVisible private static void addUserToSOEDelegatePermSet(User userRecord){
        Id soeDelegateId = getSOEDelegatePermset().Id;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userRecord.Id;
        psa.PermissionSetId = soeDelegateId;
        insert psa;
    }

    @TestVisible private static void addUserToFSCInsurancePermSet(User userRecord){
        Id fscInsuranceId = getFSCInsurancePermSet().Id;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userRecord.Id;
        psa.PermissionSetId = fscInsuranceId;
        insert psa;
    }
    
    @TestVisible private static Task buildDefaultTask(){
        Task taskRecord = new Task();
        taskRecord.AppCode__c = 'BOD - Auto Extracts';
        taskRecord.Status = 'Not Started';
        taskRecord.Description = 'Policy was issued and mailed.';
        taskRecord.ActivityDate = Date.today();
        taskRecord.Priority = 'No';
        taskRecord.LineofBusiness__c = AUTO;
		taskRecord.BOD_Flag__c = true;
        taskRecord.Subject = 'BOD Policy Issued and Mailed';
        taskRecord.ProductDescription__c = policyDesc;
        taskRecord.Task_Type__c = 'Service';
        taskRecord.Type = 'Internet';
        return taskRecord;
    }
    
    @TestVisible private static Case buildDefaultCase(){
        Case caseRecord = new Case();
		caseRecord.Type = 'Policy Change';
        caseRecord.App_Code__c = 'BOD - Auto Extracts';
       	caseRecord.Subject = 'Some Subject';
       	caseRecord.Description = 'Policy Change';
        caseRecord.Status = 'Agent Review';
        caseRecord.PolicyNumber__c = '222 3333-A44-55B';
        caseRecord.LOB__c = AUTO;
        caseRecord.ProductDescription__c = policyDesc;
        return caseRecord;
    }
    
    @TestVisible
    private static void setupPNITestData(User agentUser){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
		List<Account> accounts = new List<Account>();
            Account account1 = new Account(FirstName = 'DAVID', LastName='RICE', clientIdentifier__c = PNI_SECONDARY_ACCOUNT_CLIENT_ID);
            Account account2 = new Account(FirstName = 'VALORIE', LastName='RICE', clientIdentifier__c = PNI_PRIMARY_ACCOUNT_CLIENT_ID);
            accounts.add(account1);
            accounts.add(account2);
            Database.insert(accounts);
        
        	InsurancePolicy policy = new InsurancePolicy(
                AgreIndexID__c = AGREEMENT_INDEX_ID,
                NameInsuredId = account2.Id,
                Name = '0581250-F07-05B',
                Status = 'In Force',
                ProdLineCd__c = 'A',
                PolicyName = 'PRIVATE PASSENGER',
                PolicyDescription = '1989 Chevrolet Cheyenne Pickup',
                Servicing_Agent__c = agentUser.id,
                SFDCPolicyNumberSearchKey__c = PNI_SFDC_POLICY_NUM_SEARCH_KEY
        	);
        	insert policy;
        
        	InsurancePolicyParticipant participant = new InsurancePolicyParticipant(
            	PrimaryParticipantAccountId = account1.Id,
                InsurancePolicyId = policy.id,
                RoleNameCd__c = '18',
                SecondaryRoleNameCd__c = '1',
                Role = 'Named Insured',
                SecondaryRoleName__c = 'Additional',
                SourceSystemIdentifier = '91929577~R1ZLM0D3002~~18~1'
            );
        
        	insert participant;
    }
    
    @TestVisible    
    private static Case getPNICase(String appCode){
        Case c = new Case();
        c.App_Code__c = appCode;
        c.Status = 'New Request';
        c.Case_Originator__c = 'Internet';
        return c;
    }
    
    @TestVisible    
    private static SR_MatchParams getPNIMatchParams(User userRecord){
        SR_MatchParams matchParams = new SR_MatchParams();
        
        matchParams.clientId = PNI_SECONDARY_ACCOUNT_CLIENT_ID;
        matchParams.ownerAssociateId = userRecord.Proxy_External_ID__c;
        matchParams.recordTypeName = 'Policy_Change';
        return matchParams;
    }
    
    
    @TestVisible    
    private static SR_Payload getPNIPayload(User userRecord, String appCode, String lob){
		SR_Payload testPayload = new SR_Payload();       
        SR_MatchParams matchParams = getPNIMatchParams(userRecord);
        Case myCase = getPNICase(appCode);
        if(lob == AUTO){
            myCase.LOB__c = AUTO;
        	myCase.ProductDescription__c = '2001 Chevrolet S10 Pickup';
        	myCase.Request_Type__c = 'Replace Vehicle';
            myCase.Subject = 'Internet Quote - Replaced Vehicle';
            matchParams.policyDescription = '2001 Chevrolet S10 Pickup';
            matchParams.policyId = POLICY_ID;
        }else if(lob == 'Fire'){
            //matchParams.policyId intentionally left out to meet the SR_PNIUtil.getPNIforPolicyDesc query criteria
            myCase.LOB__c = 'Fire';
        	myCase.ProductDescription__c = 'Homeowners Policy: 123 Main St';
        	myCase.Request_Type__c = 'Policy Change/Request';
            myCase.Subject = 'Internet Quote - Coverage Change';
            matchParams.policyDescription = 'Homeowners Policy: 123 Main St';
        }

        testPayload.matchParams = matchParams;
        testPayload.caseRecord = myCase;
        testPayload.numberOfTimesThroughProcess = 0;
        return testPayload;
    }
}
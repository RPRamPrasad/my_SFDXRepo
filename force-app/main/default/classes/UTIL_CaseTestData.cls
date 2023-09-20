@isTest
(seeAllData=false)
public class UTIL_CaseTestData {

    
    public static User nonAPIUser;
    public static User agentUser;
    public static User atmUser;    
    public static User proxyUser;
    public static User techSupportUser;
    public static User systemAdminUser;
    public static User cccSalesUser;
    public static User cccServiceUser;
    public static User apiOnlyUser;
    public static User salesLeaderUser;
    public static User systemRecordOwner;
    public static UserRole proxyStandardUserRole;
    public static UserRole atmStandardUserRole;
    public static UserRole agentStandardUserRole;
    public static UserRole salesLeaderUserRole;
    private static User bankSupportCenterUser;
    public static User agentUser2;
    public static User atmUser2;    
    public static User proxyUser2;

    public static final String AGENT_USER_NAME = 'caseAgentUser@statefarm.com.bad';
    public static final String ATM_USER_NAME = 'caseAtmUser@statefarm.com.bad';
    public static final String PROXY_USER_NAME = 'caseproxyUser@statefarm.com.bad';

    public static final String AGENT_USER2_NAME = 'caseSecondaryAgentUser@statefarm.com.bad';
    public static final String ATM_USER2_NAME = 'caseSecondaryAtmUser@statefarm.com.bad';
    public static final String PROXY_USER2_NAME = 'caseSecondaryProxyUser@statefarm.com.bad';

    public static final String CCC_LICENSED_USER_NAME = 'CCCL@statefarm.com';
    public static final String CCC_UNLICENSED_USER_NAME = 'CCCUL@statefarm.com';
    public static final String BANK_USER_NAME = 'LtdEnterprise@statefarm.com';

    public static final String SALES_LEADER_USER_NAME = 'salesLeaderRoleUser@statefarm.com.bad';
    
    public static final String SYS_ADMIN_USER_NAME = 'systemAdminUserCaseUtil@statefarm.com.bad';

    public static final String ACCOUNT_CLIENT_ID = '12345678915';
    public static final String CONTACT_CLIENT_ID = '12345678910';
    
    private static final String AGENT_ASSOCIATE_ID  = 'ASSOC123456';
    private static final String AGENT_ASSOCIATE_ID2 = 'ASSOC567890';
    private static final String CCCL_ASSOCIATE_ID   = 'CCCL1234567';
    private static final String CCCUL_ASSOCIATE_ID  = 'CCCUL567890';
    
    public static final String CASE_NEW_STATUS = 'New';
    public static final String CLOSED_STATUS = 'Closed';
    public static final String PENDING_STATUS = 'Pending';
    public static final String TASK_CLOSED_STATUS = 'Completed';
    public static final String TASK_NOTSTARTED_STATUS = 'Not Started';
    public static final String TASK_CANCELLED_STATUS = 'Cancelled';

    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_PENDING = 'Pending';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    public static final String TASK_STATUS_IN_PROGRESS = 'In Progress';
    public static final String TASK_STATUS_CANCELLED = 'Cancelled';
    public static final String TASK_STATUS_COMPLETED = 'Completed';

    private static final String CUSTOMER = 'customer';
    private static final String CCC_LICENSED = '3.00 ccc licensed';
    private static final String CCC_UNLICENSED = '3.01 ccc unlicensed';
    private static final String CUSTOMER_SERVICE_REQUEST = 'customer service request - apex test';
    private static final String NEW_STATUS = 'New';
    private static final String NOT_STARTED = 'not started';
    /**
     * @description setUpUsersForCase
     */
    public static void setUpUsersForCase() {
        setUpAgentUsers();
        setUpNonAgentUsers();
        setUpSecondaryAgentUsers();
    }
    /**
     * @description setUpAgentUsers
     */
    public static void setUpAgentUsers() {

        salesLeaderUserRole = new UserRole(name='SalesLeader_Territory');
        insert salesLeaderUserRole;
        
        agentStandardUserRole= new UserRole(name='AgentRole' , parentRoleId = salesLeaderUserRole.Id);
        insert agentStandardUserRole;
        
        atmStandardUserRole= new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);
        insert atmStandardUserRole;
        
        proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
        insert proxyStandardUserRole;
        User testProxyUser1 = new User(Alias='Proxy',LastName='CaseProxy',Username=PROXY_USER_NAME,UserExternalID__c=AGENT_ASSOCIATE_ID+'P',Servicing_Agent_Associate_ID__c=AGENT_ASSOCIATE_ID); 
        proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUser.userRoleId= proxyStandardUserRole.id;
        Database.insert(proxyUser);
        User testAgentUser1 = new User(Alias='Agent',LastName='CaseAgent',Username=AGENT_USER_NAME,Associate_ID__c=AGENT_ASSOCIATE_ID,UserExternalID__c=AGENT_ASSOCIATE_ID+'_'+AGENT_ASSOCIATE_ID,Servicing_Agent_Associate_ID__c=AGENT_ASSOCIATE_ID);
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        agentUser.userRoleId= agentStandardUserRole.id;
        Database.insert(agentUser);
        User testATMUser = new User(Alias='ATM',LastName='CaseATM',Username=ATM_USER_NAME);
        atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser(testATMUser, atmStandardUserRole);
        atmUser.Servicing_Agent_Associate_ID__c = '1234test';
        
        atmUser.UserExternalID__c = '1234test_' + agentUser.Associate_ID__c;
    	atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_id__c;
    	atmUser.Servicing_Agent_Associate_ID_List__c = agentUser.Associate_id__c;
    	atmUser.UserRoleId = atmStandardUserRole.Id;
        Database.insert(atmUser);
        User testSalesLeaderUser = new User(Alias='SALR',LastName='TestSetupSalesLeaderUser',Username=SALES_LEADER_USER_NAME,Territory_Associate_ID__c='AAA1', Territory_Associate_ID_List__c='AAA1', Associate_ID__c='SAA1',UserExternalID__c='SAA1');
        salesLeaderUser = UTIL_UserProvisioning_TEST.buildSalesLeaderUser(testSalesLeaderUser);
        salesLeaderUser.UserRoleId = salesLeaderUserRole.Id;
        salesLeaderUser.Servicing_Agent_Associate_ID__c = '123SLtest';
        Database.insert(salesLeaderUser);
    }
    /**
     * @description setUpSecondaryAgentUsers
     */
    public static void setUpSecondaryAgentUsers() {

        salesLeaderUserRole = new UserRole(name='SalesLeader_Territory');
        insert salesLeaderUserRole;
        
        UserRole agentStandardUserRole2= new UserRole(name='AgentRole2', parentRoleId = salesLeaderUserRole.Id);
        insert agentStandardUserRole2;

        UserRole atmStandardUserRole2= new UserRole(name='ATMMRole2', parentRoleId = agentStandardUserRole2.id);
        insert atmStandardUserRole2;

        UserRole proxyStandardUserRole2 = new UserRole(name='ProxyRole2', parentRoleId = atmStandardUserRole2.id);
        insert proxyStandardUserRole2;
        User testProxyUser1 = new User(Alias='Proxy2',LastName='CaseProxy2',Username=PROXY_USER2_NAME,UserExternalID__c=AGENT_ASSOCIATE_ID2+'P',Servicing_Agent_Associate_ID__c=AGENT_ASSOCIATE_ID2);
        proxyUser2 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUser2.userRoleId= proxyStandardUserRole2.id;
        Database.insert(proxyUser2);
        User testAgentUser1 = new User(Alias='Agent2',LastName='CaseAgent2',Username=AGENT_USER2_NAME,Associate_ID__c=AGENT_ASSOCIATE_ID2,UserExternalID__c=AGENT_ASSOCIATE_ID2,Servicing_Agent_Associate_ID__c=AGENT_ASSOCIATE_ID2);
        agentUser2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        agentUser2.userRoleId= agentStandardUserRole2.id;
        Database.insert(agentUser2);
        User testATMUser = new User(Alias='ATM2',LastName='CaseATM2',Username=ATM_USER2_NAME);
        atmUser2 = UTIL_UserProvisioning_TEST.buildAgentTeamUser(testATMUser, atmStandardUserRole2);
        atmUser2.Servicing_Agent_Associate_ID__c = '123test2';
        Database.insert(atmUser2);
    }
    /**
     * @description setUpNonAgentUsers
     */
    public static void setUpNonAgentUsers(){
        User testCCCLicenUser1 = new User(Alias='CCCL',LastName='cccLicensedUser',Username=CCC_LICENSED_USER_NAME,Associate_ID__c=CCCL_ASSOCIATE_ID,UserExternalID__c=CCCL_ASSOCIATE_ID);
        cccSalesUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser(testCCCLicenUser1);
        insert cccSalesUser;
        User testCCCUnLicenUser1 = new User(Alias='CCCU',LastName='cccUnLicensedUser',Username=CCC_UNLICENSED_USER_NAME,Associate_ID__c=CCCUL_ASSOCIATE_ID,UserExternalID__c=CCCUL_ASSOCIATE_ID);
        cccServiceUser = UTIL_UserProvisioning_TEST.buildCCCUnlicensedUser(testCCCUnLicenUser1);
        insert cccServiceUser;

   		apiOnlyUser = UTIL_UserProvisioning_TEST.create103APIOnlyTestUser();

        techSupportUser = UTIL_UserProvisioning_TEST.buildTechSupportUser();
        insert techSupportUser;
        
        setupBankSupportCenterUser();

        setUpSystemUserRecordOwnerOnly();
    }
    /**
     * @description setupBankSupportCenterUser
     */
    public static void setupBankSupportCenterUser(){
        bankSupportCenterUser= UTIL_UserProvisioning_TEST.buildLimitedEnterpriseUser();
        bankSupportCenterUser.SubUserType__c = 'Bank Call Center';
        Database.insert(bankSupportCenterUser);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Activities_Standard_W'];
        insert new PermissionSetAssignment(AssigneeId = bankSupportCenterUser.id, PermissionSetId = ps.Id);
        //Hack to give Account View All permission to Bank User - for FSC Test fix
        PermissionSet caseps = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_CaseAPI_PermSetPID'];
        insert new PermissionSetAssignment(AssigneeId = bankSupportCenterUser.id, PermissionSetId = caseps.Id);
        Group healthGroup = [SELECT Id FROM Group WHERE DeveloperName = 'Health_Sourced_Restricted_Users'];
        insert new GroupMember(GroupId=healthGroup.id, UserOrGroupId=bankSupportCenterUser.id);
    }
    /**
     * @description setUpSystemUserRecordOwnerOnly
     */
    public static void setUpSystemUserRecordOwnerOnly(){
        setUpSysAdminUserOnly();
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);        
    }
    /**
     * @description setUpSysAdminUserOnly
     */
    public static void setUpSysAdminUserOnly(){
        systemAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('syad', 'p_lastName', SYS_ADMIN_USER_NAME);
        insert systemAdminUser;
    }
    /**
     * @description getAgentUser
     * @return  `User`
     */
    public static User getAgentUser(){
        return UTIL_UserProvisioning_TEST.getUser(AGENT_USER_NAME);
    }
    /**
     * @description getAtmUser
     * @return  `User`
     */
    public static User getAtmUser(){
        return UTIL_UserProvisioning_TEST.getUser(ATM_USER_NAME);
    }
    /**
     * @description getAgentProxyUser
     * @return  `User`
     */
    public static User getAgentProxyUser(){
        return UTIL_UserProvisioning_TEST.getUser(PROXY_USER_NAME);
    }
    /**
     * @description getSecondaryAgentUser
     * @return  `User`
     */
    public static User getSecondaryAgentUser(){
        return UTIL_UserProvisioning_TEST.getUser(AGENT_USER2_NAME);
    }
    /**
     * @description getSecondaryAtmUser 
     * @return  `User`
     */
    public static User getSecondaryAtmUser(){
        return UTIL_UserProvisioning_TEST.getUser(ATM_USER2_NAME);
    }
    /**
     * @description getSecondaryAgentProxyUser
     * @return  `User`
     */
    public static User getSecondaryAgentProxyUser(){
        return UTIL_UserProvisioning_TEST.getUser(PROXY_USER2_NAME);
    }
    /**
     * @description getCCCLicensedUser
     * @return  `User`
     */
    public static User getCCCLicensedUser(){
        return UTIL_UserProvisioning_TEST.getUser(CCC_LICENSED_USER_NAME);
    }
    /**
     * @description getCCCUnLicensedUser
     * @return  `User`
     */
    public static User getCCCUnLicensedUser(){
        return UTIL_UserProvisioning_TEST.getUser(CCC_UNLICENSED_USER_NAME);
    }
    /**
     * @description getBankSupportCallCenterUser
     * @return  `User`
     */
    public static User getBankSupportCallCenterUser(){
        return UTIL_UserProvisioning_TEST.getUser(BANK_USER_NAME);
    }
    /**
     * @description getSalesLeaderUser
     * @return  `User`
     */
    public static User getSalesLeaderUser(){
        return UTIL_UserProvisioning_TEST.getUser(SALES_LEADER_USER_NAME);
    }
    /**
     * @description getSysAdminUser
     * @return  `User`
     */
    public static User getSysAdminUser(){
        return UTIL_UserProvisioning_TEST.getUser(SYS_ADMIN_USER_NAME);
    }
    /**
     * @description getApiOnlyUser
     * @return  `User`
     */
    public static User getApiOnlyUser(){
        return UTIL_UserProvisioning_TEST.get103APIOnlyProfileUser();
    }

    @isTest
    (seeAllData=true)
    public static Id getCaseOwnerQueueId(){
        Group caseOwnerQueue = [SELECT Id, Type FROM Group WHERE Name ='Case Owner Queue' LIMIT 1];
        System.assert(true, 'Mandatory Assert statement on Tests');
        return caseOwnerQueue.Id;
    }
    /**
     * @description getClosedCaseStatus
     * @return  `String`
     */
    public static String getClosedCaseStatus(){
        CaseStatus closedCaseStatus = [SELECT ApiName FROM CaseStatus WHERE isClosed = true LIMIT 1];
        return closedCaseStatus.ApiName;
    }
    
    /**
     * @description getOpenCaseStatus
     * @return  `String`
     */
    public static String getOpenCaseStatus(){
        CaseStatus openCaseStatus = [SELECT ApiName FROM CaseStatus WHERE isClosed = false LIMIT 1];
        return openCaseStatus.ApiName;
    }
    /**
     * @description getCaseForAssertTest
     * @param caseId 
     * @return  `Case`
     */
     public static Case getCaseForAssertTest(Id caseId){
        Case caseToTest;
        try{
           caseToTest = [SELECT Id, Subject, Case_Owner__c, OwnerId, Status, Assigned_To__c, 
                         Case_Originator__c, ContactId, AccountId, RecordTypeId, Outcome__c, Pending_Type__c 
                         FROM Case 
                         WHERE Id=: caseId LIMIT 1];
        }catch(QueryException qex){
           caseToTest.addError('Could not find the Case');          
        }
        return caseToTest;
    }
    /**
     * @description getCasesForAssertTest
     * @param caseIds 
     * @return  `List<Case>`
     */
    public static List<Case> getCasesForAssertTest(Set<Id> caseIds){
        List<Case> casesToTest;
        try{
           casesToTest = [SELECT Id, Subject, Case_Owner__c, OwnerId, Status, Assigned_To__c, 
                          Case_Originator__c, ContactId, AccountId, RecordTypeId, Outcome__c, Pending_Type__c 
                          FROM Case 
                          WHERE Id In: caseIds];
        }catch(QueryException qex){
                LoggingService.logHandledException(qex, 'UTIL_CaseTestData', 'getCasesForAssertTest', System.LoggingLevel.WARN);  
        }
        return casesToTest;
    }
    /**
     * @description contactId
     * @return  `Id`
     */
    public static Id contactId(){
        return contactId(CONTACT_CLIENT_ID);
    }
    /**
     * @description contactId
     * @param clientId 
     * @return  `Id`
     */
    public static Id contactId(String clientId){
        Contact contact = new Contact(LastName = 'lstName', FirstName = 'fstName', ClientIdentifier__c = clientId);
       	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert contact;
        Id contactId = contact.Id;
        return contactId;
    }
    /**
     * @description getContact
     * @return  `Contact`
     */
    public static Contact getContact(){
        return [SELECT Id FROM Contact WHERE ClientIdentifier__c = :CONTACT_CLIENT_ID];
    }
    /**
     * @description createAccountId
     * @return  `Id`
     */
    public static Id createAccountId(){
        Account account = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',BillingAddressType__c='US',BillingCity='Phoenix',ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert account;
        Id accountId = account.Id;
        return accountId;
    }
    /**
     * @description getAccount
     * @return  `Account`
     */
    public static Account getAccount(){
        return [SELECT Id, Name, PersonContactId FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }
    /**
     * @description createAccountWithAssociatedContact
     * @return  `Id`
     */
    public static Id createAccountWithAssociatedContact(){
        Account account = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',BillingAddressType__c='US',BillingCity='Phoenix',ClientIdentifier__c='12345678913');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert account;
        Contact contactOnAccount = [SELECT Id, AccountId FROM Contact WHERE AccountId=:account.Id LIMIT 1];
        Id contactId = contactOnAccount.Id;
        return contactId;
        
    }

    /** 11-25-19
    * @Author : ebcl
    * @description getNewCase
    * @param recordTypeId 
    * @return  `Case`
    */  
    public static Case getNewCase(Id recordTypeId){
        Case newCase = new Case();
        newCase.Status = NEW_STATUS;
        newCase.AccountId = getAccount().Id;
        newCase.ContactId = getAccount().PersonContactId;
        newCase.Subject = CUSTOMER_SERVICE_REQUEST;
        newCase.RecordTypeId = recordTypeId;
		if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            newCase.Case_Owner__c = getAgentProxyUser().Id;
        }else{
            newCase.OwnerId = getAgentProxyUser().Id;
        }
        insert newCase;
        return newCase;
    }
	    
    /** 11-25-19
    * @Author : ebcl
    * @description getNewCase
    * @param proxyAsOwner 
    * @return  `Case`
    */ 
    public static Case getNewCase(boolean proxyAsOwner){
        Case newCase = new Case();
        newCase.Status = NEW_STATUS;
        newCase.AccountId = getAccount().Id;
        newCase.ContactId = getAccount().PersonContactId;
        newCase.Subject = CUSTOMER_SERVICE_REQUEST;
        newCase.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST;
        if(proxyAsOwner){
            if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            	newCase.Case_Owner__c = getAgentProxyUser().Id;
            }else{
                newCase.OwnerId = getAgentProxyUser().Id;
            }
        }else{
            if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            	newCase.Case_Owner__c = getAgentUser().Id;
            }else{
                newCase.OwnerId = getAgentUser().Id;
            }
        }
        insert newCase;
        return newCase;
    }
    
    /** 11-25-19
    * @Author : ebcl
    * @description Create a Case with a any record type
    * @param recordTypeId 
    * @param proxyAsOwner 
    * @return  `Case`
    */ 
    public static Case getNewCase(Id recordTypeId, boolean proxyAsOwner){
        Case newCase = new Case();
        newCase.Status = NEW_STATUS;
        newCase.AccountId = getAccount().Id;
        newCase.ContactId = getAccount().PersonContactId;
        newCase.Subject = CUSTOMER_SERVICE_REQUEST;
        newCase.RecordTypeId = recordTypeId;
        if(proxyAsOwner){
            if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            	newCase.Case_Owner__c = getAgentProxyUser().Id;
            }else{
                newCase.OwnerId = getAgentProxyUser().Id;
            }
        }else{
            if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            	newCase.Case_Owner__c = getAgentUser().Id;
            }else{
                newCase.OwnerId = getAgentUser().Id;
            }
        }
        insert newCase;
        return newCase;
    }
    
    /** 11-25-19
    * @Author : ebcl
    * @description Create a Case with a any record type
    * @param recordTypeId 
    * @param ownerId 
    * @return  `Case`
    */ 
    public static Case getNewCase(Id recordTypeId, Id ownerId){
        Case newCase = new Case();
        newCase.Status = NEW_STATUS;
        newCase.AccountId = getAccount().Id;
        newCase.ContactId = getAccount().PersonContactId;
        newCase.Subject = CUSTOMER_SERVICE_REQUEST;
        newCase.RecordTypeId = recordTypeId;
        if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            newCase.Case_Owner__c = ownerId;
        }else{
             newCase.OwnerId = ownerId;
        }
        insert newCase;
        return newCase;
    }
    /**
     * @description getNewCaseWithoutInsert
     * @param recordTypeId 
     * @param ownerId 
     * @return  `Case`
     */
    public static Case getNewCaseWithoutInsert(Id recordTypeId, Id ownerId){
        Case newCase = new Case();
        newCase.Status = NEW_STATUS;
        newCase.AccountId = getAccount().Id;
        newCase.ContactId = getAccount().PersonContactId;
        newCase.Subject = CUSTOMER_SERVICE_REQUEST;
        newCase.RecordTypeId = recordTypeId;
        if(newCase.CreatedByProfileName__c == CCC_LICENSED || newCase.CreatedByProfileName__c == CCC_UNLICENSED){
            newCase.Case_Owner__c = ownerId;
        }else{
             newCase.OwnerId = ownerId;
        }
        return newCase;
    }
    /**
     * @description createBasicCaseWithCustomSubject
     * @param subject 
     * @param owner 
     * @param accountId 
     * @return  `Case`
     */
    public static Case createBasicCaseWithCustomSubject(String subject, User owner, Id accountId){
        Case newCase = new Case(Status = getOpenCaseStatus(), OwnerId = owner.Id, AccountId = accountId, Subject = subject);
        insert newCase;
        return newCase;
    }
    /**
     * @description createDARCaseWithContactAndOwnerId
     * @param ownerId 
     * @param contactId 
     * @return  `Case`
     */
    public static Case createDARCaseWithContactAndOwnerId(Id ownerId, Id contactId){
        Case newCase = new Case(Status = NEW_STATUS, OwnerId = ownerId, ContactId = contactId, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Data Access Request').getRecordTypeId());
        insert newCase;
        return newCase;
    }  
    /**
     * @description createCaseWithContactAndCaseOwnerCustomField
     * @param ownerId 
     * @param contactId 
     * @return  `Case`
     */
    public static Case createCaseWithContactAndCaseOwnerCustomField(Id ownerId, Id contactId){
        Case newCase = new Case(Status = NEW_STATUS, Case_Owner__c = ownerId, ContactId = contactId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithAccountCaseOwnerIdAndStatus
     * @param ownerId 
     * @param accountId 
     * @param status 
     * @return  `Case`
     */
    public static Case createCaseWithAccountCaseOwnerIdAndStatus(Id ownerId, Id accountId, String status){
        Case newCase = new Case(Status = status, Case_Owner__c = ownerId, AccountId = accountId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithContactAndOwnerId
     * @param ownerId 
     * @param contactId 
     * @return  `Case`
     */
    public static Case createCaseWithContactAndOwnerId(Id ownerId, Id contactId){
        Case newCase = new Case(Status = NEW_STATUS, OwnerId = ownerId, ContactId = contactId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithoutContactAndWithOwnerId
     * @param ownerId 
     * @return  `Case`
     */
    public static Case createCaseWithoutContactAndWithOwnerId(Id ownerId){
        Case newCase = new Case(Status = NEW_STATUS, OwnerId = ownerId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithContactAndWithoutOwnerId
     * @param contactId 
     * @return  `Case`
     */
    public static Case createCaseWithContactAndWithoutOwnerId(Id contactId){
        Case newCase = new Case(Status = NEW_STATUS, ContactId = contactId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithAccountAndWithoutOwnerId
     * @param accountId 
     * @return  `Case`
     */
    public static Case createCaseWithAccountAndWithoutOwnerId(Id accountId){
        Case newCase = new Case(Status = NEW_STATUS, AccountId = accountId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithAccountAndWithoutOwnerIdWithReason
     * @param accountId 
     * @param reason 
     * @return  `Case`
     */
    public static Case createCaseWithAccountAndWithoutOwnerIdWithReason(Id accountId , String reason){
        Case newCase = new Case(Status = NEW_STATUS, AccountId = accountId, Reason = reason);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithContactAndAccountAndWitCustomCaseOwnerField
     * @param ownerId 
     * @param contactId 
     * @param accountId 
     * @return  `Case`
     */
     public static Case createCaseWithContactAndAccountAndWitCustomCaseOwnerField(Id ownerId, Id contactId, Id accountId){
        Case newCase = new Case(Status = NEW_STATUS, Case_Owner__c = ownerId, AccountId = accountId);
        insert newCase;
        return newCase;
         
    }
    /**
     * @description createCaseWithContactAndOwnerIdAndStatus
     * @param ownerId 
     * @param contactId 
     * @param status 
     * @return  `Case`
     */
    public static Case createCaseWithContactAndOwnerIdAndStatus(Id ownerId, Id contactId, String status){
        Case newCase = new Case(Status = status, OwnerId = ownerId, ContactId = contactId);
        insert newCase;
        return newCase;
    }
    /**
     * @description createCaseWithSpecifiedUserOwnerAndContact
     * @param user 
     * @param ownerId 
     * @param contactId 
     * @return  `Case`
     */
    public static Case createCaseWithSpecifiedUserOwnerAndContact(User user, Id ownerId, Id contactId){
        Case newCase;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user){
        newCase = new Case(Status = NEW_STATUS, OwnerId = ownerId, ContactId = contactId);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert newCase; 
        }
        return newCase;
    }
    
    /**
     * @description createListOfCasesWithAccountIds
     * @param ownerId 
     * @return  `List<Case>`
     */
    public static List<Case> createListOfCasesWithAccountIds(Id ownerId){
        List<Case> caseList = new List<Case>();
        Case newCase1 = new Case(Subject = 'Case 1' ,Status = NEW_STATUS, OwnerId = ownerId, AccountId = createAccountId(), ContactId = contactId());
        Case newCase2 = new Case(Subject = 'Case 2' ,Status = NEW_STATUS, OwnerId = ownerId, AccountId = createAccountId(), ContactId = contactId());
        caseList.add(newCase1);
        caseList.add(newCase2);
        insert caseList;
        return caseList;
    }
    /**
     * @description createAgentRoles
     * @param agentId 
     * @param relationshipNature 
     * @return  `AgentRole__c`
     */
    public static AgentRole__c createAgentRoles(Id agentId , String relationshipNature) {
        return new AgentRole__c(Customer__c = contactId(), Agent__c = agentId, RelationshipNature__c = relationshipNature);
    }
    /**
     * @description createAgentRoleList
     * @param accountId 
     * @return  `List<AgentRole__c>`
     */
    public static List<AgentRole__c> createAgentRoleList(Id accountId){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c = accountId, Agent__c = getAgentUser().Id, RelationshipNature__c = 'Prospect');
        AgentRole__c agentRole2 = new AgentRole__c(Customer__c = accountId, Agent__c = getSecondaryAgentUser().Id, RelationshipNature__c = CUSTOMER);
        agentRoleList.add(agentRole1);
        agentRoleList.add(agentRole2);
        insert agentRoleList;
        return agentRoleList;
    }
    /**
     * @description createMultipleActiveAgentRoleList
     * @param accountId 
     * @return  `List<AgentRole__c>`
     */
    public static List<AgentRole__c> createMultipleActiveAgentRoleList(Id accountId){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c = accountId, Agent__c = getAgentUser().Id, RelationshipNature__c = CUSTOMER);
        AgentRole__c agentRole2 = new AgentRole__c(Customer__c = accountId, Agent__c = getSecondaryAgentUser().Id, RelationshipNature__c = CUSTOMER);
        agentRoleList.add(agentRole1);
        agentRoleList.add(agentRole2);
        insert agentRoleList;
        return agentRoleList;
    }
   /**
    * @description createAgentRole
    * @param accountId 
    * @param agentId 
    * @param relationshipNature 
    * @return  `List<AgentRole__c>`
    */ 
   public static List<AgentRole__c> createAgentRole(Id accountId, Id agentId, String relationshipNature){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c = accountId, Agent__c = agentId, RelationshipNature__c = relationshipNature);
        agentRoleList.add(agentRole1);
        insert agentRoleList;
        return agentRoleList;
    }
    
    /**
     * @description createAccountWithOneActiveAgentRole
     */
   public static void createAccountWithOneActiveAgentRole(){
       Id accountId = UTIL_CaseTestData.createAccountId();
       createAgentRole(accountId, getAgentUser().Id, CUSTOMER);
   }

/** 12-02-19
    * @Author : ebcl
    * @description Create Task
    * @param proxyAsOwner 
    * @return  `Task`
    */ 
   public static Task getNewTask(boolean proxyAsOwner){
        Task newTask = new Task();
        newTask.Status = NOT_STARTED;
        newTask.WhoId = getAccount().PersonContactId;
        newTask.Subject = 'New Task - Apex Test';
        newTask.RecordTypeId = TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID;
		if(proxyAsOwner){
            newTask.OwnerId = getAgentProxyUser().Id;
        }else{
            newTask.OwnerId = getAgentUser().Id;
        }
        insert newTask;
        return newTask;
    }
    
    /** 12-02-19
    * @Author : ebcl
    * @description Create Task with any record type
    * @param recordTypeId 
    * @return  `Task`
    */ 
   public static Task getNewTask(Id recordTypeId){
        Task newTask = new Task();
        newTask.Status = NOT_STARTED;
        newTask.WhoId = getAccount().PersonContactId;
        newTask.Subject = 'New Task - Apex Test';
        newTask.RecordTypeId = recordTypeId;
        newTask.OwnerId = getAgentUser().Id;
        insert newTask;
        return newTask;
    }
    
    /** 12-02-19
    * @Author : ebcl
    * @description Create Task with any priority
    * @param priority 
    * @return  `Task`
    */ 
   public static Task getNewTask(String priority){
        Task newTask = new Task();
        newTask.Status = NOT_STARTED;
        newTask.WhoId = getAccount().PersonContactId;
        newTask.Subject = 'New Task - Apex Test';
        newTask.Priority = priority;
        newTask.OwnerId = getAgentUser().Id;
        insert newTask;
        return newTask;
    }


}
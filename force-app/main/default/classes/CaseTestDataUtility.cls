/** 
* @description case test data utility 
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
public class CaseTestDataUtility {

    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678918';
    @TestVisible private static final String SECONDARY_ACCOUNT_CLIENT_ID = '12345678999';
    
    @TestVisible private static Case buildCustomerServiceRequest(Account accountRecord, Id ownerId){
        CaseFactoryCustomerServiceRequest caseFactory = new CaseFactoryCustomerServiceRequest();
        CaseFactory.setAppCode('SFDC UI - Account')
        .setCaseType('Account Change')
        .setDescription('CCC Test')
        .setReason('Added Driver')
        .setSubject('CCC Test');
        return caseFactory.buildCase(accountRecord, ownerId);
    }
    
    @TestVisible private static Case buildCustomerOnboarding(Account accountRecord, Id ownerId){
        CaseFactoryCustomerOnboarding caseFactory = new CaseFactoryCustomerOnboarding();
        return caseFactory.buildCase(accountRecord, ownerId);
    }
    
    @TestVisible private static Case buildDataAccessRequest(Account accountRecord){
        CaseFactoryDataAccessRequest caseFactory = new CaseFactoryDataAccessRequest();
        return caseFactory.buildCase(accountRecord);
        
    }
    
    @TestVisible private static Case buildRetentionCase(Account accountRecord, Id ownerId){
        Double shoppingActivity = 5;
        CaseFactoryRetentionCase caseFactory = new CaseFactoryRetentionCase();
            CaseFactory.setShoppingActLast30days(shoppingActivity)
            .setShoppingActLast30to90days(shoppingActivity)
            .setShoppingActLast90to1year(shoppingActivity)
            .setShoppingActLast1to2years(shoppingActivity)
            .setShoppingActLast2to3years(shoppingActivity)
            .setFirstShoppedDate(Date.today())
            .setLastShoppedDate(Date.today());
        return caseFactory.buildCase(accountRecord, ownerId);
    }
    
    @TestVisible private static Case buildPolicyChangeCase(Map<String, Object> paramMap){
        CaseFactoryPolicyChange caseFactory = new CaseFactoryPolicyChange();
        caseFactory.setPolicyIdentifier(String.valueOf(paramMap.get('PolicyIdentifier')))
            .setProductDescription(String.valueOf(paramMap.get('ProductDescription')))
            .setIssued(boolean.valueOf(paramMap.get('Issued')))
            .setIsEscalated(boolean.valueOf(paramMap.get('IsEscalated')))
            .setEffectiveDate(Date.today());
        return caseFactory.buildCase((Account)paramMap.get('Account'), String.valueOf(paramMap.get('OwnerId')));
        
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
    
    @TestVisible private static Case retrieveCaseAfterInsert(Case caseRecord){
        Id caseId = caseRecord.Id;
        return [SELECT Id, Status, OwnerId, Case_Owner__c, Assigned_To__c,  Type, Reason, RecordTypeId, ContactId, AccountId, Account.ClientIdentifier__c, Policy_Identifier__c, ProductDescription__c, IsEscalated, Owner_User_External_Id__c, RecordType.DeveloperName FROM Case WHERE Id =: caseId LIMIT 1];
    }
    
    @TestVisible private static Case retrieveCaseAfterInsert(Id caseId){
        return [SELECT Id, Status, OwnerId, Case_Owner__c, Assigned_To__c,  Type, Reason, RecordTypeId, ContactId, AccountId, Opportunity_Related_To__c, Account.ClientIdentifier__c, Policy_Identifier__c, ProductDescription__c, IsEscalated, Owner_User_External_Id__c, RecordType.DeveloperName FROM Case WHERE Id =: caseId LIMIT 1];
    }
    
    @TestVisible private static List<Case> retrieveCaseListAfterInsert(List<Case> caseRecords){
        Set<Id> caseIds = new Set<Id>();
        for(Case caseRecord : caseRecords){
            caseIds.add(caseRecord.Id);
        }
        return [SELECT Id, Status, OwnerId, Case_Owner__c, Assigned_To__c, Type, Reason, RecordTypeId, ContactId, AccountId, Account.ClientIdentifier__c, Policy_Identifier__c, ProductDescription__c, IsEscalated, Owner_User_External_Id__c, RecordType.DeveloperName FROM Case WHERE Id In: caseIds];
    }
    
    @TestVisible private static PermissionSet getCaseAPIPermset(){
        return [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_CaseAPI_PermSetPID'];
    }
    @TestVisible private static void addUserToCaseAPI(User userRecord){
        Id caseAPIId = getCaseAPIPermset().Id;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userRecord.Id;
        psa.PermissionSetId = caseAPIId;
        insert psa;
    }
    
    @TestVisible private static void addUserToDataAccessRequestPermissionSet(User userRecord){
        PermissionSet dataAccessRequestPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Data_Access_Request'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userRecord.Id;
        psa.PermissionSetId = dataAccessRequestPermSet.Id;
        insert psa;
    }
    
    @TestVisible private static void addUserToOOPPublicGroup(User userRecord){
        Group oopGroup = [SELECT Id FROM Group WHERE DeveloperName = 'ECE_Office_of_Privacy'];
        GroupMember oopMember = new GroupMember();
        oopMember.GroupId = oopGroup.Id;
        oopMember.UserOrGroupId = userRecord.Id;
        insert oopMember;
    }
    
    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole; 
    }
    
    
    
    @TestVisible private static void createOpportunity(Account accountRecord, User userRecord){
        //Name, StageName, CloseDate
        Opportunity opp = new Opportunity();
        opp.AccountId = accountRecord.Id;
        opp.LOB__c = 'Auto';
        opp.ContactId = accountRecord.PersonContactId;
        opp.OwnerId = userRecord.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = Date.today();
        bypassOpporunityTriggers(true);
        insert opp;
		bypassOpporunityTriggers(false);       
    }
    
    @TestVisible private static Opportunity getOpportunity(Id accountId){
        return [SELECT Id, AccountId FROM Opportunity WHERE AccountId =: accountId LIMIT 1];
    }
    
    @TestVisible private static void bypassOpporunityTriggers(boolean bypassAll){
        CS001_ByPassTriggerGtoZ__c byPassObjectTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        byPassObjectTrigger.Override_OppBeforeInsert__c = bypassAll;
        byPassObjectTrigger.Override_OppBeforeUpdate__c = bypassAll;
        byPassObjectTrigger.Override_OppAfterUpdate__c = bypassAll;
        byPassObjectTrigger.Override_OpportunityAfterInsert__c = bypassAll;
    }
    
    @TestVisible private static void createCustomTemplates(){
        List<Custom_Template__c> customTemplateList = new List<Custom_Template__c>();
        Custom_Template__c customTemplate = new Custom_Template__c(
        Custom_Template_Title__c = 'Testing Title',Task_Subject__c = 'Testing Task Subject',Task_Description__c = 'Flow description',
        Task_Category__c = 'Other',Task_SubCategory__c = 'Other',Due_Date_Number_of_Days_from_Today__c = 3,Task_Priority__c = 'Low',
        Task_Type__c = 'Service',Template_Type__c = 'Onboarding',
        RecordTypeId = Schema.SObjectType.Custom_Template__c.getRecordTypeInfosByDeveloperName().get('New_Corporate_Task_Template').getRecordTypeId());
        customTemplateList.add(customTemplate);
        customTemplateList.add(customTemplate.clone());
        insert customTemplateList;
    }
    
    @TestVisible private static List<Id> getCustomTemplateIds(){
        List<Id> customTemplateIds = new List<Id>();
        List<Custom_Template__c> customTemplateList = [SELECT Id, Template_Type__c FROM Custom_Template__c WHERE Template_Type__c = 'Onboarding' LIMIT 2];
        for(Custom_Template__c customTemplate :  customTemplateList){
            customTemplateIds.add(customTemplate.Id);
        }
        return customTemplateIds;
    }
}
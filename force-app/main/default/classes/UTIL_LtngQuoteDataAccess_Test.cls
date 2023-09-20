/**
* Author : Golden Spikes Team
* Date Created : 10/22/2018
* @description : Test class for the UTIL_LtngQuoteDataAccess apex class.
*/

@isTest(seeAllData=false)
private class UTIL_LtngQuoteDataAccess_Test {

    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    
    //method to setup common data 
    @TestSetup
    static void makeData(){
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('tstFtchOdataQueryAdm2@statefarm.com.bad');
        insert adminuser;

        User agentUser;
        User proxyUser; 

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            User testAgentUser = new User(Alias='XQDT',LastName='agent',Username='tstFtchOdataQueryAgt2@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;                          
            insert agentUser;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            User testProxyUser = new User(Alias='XODT',LastName='middle',Username='tstFtchOdataQueryPrxy2@statefarm.com.bad',UserExternalID__c='EXTERNALID2',Servicing_Agent_Associate_ID__c='ASSOCID0001', Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            
        }
		Account acc = buildAccountRecord('Quote ODTA','111',agentUser.Id);
        insert acc;    
        
       //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
    }
    
    /**
     * @description byPassTrigger
     */
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    /**
     * @description buildRole
     * @param roleName
     * @return UserRole
     */
    //method to build userrole with the given parameter value
    private static UserRole buildRole(String roleName) {
        return new UserRole(name = roleName);
    }

    /**
     * @description buildUserRoleWithParent
     * @param roleName
     * @param parentRole
     * @return UserRole
     */
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        return new UserRole(name = roleName, parentRoleId = parentrole);
    }
    
    /**
     * @description buildAccountRecord
     * @param fstLstName
     * @param clientId
     * @param owner
     * @return Account
     */
    //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD');
    }
    
    /**
     * @description buildOpportunityRecord
     * @param accountId
     * @param lobProduct
     * @param ownerId
     * @return Opportunity
     */
    //method to build Opportunity record with Lob,Product, AccountId and OwnerId
	private static Opportunity buildOpportunityRecord(String accountId, String lobProduct, String ownerId) {
        String[] splitlobProduct = lobProduct.split('-');   
        return new Opportunity(Name = splitlobProduct[0],
                                          AccountId = accountId, 
                                          LOB__c = splitlobProduct[0], 
                                          Product__c = (splitlobProduct.size()>1)?splitlobProduct[1]:'',
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = ownerId);
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
    }

    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }

    //test method to fetch quote summary and detail ODATA records.
    @isTest
    private static void testPerformQueryOnQuoteODATASummaryDetail() {
        User agentUser1 = [SELECT Id, Associate_ID__c, UserExternalID__c FROM User WHERE username = 'tstFtchOdataQueryAgt2@statefarm.com.bad'];
        assignPermissionSet(agentUser1, 'SF_CRM_QuoteManagement_PermSetPID');
        Test.startTest();
        System.runAs(agentUser1) {
            List<Quotes__x> quoteSummaryList = UTIL_LtngQuoteDataAccess.performQueryOnQuoteODATASummary('Auto', '9802011', 'qqccww11zzc');
            System.assertEquals(0, quoteSummaryList.size(), 'quoteSummaryList size should be 0');
            List<QuoteDetails__x> quoteDetailList = UTIL_LtngQuoteDataAccess.performQueryOnQuoteODATADetail(new Set<String>{'123', '456'});
            System.assertEquals(0, quoteDetailList.size(), 'quoteDetailList size should be 0');
        }
        Test.stopTest();
    }

    //test method to fetch Quote and Opportunity
    @isTest
    private static void testPerformQueryOnOpportunityAndQuote() {
        User agentUser2 = [SELECT Id, Associate_ID__c, UserExternalID__c FROM User WHERE username = 'tstFtchOdataQueryAgt2@statefarm.com.bad'];
        User proxyUser2 = [SELECT Id, Associate_ID__c FROM User WHERE Alias = 'XODTP'];
    	Account acc = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'ODTA'];
        Opportunity opp;
        assignPermissionSet(agentUser2, 'SF_CRM_QuoteManagement_PermSetPID');
        	System.runAs(agentUser2) {
            List<Opportunity> opportunityList = new List<Opportunity>();
            System.assertEquals(0, opportunityList.size(), 'opportunityList size should be 0');
            
            opp = buildOpportunityRecord(acc.id,'Auto', proxyUser2.Id);
            insert opp;
 			
          	Test.startTest();  
            opportunityList = UTIL_LtngQuoteDataAccess.performQueryOnOpportunity(opp.id);
            System.assertEquals(1, opportunityList.size(), 'opportunityList size should be 1');

            Quote__c qtRecord = new Quote__c (Name = 'Tst Quote', Opportunity__c= opp.id);
            insert qtRecord;

            Quote__c quoteRecord = UTIL_LtngQuoteDataAccess.performQueryOnQuote(qtRecord.Id);
            System.assertEquals('Tst Quote', quoteRecord.name, 'quoteRecord name should be: Tst Quote');

            System.assertEquals('Agent', UTIL_LtngQuoteDataAccess.performQueryOnUser(), 'performQueryOnUser should return: Agent');
        }
        Test.stopTest();
    }

}
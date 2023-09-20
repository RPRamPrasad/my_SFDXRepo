/**
* Author : Team Kraken
* Owner: Team Grumpy Cats
* Date Created : 04/17/2017
* Description : Test class for the AT_ABSActivies apex class.
*/
@isTest (seeAllData=false)
public class AT_ABSActivitiesControllerTest {

    @testsetup
    private static void testUsersSetup() {  
        UTIL_CaseTestData.setUpUsersForCase();
        User sysAdminUser = UTIL_CaseTestData.getSysAdminUser();
        System.runAs(sysAdminUser){
            createAccountAndContact();
            Id accountId = UTIL_CaseTestData.getAccount().Id;
            UTIL_CaseTestData.createAgentRoleList(accountId);
        }
    }

    private static void createAccountAndContact(){
        Id accountId = UTIL_CaseTestData.createAccountId();
        UTIL_CaseTestData.contactId();
	}
	
    private static Account createAccount(String clientIdentifier){
        Account getAccount = new Account(FirstName = 'tst1', LastName='Ltst'+clientIdentifier, ClientIdentifier__c  = clientIdentifier,Edit_In_VFP__c = true);
        return getAccount;
    }
 
    private static CustomerGroup__c createCustomerGroup(User agentUser, List<Account> testAccountList){
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        insert cg;
        List<CustomerGroupMember__c> memberList = new List<CustomerGroupMember__c>();
        for(Account testAccount : testAccountList){
        	CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
        	custGrpMember.Customer__c = testAccount.id;
        	custGrpMember.group__c = cg.id;
        	custGrpMember.groupmemberid__c = cg.sfgroupidentifier__c + '~' + testAccount.clientidentifier__c;
            memberList.add(custGrpMember);
        }
        insert memberList;
        return cg;
    }    
 
    private static Activities__x createActivities(String clientId, String activityId, String associateId){
        Activities__x getActivities = new Activities__x(ActivityID__c = activityId, ClientID__c=clientId, AgentName__c = 'AgentSmith',
                                                        AssociateID__c = associateId, Category__c = 'catID1',
                                                        Customer__c = 'Cust1', Description__c = 'Descriptive', DueDate__c = '2018-12-30',
                                                        Status__c = 'Active', LineOfBusiness__c = 'A', ModifiedDate__c = '2016-06-14 16:56:00.659000000');
        return getActivities;
    }

    @IsTest
    private static void loggedInUserIsAnAgentProfileTrue(){       
        User agentUser = UTIL_CaseTestData.getAgentUser();
        Id accountId = UTIL_CaseTestData.getAccount().Id;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        Test.startTest();        
        System.runas(agentUser){
            Boolean booleanValue = AT_ABSActivitiesController.loggedInUserIsAnAgentOrATMProfile();
            System.assertEquals(true, booleanValue, '');
        }
        Test.stopTest();
    }

    @IsTest
    private static void loggedInUserIsAnAgensalesleaderUsertProfileFalse(){        
        User  salesleaderUser = UTIL_CaseTestData.getSalesLeaderUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesleaderUser);        
        Test.startTest();        
        System.runas(salesleaderUser){
            System.assertEquals(false, AT_ABSActivitiesController.loggedInUserIsAnAgentOrATMProfile(), '');
        }
        Test.stopTest();
    }
  
    @IsTest
    private static void getClientIdsFromGroupTest(){     
        User agentUser = UTIL_CaseTestData.getAgentUser();        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        Test.startTest();        
        System.runas(agentUser){
            List<Account> acctList = new List<Account>();
            acctList.add(createAccount('Test1'));
            acctList.add(createAccount('Test2'));
            acctList.add(createAccount('Test3'));           
            insert acctList; 
            CustomerGroup__c tstGroup = createCustomerGroup(agentUser, acctList);
            String cgID = tstGroup.Id;
            List<String> tstClientList = AT_ABSActivitiesController.getClientIdsFromGroup(cgID);
            System.assertEquals(tstClientList.size(), 3,'');
            System.assertEquals(true,tstClientList.contains('Test1'),'');
        }
    }
 
    @IsTest
    private static void activityInfoData(){
        User agentUser = UTIL_CaseTestData.getSecondaryAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Id accountId = UTIL_CaseTestData.getAccount().Id;       
        List<ActivityWrapper> activityWrapperList = new List<ActivityWrapper>();
        activityWrapperList.add(createActivityWrapper('dknyz','10010','M1001'));        
        Test.startTest();        
        System.runas(agentUser){
            AT_ABSActivitiesController.mockedTempActivityList.add(AT_ABSActivitiesControllerTest.createActivities('dknyz','10010','M1001'));
            List<ActivityWrapper> activityWrapperTest = AT_ABSActivitiesController.getActivitiesList(accountId,'dummyFilter', false);
            System.assertEquals(activityWrapperList[0].activityID,activityWrapperTest[0].activityID, '');
            System.assertEquals(activityWrapperList[0].clientID,activityWrapperTest[0].clientID, '');
            System.assertEquals(activityWrapperList[0].associateID,activityWrapperTest[0].associateID, '');
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void activityInfoDataFSCGroup(){
        User agentUser = UTIL_CaseTestData.getSecondaryAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Id accountId = UTIL_CaseTestData.getAccount().Id;       
        List<ActivityWrapper> activityWrapperList = new List<ActivityWrapper>();
        activityWrapperList.add(createActivityWrapper('dknyz','10010','M1001'));     
        boolean isHouseholdPage = true;
        ID hhId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account tempHHAccount = new Account(Name = 'myName', ClientIdentifier__c  = '123456789', RecordtypeId = hhId);
        Account tempAccount = new Account(Name = 'myName', ClientIdentifier__c  = '12345678901', Primary_Household__pc = tempHHAccount.Id);
        UTIL_CustomerGroupData_FSC.mockedGroupMember = tempAccount;
        Test.startTest();        
        System.runas(agentUser){
            AT_ABSActivitiesController.mockedTempActivityList.add(AT_ABSActivitiesControllerTest.createActivities('dknyz','10010','M1001'));
            List<ActivityWrapper> activityWrapperTest = AT_ABSActivitiesController.getActivitiesList(accountId,'dummyFilter', isHouseholdPage);
            System.assertEquals(activityWrapperList[0].activityID,activityWrapperTest[0].activityID, '');
            System.assertEquals(activityWrapperList[0].clientID,activityWrapperTest[0].clientID, '');
            System.assertEquals(activityWrapperList[0].associateID,activityWrapperTest[0].associateID, '');
        }
        Test.stopTest();
    }
  
    @IsTest
    private static void activityInfoDataNull(){        
		User agentUser = UTIL_CaseTestData.getAgentUser(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser); 
        Test.startTest();        
        System.runas(agentUser){
            AT_ABSActivitiesController.mockedTempActivityList = null;            
            List<ActivityWrapper> activityWrapperTest = AT_ABSActivitiesController.getActivitiesList('0012900000MnweAAAR','dummyFilter',false);
            System.assertEquals(null,activityWrapperTest, '');
        }
        Test.stopTest();
    }

    @IsTest
    private static void activityInfoDataEmpty(){       
		User agentUser = UTIL_CaseTestData.getAgentUser();
        Id accountId = UTIL_CaseTestData.getAccount().Id; 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);       
        Test.startTest();        
        System.runas(agentUser){
            AT_ABSActivitiesController.mockedTempActivityList = new List<Activities__x>();            
              List<ActivityWrapper> activityWrapperTest = AT_ABSActivitiesController.getActivitiesList(accountId,'dummyFilter',false);
            System.assertEquals(0,activityWrapperTest.size(), '');
        }
        Test.stopTest();
    }

    @IsTest
    private static void activityInfoDataThrowError(){        
        User agentUser = UTIL_CaseTestData.getAgentUser();  
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);      
        Test.startTest();        
        System.runas(agentUser){
            AT_ABSActivitiesController.mockedTempActivityList.add(AT_ABSActivitiesControllerTest.createActivities('error','10010','M1001'));
            try {   
              List<ActivityWrapper> activityWrapperTest = AT_ABSActivitiesController.getActivitiesList('0012900000MnweAAAR','dummyFilter',false);
            }
            catch(Exception e) {
            System.Assert(e.getMessage().contains('error'), '');
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void formatDate(){       
        User agentUser = UTIL_CaseTestData.getAgentUser(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);               
        Test.startTest();
        System.runas(agentUser){           
            System.assertEquals('absce',AT_ABSActivitiesController.formatDate('absce'), '');
            System.assertEquals('01/01/1950',AT_ABSActivitiesController.formatDate('1950-01-01'), '');
            System.assertEquals('',AT_ABSActivitiesController.formatDate('0001-01-01'), '');
            System.assertEquals('',AT_ABSActivitiesController.formatDate(null), '');
            System.assertEquals('',AT_ABSActivitiesController.formatDate(null), '');
            System.assertEquals('',AT_ABSActivitiesController.formatDate(''), '');
            System.assertEquals('asbvasdf',AT_ABSActivitiesController.formatTimestamp('asbvasdf'), '');
            System.assertEquals('06/14/2016',AT_ABSActivitiesController.formatTimestamp('2016-06-14 16:56:00.659000000'), '');
            System.assertEquals('',AT_ABSActivitiesController.formatTimestamp(null), '');
            System.assertEquals('',AT_ABSActivitiesController.formatTimestamp(''), '');
        }
        Test.stopTest();
    }

    @IsTest
    private static void fetchRemarkNull(){        
        Test.startTest();        
        AT_ABSActivitiesRemarksHandler.mockedTempRemarkList = null;            
        String returnMessage = AT_ABSActivitiesController.fetchRemark('ABCDEFGHIJK');
        System.assertEquals(AT_ABSActivitiesRemarksHandler.CL_TRY_LATER,returnMessage, '');
        Test.stopTest();
    }
    
    @IsTest
    private static void fetchRemarkEmpty(){
        Remarks__x testRemark = new Remarks__x(Remark__c = '');
        Test.startTest();        
        AT_ABSActivitiesRemarksHandler.mockedTempRemarkList.add(testRemark);            
        String returnMessage = AT_ABSActivitiesController.fetchRemark('11176210672');
        System.assertEquals(AT_ABSActivitiesRemarksHandler.CL_NO_RECORDS,returnMessage, 'Expected No records Message');
        Test.stopTest();
    }
    
    @IsTest
    private static void fetchRemarkNoData(){        
        Remarks__x testRemark = new Remarks__x(Remark__c = '');
        Test.startTest();            
        String returnMessage = AT_ABSActivitiesController.fetchRemark('11176210672');
        System.assertEquals(AT_ABSActivitiesRemarksHandler.CL_NO_RECORDS,returnMessage, '');
        Test.stopTest();
    }
    
    @IsTest
    private static void fetchRemarkData(){              
        Remarks__x testRemark = new Remarks__x(Remark__c = 'this is a normal remark');
        Test.startTest();        
        AT_ABSActivitiesRemarksHandler.mockedTempRemarkList.add(testRemark);        
        String returnMessage = AT_ABSActivitiesController.fetchRemark('11176210672');
        System.assertEquals('this is a normal remark<br/>',returnMessage, '');
        Test.stopTest();
    }
    
    @IsTest
    private static void fetchRemarkThrowError(){       
        Test.startTest();        
        try {   
              String returnMessage = AT_ABSActivitiesController.fetchRemark('error');
        }
        catch(Exception e) {
            System.Assert(e.getMessage().contains('error'), '');
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void fetchWorkItemsData(){              
        WorkItems__x testWorkItem = new WorkItems__x(WorkItemLink__c = 'w://WorkItemLink', StatusFilter__c = 'Incomplete');
        Test.startTest();        
        AT_ABSActivitiesWorkItemsHandler.mockedTempWorkItemList.add(testWorkItem);
        String returnMessage = AT_ABSActivitiesController.fetchWorkItems('11176210672','Incomplete', 'AssociateId');
        System.assertEquals('w://WorkItemLink<br/>',returnMessage, '');
        Test.stopTest();
   }
   
	@IsTest
   	private static void fetchWorkItemsDataException(){              
        WorkItems__x testWorkItem = new WorkItems__x(WorkItemLink__c = 'w://WorkItemLink', StatusFilter__c = 'Incomplete');
        Test.startTest();        
        AT_ABSActivitiesWorkItemsHandler.mockedTempWorkItemList.add(testWorkItem);
        DmlException expectedException;
       	try{
        	String returnMessage = AT_ABSActivitiesController.fetchWorkItems('error','Incomplete', 'AssociateId');
       	}
       	catch(DmlException dmx) {
            expectedException = dmx;
            System.assert(expectedException.getMessage().contains('error'), '');
       	}
       	Test.stopTest();        
   } 
    
   private static ActivityWrapper createActivityWrapper(String clientId, String activityId, String associateId){
        
        ActivityWrapper getActivities = new ActivityWrapper();
        getActivities.activityID = activityId;
        getActivities.clientID = clientId;
        getActivities.agentName = 'AgentSmith';
        getActivities.associateID = associateId;
        getActivities.category = 'catID1';
        getActivities.customer = 'Cust1';
        getActivities.description = 'Descriptive';
        getActivities.dueDate = '12/30/2018';
        getActivities.status = 'Active';
        getActivities.lob = 'A';
        getActivities.modifiedDate = '06/14/2016';
        return getActivities;
    }
    
}
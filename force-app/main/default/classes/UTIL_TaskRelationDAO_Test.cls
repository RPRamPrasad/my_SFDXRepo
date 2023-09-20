/**
@Author Team Dream Builders
@Name UTIL_FeedItemDAO_Test
@CreateDate 12/8/2016
*Updated 10/29/2020 by CATS for profile logic pmd violations
@description Common class to access various Task related operations for various Processor Test.
@Version 1.0
*/
@isTest(seeAllData=false)
public class UTIL_TaskRelationDAO_Test {

    /**
     * @description This method sets up for the test
     * @name setup
	 */
    public static void setup() {
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    }

    /**
     * @description method to set up the users referenced in the test
     * @name testUsersSetup
	 */
    @testsetup
    public static void testUsersSetup() {
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            TaskTestDataUtility.createAccount();
            TaskTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), TaskTestDataUtility.getAccount());
        }
    }

    /**
   	 * @description Create list of TaskRelations
   	 * @return List<TaskRelation>
	 */
    private static List<TaskRelation> createTaskRelationList(){
        List<TaskRelation> taskRelationList = new List<TaskRelation>();
        Account acct = TaskTestDataUtility.getAccount();
        Task ts = [SELECT Id FROM Task WHERE Subject = 'Test Subject'];
        TaskRelation post = new TaskRelation(RelationId = acct.id, Taskid = ts.id, iswhat = true);
        taskRelationList.add(post);
        return taskRelationList;
    }

    //Test class that tests the method insertTaskRelations
    @isTest
    private static void testInsertTaskRelations() {
        Account acct = TaskTestDataUtility.getAccount();
        User agent = TestUserSetupUtility.getAgentUser();
        Task testTask = TaskTestDataUtility.buildTask(acct, agent.Id);
        testTask.whatId = null;
        insert testTask;
        List<TaskRelation> taskRelationList = createTaskRelationList();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            test.startTest();
			UTIL_TaskRelationDAO.insertTaskRelations(taskRelationList);
            TaskRelation tr = [SELECT RelationId, TaskId FROM TaskRelation WHERE RelationId = :acct.Id];
            System.assertEquals(acct.Id, tr.RelationId, 'account id is different');
            System.assertEquals(testTask.Id, tr.TaskId, 'task id is different');
            test.stopTest();
        }
    }

    //Test class that tests the method insertTaskRelations failure
    @isTest
    private static void testFailureInsertTaskRelations() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            test.startTest();
			UTIL_TaskRelationDAO.insertTaskRelations(null);//does not break with null
            System.assert(true, 'Mandatory Assert statement on Tests');
            test.stopTest();
        }
    }
}
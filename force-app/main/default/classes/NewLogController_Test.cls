@isTest
(SeeAllData=false)
public class NewLogController_Test {

    /**
     * @name testNewLogController
     * @description tests the functionality of the getLogSubject method of the NewLogController class
     */
    @isTest
    public static void testNewLogController(){
        UTIL_CaseTestData.setUpUsersForCase();
        User proxyUser = UTIL_CaseTestData.getAgentProxyUser();
        User sysAdminUser = UTIL_CaseTestData.getSysAdminUser();
        String taskSubject = 'Log Call Subject Test';
        Test.startTest();
        System.runAs(sysAdminUser){
        Task task = new Task();
        task.Subject = taskSubject;
        task.Status = 'Not Started';
        task.ActivityDate = Date.today();
        task.Priority = 'No';
        task.OwnerId = proxyUser.Id;
        insert task;
        Task createdTask = [SELECT Id, Subject FROM Task WHERE Subject =: taskSubject LIMIT 1];
        String retrivedSubject = NewLogController.getLogSubject(createdTask.Id); 
        System.assertEquals(createdTask.Subject, retrivedSubject, 'subject is different');    
        }
        Test.stopTest();
    }
  
}
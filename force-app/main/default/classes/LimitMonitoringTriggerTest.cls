@isTest
(seeAllData=false)
private class LimitMonitoringTriggerTest {

    private static String className1 = 'testclassName1';
    private static String className2 = 'testclassName2';
    private static Double threshold = 75.00;
    private static String transactionId1 = 'TID:12121212';
    private static String transactionId2 = 'TID:232323232';
    
    @isTest
    private static void testInsertTrigger(){
        Test.startTest();
        LimitMonitoringTestUtility.insertLMS();
       	List<Limit_Monitoring__c> lms = [SELECT Id, Class_Name__c, Threshold_Percentage__c, Limits__c, Transaction_Id__c, Number_of_Offenses__c FROM Limit_Monitoring__c];
        System.assert(lms.size() == 2, 'returned list size check');
        for(Limit_Monitoring__c lm : lms){
            System.assert(lm.Threshold_Percentage__c == threshold, 'threshold check');
            System.assert(lm.Transaction_Id__c == transactionId1, 'transaction id check');
            System.assert(lm.Number_of_Offenses__c == 2, 'number of offenses check');
            System.assert(lm.Class_Name__c == className1 || lm.Class_Name__c == className2 , 'class name check');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateTrigger(){
        Test.startTest();
        LimitMonitoringTestUtility.insertLMS();
        List<Limit_Monitoring__c> lms = [SELECT Id, Class_Name__c, Threshold_Percentage__c, Limits__c, Transaction_Id__c, Number_of_Offenses__c FROM Limit_Monitoring__c];
        System.assert(lms.size() == 2, 'returned list size check');
        for(Limit_Monitoring__c lm : lms){
            lm.Transaction_Id__c = transactionId2;
        }
        Database.upsert(lms, Limit_Monitoring__c.Class_Name__c, false);
        lms = [SELECT Id, Class_Name__c, Threshold_Percentage__c, Limits__c, Transaction_Id__c, Number_of_Offenses__c FROM Limit_Monitoring__c];
        System.assert(lms.size() == 2, 'upsert on classname check');
        for(Limit_Monitoring__c lm : lms){
            System.assert(lm.Number_of_Offenses__c == 4, 'number of offenses update check');
        }
        Test.stopTest();
    }
}
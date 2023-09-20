@isTest
(seeAllData=false)
private class LimitMonitorTest {

    private static String className = 'TestClassName';
    private static String methodName = 'testMethodName';
   
    @TestSetup
    private static void setup(){
        createMonitorCS(70);
    }

	@isTest    
    private static void testConstuctorWithoutMethodName(){
        Test.startTest();
        CS_Limit_Monitoring__c limitMonitorCS = CS_Limit_Monitoring__c.getValues(className);
        LimitMonitor lm = new LimitMonitor(limitMonitorCS);
        System.assert(lm.limitMonitorCS == limitMonitorCS, 'custom setting set check');
        System.assert(lm.className == limitMonitorCS.Apex_Class_Name__c, 'class name set check');
        System.assert(lm.threshold == limitMonitorCS.Limit_Threshold_Percentage__c , 'threshold level set check');
        Test.stopTest();
    }
    
    @isTest    
    private static void testConstuctorWithNull(){
        Test.startTest();
        LimitMonitor lm = new LimitMonitor(null);
        System.assert(lm.limitMonitorCS == null, 'custom setting set check');
        System.assert(lm.className == null, 'class name set check');
        Test.stopTest();
    }
    
    @isTest    
    private static void testMonitorMainMethodNoLimitsHit(){
        Test.startTest();
        CS_Limit_Monitoring__c limitMonitorCS = CS_Limit_Monitoring__c.getValues(className);
        LimitMonitor lm = new LimitMonitor(limitMonitorCS);
        lm.monitor();
        System.assert(lm.limitsHit.isEmpty(), 'limits hit check');
        Test.stopTest();
        List<Limit_Monitoring__c> lms = [SELECT Id, Class_Name__c, Threshold_Percentage__c, Limits__c, Transaction_Id__c, Number_of_Offenses__c FROM Limit_Monitoring__c];
        System.assert(lms.isEmpty(), 'record creation check');
    }
    
     @isTest    
    private static void testMonitorMainMethodLimitsHit(){
        Test.startTest();
        CS_Limit_Monitoring__c limitMonitorCS = CS_Limit_Monitoring__c.getValues(className);
        limitMonitorCS.Limit_Threshold_Percentage__c = 0;
        LimitMonitor lm = new LimitMonitor(limitMonitorCS);
        System.assert(lm.limitMonitorCS != null, 'limitMonitorCS check');
        System.assert(lm.limitMonitorCS.Monitor_Class__c, 'monitor class check');
        lm.monitor();
        System.assert(!lm.limitsHit.isEmpty(), 'limits hit check');
        Test.stopTest();
        List<Limit_Monitoring__c> lms = [SELECT Id, Class_Name__c, Threshold_Percentage__c, Limits__c, Transaction_Id__c, Number_of_Offenses__c FROM Limit_Monitoring__c];
        System.assert(lms.size() == 1, 'record creation check');
    }
    
    private static void createMonitorCS(Integer warningLevel){
        CS_Limit_Monitoring__c limitMonitorCS = new CS_Limit_Monitoring__c();
        limitMonitorCS.Apex_Class_Name__c = className;
        limitMonitorCS.Include_Aggregate_Queries__c = true;
        limitMonitorCS.Include_Callouts__c = true;
        limitMonitorCS.Include_CPU__c = true;
        limitMonitorCS.Include_DML__c = true;
        limitMonitorCS.Include_Email_Invocations__c = true;
        limitMonitorCS.Include_Find_Similar_Calls__c = true;
        limitMonitorCS.Include_Future_Calls__c = true;
        limitMonitorCS.Include_Heap_Size__c = true;
        limitMonitorCS.Include_Queries__c = true;
        limitMonitorCS.Include_Queue_Jobs__c = true;
        limitMonitorCS.Monitor_Class__c = true;
        limitMonitorCS.Name = className;
        limitMonitorCS.Print_Usage_To_Console__c = true;
        limitMonitorCS.Limit_Threshold_Percentage__c = warningLevel;
        insert limitMonitorCS;
    }

}
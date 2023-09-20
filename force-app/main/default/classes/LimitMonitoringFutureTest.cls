@isTest
(seeAllData=false)
public without sharing class LimitMonitoringFutureTest {
    
    @isTest
    private static void testFuture(){
        Test.startTest();
        String exMessage;
        try{
            LimitMonitoringFuture.handleLimitMonitoring(JSON.serialize(LimitMonitoringTestUtility.getLMS(), true));
        }catch(Exception ex){
            exMessage = ex.getMessage();
        }
        System.assert(Limits.getFutureCalls() == 1, 'Future calls is not 1');
        Test.stopTest();
        List<Limit_Monitoring__c> lms = [SELECT Id, Class_Name__c, Threshold_Percentage__c, Limits__c, Transaction_Id__c, Number_of_Offenses__c FROM Limit_Monitoring__c];
        System.assert(lms.size() == 2, 'upsert size');
    }
    
    @isTest
    private static void testFutureException(){
        Test.startTest();
        String exMessage;
        try{
            List<String> strings = new List<String>();
            strings.add('test');
            LimitMonitoringFuture.handleLimitMonitoring(JSON.serialize(strings, true));
        }catch(Exception ex){
            exMessage = ex.getMessage();
        }
        System.assert(Limits.getFutureCalls() == 1, 'Future calls is not 1');
        Test.stopTest();
        
    }
    
    @isTest
    private static void testFutureExceptionMissingRequiredField(){
        Test.startTest();
        String exMessage;
        try{
            List<Limit_Monitoring__c> lms = LimitMonitoringTestUtility.getLMS();
            lms.remove(1);
            for(Limit_Monitoring__c lm : lms){
                lm.Class_Name__c = null;
            }
            LimitMonitoringFuture.handleLimitMonitoring(JSON.serialize(lms, true));
        }catch(Exception ex){
            exMessage = ex.getMessage();
        }
        System.assert(Limits.getFutureCalls() == 1, 'Future calls is not 1');
        Test.stopTest();
        
    }
}
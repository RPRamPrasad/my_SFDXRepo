/**
Author Team ClubCar
Name - SCH_HandleSwcNoResponse_Test
@description Test class written for SignedWrittenConsent.cls
========================================================================================================================================+
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                10/12/2020              Initial Development
******************************************************************************************************************************************/
@isTest(SeeAlldata=false)
public with sharing class SCH_HandleSwcNoResponse_Test {
    public static Date todaysDate = System.today();
    public static Integer nextYear = todaysDate.Year() + 1;
    public static final String CRON_EXP = '0 0 0 1 6 ? '+nextYear;
    
    @testsetup
    private static void setUp() {
        CS_ApexBatchSize__c chatterMonitorCS = new CS_ApexBatchSize__c(Name='HandleSwcNoResponse',BatchSize__c=200);
        insert chatterMonitorCS;
    }

    // test method to validate Swc batch has been scheduled
    @isTest
    private static void testScheduleHandleSwcNoResponse() {
        String jobId = null;
        Test.startTest();
        jobId = System.schedule('Handle Swc No Response', CRON_EXP, new SCH_HandleSwcNoResponse());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];                            
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Exp mismatch');
        System.assertEquals(0, ct.TimesTriggered,'Cron Exp mismatch' );
        System.assertEquals(nextYear+'-06-01 00:00:00',String.valueOf(ct.NextFireTime),'Cron Next Fire Time mismatch');
    }
}
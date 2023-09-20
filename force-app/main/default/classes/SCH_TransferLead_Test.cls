/**
* Author : Golden Spikes Team
* Date Created : 10/26/2020
* @description testTransferLeadScheduleRollout : Test class for SCH_TransferLead Scheduler
*/
@isTest(seeAllData = false)
public class SCH_TransferLead_Test {

    @isTest private static void testTransferLeadScheduleRollout() {
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CSLeadBatch__c leadBatchCs = new CSLeadBatch__c(Name = 'Transfer_Lead_Batch', BatchEmailRecipient__c = 'home.et-fb-daily-batch-test.047j01@statefarm.com',
                    BatchSize__c = 30, QuerySize__c = 1000000, SenderDisplayName__c = 'Enterprise CRM Facebook Lead Update Summary',
                    QueryFilterStartDay__c = 0);
        insert leadBatchCs;

        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = systemUser.id);
        insert actOwnerCs;

        User transferLeadProcIdUser;
        System.runAs(sysAdminUser) {
            transferLeadProcIdUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('apiTLd'+UTIL_TestUsername_TEST.getTestUsername());
            insert transferLeadProcIdUser;
            insert new PermissionSetAssignment(
                AssigneeId = transferLeadProcIdUser.id,
                PermissionSetId = [Select id FROM PermissionSet WHERE Name = 'SF_CRM_EventLeadOppMgmt_PermSetPID' Limit 1].id
            );
        }

        Date todaysDate = System.today();
        //set it to a time which is after some time from now. Next year is an example
        Integer nextYear = todaysDate.Year() + 1;
        String nextStr = nextYear + '';
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String transferLeadCronExp = '0 0 0 1 8 ? ' + nextStr;

        Test.startTest();
        System.runAs(transferLeadProcIdUser) {
            SCH_TransferLead schedulerTransferLead = new SCH_TransferLead();
            //schedule the job
            String transferLeadJobId = System.schedule('Scheduler_TransferLead', transferLeadCronExp, schedulerTransferLead);
            List<CronTrigger> cronTriggerTest = [select id, TimesTriggered, CronExpression From CronTrigger where Id =: transferLeadJobId];
            //verify if the job was scheduled.
            system.assertEquals(true, cronTriggerTest!=null && cronTriggerTest.size() == 1, 'Failed Scheduling Transfer Lead Batch');
            //verify that job didnt run yet.
            System.assertEquals(0, cronTriggerTest.get(0).TimesTriggered,'Expected value is 0, but actual value is'+cronTriggerTest.get(0).TimesTriggered);
        }
        Test.stopTest();
    }
}
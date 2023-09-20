/**
* @author: Targaryen
* @owner Targaryen
* @name: AP_AccountContactRelationshipTrigger_Test
* @createdDate 04/04/2020
* @description The class will perform all backend activities related to ACR records insert or delete.
* @version 1.0
*/

@IsTest(seeAllData=false)
public class Batch_CleanupHouseholdRecord_Test {
    private static User systemUser;
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    
    /**
    * @description testDataSetup
    * @name: testDataSetup
    */ 
    public static void testDataSetup(){
        User systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser; 
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        System.runAs(systemUser){

            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
            insert objectBasedByPassTrigger;
        }   
    }

    /**
    * @description test Household Batch With All Orphan HH
    * @name: testHouseholdBatchWithAllOrphanHH
    */ 
    @isTest static void testHouseholdBatchWithAllOrphanHH(){
        testDataSetup();
   
        CS_HouseholdBatch__c hhBatchCS = new CS_HouseholdBatch__c(Name='EmailAndBatchDetails', BatchEmailRecipient__c='home.et-customerview-support.062i01@statefarm.com',StartDaysToCheck__c=3,
                                                                     EndDaysToCheck__c=2);
        insert hhBatchCS;
          
        List<Account> orphaneHHList = new List<Account>();
        Account hhRecordOrphan1 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45678', AllowHousehold__c = true);
        Account hhRecordOrphan2 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45827', AllowHousehold__c = true);
        Account hhRecordOrphan3 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '52682', AllowHousehold__c = true);
        orphaneHHList.add(hhRecordOrphan1);
        orphaneHHList.add(hhRecordOrphan2);
        orphaneHHList.add(hhRecordOrphan3);
        System.runAs(salesRoleHierarchy1.Agent){
            insert orphaneHHList;
        }
        Datetime dayBeforeTomorrow = Datetime.now().addDays(-3);
        
        for(Account orphHH : orphaneHHList){
            Test.setCreatedDate(orphHH.Id, dayBeforeTomorrow);
        }

        Test.startTest();    
        Batch_CleanupHouseholdRecord hhBatch = new Batch_CleanupHouseholdRecord(false); 
        Id jobId = DataBase.executeBatch(hhBatch,2000);        
        Test.stopTest();
       
        system.assertEquals(jobId != null,true, 'job failed');
    }
    
    /**
    * @description test Household Batch With One Orphan HH And One Single Member HH 
    * @name: testHouseholdBatchWithOneOrphanHHAndOneSingleMemberHH
    */ 
    @isTest static void testHouseholdBatchWithOneOrphanHHAndOneSingleMemberHH(){
        testDataSetup();
   
        CS_HouseholdBatch__c hhBatchCS = new CS_HouseholdBatch__c(Name='EmailAndBatchDetails', BatchEmailRecipient__c='home.et-customerview-support.062i01@statefarm.com',StartDaysToCheck__c=3,
                                                                     EndDaysToCheck__c=2);
        insert hhBatchCS;
        Account accRecord1 = new Account(FirstName='Batch',LastName='Job1',BillingAddressType__c='US',ClientIdentifier__c='IAMCLIENT1D');
        Account accRecord2 = new Account(FirstName='Batch',LastName='Job2',BillingAddressType__c='US',ClientIdentifier__c='IAMCLIENT2D');
        Account accRecord3 = new Account(FirstName='Batch',LastName='Job3',BillingAddressType__c='US',ClientIdentifier__c='IAMCLIENT3D');
        List<Account> acntList = new List<Account>();
        acntList.add(accRecord1);
        acntList.add(accRecord2);
        acntList.add(accRecord3);
        System.runAs(salesRoleHierarchy1.Agent){
            insert acntList;
        }
              
        List<Account> mixedHHList = new List<Account>();
        Account hhRecordOrphan1 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45678', AllowHousehold__c = true);
        Account hhRecordSingleMember = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45827', AllowHousehold__c = true);
        Account hhRecordNewSingleMember = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '52682', AllowHousehold__c = true);
        mixedHHList.add(hhRecordOrphan1);
        mixedHHList.add(hhRecordSingleMember);
        mixedHHList.add(hhRecordNewSingleMember);

        System.runAs(salesRoleHierarchy1.Agent){
            insert mixedHHList;
        }
        
        Datetime dayBeforeTomorrow = Datetime.now().addDays(-3);
        
        List<Account> mixedHHListData = [SELECT Id, createdDate, FinServ__SourceSystemId__c from Account Where RecordType.DeveloperName='IndustriesHousehold']; 
       
        Contact c1 =[Select Id from Contact where AccountId=:accRecord1.Id];
        Contact c2 =[Select Id from Contact where AccountId=:accRecord2.Id];
        Contact c3 =[Select Id from Contact where AccountId=:accRecord3.Id];
        
        AccountContactRelation acr1 = new AccountContactRelation(AccountId=hhRecordSingleMember.Id,ContactId=c1.Id,FinServ__PrimaryGroup__c = true);
        AccountContactRelation acr2 = new AccountContactRelation(AccountId=hhRecordNewSingleMember.Id,ContactId=c2.Id,FinServ__PrimaryGroup__c = true);
        AccountContactRelation acr3 = new AccountContactRelation(AccountId=hhRecordNewSingleMember.Id,ContactId=c3.Id,FinServ__PrimaryGroup__c = true);
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList.add(acr1);
        acrList.add(acr2);
        acrList.add(acr3);
        
        insert acrList;

        for(Account singleHH : mixedHHListData){
            if(singleHH.FinServ__SourceSystemId__c !='52682'){
                Test.setCreatedDate(singleHH.Id, dayBeforeTomorrow);
            }
        }

        Test.startTest();    
        Batch_CleanupHouseholdRecord hhBatch = new Batch_CleanupHouseholdRecord(false); 
        Id jobId = DataBase.executeBatch(hhBatch,2000);        
        Test.stopTest();
      
        system.assertEquals(jobId != null,true, 'job failed');
    }
    
    /**
    * @description test method to verify that the scheduler class is able to be scheduled properly 
    * @name: testSchedule
    */ 
    @isTest
    static void testSchedule() {        
        testDataSetup();
   
        CS_HouseholdBatch__c hhBatchCS = new CS_HouseholdBatch__c(Name='EmailAndBatchDetails', BatchEmailRecipient__c='home.et-customerview-support.062i01@statefarm.com',StartDaysToCheck__c=3,
                                                                     EndDaysToCheck__c=2, Batch_Size__c=2000);
        insert hhBatchCS;
        String sch = '0 0 0 15 3 ? 2099';
        String jobId = null;
      
        Test.startTest();
            SCH_HouseholdCleanup sh1 = new SCH_HouseholdCleanup();//schedule the job  
            jobId = System.schedule('Test', sch, sh1);            
		Test.stopTest();
            system.assertEquals(jobId != null,true, 'job failed');
     
    }
}

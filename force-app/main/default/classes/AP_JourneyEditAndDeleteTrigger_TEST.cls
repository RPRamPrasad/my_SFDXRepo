/****************************************************************************************
Name: AP_JourneyEditAndDeleteTrigger_TEST
Copyright © State Farm
=========================================================================================
* @description : Test class for Apex class AP_JourneyEditAndDeleteTrigger
Team: ClubCar
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  12/12/2019              Initial Development
******************************************************************************************/
@IsTest(SeeAllData = false)
public class AP_JourneyEditAndDeleteTrigger_TEST {
    
    //method to build journey record with the given parameter value
    private static Journey__c buildJourneyRecord() {
        Journey__c jny = new Journey__c(JourneyName__c='Journey1', BusinessLineCode__c = 'Auto',CategoryName__c = 'Corporate assigned',
                                        JourneyDescription__c='Jnydescription',CustomDemographicsInd__c = true,EffectiveDate__c = System.today(),
                                        ExpirationDate__c = System.today()+60, ApplicableStates__c = 'CO;CT;DE;DC', AppliestoAllStates__c = false,Type__c = 'Standard' );
        return jny;
    }
    
    //test method to delete master journey record which is having 4 child journey records
    @isTest
    private static void deleteMasterJourneyRecord(){
        Journey__c masterJourneyRecord = buildJourneyRecord();            
        insert masterJourneyRecord;
        Test.startTest();
        delete masterJourneyRecord;
        Test.stopTest();
        List<Journey__c> jrnyList = [Select id from Journey__c LIMIT 5];
        System.assertEquals(0, jrnyList.size(), 'Journeys were not deleted');
    }
    
    //test method to delete child journey record
    @isTest
    private static void deleteChildJourneyRecord(){
        Journey__c jrnyRecord = buildJourneyRecord();                  
        insert jrnyRecord;
        Journey__c childJrnyRecord = [Select id from Journey__c where MasterJourneyId__c != null Limit 1];
        try{
            Test.startTest();  
            delete childJrnyRecord;
            Test.stopTest();
        }
        catch(Exception ex){
            System.assert(ex.getMessage().contains(AP_JourneyEditAndDeleteTrigger.JOURNEY_EDITDELETE_ERRORMESSAGE), 'Journey delete exception was not generated'); 
        }
    }
    
    //test method to Bypass journey delete trigger
    @isTest
    private static void deleteJourneyRecordAfterTriggerBypass(){
        Journey__c jrnyRecord = buildJourneyRecord();
        insert jrnyRecord;
        CS001_ByPassTriggerGtoZ__c passObjectBasedTrigger = new CS001_ByPassTriggerGtoZ__c(Override_JourneyBeforeDelete__c = true);
        insert passObjectBasedTrigger;
        Journey__c parentJrnyRecord = [Select id from Journey__c where MasterJourneyId__c = null LIMIT 1];
        Test.startTest();
        delete parentJrnyRecord;
        Test.stopTest(); 
        System.assertEquals(4,[Select id, Name from Journey__c LIMIt 5].size(), 'Journey list size is not as expected');
    }
    
    //test method to check exception on journey delete
    @isTest
    private static void testJourneyDeleteException(){
        Test.startTest();
        AP_JourneyEditAndDeleteTrigger.processJourneysDelete(null);
        Test.stopTest();
        assertExceptionLog();  
        System.assert(true, 'Mandatory Assert statement on Tests');  
    }
    
    //test method to edit master journey record which is having 4 child journey records
    @isTest
    private static void editMasterJourneyRecord(){
        
        Journey__c masterJrnyRecord = buildJourneyRecord();                  
        insert masterJrnyRecord;        
        AP_JourneyProcessing.isAfterInsertTriggerFirstRun = true;
        masterJrnyRecord.CategoryName__c = 'Prospect customers';
        masterJrnyRecord.BusinessLineCode__c = 'Fire';
        masterJrnyRecord.JourneyName__c = 'UpdatedJourneyName';
        masterJrnyRecord.JourneyDescription__c = 'UpdatedJourneyDescription';
        Test.startTest();                
        update masterJrnyRecord;
        Test.stopTest(); 
        List<Journey__c> childJnyListAfterUpdate = [Select id,CategoryName__c,BusinessLineCode__c,JourneyName__c,JourneyDescription__c from Journey__c WHERE MasterJourneyId__c != null];
        System.assertEquals('Prospect customers', childJnyListAfterUpdate[0].CategoryName__c, 'CateoryName is not as expected');
        System.assertEquals('Fire', childJnyListAfterUpdate[1].BusinessLineCode__c, 'LOB is not as expected');
        System.assertEquals('UpdatedJourneyName', childJnyListAfterUpdate[2].JourneyName__c, 'JourneyName is not as expected');
        System.assertEquals('UpdatedJourneyDescription', childJnyListAfterUpdate[3].JourneyDescription__c, 'JourneyDescription is not as expected');        
        
    }
    
    //test method to edit child journey record
    @isTest
    private static void editChildJourneyRecord(){
        Journey__c jrnyRecord = buildJourneyRecord();                  
        insert jrnyRecord;
        AP_JourneyProcessing.isAfterInsertTriggerFirstRun = true;
        Journey__c childJrnyRecord = [Select id from Journey__c where MasterJourneyId__c != null Limit 1];
        try{
            childJrnyRecord.BusinessLineCode__c = 'Fire';
            Test.startTest();  
            update childJrnyRecord;
            Test.stopTest();
        }
        catch(Exception ex){
            System.assert(ex.getMessage().contains(AP_JourneyEditAndDeleteTrigger.JOURNEY_EDITDELETE_ERRORMESSAGE), 'Journey edit exception was not generated'); 
        }
    }
    
    //test method to Bypass journey edit trigger
    @isTest
    private static void editJourneyRecordAfterTriggerBypass(){
        Journey__c masterJrnyRecord = buildJourneyRecord();
        insert masterJrnyRecord;
        AP_JourneyProcessing.isAfterInsertTriggerFirstRun = true;
        CS001_ByPassTriggerGtoZ__c passObjectBasedTrigger = new CS001_ByPassTriggerGtoZ__c(Override_JourneyBeforeUpdate__c = true);
        insert passObjectBasedTrigger;
        masterJrnyRecord.CategoryName__c = 'Prospect customers';
        Test.startTest();
        update masterJrnyRecord;
        Test.stopTest();
        List<Journey__c> childJnyListAfterUpdate = [Select id,CategoryName__c,TargetGroupCode__c from Journey__c WHERE MasterJourneyId__c != null LIMIT 4];
        System.assertEquals('Corporate assigned',childJnyListAfterUpdate[0].CategoryName__c, 'Category Name is not as expected');
        System.assertEquals('01',childJnyListAfterUpdate[1].TargetGroupCode__c, 'Target Group Code is not as expected');
    }
    
    //test method to check exception on journey after update
    @isTest
    private static void testJourneyAfterUpdateException(){
        Test.startTest();
        AP_JourneyEditAndDeleteTrigger.processEditedJourneys(null,null);
        Test.stopTest();
        assertExceptionLog();  
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    
    /**
    * @description - method for checking expected exception log size
    */
    private static void assertExceptionLog() {
        List<ExceptionLog__c> exLog = [SELECT Id,class__c, exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_JourneyEditAndDeleteTrigger' LIMIT 2];           
        system.assertEquals(1,exLog.size(), 'Exception was not generated');   
    }
}

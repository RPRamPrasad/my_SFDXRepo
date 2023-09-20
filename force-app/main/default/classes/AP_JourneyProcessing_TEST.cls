/*******************************************************************************************************************
* Name: AP_JourneyProcessing_TEST 
Copyright © State Farm
====================================================================================================================
* @description : Test class written for code coverage for AP_JourneyProcessing class
Team: ClubCar
====================================================================================================================
History
-------
VERSION         AUTHOR      DATE                   DETAIL
1.0             ClubCar     10/01/2018             Initial Development
2.0             ClubCar     02/04/2019             Added Test Methods to test the create of dup Journey for CA, TX and NY
3.0             ClubCar     05/02/2019             Added Test Method to test the Targetgroupcode for Case Journeys
********************************************************************************************************************/
@IsTest(SeeAllData = false)
Private class AP_JourneyProcessing_TEST {
    private static User sysAdminUser;
    private static User corpMktingUser;
    
    /**
    * @method - setup
    * @description - setup method
    */
    public static void setup(){
        //create system Admin user and croporate marketing user to insert records
        Profile sysProfile = [Select Id from Profile where name = 'System Administrator' LIMIT 1];
        sysAdminUser = TestDataFactory_Journey.buildtestUser('remCmpMemSysAd@statefarm.com', sysProfile);
        Profile corpMktingProfile = [Select Id from Profile where name = '5.04 Corporate Marketing'];
        corpMktingUser = TestDataFactory_Journey.buildtestUser('corpMarketing@statefarm.com', corpMktingProfile);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(corpMktingUser);
    }
       
    //method to insert single journey record with selected states
    @isTest
    private static void insertJourneyRecord(){
        setup();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = false;
        journey.BusinessLineCode__c = 'Auto;General';
        journey.CategoryName__c = 'Corporate assigned';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            Journey__c parentJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,VendorCode__c,UserAlias__c,
                                           JourneyFundingID__c,TargetGroupCode__c,TimingTypeCode__c from Journey__c where MasterJourneyId__c = null];
            
            System.assertEquals(0,parentJrnyRecord.VendorCode__c,'Unexpected VendorCode');
            System.assertEquals(corpMktingUser.alias,parentJrnyRecord.UserAlias__c, 'Unexpected UserAlias__c');
            System.assertEquals(parentJrnyRecord.Name.right(6),parentJrnyRecord.JourneyFundingID__c, 'Unexpected JourneyFundingId');
            System.assertEquals('01',parentJrnyRecord.TargetGroupCode__c, 'Unexpected TargetGroupCode');
            System.assertEquals(1,parentJrnyRecord.TimingTypeCode__c, 'Unexpected TimingTypeCode');
            List<Journey__c> childJrnyList = [Select id,Name,JourneyName__c,JourneyFundingID__c,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                              JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,Journey_External_ID__c,
                                              EffectiveDate__c,ExpirationDate__c,TargetGroupCode__c,TimingTypeCode__c from Journey__c where MasterJourneyId__c != null];
            System.assertEquals(4, childJrnyList.size(), 'Unexpected JourneyListSize');
            for(Journey__c jrnyRec :childJrnyList){
                String jnYExternalIdTocheck = null;
                jnYExternalIdTocheck = parentJrnyRecord.Name.right(6) +'-'+ jrnyRec.StateCode__c;
                System.assertEquals(jnYExternalIdTocheck, jrnyRec.Journey_External_ID__c, 'Unexpected JourneyExternalId');
                System.assertEquals('Corporate assigned',jrnyRec.categoryName__c, 'Unexpected CategoryName');
                System.assert(jrnyRec.BusinessLineCode__c.contains('Auto') && jrnyRec.BusinessLineCode__c.contains('General'), 'Unexpected Business Line Code');
                System.assertEquals('Jnydescription',jrnyRec.JourneyDescription__c, 'Unexpected JourneyDescription');
                System.assertEquals(true,jrnyRec.CustomDemographicsInd__c, 'Unexpected CustomerDemographicsInd');
                System.assertEquals(System.today(),jrnyRec.EffectiveDate__c, 'Unexpected Effective Date');                
                System.assertEquals(System.today()+60,jrnyRec.ExpirationDate__c, 'Unexpected ExpirationDate');
                System.assertEquals('Journey1',jrnyRec.JourneyName__c, 'Unexpected JourneyName');
                System.assertEquals(0,jrnyRec.VendorCode__c,'Unexpected VendorCode');
                System.assertequals(parentJrnyRecord.Name.right(6),jrnyRec.JourneyFundingID__c, 'Unexpected Journey FundingId');
                System.assertequals(parentJrnyRecord.Name.right(6),jrnyRec.JourneyNumber__c, 'Unexpected JourneyNumber');                
                System.assertEquals('C',jrnyRec.CreatorRoleCode__c, 'Unexpected CreatorRoleCode');
                System.assertEquals('01',jrnyRec.TargetGroupCode__c, 'Unexpected TargetGroupCode');
                System.assertEquals(1,jrnyRec.TimingTypeCode__c, 'Unexpected TimingTypeCode');
                if('09'.equals(jrnyRec.StateCode__c)){
                    System.assert('DC'.equals(jrnyRec.StateCodemap__c), 'Unexpected StateCodeMap');                    
                }                         
            }    
        }
        Test.stopTest();
    }  
    
    //method to insert List of journey records with selected states
    @isTest
    private static void insertJourneyRecordsList(){
        setup();
        Test.startTest();
        System.runAs(corpMktingUser){
            List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c journey =new Journey__c();
            journey.JourneyName__c = 'Jny1';
            journey.ApplicableStates__c = 'AZ;AL;MO;MN';
            journey.AppliestoAllStates__c = false;
            journey.BusinessLineCode__c = 'General;Auto';
            journey.CategoryName__c = 'Prospect customers';
            journey.Type__c = 'Standard';
            journeyList.add(TestDataFactory_Journey.buildJourneyRecord(journey));
            Journey__c journey1 =new Journey__c();
            journey1.JourneyName__c = 'Jny2';
            journey1.ApplicableStates__c = 'CA';
            journey1.AppliestoAllStates__c = true;
            journey1.BusinessLineCode__c = 'Auto';
            journey1.CategoryName__c = 'Lead campaigns';
            journey1.Type__c = '  Xdate';
            journeyList.add(TestDataFactory_Journey.buildJourneyRecord(journey1));
            Journey__c journey2 =new Journey__c();
            journey2.JourneyName__c = 'Jny3';
            journey2.ApplicableStates__c = 'KS;NY;IL';
            journey2.AppliestoAllStates__c = false;
            journey2.BusinessLineCode__c = 'Auto;Home - Fire';
            journey2.CategoryName__c = 'Customer prospect campaigns';
            journey2.Type__c = 'Xdate';
            journeyList.add(TestDataFactory_Journey.buildJourneyRecord(journey2));            
            insert journeyList;
            List<Journey__c> parentJrnyList = [Select id,JourneyName__c,Name,VendorCode__c,UserAlias__c,TargetGroupCode__c,
                                               TimingTypeCode__c from Journey__c where MasterJourneyId__c = null];
            Journey__c parentJrnyRecord1;
            Journey__c parentJrnyRecord2;
            Journey__c parentJrnyRecord3; 

            AssignParentJrnyRecordWrapper assignParentWrapper = new AssignParentJrnyRecordWrapper();
            assignParentWrapper.parentJrnyList = parentJrnyList;
            assignParentWrapper.parentJrnyRecord1 = parentJrnyRecord1;
            assignParentWrapper.parentJrnyRecord2 = parentJrnyRecord2;
            assignParentWrapper.parentJrnyRecord3 = parentJrnyRecord3;
            assignParentJrnyRecord(assignParentWrapper);
            
            parentJrnyRecord1 = assignParentWrapper.parentJrnyRecord1;
            parentJrnyRecord2 = assignParentWrapper.parentJrnyRecord2;
            parentJrnyRecord3 = assignParentWrapper.parentJrnyRecord3;
            
            List<Journey__c> childJrnyList = [Select id,Name,JourneyName__c,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,JourneyNumber__c,
                                              CreatorRoleCode__c,CustomDemographicsInd__c,JourneyFundingID__c,EffectiveDate__c,ExpirationDate__c,TargetGroupCode__c,TimingTypeCode__c 
                                              from Journey__c where   MasterJourneyId__c != null];          
            List<Journey__c> jrny1List = new List<Journey__c>();
            List<Journey__c> jrny2List = new List<Journey__c>();
            List<Journey__c> jrny3List = new List<Journey__c>();
            for(Journey__c jrny : childJrnyList){
                AddingJourneyWrapper addJnyWrap = new AddingJourneyWrapper();
                addJnyWrap.jrny = jrny;
                addJnyWrap.parentJrnyRecord1 = parentJrnyRecord1;
                addJnyWrap.parentJrnyRecord2 = parentJrnyRecord2;
                addJnyWrap.parentJrnyRecord3 = parentJrnyRecord3;
                addJnyWrap.jrny3List = jrny3List;
                addingJourneyToJourneyList(jrny1List, jrny2List, addJnyWrap);
            }
            System.assertEquals(63,childJrnyList.Size(), 'Unexpected JourenyList Size');
            System.assertEquals(4,jrny1List.Size(), 'Unexpected JourenyList Size');
            System.assertEquals(55,jrny2List.Size(), 'Unexpected JourenyList Size');
            System.assertEquals(4,jrny3List.Size(), 'Unexpected JourenyList Size');          
        }
        Test.stopTest();
    }

    /**
     * @description AddingJourneyWrapper
     */
    private class AddingJourneyWrapper{
        Journey__c jrny;
        Journey__c parentJrnyRecord1;
        Journey__c parentJrnyRecord2;
        Journey__c parentJrnyRecord3;
        List<Journey__c> jrny3List;
    }

    private static void addingJourneyToJourneyList(List<Journey__c> jrny1List, List<Journey__c> jrny2List, AddingJourneyWrapper addWrap){
        if (addWrap.jrny.JourneyName__c == 'Jny1') {
            jrny1List.add(addWrap.jrny);
            System.assertEquals('Prospect customers',addWrap.jrny.categoryName__c, 'Unexpected CategoryName');
            System.assert(addWrap.jrny.BusinessLineCode__c.contains('Auto') && addWrap.jrny.BusinessLineCode__c.contains('General'), 'Unexpected BusinessLineCode');
            System.assertEquals(System.today(),addWrap.jrny.EffectiveDate__c, 'Unexpected EffectiveDate');                
            System.assertEquals(System.today()+60,addWrap.jrny.ExpirationDate__c, 'Unexpected ExpirationDate');
            System.assertEquals(1,addWrap.jrny.TimingTypeCode__c, 'Unexpected TimingTypeCode');
            System.assertequals(addWrap.parentJrnyRecord1.Name.right(6),addWrap.jrny.JourneyFundingID__c, 'Unexpected JourneyFundingId');
            System.assertequals(addWrap.parentJrnyRecord1.Name.right(6),addWrap.jrny.JourneyNumber__c, 'Unexpected JourneyNumber');
        }
        else if (addWrap.jrny.JourneyName__c == 'Jny2') {
            jrny2List.add(addWrap.jrny);
            System.assertEquals('Lead campaigns',addWrap.jrny.categoryName__c, 'Unexpected CategoryName');
            System.assertEquals('Auto',addWrap.jrny.BusinessLineCode__c, 'Unexpected BusinessLineCode');
            System.assertEquals(System.today(),addWrap.jrny.EffectiveDate__c, 'Unexpected EffectiveDate');                
            System.assertEquals(System.today()+60,addWrap.jrny.ExpirationDate__c, 'Unexpected ExpirationDate');
            System.assertEquals(2,addWrap.jrny.TimingTypeCode__c, 'Unexpected TimingTypeCode');
            System.assertequals(addWrap.parentJrnyRecord2.Name.right(6),addWrap.jrny.JourneyFundingID__c, 'Unexpected Journey FundingId');
            System.assertequals(addWrap.parentJrnyRecord2.Name.right(6),addWrap.jrny.JourneyNumber__c, 'Unexpected JourneyNumber');
        } 
        else {
            addWrap.jrny3List.add(addWrap.jrny);
            System.assertEquals('Customer prospect campaigns',addWrap.jrny.categoryName__c, 'Unexpected CategoryName');
            System.assert(addWrap.jrny.BusinessLineCode__c.contains('Auto') && addWrap.jrny.BusinessLineCode__c.contains('Home - Fire'), 'Unexpected BusinessLineCode');
            System.assertEquals(System.today(),addWrap.jrny.EffectiveDate__c, 'Unexpected EffectiveDate');                
            System.assertEquals(System.today()+60,addWrap.jrny.ExpirationDate__c, 'Unexpected ExpirationDate');
            System.assertEquals(2,addWrap.jrny.TimingTypeCode__c, 'Unexpected TimingTypeCode');
            System.assertequals(addWrap.parentJrnyRecord3.Name.right(6),addWrap.jrny.JourneyFundingID__c, 'Unexpected JourneyFundingId');
            System.assertequals(addWrap.parentJrnyRecord3.Name.right(6),addWrap.jrny.JourneyNumber__c, 'Unexpected JourneyNumber');    
        }
    }

/**
* @description AssignParentJrnyRecordWrapper
*/
 private class AssignParentJrnyRecordWrapper{
    List<Journey__c> parentJrnyList;
    Journey__c parentJrnyRecord1;
    Journey__c parentJrnyRecord2;
    Journey__c parentJrnyRecord3;
 }

 /**
  * @description assignParentJrnyRecord
  * @param assignWrapper
  */
    private static void assignParentJrnyRecord(AssignParentJrnyRecordWrapper assignWrapper){
        for(Journey__c jrny : assignWrapper.parentJrnyList){
            if (jrny.JourneyName__c == 'Jny1') {                    
                System.assertEquals(0,jrny.VendorCode__c, 'Unexpected VendorCode');
                System.assertEquals(corpMktingUser.alias,jrny.UserAlias__c, 'Unexpected UserAlias__c');
                System.assertEquals('00',jrny.TargetGroupCode__c, 'Unexpected TargetGroupCode');
                System.assertEquals(1,jrny.TimingTypeCode__c, 'Unexpected TimingTypeCode');
                assignWrapper.parentJrnyRecord1 = jrny;
            }
            else if (jrny.JourneyName__c == 'Jny2') {                    
                System.assertEquals(0,jrny.VendorCode__c, 'Unexpected VendorCode');
                System.assertEquals(corpMktingUser.alias,jrny.UserAlias__c, 'Unexpected UserAlias__c');
                System.assertEquals('01',jrny.TargetGroupCode__c, 'Unexpected TargetGroupCode');
                assignWrapper.parentJrnyRecord2 = jrny;
            }
            
            else {                    
                System.assertEquals(0,jrny.VendorCode__c, 'Unexpected VendorCode');
                System.assertEquals(corpMktingUser.alias,jrny.UserAlias__c, 'Unexpected UserAlias__c');
                System.assertEquals('00',jrny.TargetGroupCode__c, 'Unexpected TargetGroupCode');
                System.assertEquals(2,jrny.TimingTypeCode__c, 'Unexpected TimingTypeCode');
                assignWrapper.parentJrnyRecord3 = jrny;
            }
        }
    }

    //method to insert single journey record with Applies to All States set to true
    @isTest
    private static void insertJrnyRecordAppliestoAllStatesTrue(){
        setup();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = true;
        journey.BusinessLineCode__c = 'Auto';
        journey.CategoryName__c = 'Lead campaigns';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){                       
            insert jrnyRecord;
            Journey__c parentJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,VendorCode__c,UserAlias__c,
                                           JourneyFundingID__c,TargetGroupCode__c,ApplicableStates__c,TimingTypeCode__c from Journey__c where MasterJourneyId__c = null];
            System.assertEquals(null,parentJrnyRecord.ApplicableStates__c, 'ApplicableStates is not null');
            System.assertEquals(0,parentJrnyRecord.VendorCode__c, 'Unexpected VendorCode');
            System.assertEquals(corpMktingUser.alias,parentJrnyRecord.UserAlias__c,'Unexpected UserAlias__c');            
            List<Journey__C> childJrnyList = [Select id,JourneyName__c,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                              JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,JourneyFundingID__c,EffectiveDate__c,ExpirationDate__c,TargetGroupCode__c,
                                              TimingTypeCode__c,Journey_External_ID__c from Journey__c where MasterJourneyId__c != null];                        
            for(Journey__c jrnyRec :childJrnyList){
                String jnyExternalIdTocheck = null;
                jnyExternalIdTocheck = parentJrnyRecord.Name.right(6) +'-'+ jrnyRec.StateCode__c;
                System.assertEquals(jnyExternalIdTocheck,jrnyRec.Journey_External_ID__c, 'Unexpected Journey ExternalId');
                System.assertEquals(jrnyRec.categoryName__c,'Lead campaigns', 'Unexpected CategoryName');
                System.assertEquals('Auto',jrnyRec.BusinessLineCode__c, 'Unexpected BusinessLineCode');
                System.assertEquals('Jnydescription',jrnyRec.JourneyDescription__c, 'Unexpected JourneyDescription');
                System.assertEquals(true,jrnyRec.CustomDemographicsInd__c, 'Unexpected CustomerDemographicsInd');
                System.assertEquals(System.today(),jrnyRec.EffectiveDate__c, 'Unexpected EffectiveDate');
                System.assertEquals(System.today()+60,jrnyRec.ExpirationDate__c, 'Unexpected ExpirationDate');
                System.assertEquals('Journey1',jrnyRec.JourneyName__c, 'Unexpected JourneyName');
                System.assertEquals(0,jrnyRec.VendorCode__c, 'Unexpected VendorCode');
                System.assertequals(parentJrnyRecord.Name.right(6),jrnyRec.JourneyFundingID__c, 'Unexpected JourneyFundingId');
                System.assertequals(parentJrnyRecord.Name.right(6),jrnyRec.JourneyNumber__c, 'Unexpected JourneyNumber');                          
            }
            List<String> caList = new List<String>();
            List<String> txList = new List<String>();
            List<String> nyList = new List<String>();
            for(Journey__c jrnyRec :childJrnyList){
                if(jrnyRec.StateCodemap__c == 'CA'){
                    caList.add(jrnyRec.StateCodemap__c);                   
                }
                else if(jrnyRec.StateCodemap__c == 'TX'){
                    txList.add(jrnyRec.StateCodemap__c);                    
                }
                else if(jrnyRec.StateCodemap__c == 'NY'){
                    nyList.add(jrnyRec.StateCodemap__c);
                }
            }
            System.assertEquals(55,childJrnyList.size(), 'Unexpected JourenyList Size');
            System.assertEquals(3,caList.size(), 'Unexpected JourenyList Size');
            System.assertEquals(2,txList.size(), 'Unexpected JourenyList Size');
            System.assertEquals(2,nyList.size(), 'Unexpected JourenyList Size');                        
        }
        Test.stopTest();
    }   
    //method to insert single journey record with selected states for duplicate state codes
    @isTest
    private static void insertJourneyRecordWithDuplicateStateCodes(){
        setup();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CA;TX;NY';
        journey.AppliestoAllStates__c = false;
        journey.BusinessLineCode__c = 'Auto;General';
        journey.CategoryName__c = 'Corporate assigned';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;                                 
            List<Journey__c> querychildJrnyList = [Select id,Name,JourneyName__c,JourneyFundingID__c,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                                   JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,Journey_External_ID__c,
                                                   EffectiveDate__c,ExpirationDate__c,TargetGroupCode__c,TimingTypeCode__c from Journey__c where masterjourneyid__c != null];
            List<String> caList = new List<String>();
            List<String> txList = new List<String>();
            List<String> nyList = new List<String>();            
            System.assertEquals(7, querychildJrnyList.size(), 'Unexpected JourenyList Size');                       
            for(Journey__c jrnyRec :querychildJrnyList){
                if(jrnyRec.StateCodemap__c == 'CA'){
                    caList.add(jrnyRec.StateCodemap__c);                   
                }
                else if(jrnyRec.StateCodemap__c == 'TX'){
                    txList.add(jrnyRec.StateCodemap__c);                    
                }
                else if(jrnyRec.StateCodemap__c == 'NY'){
                    nyList.add(jrnyRec.StateCodemap__c);
                }
            }
            System.assertEquals(3,caList.size(), 'Unexpected ListSize');
            System.assertEquals(2,txList.size(), 'Unexpected ListSize');
            System.assertEquals(2,nyList.size(), 'Unexpected ListSize');            
        }
        Test.stopTest();
    }
    
    //method to test targetgroupcode for case journeys.
    @isTest
    private static void insertJourneyRecordWithCategorynameCases(){
        setup();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = false;
        journey.BusinessLineCode__c = 'Auto';
        journey.CategoryName__c = 'Cases';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            List<Journey__c> caseJrnyList = [Select categoryName__c, TargetGroupCode__c from Journey__c Limit 5];            
            for(Journey__c jrnyRec :caseJrnyList){
                System.assertEquals('Cases',jrnyRec.categoryName__c, 'Unexpected CategoryName');
                System.assertEquals('02',jrnyRec.TargetGroupCode__c, 'Unexpected TargetGroupCode');                                       
            }    
        }
        Test.stopTest();
    }    
    
    //method to Bypass trigger
    @isTest
    private static void insertJourneyRecordAfterTriggerBypass(){
        setup();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c= true);
        insert passTriggerAll;
        CS001_ByPassTriggerGtoZ__c passObjectBasedTrigger = new CS001_ByPassTriggerGtoZ__c( Override_JourneyAfterInsert__c=true);
        insert passObjectBasedTrigger;
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = false;
        journey.BusinessLineCode__c = 'General;Auto';
        journey.CategoryName__c = 'Corporate assigned;Prospect customers';
        journey.Type__c = 'Xdate';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            System.assertEquals(1,[Select id, Name from Journey__c Where MasterJourneyId__c = null].size(), 'Unexpected ListSize');			            
        }
        Test.stopTest();        
    }
    //test method to check exceptions
    @isTest
    private static void insertJourneyWithException(){             
        Test.startTest();   
        AP_JourneyProcessing.processJourneyStates(null);
        HLPR_JourneyProcessing.populateJourneyNonUIFields(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,name, class__c, exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_JourneyProcessing'];           
        system.assertEquals(2,exLog.size(), 'Unexpected exceptionLogSize');     
    }
        
}
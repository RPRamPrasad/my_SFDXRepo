/***************************************************************************************************************************
Name: AP_JourneyStepProcessing_TEST 
Copyright © State Farm
============================================================================================================================
Purpose:
-------
@description Test class written for code coverage for AP_JourneyStepProcessing class
Team: ClubCar
============================================================================================================================
History
-------
VERSION         AUTHOR      DATE                   DETAIL
1.0             ClubCar     10/11/2018             Initial Development
2.0             ClubCar     02/04/2019             Added Test Methods to Test the create of dup Journeysteps for CA,TX and NY
                                                    and test populating Journey ExternalId on Journey Step
3.0             ClubCar     03/04/2019             Added test method for type Task
4.0             ClubCar     05/02/2019             Added assertion to test the Step Type Code populated for Task Journey Step
5.0             Incognito   06/30/2022             Refactor to remove duplicate code
*****************************************************************************************************************************/
@IsTest(SeeAllData = false)
Private class AP_JourneyStepProcessing_TEST {
    private static User sysAdminUser;
    private static User corpMktingUser;
    private static final String SELECT_ID = 'select Id';      
    private static string querystringForLeadMessage='';
    private static string dynamicQuery='';
    private static string dynamicQuery1='';
    private static final String QUERY_DELIMETER = ',';
    private static list<CMOpportunityStartJourneyMapping__mdt> mappingForAccountMessagetoJourneyStep = [SELECT Id, MappingType__c, SourceField__c, TargetField__c
                                                                                                        FROM CMOpportunityStartJourneyMapping__mdt  WHERE MappingType__c = 'JourneyStepToAccountMessage' and SourceField__c != 'StateCode__c'];    
    /**
    * @method - setup
    * @description - setup method
    */
    public static void setup(){
        //create system Admin user and croporate marketing user to insert records
        List<User> users = TestDataFactory_Journey.seupAdminAndCorporateUser();
        sysAdminUser = users.get(0);
        corpMktingUser = users.get(1);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(corpMktingUser);
    }
    
    //method to build journey steps record with the given parameter value
    private static Journey_Step__c buildJourneyStepsRecord(Journey_Step__c sampleJnySteps) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = sampleJnySteps.JourneyID__c ,ContactMethodName__c = sampleJnySteps.ContactMethodName__c,Cost__c= '0.28', MailClassCode__c = sampleJnySteps.MailClassCode__c,JourneyNumber__c = '224489',
                                                      VendorCode__c = 0,CustomGreetingText__c='Hello, How are you',GiveawayOptionCode__c='b',GreetingCode__c='Hi',
                                                      LetterName__c ='New Letter',MediaTypeFilterText__c='This Text',PhotoOptionCode__c='A',PreferenceObjectID__c=123344,    SatelliteOfficeInd__c=false,Script__c='Description',StaffEmailID__c='Email',
                                                      StepTypeCode__c=1,TaskActionCode__c='B',TaskCategoryID__c=23433534,TaskHighPriorityInd__c=false,JourneyStepID__c=sampleJnySteps.JourneyStepID__c);
        return jnyStep;
    }
    
    //method to insert single journey record with selected states and a journey step record
    @isTest
    private static void insertJourneyStepRecordwithSelectedStatesJourney(){
        setup();
        Test.startTest();
        System.runAs(sysAdminUser){
            Journey__c journey =new Journey__c();
            journey.JourneyName__c = 'Journey1';
            journey.ApplicableStates__c = 'CO;CT;DE;DC';
            journey.AppliestoAllStates__c = false;
            journey.BusinessLineCode__c = 'Auto;General';
            journey.CategoryName__c = 'Corporate assigned';
            journey.Type__c = 'Standard';
            Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);                  
            insert jrnyRecord;
            Journey__c parentJrnyRecord = [Select id,JourneyName__c,Name,VendorCode__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];
            Journey_Step__c jnyStep1 = new Journey_Step__c();
            jnyStep1.JourneyID__c = jrnyRecord.id;
            jnyStep1.ContactMethodName__c = 'Mailing';
            jnyStep1.MailClassCode__c = '1';
            jnyStep1.JourneyStepID__c = 1;              
            Journey_step__c jnyStep = buildJourneyStepsRecord(jnyStep1);
            insert jnyStep;
            
            String queryString = ', DaysNum__c' +', JourneyName__c' +',ExternalJourneyStepIdentifier__c'+',JourneyID__r.Journey_External_ID__c' 
            + ', BusinessLineCode__c' +', CategoryName__c' +', Journey_External_ID__c'+', JourneyID__r.Statecode__c'+', Statecode__c'+', JourneyID__c'+', JourneyID__r.id' 
            +', JourneyID__r.MasterJourneyId__c' +', JourneyID__r.JourneyName__c' +', JourneyID__r.BusinessLineCode__c' +', JourneyID__r.CategoryName__c'+' From Journey_Step__c' ; 
            List<Journey_Step__c> jnystepsList = queryForJourney(queryString);
            List<Journey_Step__c> childJnyStepList = new List<Journey_Step__c>();
            
            Journey_Step__c parentJrnyStepRecord;
            for(Journey_Step__c jrnyStep : jnystepsList){
                if(jrnyStep.JourneyID__r.MasterJourneyId__c == null){
                    System.assertEquals(jrnyStep.JourneyID__r.JourneyName__c,jrnyStep.JourneyName__c, 'Unexpected JourneyName');
                    System.assertEquals(parentJrnyRecord.JourneyFundingID__c,jrnyStep.Bundle_ID__c, 'Unexpected BundleId');            
                    System.assertEquals(jrnyStep.JourneyID__r.BusinessLineCode__c,jrnyStep.BusinessLineCode__c, 'Unexpected BusinessLineCode');
                    System.assertEquals(jrnyStep.JourneyID__r.CategoryName__c,jrnyStep.CategoryName__c, 'Unexpected CategoryName');
                    parentJrnyStepRecord = jrnyStep;
                }      
                else if(jrnyStep.JourneyID__r.MasterJourneyId__c != null){
                    childJnyStepList.add(jrnyStep);                 
                    System.assertEquals(jrnyStep.JourneyID__r.Journey_External_ID__c + '-' +jrnyStep.JourneyStepID__c,jrnyStep.ExternalJourneyStepIdentifier__c, 'Unexpected ExternalJourneyStepIdentifier');
                    System.assertEquals(jrnyStep.JourneyID__r.Journey_External_ID__c,jrnyStep.Journey_External_ID__c, 'Unexpected JourneyExternalId');
                    System.assertEquals(jrnyStep.JourneyID__r.Statecode__c,jrnyStep.Statecode__c, 'Unexpected StateCode');
                    System.assertEquals(jrnyStep.JourneyID__r.id,jrnyStep.JourneyID__c, 'Unexpected JourneyId');
                }               
            }
            for(Journey_Step__c journeyStep : childJnyStepList ){
                for(CMOpportunityStartJourneyMapping__mdt metadataMapping : mappingForAccountMessagetoJourneyStep){                       
                    System.assertEquals(journeyStep.get(metadataMapping.SourceField__c), parentJrnyStepRecord.get(metadataMapping.SourceField__c), 'Unexpected');
                }
            }
            System.assertEquals(4, childJnyStepList.size(), 'Unexpected JourneyStepListSize');
        }
        Test.stopTest();
    }
    
    //Test method to verify Journey Step insert for Type Mailer and then type Task
    @isTest
    private static void insertJourneyStepTypeTaskAndMailer () {
        setup();
        Test.startTest();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = false;
        journey.BusinessLineCode__c = 'Auto;General';
        journey.CategoryName__c = 'Prospect customers';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        System.runAs(sysAdminUser){            
            insert jrnyRecord;
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c= true);
            insert passTriggerAll;  
            System.runAs(corpMktingUser) { 
                Journey_Step__c jnyStep = new Journey_Step__c();
                jnyStep.JourneyID__c = jrnyRecord.id;
                jnyStep.ContactMethodName__c = 'Mailing';
                jnyStep.MailClassCode__c = '1';
                jnyStep.JourneyStepID__c = 1;  
                Journey_step__c jrnyStepMailer = buildJourneyStepsRecord(jnyStep);
                insert jrnyStepMailer;
            }
            PassTriggerAll.Override_All__c = false;
            update PassTriggerAll;
        }
            System.runAs(corpMktingUser) { 
            Journey_Step__c jnyStep = new Journey_Step__c();
            jnyStep.JourneyID__c = jrnyRecord.id;
            jnyStep.ContactMethodName__c = 'Call';
            jnyStep.MailClassCode__c = '1';
            jnyStep.JourneyStepID__c = null;  
            Journey_step__c jrnyStepTask = buildJourneyStepsRecord(jnyStep);
            jrnyStepTask.Script__c = 'Call Mike';
            jrnyStepTask.LetterName__c = 'Send Letter';
            jrnyStepTask.DaysNum__c = 150;
            CMP_JourneyStepTask.processTaskJnyStep(jrnyStepTask);
            }
            
            List<Journey_Step__c> insertedJnyStepList = [Select id, JourneyStepID__c, ContactMethodName__c, DaysNum__c, Script__c, LetterName__c,steptypecode__c from Journey_Step__c where ContactMethodName__c = 'Call'];
            System.assertEquals(5, insertedJnyStepList.size(), 'Unexpected JourneyStepListSize');
            for(Journey_Step__c taskJrnyStep : insertedJnyStepList){
                System.assertEquals('Call', taskJrnyStep.ContactMethodName__c, 'Unexpected ContactMethodName');
                System.assertEquals('Call Mike', taskJrnyStep.Script__c, 'Unexpected Script');
                System.assertEquals('Send Letter', taskJrnyStep.LetterName__c, 'Unexpected LetterName');
                System.assertEquals(2, taskJrnyStep.JourneyStepID__c, 'Unexpected JourneyStepId');
                System.assertEquals(150, taskJrnyStep.DaysNum__c, 'Unexpected DaysNum');
                System.assertEquals(3, taskJrnyStep.steptypecode__c, 'Unexpected StepTypeCode');
            }
        Test.stopTest();
    }   
    
    //method to insert list of journey steps
    @isTest
    private static void insertJourneyStepsListWithSelectedStatesJourney(){
        setup();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = false;
        journey.BusinessLineCode__c = 'Auto;General';
        journey.CategoryName__c = 'Prospect customers';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){       
            insert jrnyRecord;
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyStep = new Journey_Step__c();
            jnyStep.JourneyID__c = jrnyRecord.id;
            jnyStep.ContactMethodName__c = 'Mailing';
            jnyStep.MailClassCode__c = '1';
            jnyStep.JourneyStepID__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep));
            Journey_Step__c jnyStep1 = new Journey_Step__c();
            jnyStep1.JourneyID__c = jrnyRecord.id;
            jnyStep1.ContactMethodName__c = 'Mailing';
            jnyStep1.MailClassCode__c = '1';
            jnyStep1.JourneyStepID__c = 2;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep1));
            Journey_Step__c jnyStep2 = new Journey_Step__c();
            jnyStep2.JourneyID__c = jrnyRecord.id;
            jnyStep2.ContactMethodName__c = 'Mailing';
            jnyStep2.MailClassCode__c = '1';
            jnyStep2.JourneyStepID__c = 3;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep2));
            Journey_Step__c jnyStep3 = new Journey_Step__c();
            jnyStep3.JourneyID__c = jrnyRecord.id;
            jnyStep3.ContactMethodName__c = 'Mailing';
            jnyStep3.MailClassCode__c = '1';
            jnyStep3.JourneyStepID__c = 4;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep3));            
            insert jnystepsList;
            
            string queryString = ', DaysNum__c' +', JourneyName__c' +',ExternalJourneyStepIdentifier__c'+',JourneyID__r.Journey_External_ID__c' 
            + ', BusinessLineCode__c' +', CategoryName__c' +', Journey_External_ID__c'+', JourneyID__r.Statecode__c'+', Statecode__c'+', JourneyID__c'+', JourneyID__r.id' +', JourneyID__r.MasterJourneyId__c' +' From Journey_Step__c' ;
            List<Journey_Step__c> jrnystepsList = queryForJourney(queryString);
            List<Integer> journeyCounts = getJourneyCounts(jrnystepsList);
         
            System.assertEquals(4, journeyCounts.get(0), 'Unexpected JourneyStepListSize'); 
            System.assertEquals(16, journeyCounts.get(1), 'Unexpected JourneyStepListSize');            
        }
        Test.stopTest();
    }
    //method to insert list of journey steps with Applies to all states
    @isTest
    private static void insertJourneyStepsListWithAppliestoAllStates(){
        setup();
        Journey__c journey =new Journey__c();
        journey.JourneyName__c = 'Journey1';
        journey.ApplicableStates__c = 'CO;CT;DE;DC';
        journey.AppliestoAllStates__c = true;
        journey.BusinessLineCode__c = 'Auto;General';
        journey.CategoryName__c = 'Prospect customers';
        journey.Type__c = 'Standard';
        Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(journey);
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            Journey_Step__c jnyStep = new Journey_Step__c();
            jnyStep.JourneyID__c = jrnyRecord.id;
            jnyStep.ContactMethodName__c = 'Mailing';
            jnyStep.MailClassCode__c = '1';
            jnyStep.JourneyStepID__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep));
            Journey_Step__c jnyStep1 = new Journey_Step__c();
            jnyStep1.JourneyID__c = jrnyRecord.id;
            jnyStep1.ContactMethodName__c = 'Mailing';
            jnyStep1.MailClassCode__c = '1';
            jnyStep1.JourneyStepID__c = 2;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep1));           
            insert jnystepsList;
            
            String queryString = ', DaysNum__c' +', JourneyName__c' +',ExternalJourneyStepIdentifier__c'+',JourneyID__r.Journey_External_ID__c' 
                + ', BusinessLineCode__c' +', CategoryName__c' +', Journey_External_ID__c'+', JourneyID__r.Statecode__c'+', Statecode__c'+', JourneyID__c'+', JourneyID__r.id' +', JourneyID__r.MasterJourneyId__c' +' From Journey_Step__c' ;
            List<Journey_Step__c> jrnystepsList = queryForJourney(queryString);
            List<Journey_Step__c> childJnyStepList = new List<Journey_Step__c>();
            List<Journey_Step__c> parentJnyStepList = new List<Journey_Step__c>(); 
            for(Journey_Step__c jrnyStep : jrnystepsList){
                if(jrnyStep.JourneyID__r.MasterJourneyId__c == null){
                    parentJnyStepList.add(jrnyStep);
                }
                else if(jrnyStep.JourneyID__r.MasterJourneyId__c != null){
                    childJnyStepList.add(jrnyStep);
                }
            }    
            System.assertEquals(2, parentJnyStepList.size(), 'Unexpected JourneyStepListSize');          
            System.assertEquals(110, childJnyStepList.size(), 'Unexpected JourneyStepListSize');
        }
        Test.stopTest(); 
    }
    //method to insert journey and journey step list
    @isTest
    private static void insertJourneyandJourneyStepsList(){
        setup();
        Test.startTest();
        System.runAs(corpMktingUser){
            List<Journey__c> journeyList=new List<Journey__c>();
            Journey__c journey =new Journey__c();
            journey.JourneyName__c = 'Jny1';
            journey.ApplicableStates__c = 'AZ;AL;MO;MN';
            journey.AppliestoAllStates__c = false;
            journey.BusinessLineCode__c = 'Auto;General';
            journey.CategoryName__c = 'Corporate assigned';
            journey.Type__c = 'Standard';
            journeyList.add(TestDataFactory_Journey.buildJourneyRecord(journey));
            Journey__c journey1 =new Journey__c();
            journey1.JourneyName__c = 'Jny2';
            journey1.ApplicableStates__c = '';
            journey1.AppliestoAllStates__c = true;
            journey1.BusinessLineCode__c = 'Auto';
            journey1.CategoryName__c = 'Prospect customers';
            journey1.Type__c = 'Standard';
            journeyList.add(TestDataFactory_Journey.buildJourneyRecord(journey1));
            Journey__c journey2 =new Journey__c();
            journey2.JourneyName__c = 'Jny3';
            journey2.ApplicableStates__c = 'KS;NY;IL';
            journey2.AppliestoAllStates__c = false;
            journey2.BusinessLineCode__c = 'Auto;Home - Fire';
            journey2.CategoryName__c = 'Prospect customers';
            journey2.Type__c = 'Standard';
            journeyList.add(TestDataFactory_Journey.buildJourneyRecord(journey2));            
            insert journeyList;
            
            List<Journey__c> parentJrnyRecordsList = [Select id,JourneyName__c,Name,VendorCode__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];
            
            Journey__c jrnyRecord1;
            Journey__c jrnyRecord2;
            Journey__c jrnyRecord3;
            
            for (Journey__c jrny : parentJrnyRecordsList) {
                if (jrny.JourneyName__c == 'Jny1') {
                    jrnyRecord1 = jrny;
                }
                else if (jrny.JourneyName__c == 'Jny2') {
                    jrnyRecord2 = jrny;
                }               
                else {
                    jrnyRecord3 = jrny;
                }
            }

            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>(); 
            Journey_Step__c jnyStep = new Journey_Step__c();
            jnyStep.JourneyID__c = jrnyRecord1.id;
            jnyStep.ContactMethodName__c = 'Mailing';
            jnyStep.MailClassCode__c = '1';
            jnyStep.JourneyStepID__c = 1;     
            jnystepsList.add(buildJourneyStepsRecord(jnyStep));
            Journey_Step__c jnyStep1 = new Journey_Step__c();
            jnyStep1.JourneyID__c = jrnyRecord1.id;
            jnyStep1.ContactMethodName__c = 'Mailing';
            jnyStep1.MailClassCode__c = '1';
            jnyStep1.JourneyStepID__c = 2;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep1));
            Journey_Step__c jnyStep2 = new Journey_Step__c();
            jnyStep2.JourneyID__c = jrnyRecord2.id;
            jnyStep2.ContactMethodName__c = 'Mailing';
            jnyStep2.MailClassCode__c = '1';
            jnyStep2.JourneyStepID__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep2));
            Journey_Step__c jnyStep3 = new Journey_Step__c();
            jnyStep3.JourneyID__c = jrnyRecord3.id;
            jnyStep3.ContactMethodName__c = 'Mailing';
            jnyStep3.MailClassCode__c = '1';
            jnyStep3.JourneyStepID__c = 1;
            jnystepsList.add(buildJourneyStepsRecord(jnyStep3));            
            insert jnystepsList;

            String queryString = ', DaysNum__c' +', JourneyName__c' +',ExternalJourneyStepIdentifier__c'+',JourneyID__r.Journey_External_ID__c' 
                + ', BusinessLineCode__c' +', CategoryName__c' +', Journey_External_ID__c'+', JourneyID__r.Statecode__c'+', Statecode__c'+', JourneyID__c'+', JourneyID__r.id' +', JourneyID__r.StateCodemap__c' +', JourneyID__r.MasterJourneyId__c' +' From Journey_Step__c' ;
            List<Journey_Step__c> jrnystepsList = queryForJourney(queryString);
            List<Journey_Step__c> childJnyStepList = new List<Journey_Step__c>();
           
            childJnyStepList =  assignJnyStepList(jrnystepsList, childJnyStepList) ; 
            System.assertEquals(67, childJnyStepList.size(), 'Unexpected JourneyStepListSize');
            for(Journey_Step__c jnyStepRec :childJnyStepList){                
                System.assertEquals(jnyStepRec.ExternalJourneyStepIdentifier__c,jnyStepRec.JourneyID__r.Journey_External_ID__c + '-' +jnyStepRec.JourneyStepID__c, 'Unexpected');
                System.assertEquals(jnyStepRec.Journey_External_ID__c,jnyStepRec.JourneyID__r.Journey_External_ID__c, 'Unexpected');
            }
            createStateCodeList(childJnyStepList);
        }
        Test.stopTest(); 
    }
    
/**
 * @description assignJnyStepList
 * @param jrnystepsList
 * @param childJnyStepList
 * @return List<Journey_Step__c>
 */
    private static List<Journey_Step__c> assignJnyStepList(List<Journey_Step__c> jrnystepsList, List<Journey_Step__c> childJnyStepList){

        List<Journey_Step__c> parentJnyStepList = new List<Journey_Step__c>();
        for(Journey_Step__c jrnyStep : jrnystepsList){
            if(jrnyStep.JourneyID__r.MasterJourneyId__c == null){
                parentJnyStepList.add(jrnyStep);
            }
            else if(jrnyStep.JourneyID__r.MasterJourneyId__c != null){
                childJnyStepList.add(jrnyStep);
            }
        }
        System.assertEquals(4,parentJnyStepList.size(), 'Unexpected JourneyStepListSize');
        return childJnyStepList;
    }


    private static void createStateCodeList(List<Journey_Step__c> childJnyStepList){
        List<String> caList = new List<String>();
        List<String> nyList = new List<String>();
        List<String> txList = new List<String>();
        for(Journey_Step__c jnyStepRec :childJnyStepList){
            if(jnyStepRec.JourneyID__r.StateCodemap__c == 'CA'){
                caList.add(jnyStepRec.JourneyID__r.StateCodemap__c);
            }
            else if(jnyStepRec.JourneyID__r.StateCodemap__c == 'NY'){
                nyList.add(jnyStepRec.JourneyID__r.StateCodemap__c);
            }                
            else if(jnyStepRec.JourneyID__r.StateCodemap__c == 'TX'){
                txList.add(jnyStepRec.JourneyID__r.StateCodemap__c);
            }
        }
        System.assertEquals(3, caList.size(), 'Unexpected ListSize');
            System.assertEquals(4, nyList.size(), 'Unexpected ListSize');
            System.assertEquals(2, txList.size(), 'Unexpected ListSize');
            
    }

    //test method to check exceptions
    @isTest
    private static void insertJourneyStepWithException(){               
        AP_JourneyStepProcessing jnyStepProcessing = new AP_JourneyStepProcessing();
        Test.startTest();   
        jnyStepProcessing.processJnyStepsPreInsert(null);
        jnyStepProcessing.processJnyStepsPostInsert(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,name, class__c, exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_JourneyStepProcessing'];           
        system.assertEquals(2,exLog.size(), 'Unexpected ExceptionLogListSize');         
    }   

    /**
	* @description Method for querying Journeys
    * @param queryString
    * @return `List<Journey_Step__c>`
	*/
    private static List<Journey_Step__c> queryForJourney(String queryString) {
        if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
            for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                querystringForLeadMessage = querystringForLeadMessage + QUERY_DELIMETER + metamapping.SourceField__c;
            }
        }
        dynamicQuery = SELECT_ID + querystringForLeadMessage + queryString;
        return Database.query(dynamicQuery);
    }

    /**
	* @description Method for getting counts of parent and child Journeys
    * @param jrnystepsList List<Journey_Step__c>
    * @return `List<Integer>`
	*/
    private static List<Integer> getJourneyCounts(List<Journey_Step__c> jrnystepsList) {
        Integer parentCount = 0;
        Integer childCount = 0;
        for(Journey_Step__c jrnyStep : jrnystepsList){
            if(jrnyStep.JourneyID__r.MasterJourneyId__c == null){
                parentCount++;
            }
            else if(jrnyStep.JourneyID__r.MasterJourneyId__c != null){
                childCount++;
            }
        }
        return new List<Integer> { parentCount, childCount };
    }
}

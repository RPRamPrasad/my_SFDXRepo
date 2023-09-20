/****************************************************************************************
Name: CMP_JourneyStepTask_TEST
Copyright © State Farm
=========================================================================================
@description Test class written for code coverage for CMP_JourneyStepTask class
Team: ClubCar
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  02/25/2018              Initial Development
2.0             ClubCar                  05/02/2019              Added assertion to test the Step Type Code populated for Task Journey Step
******************************************************************************************/ 
@IsTest(SeeAllData = false)
public class CMP_JourneyStepTask_TEST {
    private static User sysAdminUser;
    private static User corpMktingUser;
    private static final String SELECT_ID = 'select Id';      
    private static string querystringForLeadMessage='';
    private static string dynamicQuery='';
    private static final String QUERY_DELIMETER = ',';   
    private static list<CMOpportunityStartJourneyMapping__mdt> mappingForAccountMessagetoJourneyStep = [SELECT Id, MappingType__c, SourceField__c, TargetField__c
                                                                                                        FROM CMOpportunityStartJourneyMapping__mdt  WHERE MappingType__c = 'JourneyStepToAccountMessage' and SourceField__c != 'StateCode__c'];    
    
    /**
    * @description Setup method used for building test data
    */
    public static void setup(){
        //create system Admin user and croporate marketing user to insert records
        List<User> users = TestDataFactory_Journey.seupAdminAndCorporateUser();
        sysAdminUser = users.get(0);
        corpMktingUser = users.get(1); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(corpMktingUser);
    }
    
    //method to build journey steps record with the given parameter value
    private static Journey_Step__c buildJourneyStepsRecord(Journey_Step__c sampleJny) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = sampleJny.JourneyID__c ,JourneyNumber__c = sampleJny.JourneyNumber__c,CustomGreetingText__c='Hello, How are you',
                                                      LetterName__c =sampleJny.LetterName__c,Script__c=sampleJny.Script__c,DaysNum__c=sampleJny.DaysNum__c);
        return jnyStep;
    }
    //method to insert single journey record with selected states and a journey step record of type Task
    @isTest
    private static void insertJourneyStepRecordwithSelectedStatesJourney(){
        setup();
        Test.startTest();
        System.runAs(corpMktingUser){
            Journey__c buildJny = new Journey__c();
            buildJny.JourneyName__c = 'Journey1';
            buildJny.ApplicableStates__c = 'CO;CT;DE;DC';
            buildJny.AppliestoAllStates__c = false;
            buildJny.BusinessLineCode__c = 'Auto;General';
            buildJny.CategoryName__c = 'Corporate assigned';
            buildJny.Type__c = 'Standard';
            Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(buildJny);                  
            insert jrnyRecord;    
            Journey_step__c jny = new Journey_step__c();
            jny.JourneyID__c = jrnyRecord.id;
            jny.LetterName__c = 'Send Letter';
            jny.Script__c = 'Send a Letter to the Customer';
            jny.DaysNum__c = 18;
            jny.JourneyNumber__c = '224489';                     
            Journey_step__c jnyStep = buildJourneyStepsRecord(jny);            
            CMP_JourneyStepTask.processTaskJnyStep(jnyStep); 
            Journey_Step__c journeyStep = [Select id,name,JourneyStepID__c,VendorCode__c,ContactMethodName__c,JourneyNumber__c,LetterName__c,Script__c,
                                           DaysNum__c,Steptypecode__c  from Journey_Step__c where JourneyId__r.MasterJourneyId__c = null];
            System.assertEquals(0, journeyStep.VendorCode__c,'Unexpected Journey step vendor code');
            System.assertEquals('Call', journeyStep.ContactMethodName__c,'Journey step ContactMethodName did not match');
            System.assertEquals(1, journeyStep.JourneyStepID__c,'Journey step JourneyStepID did not match');
            System.assertEquals('Send Letter', journeyStep.LetterName__c,'Journey step LetterName did not match');
            System.assertEquals('Send a Letter to the Customer', journeyStep.Script__c,'Journey step Script did not match');
            System.assertEquals(18, journeyStep.DaysNum__c,'Unexpected Journey step DaysNum');
            System.assertEquals(3, journeyStep.Steptypecode__c,'Unexpected Steptypecode');
        }
        Test.stopTest();
    }
    
    //test method to validate JourneyStepTask insert exception
    @isTest
    private static void testException(){
        setup();
        System.runAs(corpMktingUser) {
            Journey__c buildJny = new Journey__c();
            buildJny.JourneyName__c = 'Journey1';
            buildJny.ApplicableStates__c = 'CO;CT;DE;DC';
            buildJny.AppliestoAllStates__c = false;
            buildJny.BusinessLineCode__c = 'Auto;General';
            buildJny.CategoryName__c = 'Corporate assigned';
            buildJny.Type__c = 'Standard';
            Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(buildJny);                  
            insert jrnyRecord; 
            Journey_step__c jny = new Journey_step__c();
            jny.JourneyID__c = jrnyRecord.id;
            jny.LetterName__c = '';
            jny.Script__c = 'Send a Letter to the Customer';
            jny.DaysNum__c = 123456;
            jny.JourneyNumber__c = '224489';              
            Journey_step__c jnyStep = buildJourneyStepsRecord(jny);
            
            Test.startTest(); 
            System.assertEquals(true,CMP_JourneyStepTask.processTaskJnyStep(jnyStep), 'JourneyStep Task insert execption not generated');
            Test.stopTest();            
        }       
    }  
}

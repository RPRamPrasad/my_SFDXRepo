/****************************************************************************************
Name: HLPR_JourneyStepProcessing_TEST 
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description Test class for code coverage of UTIL_LtngJourneyProcess and 
HLPR_JourneyStepProcessing classes
Team: ClubCar
=========================================================================================
History
-------
VERSION         AUTHOR      DATE                   DETAIL
1.0             ClubCar     10/17/2018             Initial Development
******************************************************************************************/
@IsTest(SeeAllData = false)
Private class HLPR_JourneyStepProcessing_TEST {
    private static User sysAdminUser;
    private static User corpMktingUser;

   /**
    * @description Setup method used for building test data
    */
    public static void setup(){
        List<User> users = TestDataFactory_Journey.seupAdminAndCorporateUser();
        sysAdminUser = users.get(0);
        corpMktingUser = users.get(1); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(corpMktingUser);
    }

    //method to build journey steps record with the given parameter value
    private static Journey_Step__c buildJourneyStepsRecord(String paramJnyId) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = paramJnyId ,ContactMethodName__c = 'Mailing',Cost__c= '0.28', MailClassCode__c = '1',JourneyNumber__c = '224489',
                                                      VendorCode__c = 0,CustomGreetingText__c='Hello, How are you',GiveawayOptionCode__c='b',GreetingCode__c='Hi',
                                                      LetterName__c ='New Letter',MediaTypeFilterText__c='This Text',PhotoOptionCode__c='A',PreferenceObjectID__c=123344,    SatelliteOfficeInd__c=false,Script__c='Description',StaffEmailID__c='Email',
                                                      StepTypeCode__c=22,TaskActionCode__c='B',TaskCategoryID__c=23433534,TaskHighPriorityInd__c=false,JourneyStepID__c=1);
        return jnyStep;
    }
   
    //method to test JourneyStepDetails
    @isTest
    private static void getJourneyStepDetailsTest(){
        setup();
        System.runAs(corpMktingUser){
            Journey__c jny1 = new Journey__c();
                jny1.JourneyName__c='Journey1';
                jny1.ApplicableStates__c='CO;CT;DE;DC';
                jny1.AppliestoAllStates__c =false;
                jny1.BusinessLineCode__c='Auto;General';
                jny1.CategoryName__c='Corporate assigned';
                jny1.Type__c='Standard';
            Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(jny1);                  
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id, JourneyNumber__c from Journey__c WHERE MasterJourneyId__c = null];           
            
            HLPR_JourneyStepProcessing.JourneyStepWrapper jnyStepWrapper = new HLPR_JourneyStepProcessing.JourneyStepWrapper();
            jnyStepWrapper = HLPR_JourneyStepProcessing.getJourneyStepDetails(queryJrnyRecord.id);           
            System.assertEquals(jnyStepWrapper.journeyNumber,queryJrnyRecord.JourneyNumber__c, 'Journey Number did not match');
            System.assertEquals(jnyStepWrapper.UserAlias,[Select id,Alias from user WHERE id =:UserInfo.getUserId()].alias, 'Unexpected alias retruned');
        }
    }
    //method to test JourneyStepId
    @isTest
    private static void utilLtngJourneyStepDetailsTest(){
        setup();
        System.runAs(corpMktingUser){
            Journey__c jny1 = new Journey__c();
                jny1.JourneyName__c='Journey1';
                jny1.ApplicableStates__c='CO;CT;DE;DC';
                jny1.AppliestoAllStates__c =false;
                jny1.BusinessLineCode__c='Auto;General';
                jny1.CategoryName__c='Corporate assigned';
                jny1.Type__c='Standard';
            Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(jny1);                  
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id from Journey__c WHERE MasterJourneyId__c = null];
            Journey_step__c jnyStep = buildJourneyStepsRecord(jrnyRecord.id);
            insert jnyStep;                     
            UTIL_LtngJourneyProcess.getJourneyStepId(queryJrnyRecord.id);
            Journey_Step__c jnyStepp = [Select id, JourneyStepID__c from Journey_Step__c ORDER BY JourneyStepID__c  DESC LIMIT 1];
            System.assertEquals(1,jnyStepp.JourneyStepID__c, 'JourneystepId did not match');            
        }
    }
    
    //method to test JourneyStepDetailsException
    @isTest
    private static void getJourneyStepDetailsExceptionTest(){
        setup();
        System.runAs(corpMktingUser){
            String message = '';
            try{
                Journey__c jny1 = new Journey__c();
                jny1.JourneyName__c='Journey1';
                jny1.ApplicableStates__c='CO;CT;DE;DC';
                jny1.AppliestoAllStates__c =false;
                jny1.BusinessLineCode__c='Auto;General';
                jny1.CategoryName__c='Corporate assigned';
                jny1.Type__c='Standard';
                Journey__c jrnyRecord = TestDataFactory_Journey.buildJourneyRecord(jny1);                  
                insert jrnyRecord;        
                HLPR_JourneyStepProcessing.getJourneyStepDetails(null);
            }
            catch(Exception e){
                message = e.getmessage();
                System.assert(!String.isBlank(message),'No Message returned');
            }
            
        } 
    }
}
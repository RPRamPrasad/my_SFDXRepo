/****************************************************************************************
Name: AP_Campaign_StartJourney_Test
=========================================================================================
* @description : Test class written for AP_Campaign_StartJourney
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                  DATE                    DETAIL
1.0             Team Pike               04/19/2018              Removed LOB_OTHER as the value is no longer in the Task picklist values
2.0             Team ClubCar            08/15/2018              Added new testmethods for callout
3.0             Team ClubCar            06/14/2019              Removed references to Task - Journey recordtype check
4.0             Team ClubCar            08/19/2019              Removed test methods for CampaignMessagesCreation and callouts
5.0				Team ClubCar            05/14/2020              Added @TestSetup on setUpAgentOffice() method
******************************************************************************************/

@IsTest(SeeAlldata=false)
public class AP_Campaign_StartJourney_Test {
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
    
    /**
    *@method - setUpAgentOffice This method will set up test data for Agent Office(Creation of Agent, ATM, Proxy Users and Role hierarchy)
    *@description - This method will set up test data for Agent Office(Creation of Agent, ATM, Proxy Users and Role hierarchy)
    */
    @TestSetup
    static void setUpAgentOffice() {
        agentStandardUserRole= new UserRole(name='AgentRole');                    
        insert agentStandardUserRole;
        atmStandardUserRole= new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);                    
        insert atmStandardUserRole;
        proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
        insert proxyStandardUserRole;
        User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='verifytaskproxy@statefarm.com.bad',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
        proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUser.userRoleId= proxyStandardUserRole.id;
        Database.insert(proxyUser);
        atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'verifytaskAtm@statefarm.com.bad');
        atmUser.userRoleId= atmStandardUserRole.id;
        atmUser.Servicing_Agent_Associate_ID__c = '1231test';
        atmUser.UserExternalID__c='123testatm';
        Database.insert(atmUser);
        User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='verifytaskAgent@statefarm.com.bad',Associate_ID__c='123test',UserExternalID__c='1231test',Servicing_Agent_Associate_ID__c='123test');
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        agentUser.userRoleId= agentStandardUserRole.id;
        Database.insert(agentUser);
    }
    
    //method to get Agent Office
    private static void getAgentOffice(){
        List<User> usrlist=[SELECT Id, UserExternalID__c FROM User where  UserExternalID__c in('123testP','1231test')];
        for(User usrobj:usrlist){
            if('1231test'.equals(usrobj.UserExternalID__c))
            {
                agentUser=usrobj;
            }
            else{
                proxyUser=usrobj;
            }
        }
    }
    
    /**
    *@description - test method to check campaign journey details after campaign start journey
	*/
    @isTest
    private static void testCampaignStartJourney() {
        getAgentOffice();
                
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Campaign cmp = new Campaign(Name='CmpTestStartJourney', RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, OwnerId = proxyUser.id);
            insert cmp;
            Journey__c tstJourney = buildJourneyRecord();
            insert tstJourney;
            List<Journey_Step__c> jnyStepsList = new List<Journey_Step__c>();
            AP_Campaign_StartJourney_TestWrapper wrap = new AP_Campaign_StartJourney_TestWrapper();
            wrap.paramJnyId = tstJourney.id;
            wrap.paramJnyStepId = 1;
            wrap.paramJnyNumber = '1';
            wrap.paramVendorCode = 11111;
            wrap.paramDaysNum = 1;
            wrap.paramContactMethodName = 'Mailing';
            jnyStepsList.add(buildJourneyStepsRecord(wrap));
            AP_Campaign_StartJourney_TestWrapper wrapper = new AP_Campaign_StartJourney_TestWrapper();
            wrapper.paramJnyId = tstJourney.id;
            wrapper.paramJnyStepId = 5;
            wrapper.paramJnyNumber = '5';
            wrapper.paramVendorCode = 55555;
            wrapper.paramDaysNum = 5;
            wrapper.paramContactMethodName = 'Call';
            jnyStepsList.add(buildJourneyStepsRecord(wrapper));
            insert jnyStepsList;
            
            List<AP_Campaign_StartJourney.CampaignJourneyRequest> campaignWrapper = new List<AP_Campaign_StartJourney.CampaignJourneyRequest>();
            AP_Campaign_StartJourney.CampaignJourneyRequest obj = new AP_Campaign_StartJourney.CampaignJourneyRequest();
            obj.campaignId = cmp.id;
            obj.journeyId = tstJourney.id;
            obj.selectedJourneyDate = System.today()+3;
            campaignWrapper.add(obj);
            
            Test.startTest();
            AP_Campaign_StartJourney.campaignStartJourney(campaignWrapper);
            Test.StopTest();
            
            Campaign cmpAfterJourney = [Select id, OwnerId, Journey_ID__c, Journey_Start_Date__c, Journey_Description__c from Campaign where id =: cmp.id Limit 1];            
            System.assertEquals(tstJourney.Journey_External_ID__c,cmpAfterJourney.Journey_ID__c, 'Campaign Journey Id field was not updated') ;
            System.assertEquals(obj.selectedJourneyDate,cmpAfterJourney.Journey_Start_Date__c, 'Campaign Journey StartDate field was not updated') ;
            System.assertEquals(tstJourney.JourneyDescription__c, cmpAfterJourney.Journey_Description__c, 'Campaign Journey Desc field was not updated');
        }
    }
    
    /**
    *@description - test method to check campaign journey details after campaign start journey using updateCampaignAndStartJourney
	*/
    @isTest
    private static void testupdateCampaignAndStartJourney() {
        getAgentOffice();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Campaign campaignRecord = new Campaign(Name='CmpTestStartJourney', RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, OwnerId = proxyUser.id);
            insert campaignRecord;
            Journey__c journeyRecord = buildJourneyRecord();
            insert journeyRecord;
            Date selectedJourneyDate= System.today()+3;
            
            Test.startTest();
            AP_Campaign_StartJourney.updateCampaignAndStartJourney(campaignRecord.Id,journeyRecord.Id,selectedJourneyDate);
            Test.StopTest();
            
            Campaign updatedCampaign = [Select id, Journey_ID__c, Journey_Start_Date__c, Journey_Description__c from Campaign where id =: campaignRecord.id Limit 1];            
            System.assertEquals(journeyRecord.Journey_External_ID__c,updatedCampaign.Journey_ID__c, 'Campaign Journey Id field was not updated') ;
            System.assertEquals(selectedJourneyDate,updatedCampaign.Journey_Start_Date__c, 'Campaign Journey StartDate field was not updated') ;
            System.assertEquals(journeyRecord.JourneyDescription__c, updatedCampaign.Journey_Description__c, 'Campaign Journey Desc field was not updated');
        }
    }
  
    /**
    *@description - test method to generate Start Journey Exception
	*/
    @isTest
    private static void  testStartJourneyExceptionForLeadCampaignAsAgent() {
        getAgentOffice(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);       
        System.runas(agentUser){            
            Campaign cmp = new Campaign(Name='CmpTestStartJourney', RecordTypeId = campaignRecordTypeMap.get('Lead Campaign').RecordTypeId, OwnerId=proxyUser.id);
            insert cmp;
            Journey__c appliedJourney = buildJourneyRecord();
            insert appliedJourney;
            
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            AP_Campaign_StartJourney_TestWrapper wrap = new AP_Campaign_StartJourney_TestWrapper();
            wrap.paramJnyId = appliedJourney.id;
            wrap.paramJnyStepId = 1;
            wrap.paramJnyNumber = '1';
            wrap.paramVendorCode = 11111;
            wrap.paramDaysNum = 1;
            wrap.paramContactMethodName = 'Email';
            jnystepsList.add(buildJourneyStepsRecord(wrap));
            
            insert jnystepsList;  
            List<AP_Campaign_StartJourney.CampaignJourneyRequest> campaignWrapper = New List<AP_Campaign_StartJourney.CampaignJourneyRequest>();
            AP_Campaign_StartJourney.CampaignJourneyRequest obj = New AP_Campaign_StartJourney.CampaignJourneyRequest();
            obj.campaignId = '';
            obj.journeyId = appliedJourney.id;
            obj.selectedJourneyDate = System.today()+3;
            campaignWrapper.add(obj);
            
            Test.StartTest();
            AP_Campaign_StartJourney.campaignStartJourney(campaignWrapper);
            Test.StopTest();
            Campaign selectedCampaign = [Select id, Journey_ID__c from Campaign where id =:cmp.Id Limit 1];
            List<ExceptionLog__c> exceptionLogList = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='AP_Campaign_StartJourney' order by createdDate desc limit 1 ];
            System.assert(exceptionLogList.get(0).Exception_Message__c != null, 'Exception not occured');     
            System.assertEquals(null, selectedCampaign.Journey_ID__c, 'Campaign Journey Id was not updated');
        }
    }
    
    /**
    *@description - test method to generate Start Journey Exception with null request
	*/
    @isTest
    private static void testStartJourneyExceptionWithNullRequest() {
        getAgentOffice();

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Campaign cmp = new Campaign(Name='CmpTestStartJourney', RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, OwnerId=proxyUser.id);
            insert cmp;
            List<AP_Campaign_StartJourney.CampaignJourneyRequest> campaignWrapper = null;
            
            Test.startTest();
            AP_Campaign_StartJourney.campaignStartJourney(campaignWrapper);
            Test.StopTest(); 
            Campaign selectedCampaign = [Select id, Journey_ID__c from Campaign where id =:cmp.Id Limit 1];
            System.assertEquals(null, selectedCampaign.Journey_ID__c, 'Campaign Journey Id was not updated');
        }        
    }
        
    /**
    * @method buildJourneyRecord 
    * @description Setup method used for building test data for Journey     
    * @return Journey__c  
    */
    private static Journey__c buildJourneyRecord() {
        Journey__c jny = new Journey__c(JourneyName__c='Jny1', Journey_External_ID__c ='101010',BusinessLineCode__c = 'Auto',CategoryName__c = 'prospect customers',
                                        JourneyDescription__c='Jnydescription', VendorCode__c= 12345, JourneyNumber__c = '1', 
                                        CreatorRoleCode__c = '0', CustomDemographicsInd__c = true, JourneyFundingID__c = '111111');
        return jny;
    }
    
    private class AP_Campaign_StartJourney_TestWrapper{
        String paramJnyId;
        integer paramJnyStepId;
        String paramJnyNumber;
        integer paramVendorCode;
        integer paramDaysNum;
        String paramContactMethodName;
    }
    /**
    * @method buildJourneyStepsRecord
    * @description - Setup method used for building test data for Journey Step
    * @param wrap  
    * @return Journey_Step__c
    */
    private static Journey_Step__c buildJourneyStepsRecord(AP_Campaign_StartJourney_TestWrapper wrap) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = wrap.paramJnyId , JourneyStepID__c = wrap.paramJnyStepId,
                                                      VendorCode__c= wrap.paramVendorCode, JourneyNumber__c = wrap.paramJnyNumber, DaysNum__c = wrap.paramDaysNum, ContactMethodName__c = wrap.paramContactMethodName);
        return jnyStep;
    } 
}
/**
Author Team ClubCar
Name - AP_CampMailerCostNotifications_TEST
@description Test class written for AP_CampMailerCostNotifications 
========================================================================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                04/27/2020              Initial Development
2.0             Team ClubCar                05/17/2020              Added new testmethods for start journey send email notifications
******************************************************************************************************************************************/
@isTest(SeeAlldata=false)
public class AP_CampMailerCostNotifications_TEST {
    
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User sysAdminuser;    
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static final String CAMPAIGNMESSAGE_STATUS_SCHEDULED  = 'Scheduled';
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
    private static final String TDOPEN = '<td align="center">';
    private static final String TDCLOSE = '</td>';
    private static final String EMAILFROMNAME = System.Label.CL_CAMP_MAILER_SENDERNAME;
    private static final String EMAILSUBJECT = System.Label.CL_CAMP_MAILER_SUBJECT;
    private static final String LEGENDSTARSTRING = '<font color="red">*</font>';
    
    //setup method to set test data for Agent Office Creation of Agent, ATM, Proxy Users
    @TestSetup
    private static void setUp() {        
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        system.debug(System.LoggingLevel.INFO, sysAdminuser);
        System.runAs(sysAdminuser) {            
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            atmStandardUserRole= new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);                    
            insert atmStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='verifytaskproxy1@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'verifytaskAtm1@statefarm.com');
            atmUser.userRoleId= atmStandardUserRole.id;
            atmUser.Servicing_Agent_Associate_ID__c = '123test';
            Database.insert(atmUser);
            User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='verifytaskAgent1@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId= agentStandardUserRole.id;
            agentUser.UserPermissionsMarketingUser = true;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,atmUser});
        }
    }   
    
    //testMethod to test oneoff send email notifications 
    @isTest   
    private static void testOneOffSendEmailNotifications(){ 
        User queryAgent = [Select id from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        Campaign testLeadCampaign;
        System.runAs(agentUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
            testLeadCampaign.Initiated_By_Id__c = agentUser.id;
            insert testLeadCampaign;    
        }        
        user proxy_User = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxy_User,5);
        campaignMessage__c campaignMessage = buildCampaignMessageRecord(testLeadCampaign.id, System.today().adddays(10),'campMessage5');
        campaignMessage.journeyid__c = null;
        Test.startTest();
        insert campaignMessage;
        Test.stopTest();        
        EmailMessage emailMsg = [SELECT Id,FromName,Status,Subject,ToAddress FROM EmailMessage LIMIT 1];
        System.assertEquals('3',emailMsg.Status, 'Email status did not match');
        System.assertEquals('Campaign: Mail Notification',emailMsg.Subject, 'Email Subject did not match');
        System.assertEquals(EMAILFROMNAME,emailMsg.FromName, 'Email From Name did not match');
        System.assertEquals('verifytaskagent1@statefarm.com',emailMsg.ToAddress, 'Agent Email Address did not match');
    }
    
    //testMethod to test email is not sent when total number members is zero 
    @isTest   
    private static void testEmailNotSentWithZeroCampaignMembers(){
        User queryAgent = [Select id from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        Campaign testCustomerProspectCampaign;
        System.runAs(agentUser) {
            testCustomerProspectCampaign = buildCampaignRecord('CustomerProspectCampaignTest',campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
            insert testCustomerProspectCampaign;
        }       
        campaignMessage__c campaignMessage = buildCampaignMessageRecord(testCustomerProspectCampaign.id, System.today().adddays(10),'campMessage5');
        campaignMessage.journeyid__c = null;
        Test.startTest();
        insert campaignMessage;        
        Test.stopTest();
        List<EmailMessage> emailMsgList = [SELECT Id FROM EmailMessage LIMIT 1];
        System.assertEquals(0, emailMsgList.size(), 'EmailMessageList Size did not match');
    }
    
    //testMethod to test order lead do not send email notifications when there are no campaign messages
    @isTest
    private static void testOrderLeadNotSentEmailWithoutMessages(){
        User queryAtm = [Select id from User where username = 'verifytaskAtm1@statefarm.com'];
        atmUser= queryAtm;
        Campaign testLeadCampaign;
        System.runAs(atmUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = atmUser.id;
            insert testLeadCampaign;
        }
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        testLeadCampaign.Status = 'Fulfillment Completed';
        Test.startTest();
        update testLeadCampaign;  
        Test.stopTest();
        List<EmailMessage> emailMsgList = [SELECT Id FROM EmailMessage LIMIT 1];
        System.assertEquals(0, emailMsgList.size(), 'EmailMessageList Size did not match');
    }
    
    //testMethod to test order lead send email notifications 
    @isTest   
    private static void testAtmOrderLeadSendEmailNotifications(){
        User queryAtm = [Select id from User where username = 'verifytaskAtm1@statefarm.com'];
        atmUser= queryAtm;
        Campaign testLeadCampaign;
        System.runAs(atmUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = atmUser.id;
            insert testLeadCampaign;
        }
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(testLeadCampaign);
        insert campaignMessageList;        
        String emailHtmlBody = '';
        emailHtmlBody += '<html><font color="gray"><h3>The following Mail has been started on a Campaign by TaskATM</h3>';
        emailHtmlBody += getEmailHtmlBody(testLeadCampaign,campaignMessageList,true);
        testLeadCampaign.Status = 'Fulfillment Completed';
        Test.startTest();
        update testLeadCampaign;       
        Test.stopTest();        
        EmailMessage emailMsg = [SELECT Id,CcAddress,FromName,Status,Subject,ToAddress,HtmlBody FROM EmailMessage LIMIT 1];
        System.assertEquals(emailHtmlBody, emailMsg.HtmlBody, 'Email body does not match');
        System.assertEquals('3',emailMsg.Status, 'Email status did not match');
        System.assertEquals('Campaign: Mail Notification',emailMsg.Subject, 'Email Subject did not match');
        System.assertEquals(EMAILFROMNAME,emailMsg.FromName, 'Email From Name did not match');
        System.assertEquals('verifytaskagent1@statefarm.com',emailMsg.ToAddress, 'Agent Email Address did not match');
        System.assertEquals('verifytaskatm1@statefarm.com',emailMsg.CcAddress, 'Initiated User Email Address did not match');
        System.assertEquals('TaskATM',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedOrLstModfdUserMap.get(testLeadCampaign.Id).Name, 'Initiated User Name did not match');
    }
    
    //testMethod to one off send email when there are existing campaign messages created from order lead flow  
    @isTest 
    private static void testOneOffSendEmailWithExistingOrderLeadCampMessages(){
        User queryAgent = [Select id from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        Campaign testLeadCampaign;
        System.runAs(agentUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = agentUser.id;
            insert testLeadCampaign;
        }        
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(testLeadCampaign);
        insert campaignMessageList;
        campaignMessage__c campaignMessage = buildCampaignMessageRecord(testLeadCampaign.id, System.today().adddays(110),'campMessage6');        
        campaignMessage.journeyid__c = null;
        campaignMessage.Cost__c = '1.02';
        String emailHtmlBody = '';
        emailHtmlBody += '<html><font color="gray"><h3>The following Mail has been started on a Campaign</h3>';
        emailHtmlBody += getEmailHtmlBody(testLeadCampaign,campaignMessageList,false);
        Test.startTest();
        insert campaignMessage;   
        Test.stopTest();        
        EmailMessage emailMsg = [SELECT Id,FromName,Status,Subject,ToAddress,HtmlBody FROM EmailMessage LIMIT 1];
        System.assertEquals(emailHtmlBody, emailMsg.HtmlBody, 'Email body does not match');
        System.assertEquals('3',emailMsg.Status, 'Email status did not match');
        System.assertEquals('Campaign: Mail Notification',emailMsg.Subject, 'Email Subject did not match');
        System.assertEquals(EMAILFROMNAME,emailMsg.FromName, 'Email From Name did not match');
        System.assertEquals('verifytaskagent1@statefarm.com',emailMsg.ToAddress, 'Agent Email Address did not match');  
    }
    
    //testMethodf to test start journey send email notifications with existing one off campaign message on campaign
    @isTest
    private static void testStartJourneySendEmailNotifications(){
        User queryAtm = [Select id from User where username = 'verifytaskAtm1@statefarm.com'];
        atmUser= queryAtm;
        Campaign testLeadCampaign;
        System.runAs(atmUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = atmUser.id;
            insert testLeadCampaign;
        }
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        System.runAs(atmUser) {
            campaignMessage__c campaignMessage = buildCampaignMessageRecord(testLeadCampaign.id, System.today().adddays(10),'campMessage5');
            campaignMessage.journeyid__c = null;
            insert campaignMessage;
            Journey__c tstJourney = buildJourneyRecord();
            insert tstJourney;
            List<Journey_Step__c> jnyStepsList = new List<Journey_Step__c>();
            jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 1, 10));
            jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 5, 20));
            jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 5, 30));
            insert jnyStepsList;
            Date selectedJourneyDate= System.today()+3;
            String emailHtmlBody = '';
            emailHtmlBody += '<html><font color="gray"><h3>The following Mail has been started on a Campaign by TaskATM</h3>';
            emailHtmlBody += getEmailHtmlBodyForStartJourney(testLeadCampaign,jnyStepsList);
            Test.startTest();
            AP_Campaign_StartJourney.updateCampaignAndStartJourney(testLeadCampaign.Id,tstJourney.Id,selectedJourneyDate);            
            Test.StopTest();
            List<EmailMessage> emailMsgList = [SELECT Id,FromName,Status,TextBody,Subject,ToAddress,HtmlBody,CcAddress FROM EmailMessage ORDER BY Createddate LIMIT 2];
            System.assertEquals(emailHtmlBody, emailMsgList[1].HtmlBody, 'Email body does not match');
            System.assertEquals('3',emailMsgList[1].Status, 'Email Status did not match');
            System.assertEquals('Campaign: Mail Notification',emailMsgList[1].Subject, 'Email Subject did not match');
            System.assertEquals(EMAILFROMNAME,emailMsgList[1].FromName, 'Email From Name did not match');
            System.assertEquals('verifytaskagent1@statefarm.com',emailMsgList[1].ToAddress, 'Agent Email Address did not match');
            System.assertEquals('verifytaskatm1@statefarm.com',emailMsgList[1].CcAddress, 'Initiated User Email Address did not match');            
            System.assertEquals('TaskATM',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedOrLstModfdUserMap.get(testLeadCampaign.Id).Name, 'Initiated User Name did not match'); 
        }      
    }
    
    //testMethodf to test start journey send email notifications without campaign messages on campaign
    @isTest
    private static void testStartJnySendEmailNotificationsWithoutCampMsgs(){
        User atm_User = [Select id from User where username = 'verifytaskAtm1@statefarm.com'];
        Campaign testLeadCampaign;
        System.runAs(atm_User) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = atm_User.id;
            insert testLeadCampaign;
        }
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        System.runAs(atm_User) {
            Journey__c tstJourney = buildJourneyRecord();
            insert tstJourney;
            List<Journey_Step__c> jnyStepsList = new List<Journey_Step__c>();
            jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 1, 10));
            jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 5, 20));
            jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 5, 30));
            insert jnyStepsList;
            Date selectedJourneyDate= System.today()+3;
            Test.startTest();
            AP_Campaign_StartJourney.updateCampaignAndStartJourney(testLeadCampaign.Id,tstJourney.Id,selectedJourneyDate);
            Test.StopTest();
            EmailMessage emailMsg = [SELECT FromName,Id,Status,Subject,ToAddress,HtmlBody,CcAddress FROM EmailMessage LIMIT 1];
            System.assertEquals('3',emailMsg.Status, 'Email Status did not match');
            System.assertEquals('Campaign: Mail Notification',emailMsg.Subject, 'Email Subject did not match');
            System.assertEquals(EMAILFROMNAME,emailMsg.FromName, 'Email From Name did not match');
            System.assertEquals('verifytaskagent1@statefarm.com',emailMsg.ToAddress, 'Agent Email Address did not match');
            System.assertEquals('verifytaskatm1@statefarm.com',emailMsg.CcAddress, 'Initiated User Email Address did not match');            
            System.assertEquals('TaskATM',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedOrLstModfdUserMap.get(testLeadCampaign.Id).Name, 'Initiated User Name did not match'); 
        }  
    }
    
    //testMethod to test send email exception
    @isTest
    private static void testOneOffSendEmailException(){
        Campaign testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
        testLeadCampaign.Journey_ID__c = null;
        insert testLeadCampaign;
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        CampaignMessage__c campMessage = new CampaignMessage__c (Campaign__c = testLeadCampaign.id , ContactMethodName__c = 'Mailing', JourneyID__c = null,CategoryName__c= 'Customer/Prospect Campaign', Status__c = CAMPAIGNMESSAGE_STATUS_SCHEDULED,
                                                                 StepTypeCode__c = 1,TimingTypeCode__c = 1,CampaignId__c = 'EXTCAMPAIGNID',TransmissionDate__c = System.today().adddays(10),Name = 'campMessage1',Itemid__c = 'PK43',cost__c = '0.34',MailClassCode__c = '1');
        Test.startTest();
        insert campMessage;
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,Exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_CampMailerCostNotifications'];
        system.assertEquals(1,exLog.size(), 'Exception not found');
    }
    
    //testMethod to test order leads send email exception
    @isTest
    private static void testOrderLeadSendEmailException(){
        User queryAgent = [Select id,name from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        Campaign testLeadCampaign;
        System.runAs(agentUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
            testLeadCampaign.Type = 'Lead';
            insert testLeadCampaign;
        }
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        CampaignMessage__c campMessage = new CampaignMessage__c (Campaign__c = testLeadCampaign.id , ContactMethodName__c = 'Mailing', JourneyID__c = '00555-13',CategoryName__c= 'Customer/Prospect Campaign', Status__c = CAMPAIGNMESSAGE_STATUS_SCHEDULED,
                                                                 StepTypeCode__c = 1,TimingTypeCode__c = 1,CampaignId__c = 'EXTCAMPAIGNID#1',TransmissionDate__c = System.today().adddays(10),Name = 'campMessage1',cost__c = '0.34',MailClassCode__c = '1');
        insert campMessage;
        testLeadCampaign.Status = 'Fulfillment Completed';
        Test.startTest();
        update testLeadCampaign;
        Test.stopTest();               
        List<ExceptionLog__c> exLog = [SELECT Id,Exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_CampMailerCostNotifications'];
        system.assertEquals(1,exLog.size(), 'Exception not found');
    }
    
    //testMethod to test main class exception - Cost and mail class code has incorrect values in 3rd step
    @isTest
    private static void testStartJourneySendEmailException(){
        User queryAgent = [Select id,name from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        Campaign testLeadCampaign;
        System.runAs(agentUser) {
            testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
            testLeadCampaign.Type = 'Lead';
            insert testLeadCampaign;
        }
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testLeadCampaign,proxyUser,5);
        testLeadCampaign.Status = 'Fulfillment Completed';
        Journey__c tstJourney = buildJourneyRecord();
        insert tstJourney;
        List<Journey_Step__c> jnyStepsList = new List<Journey_Step__c>();
        jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 1, 10));
        jnyStepsList.add(buildJourneyStepsRecord(tstJourney.id, 2, 20));
        jnyStepsList.add(new Journey_Step__c(JourneyID__c = tstJourney.id , JourneyStepID__c = 3,Itemid__c = 'PK43',cost__c = 'Test',MailClassCode__c = '5',JourneyName__c = 'Test Journey Lead Campaign 2019',
                                             VendorCode__c= 0, JourneyNumber__c = '1', DaysNum__c = 30, ContactMethodName__c = 'Mailing'));
        insert jnyStepsList;
        Date selectedJourneyDate= System.today()+3;
        Test.startTest();
        AP_Campaign_StartJourney.updateCampaignAndStartJourney(testLeadCampaign.Id,tstJourney.Id,selectedJourneyDate);       
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,Exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_CampMailerCostNotifications'];
        system.assertEquals(1,exLog.size(), 'Exception not found');       
    }
    
    //method to create campaign members
    private static void buildCampaignMembers(Campaign campaign,User proxyUser, Integer numofLeads)
    { 
        List<Lead> testLeadList = createLeads(numofLeads,proxyUser);
        List<CampaignMember> testCampaignMemberList = new List<CampaignMember>();
        for(Lead testLead:testLeadList)
        {
            testCampaignMemberList.add(new CampaignMember(CampaignId = campaign.id,leadId = testLead.id,Status= 'Sent'));
        }
        insert testCampaignMemberList;
    }
    
    //method to create leads for campaign members
    private static List<Lead> createLeads(Integer numofLeads, User proxyUser){
        List<Lead> testLeadList = new List<Lead>();
        for(Integer i = 1;i <= numofLeads;i++)
        {
            testLeadList.add(new Lead(LastName = 'tstCmpMemval'+1, ownerId = proxyUser.Id));
        }
        insert testLeadList;
        return testLeadList;
    }
    
    //method to build campaign message
    private static CampaignMessage__c buildCampaignMessageRecord(String paramCmpId, Date paramTransmissionDate,String paramName){ 
        CampaignMessage__c  cmpMessage = new CampaignMessage__c (Campaign__c = paramCmpId , ContactMethodName__c = 'Mailing', JourneyID__c = '00555-13',CategoryName__c= 'Lead Camapigns', Status__c = CAMPAIGNMESSAGE_STATUS_SCHEDULED,
                                                                 StepTypeCode__c = 1,TimingTypeCode__c = 1,CampaignId__c = 'EXTCAMPAIGNID#3',TransmissionDate__c = paramTransmissionDate,Name = paramName,Associateid__c = '123test',
                                                                 Itemid__c = 'PK43',cost__c = '0.34',MailClassCode__c = '1',JourneyName__c = 'Test Journey Lead Campaign 2019');
        return cmpMessage;
    }
    
    //method to build campaign messages 
    private static List<CampaignMessage__c> buildCampaignMessagesForCampaign(Campaign currentCmp) {
        List<CampaignMessage__c> listofCampaignMessages = new List<CampaignMessage__c>();
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(10),'campMessage1'));
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(40),'campMessage2'));
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(75),'campMessage3'));
        return listofCampaignMessages;
    }
    
    //method to build campaign
    private static Campaign buildCampaignRecord(String paramCampaignName,Id paramRecordTypeId, String paramExternalCampaignId) {
        Campaign campaigntoBuild = new Campaign(Name = paramCampaignName, Journey_ID__c = '00555-13' ,Journey_Name__c = 'Test Journey Lead Campaign 2019',External_Campaign_ID__c = paramExternalCampaignId,
                                                RecordTypeId = paramRecordTypeId,EndDate = System.today().adddays(60),StartDate =System.today(),Status = 'Fulfillment Pending');       
        return campaigntoBuild;
    }
    
    //method to build journey
    private static Journey__c buildJourneyRecord() {
        Journey__c jny = new Journey__c(JourneyName__c='Test Journey Lead Campaign 2019', Journey_External_ID__c ='00555-13',BusinessLineCode__c = 'Auto',CategoryName__c = 'prospect customers',
                                        JourneyDescription__c='Jnydescription', VendorCode__c= 12345, JourneyNumber__c = '1', 
                                        CreatorRoleCode__c = '0', CustomDemographicsInd__c = true, JourneyFundingID__c = '111111');
        return jny;
    }
    
    //method to build journey step
    private static Journey_Step__c buildJourneyStepsRecord(String paramJnyId, integer paramJnyStepId, integer paramDaysNum) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = paramJnyId , JourneyStepID__c = paramJnyStepId,Itemid__c = 'PK43',cost__c = '0.34',MailClassCode__c = '1',JourneyName__c = 'Test Journey Lead Campaign 2019',
                                                      VendorCode__c= 0, JourneyNumber__c = '1', DaysNum__c = paramDaysNum, ContactMethodName__c = 'Mailing');
        return jnyStep;
    }
    
    
    //method to build expected email html body used to assert with actual email html body
    private static String getEmailHtmlBody(Campaign testCampaign,List<CampaignMessage__c> campMessageList,Boolean isOrderLeadNotification){
        String htmlBody = '';
        htmlBody += getHtmlTableHeader();
        htmlBody += getHtmlTableBody(campMessageList,isOrderLeadNotification);        
        htmlBody += getCampaignUrlAndLegend(testCampaign);
        return htmlBody;
    }
    
    //method to build expected email html body used to assert with actual email html body
    private static String getEmailHtmlBodyForStartJourney(Campaign testCampaign,List<Journey_Step__c> jnyStepsList){
        String htmlBody = '';
        htmlBody += getHtmlTableHeader();
        htmlBody += getHtmlTableBodyForJnySteps(jnyStepsList);        
        htmlBody += getCampaignUrlAndLegend(testCampaign);
        return htmlBody;
    }
    
    //Helper method to build html body header
    private static String getHtmlTableHeader(){        
        String htmlTableHeader = '';        
        htmlTableHeader += '<br />Number of Campaign Members: 5<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
        htmlTableHeader += '<td colspan="6"><b>'+'leadCampaignTest'+'</b></td> </tr>';
        htmlTableHeader += '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th> </tr>';
        return htmlTableHeader;
    }
    
    //Helper method to build html table body
    private static String getHtmlTableBody(List<CampaignMessage__c>campMessageList, Boolean isOrderLeadNotification){
        String htmlTableBody = '';
        for(CampaignMessage__c campaignMessage : campMessageList){
            String transmissionDate = DateTime.newInstance(campaignMessage.TransmissionDate__c.year(), campaignMessage.TransmissionDate__c.month(),campaignMessage.TransmissionDate__c.day()).format('MM/dd/yy');
            String starString = '';
            if(isOrderLeadNotification){
                starString = LEGENDSTARSTRING;
            }
            htmlTableBody += '<tr>' +TDOPEN + starString + transmissionDate + TDCLOSE +TDOPEN + campaignMessage.JourneyName__c + TDCLOSE +
                TDOPEN + '1st Class' + TDCLOSE+TDOPEN +'$'+campaignMessage.Cost__c +TDCLOSE +TDOPEN + campaignMessage.ItemID__c+ TDCLOSE +
                TDOPEN + campaignMessage.Status__c + TDCLOSE +'</tr>';
            
        }
        If(!isOrderLeadNotification){
            Date transmissionDate = System.today().adddays(110);
            htmlTableBody += '<tr>' +TDOPEN +LEGENDSTARSTRING+DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy') + tdClose +
                TDOPEN +'Single Mailer' + TDCLOSE +TDOPEN + '1st Class' + TDCLOSE+TDOPEN +'$'+'1.02'+TDCLOSE +TDOPEN + 'PK43'+ TDCLOSE +TDOPEN + 'Scheduled' + TDCLOSE +'</tr>';
        }
        return htmlTableBody;
    }
    
    //Helper method to build html table body
    private static String getHtmlTableBodyForJnySteps(List<Journey_Step__c> jnyStepsList){
        String htmlTableBody = '';
        Date journeyStartDate = System.today().addDays(3);        
        Date transmissionDate = System.today().adddays(10);
        htmlTableBody += '<tr>' +
            +TDOPEN +DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy') + tdClose +
            TDOPEN +'Single Mailer' + TDCLOSE + TDOPEN + '1st Class' + TDCLOSE+ TDOPEN +'$'+'0.34'+TDCLOSE +TDOPEN + 'PK43'+ TDCLOSE +TDOPEN + 'Scheduled' + TDCLOSE +'</tr>';        
        for(Journey_Step__c journeyStep : jnyStepsList){            
            Integer daysNum = journeyStep.DaysNum__c.intvalue();
            Date estmtdDate = journeyStartDate.addDays(daysNum);
            String estimatedDate = DateTime.newInstance(estmtdDate.year(), estmtdDate.month(),estmtdDate.day()).format('MM/dd/yy');
            htmlTableBody += '<tr>' + TDOPEN + LEGENDSTARSTRING + estimatedDate + TDCLOSE +TDOPEN + journeyStep.JourneyName__c + TDCLOSE +TDOPEN + '1st Class' + TDCLOSE+            
                TDOPEN +'$'+journeyStep.Cost__c +TDCLOSE + TDOPEN + journeyStep.ItemID__c+ TDCLOSE + TDOPEN + 'Scheduled' + TDCLOSE +'</tr>';
        }       
        return htmlTableBody;
    }
    
    //Helper method to get campaignurl and camp mailer message
    private static String getCampaignUrlAndLegend(Campaign testCampaign){
        String campaignUrlAndMessage = '';
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + testCampaign.Id;
        campaignUrlAndMessage += +'<tr>'+TDOPEN+'<b>TOTAL COST:</b>'+TDCLOSE+TDOPEN+tdClose+TDOPEN+TDCLOSE+TDOPEN+'$'+5.1+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+TDCLOSE+'</table>';
        campaignUrlAndMessage += '<br />'+LEGENDSTARSTRING + ' New Mails'+'<p>'+'View Campaign '+'<a href="'+recordUrl+'">here</a>'+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font></html>';    
        return campaignUrlAndMessage;
    }
}
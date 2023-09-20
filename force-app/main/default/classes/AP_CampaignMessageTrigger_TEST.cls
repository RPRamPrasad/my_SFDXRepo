/****************************************************************************************
Name: AP_CampaignMessageTrigger_Test
Copyright © State Farm
=========================================================================================
@description : Test class for AP_CampaignMessageTrigger
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  05/16/2019              Initial Development
******************************************************************************************/ 
@IsTest(SeeAlldata=false)
public class AP_CampaignMessageTrigger_TEST {
    
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static final String CAMPAIGNMESSAGE_STATUS_SCHEDULED  = 'Scheduled';
    private static final String CAMPAIGNMESSAGE_STATUS_SENT  = 'Sent';
    private static final String CAMPAIGNMESSAGE_STATUS_CANCELLED  = 'Cancelled - Stopped Journey';
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
    private static List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRulesList;
    private static Map<String, List<CM_CampaignExpiryDateLogic__mdt>> expiryDateAdjustmentRuleSets = new Map<String, List<CM_CampaignExpiryDateLogic__mdt>>();
    private static Map<Id, Campaign> campIdToCampMap = new Map<Id, Campaign> ();
    private static AP_CampaignMessageTriggerTestWrapper apWrap = new AP_CampaignMessageTriggerTestWrapper();
    private static AP_CampaignMessageTESTWrapper apCampWrap = new AP_CampaignMessageTESTWrapper();
    
    /**
    * @method : setUp
    * @description  : setup method 
    */
    public static void setUp() {
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        System.runAs(sysAdminuser) {
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            atmStandardUserRole= new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);                    
            insert atmStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='verifytaskproxy1@statefarm.com.bad',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'verifytaskAtm1@statefarm.com.bad');
            atmUser.userRoleId= atmStandardUserRole.id;
            atmUser.Servicing_Agent_Associate_ID__c = '123test';
            Database.insert(atmUser);
            User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='verifytaskAgent1@statefarm.com.bad',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            PermissionSet permSet = [select Id from PermissionSet where Name = 'Campaign_ManageCampaigns_CRU'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = agentUser.Id, PermissionSetId = permSet.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = atmUser.Id, PermissionSetId = permSet.Id);
            List<PermissionSetAssignment> psalist = new List<PermissionSetAssignment> {
                psa1, psa2
            };
            insert psalist;

            queryRulesFromCampExpiryMetadata();
        }
    }
    
    
    // test method to check lastMessagesentdate and expiration date of Campaign when two Campaign Messages are sent
    @isTest
    private static void testTwoCampaignMessagesStatusUpdateToSent() {
        setUp(); 
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where username = 'verifytaskAgent1@statefarm.com.bad'];
        agentUser= queryAgent;
        System.runAs(agentUser) {            
            //Creating Campaign and Campaign Messages  
            AP_CampaignMessageTrigger_TestWrapper wrap = new AP_CampaignMessageTrigger_TestWrapper();
                wrap.paramCampaignName = 'CorporateCampaignTest';
                wrap.paramRecordTypeId = campaignRecordTypeMap.get('Corporate Leads').RecordTypeId;
                wrap.paramExternalCampaignId = 'EXTCAMPAIGNID#2';
                wrap.paramEndDate = System.today().adddays(60);
                wrap.paramStartDate = System.today();
            Campaign campRecord1 = buildCampaignRecord(wrap);
            insert campRecord1;
            List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(campRecord1);            
            insert campaignMessageList;
            Test.startTest();
            //Updating last campaignMessage status to sent
            List<CampaignMessage__c> campaignMessagestoUpdate = [Select id,Name from CampaignMessage__c where Name IN ('campMessage3', 'campMessage4')];
            apCampWrap.testTwoCampaignMessagesStatusUpdateToSent(campaignMessagestoUpdate);
            update campaignMessagestoUpdate;
            
            Test.stopTest();
            //Query Campaign data and Campaign Messages after update  
            List<CampaignMessage__c> campaignMessagesListAfterUpdate = [Select id,TransmissionDate__c,campaign__c, campaign__r.LastMessageSentDate__c, campaign__r.Enddate
                                                                        from CampaignMessage__c where Name IN ('campMessage3', 'campMessage4')];
            compileParentCampaignMap(campaignMessagesListAfterUpdate);
            //Assertion to check the lastMessagesentdate and expiration date of Campaign
            for(CampaignMessage__c campaignMessageAfterUpdate : campaignMessagesListAfterUpdate){
                Campaign camp = campIdToCampMap.get(campaignMessageAfterUpdate.campaign__c);
                integer daysToBump = getBumpDays(camp);  
                system.assertEquals(campaignMessageAfterUpdate.TransmissionDate__c, campaignMessageAfterUpdate.campaign__r.LastMessageSentDate__c, 'Unexpected LastMessageSentDate');            
                system.assertEquals(campaignMessageAfterUpdate.TransmissionDate__c.adddays(daysToBump), campaignMessageAfterUpdate.campaign__r.Enddate,'Unexpected Expiration Date');            
                system.assertEquals(camp.CurrentPathStep__c, 'inProgress', 'Unexpected current path step');            
                
            }
        }
    }    
    
    // test method to check expiration date of Campaign when Campaign Messages are Cancelled due to Stop-Journey
    @isTest
    private static void testAllCampaignMessageStatusUpdateToCancel() {
        setUp();
        System.runAs(agentUser) {
            
            //Creating Campaign and Campaign Messages  
            AP_CampaignMessageTrigger_TestWrapper wrap = new AP_CampaignMessageTrigger_TestWrapper();
                wrap.paramCampaignName = 'CustomerProspectCampaignTest';
                wrap.paramRecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId;
                wrap.paramExternalCampaignId = 'EXTCAMPAIGNID#1';
                wrap.paramEndDate = System.today().adddays(60);
                wrap.paramStartDate = Date.newInstance(2012, 12, 12);                     
            Campaign campRecord1 = buildCampaignRecord(wrap);            
            insert campRecord1;
            List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(campRecord1);
            campaignMessageList[3].JourneyID__c = null;
            insert campaignMessageList;            
            Test.startTest();            
            List<CampaignMessage__c> campaignMessagesListtoUpdate = [Select id from CampaignMessage__c where Campaign__c =:campRecord1.id];
            for(CampaignMessage__c campaignMessagetoUpdate : campaignMessagesListtoUpdate){                
                campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_CANCELLED;
            }
            update campaignMessagesListtoUpdate;
            
            //Query Campaign data and Campaign Messages after update  
            List<CampaignMessage__c> cancelledCampMessagesList = [Select id,campaign__c, campaign__r.StartDate, campaign__r.Enddate,
                                                                  campaign__r.LastMessageSentDate__c from CampaignMessage__c where Campaign__c =:campRecord1.id];
            Test.stopTest();
            //Assertion to check the expiration date of the Campaign 
            compileParentCampaignMap(cancelledCampMessagesList);           
            for(CampaignMessage__c cancelledCampMessage : cancelledCampMessagesList){
                Campaign camp = campIdToCampMap.get(cancelledCampMessage.campaign__c);
                integer daysToBump = getBumpDays(camp);
                system.assertEquals(campRecord1.StartDate.adddays(daysToBump), cancelledCampMessage.campaign__r.Enddate, 'Unexpected Expiration Date');
                system.assertEquals(null, cancelledCampMessage.campaign__r.LastMessageSentDate__c, 'LastMessageSentDate is not null');
                system.assertEquals(camp.CurrentPathStep__c, 'new', 'Unexpected current path step');            
                
            }            
        } 
    }
    
    // test method to check lastMessagesentdate and expiration date of Campaigns when status of Campaign Messages List is updated to sent or cancel
    @isTest
    private static void testCampaignMessagesListStatusUpdateToSentandCancel() {
        setUp();
        System.runAs(agentUser) {
            
            //Creating Campaigns and Campaign Messages
            List<Campaign> campaignList = new List<campaign>();
            List<CampaignMessage__c> campaignMessageList = new List<CampaignMessage__c> ();      
            
            AP_CampaignMessageTrigger_TestWrapper wrap6 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap6.paramCampaignName = 'corporateCampaignSecondTest';
                wrap6.paramRecordTypeId = campaignRecordTypeMap.get('Corporate Leads').RecordTypeId;
                wrap6.paramExternalCampaignId = 'EXTCAMPAIGNID#7';
                wrap6.paramEndDate = System.today().adddays(60);
                wrap6.paramStartDate = Date.newInstance(2012, 12, 12); 
            Campaign campRecord7 = buildCampaignRecord(wrap6);
            AP_CampaignMessageTrigger_TestWrapper wrap8 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap8.paramCampaignName = 'leadCampaignSecondTest';
                wrap8.paramRecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId;
                wrap8.paramExternalCampaignId = 'EXTCAMPAIGNID#9';
                wrap8.paramEndDate = System.today().adddays(60);
                wrap8.paramStartDate = System.today(); 
            Campaign campRecord9 = buildCampaignRecord(wrap8);
            campRecord9.LastMessageSentDate__c = System.Today().adddays(5);
            campaignList.add(campRecord7);
            campaignList.add(campRecord9);
            addingWrapToCampRecord(campaignList);
            insert campaignList;
            
            apCampWrap.testCampaignMessagesListStatusUpdateToSentandCancel(campaignList, campaignMessageList);
            insert campaignMessageList;
            
            Test.startTest();
            //Updating Campaign Messages status to sent and cancel
            List<CampaignMessage__c> campaignMessagesListtoUpdate = [Select id,Name,campaign__r.Name from CampaignMessage__c where campaign__c IN: campaignList];
            campaignMessagetoUpdateStatus(campaignMessagesListtoUpdate);
            update campaignMessagesListtoUpdate;
            Test.stopTest();
            //Query Campaign data and Campaign Messages after update  
            List<CampaignMessage__c> campaignMessagesListAfterUpdate = [Select id,TransmissionDate__c,campaign__c, campaign__r.Name,campaign__r.LastMessageSentDate__c,campaign__r.StartDate,
                                                                        JourneyId__c,Status__c,campaign__r.Enddate from CampaignMessage__c where campaign__c IN: campaignList];
            compileParentCampaignMap(campaignMessagesListAfterUpdate);
            //Assertion to check the lastMessagesentdate and expiration date of Campaign
            for (CampaignMessage__c campaignMessageAfterUpdate : campaignMessagesListAfterUpdate) {
                Campaign camp = campIdToCampMap.get(campaignMessageAfterUpdate.campaign__c);
                integer daysToBump = getBumpDays(camp);               
                if(campaignMessageAfterUpdate.Status__c.equals(CAMPAIGNMESSAGE_STATUS_SENT)){
                    system.assertEquals(campaignMessageAfterUpdate.TransmissionDate__c, campaignMessageAfterUpdate.campaign__r.LastMessageSentDate__c,'Unexpected LastMessageSentDate');                    
                    if('leadCampaignTest'.equals(campaignMessageAfterUpdate.campaign__r.Name) || 'customerProspectCampaignTest'.equals(campaignMessageAfterUpdate.campaign__r.Name)){
                        system.assertEquals(campaignMessageAfterUpdate.TransmissionDate__c.adddays(daysToBump), campaignMessageAfterUpdate.campaign__r.Enddate, 'Unexpected Expiration Date');  
                    }                   
                    else{
                        system.assertEquals(System.today().adddays(60), campaignMessageAfterUpdate.campaign__r.Enddate, 'Unexpected Expiration Date');
                    }
                }
                else if(campaignMessageAfterUpdate.Status__c.equals(CAMPAIGNMESSAGE_STATUS_CANCELLED)){
                 ValidateExpirationDateWrapper validateDateWrapper = new ValidateExpirationDateWrapper();
                 validateDateWrapper.campaignMessageAfterUpdate = campaignMessageAfterUpdate;
                 validateDateWrapper.campRecord7 = campRecord7;
                 validateDateWrapper.campRecord9 = campRecord9;
                 validateDateWrapper.daysToBump = daysToBump;
                 validateExpirationDate(validateDateWrapper);
                }
            }
        }        
    }
    
    /**
     * @description addingWrapToCampRecord
     * @param campaignList 
     */
    private static void addingWrapToCampRecord(List<Campaign> campaignList){
        AP_CampaignMessageTrigger_TestWrapper wrap = new AP_CampaignMessageTrigger_TestWrapper();
                wrap.paramCampaignName = 'leadCampaignTest';
                wrap.paramRecordTypeId = campaignRecordTypeMap.get('Lead Campaign').RecordTypeId;
                wrap.paramExternalCampaignId = 'EXTCAMPAIGNID#1';
                wrap.paramEndDate = System.today().adddays(60);
                wrap.paramStartDate = System.today();      
            Campaign campRecord1 = buildCampaignRecord(wrap);
            AP_CampaignMessageTrigger_TestWrapper wrap1 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap1.paramCampaignName = 'corporateCampaignTest';
                wrap1.paramRecordTypeId = campaignRecordTypeMap.get('Corporate Leads').RecordTypeId;
                wrap1.paramExternalCampaignId = 'EXTCAMPAIGNID#2';
                wrap1.paramEndDate = System.today().adddays(60);
                wrap1.paramStartDate = Date.newInstance(2019, 07, 20);
            Campaign campRecord2 = buildCampaignRecord(wrap1);
            AP_CampaignMessageTrigger_TestWrapper wrap2 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap2.paramCampaignName = 'customerProspectCampaignTest';
                wrap2.paramRecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId;
                wrap2.paramExternalCampaignId = 'EXTCAMPAIGNID#3';
                wrap2.paramEndDate = System.today().adddays(60);
                wrap2.paramStartDate = System.today(); 
            Campaign campRecord3 = buildCampaignRecord(wrap2);
            AP_CampaignMessageTrigger_TestWrapper wrap3 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap3.paramCampaignName = 'leadUploadIndividualTest';
                wrap3.paramRecordTypeId = campaignRecordTypeMap.get('Lead Upload Individual').RecordTypeId;
                wrap3.paramExternalCampaignId = 'EXTCAMPAIGNID#4';
                wrap3.paramEndDate = System.today().adddays(60);
                wrap3.paramStartDate = System.today(); 
            Campaign campRecord4 = buildCampaignRecord(wrap3);
            AP_CampaignMessageTrigger_TestWrapper wrap4 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap4.paramCampaignName = 'leadUploadOrganizationTest';
                wrap4.paramRecordTypeId = campaignRecordTypeMap.get('Lead Upload Organization').RecordTypeId;
                wrap4.paramExternalCampaignId = 'EXTCAMPAIGNID#5';
                wrap4.paramEndDate = System.today().adddays(60);
                wrap4.paramStartDate = System.today(); 
            Campaign campRecord5 = buildCampaignRecord(wrap4);
            campaignList.add(campRecord1);
            campaignList.add(campRecord2);
            campaignList.add(campRecord3);
            campaignList.add(campRecord4);
            campaignList.add(campRecord5);

            addingWrapToCampRecord1(campaignList);
    }

    private static void addingWrapToCampRecord1(List<Campaign> campaignList){
        AP_CampaignMessageTrigger_TestWrapper wrap5 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap5.paramCampaignName = 'eventLeadTest';
                wrap5.paramRecordTypeId = campaignRecordTypeMap.get('Event Leads').RecordTypeId;
                wrap5.paramExternalCampaignId = 'EXTCAMPAIGNID#6';
                wrap5.paramEndDate = System.today().adddays(60);
                wrap5.paramStartDate = System.today(); 
            Campaign campRecord6 = buildCampaignRecord(wrap5);
            AP_CampaignMessageTrigger_TestWrapper wrap7 = new AP_CampaignMessageTrigger_TestWrapper();
                wrap7.paramCampaignName = 'customerProspectCampaignSecondTest';
                wrap7.paramRecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId;
                wrap7.paramExternalCampaignId = 'EXTCAMPAIGNID#8';
                wrap7.paramEndDate = System.today().adddays(60);
                wrap7.paramStartDate = System.today(); 
            Campaign campRecord8 = buildCampaignRecord(wrap7);
            campaignList.add(campRecord6);
            campaignList.add(campRecord8);
    }

    private static void campaignMessagetoUpdateStatus(List<CampaignMessage__c> campaignMessagesListtoUpdate){
        Boolean isAssigned = false;
        apCampWrap.campaignMessagetoUpdateStatus(campaignMessagesListtoUpdate, isAssigned);
    }

    private static void checkCampaignStatusForLeadAndCorporate(CampaignMessage__c campaignMessagetoUpdate){
        Boolean isAssigned = false;
        isAssigned = apWrap.checkCampaignStatusForLeadAndCorporate(campaignMessagetoUpdate, isAssigned);
    }

    /**
     * @description checkCampaignStatusForCustomerProspect
     * @param campaignMessagetoUpdate 
     */
    private static void checkCampaignStatusForCustomerProspect(CampaignMessage__c campaignMessagetoUpdate){
        if('campMessage4'.equals(campaignMessagetoUpdate.Name) && 'customerProspectCampaignSecondTest'.equals(campaignMessagetoUpdate.campaign__r.Name)){
            campaignMessagetoUpdate.JourneyID__c = null;
            campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_CANCELLED;
        }
    }

    class ValidateExpirationDateWrapper{
        CampaignMessage__c campaignMessageAfterUpdate;
        Campaign campRecord9;
        Campaign campRecord7;
        Integer daysToBump;
    }

    private static void validateExpirationDate(ValidateExpirationDateWrapper validateWrapper){
            apCampWrap.validateExpirationDate(validateWrapper);                 
        }
    //test method to Catch Exception
    @isTest
    private static void testCampaignMessageStatusUpdateException() {
        setUp();
        System.runAs(agentUser) {            
            //Creating Campaign and Campaign Messages  
            AP_CampaignMessageTrigger_TestWrapper wrap = new AP_CampaignMessageTrigger_TestWrapper();
                wrap.paramCampaignName = 'corporateCampaignTest';
                wrap.paramRecordTypeId = campaignRecordTypeMap.get('Corporate Leads').RecordTypeId;
                wrap.paramExternalCampaignId = 'EXTCAMPAIGNID#2';
                wrap.paramEndDate = System.today().adddays(60);
                wrap.paramStartDate = System.today();         
            Campaign campRecord1 = buildCampaignRecord(wrap);
            insert campRecord1;
            
            List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(campRecord1);            
            insert campaignMessageList[0];            
            Test.startTest();
            //Updating last Campaign Message status to sent           
            CampaignMessage__c campaignMessagetoUpdate = [Select id from CampaignMessage__c Limit 1];            
            campaignMessagetoUpdate.TransmissionDate__c = null;
            campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_SENT;           
            update campaignMessagetoUpdate;                       
            Test.stopTest();
            List<ExceptionLog__c> exLog = [SELECT Id from ExceptionLog__c class__c where class__c = 'AP_CampaignMessageTrigger'];
            //Assertion to the check the exception
            system.assertEquals(1,exLog.size(), 'Exception not found');           
        }        
    }
    //test method to Bypass Trigger
    @isTest
    private static void testCampaignMessageStatusUpdateAfterTriggerBypass() {
        setUp();
        CS001_ByPassTriggerAtoF__c passObjectTrigger;
        System.runAs(agentUser) {            
            //Creating Campaign and Campaign Messages    
            AP_CampaignMessageTrigger_TestWrapper wrap = new AP_CampaignMessageTrigger_TestWrapper();
                wrap.paramCampaignName = 'corporateCampaignTest';
                wrap.paramRecordTypeId = campaignRecordTypeMap.get('Corporate Leads').RecordTypeId;
                wrap.paramExternalCampaignId = 'EXTCAMPAIGNID#2';
                wrap.paramEndDate = System.today().adddays(60);
                wrap.paramStartDate = System.today();       
            Campaign campRecord1 = buildCampaignRecord(wrap);
            insert campRecord1;
            List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(campRecord1);            
            insert campaignMessageList;
            passObjectTrigger = new CS001_ByPassTriggerAtoF__c(Override_CampaignMessageAfterUpdate__c=true);
            insert passObjectTrigger;
            Test.startTest();
            //Updating last Campaign Message status to sent            
            CampaignMessage__c campaignMessagetoUpdate = [Select id from CampaignMessage__c where Name = 'campMessage4' Limit 1];
            campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_SENT;           
            update campaignMessagetoUpdate;            
            Test.stopTest();
            CampaignMessage__c campaignMessageAfterUpdate = [Select id,campaign__r.Enddate,campaign__r.LastMessageSentDate__c
                                                             from CampaignMessage__c where Name = 'campMessage4' Limit 1];
            //Assertion to the check the lastMessagesentdate and expiration date of the Campaign
            system.assertEquals(campRecord1.Enddate, campaignMessageAfterUpdate.campaign__r.Enddate, 'Unexpected Expiration Date');
            system.assertEquals(null, campaignMessageAfterUpdate.campaign__r.LastMessageSentDate__c, 'Unexpected LastMessageSent Date'); 
        } 
        
    }

    private class AP_CampaignMessageTrigger_TestWrapperClass{
        String paramCmpId;
        Date paramTransmissionDate;
        String paramExternalCmpId;
        String paramName;
    }
    //method to build a Campaign Message
    private static CampaignMessage__c buildCampaignMessageRecords(AP_CampaignMessageTrigger_TestWrapperClass wrapper) {
        CampaignMessage__c  cmpMessage = new CampaignMessage__c (Campaign__c = wrapper.paramCmpId , ContactMethodName__c = 'Mailing', JourneyID__c = '00555-13',CategoryName__c= 'Lead Camapigns', Status__c = CAMPAIGNMESSAGE_STATUS_SCHEDULED,
                                                                 StepTypeCode__c = 1,TimingTypeCode__c = 1,CampaignId__c = wrapper.paramExternalCmpId,TransmissionDate__c = wrapper.paramTransmissionDate,Name = wrapper.paramName);
        return cmpMessage;
    }
    //method to build a Campaign Message List
    private static List<CampaignMessage__c> buildCampaignMessagesForCampaign(Campaign currentCmp) {
        List<CampaignMessage__c> listofCampaignMessages = new List<CampaignMessage__c>();
        AP_CampaignMessageTrigger_TestWrapperClass wrapper = new AP_CampaignMessageTrigger_TestWrapperClass();
        wrapper.paramCmpId = currentCmp.id;
        wrapper.paramTransmissionDate = System.today().adddays(10);
        wrapper.paramExternalCmpId = currentCmp.External_Campaign_ID__c;
        wrapper.paramName = 'campMessage1';
        listofCampaignMessages.add(buildCampaignMessageRecords(wrapper));
        AP_CampaignMessageTrigger_TestWrapperClass wrapper1 = new AP_CampaignMessageTrigger_TestWrapperClass();
        wrapper1.paramCmpId = currentCmp.id;
        wrapper1.paramTransmissionDate = System.today().adddays(40);
        wrapper1.paramExternalCmpId = currentCmp.External_Campaign_ID__c;
        wrapper1.paramName = 'campMessage2';
        listofCampaignMessages.add(buildCampaignMessageRecords(wrapper1));
        AP_CampaignMessageTrigger_TestWrapperClass wrapper2 = new AP_CampaignMessageTrigger_TestWrapperClass();
        wrapper2.paramCmpId = currentCmp.id;
        wrapper2.paramTransmissionDate = System.today().adddays(75);
        wrapper2.paramExternalCmpId = currentCmp.External_Campaign_ID__c;
        wrapper2.paramName = 'campMessage3';
        listofCampaignMessages.add(buildCampaignMessageRecords(wrapper2));
        AP_CampaignMessageTrigger_TestWrapperClass wrapper3 = new AP_CampaignMessageTrigger_TestWrapperClass();
        wrapper3.paramCmpId = currentCmp.id;
        wrapper3.paramTransmissionDate = System.today().adddays(110);
        wrapper3.paramExternalCmpId = currentCmp.External_Campaign_ID__c;
        wrapper3.paramName = 'campMessage4';
        listofCampaignMessages.add(buildCampaignMessageRecords(wrapper3));
        
        return listofCampaignMessages;
    }

    private class AP_CampaignMessageTrigger_TestWrapper{
        String paramCampaignName;
        Id paramRecordTypeId;
        String paramExternalCampaignId;
        Date paramEndDate;
        Date paramStartDate;
    }
    //method to build a Campaign
    private static Campaign buildCampaignRecord(AP_CampaignMessageTrigger_TestWrapper wrap) {
        Campaign campaigntoBuild = new Campaign(Name = wrap.paramCampaignName, Journey_ID__c = '009880-FL' ,Journey_Name__c = ' Test Journey Lead Campaign 2019',External_Campaign_ID__c = wrap.paramExternalCampaignId,
                                                RecordTypeId = wrap.paramRecordTypeId,EndDate = wrap.paramEndDate,StartDate =wrap.paramStartDate);       
        return campaigntoBuild;
    }
    // method to query custom metadata rules for Campaign expiry
    private static void queryRulesFromCampExpiryMetadata() {
        if (expiryDateAdjustmentRulesList == null || !expiryDateAdjustmentRulesList.isEmpty()) {
            expiryDateAdjustmentRulesList = [Select ActivationDate__c, DeactivationDate__c,CampRecordTypeName__c, Days__c from CM_CampaignExpiryDateLogic__mdt
                                          where BumpCampExpDate__c = true];
            for (CM_CampaignExpiryDateLogic__mdt expiryDateAdjustmentRule : expiryDateAdjustmentRulesList) {
                List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRulesForSameCampList  = null; 
                expiryDateAdjustmentRuleSets = processExpiryDateAdjustmentRulesList(expiryDateAdjustmentRule, expiryDateAdjustmentRulesForSameCampList);
            }
        }
    }

    /**
     * @description processExpiryDateAdjustmentRulesList
     * @param expiryDateAdjustmentRule 
     * @param expiryDateAdjustmentRulesForSameCampList
     * @return Map<String, List<CM_CampaignExpiryDateLogic__mdt>>
     */
    private static Map<String, List<CM_CampaignExpiryDateLogic__mdt>> processExpiryDateAdjustmentRulesList(CM_CampaignExpiryDateLogic__mdt expiryDateAdjustmentRule, List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRulesForSameCampList){
        List<CM_CampaignExpiryDateLogic__mdt> expiryDateAdjustmentRules_SameCampList = expiryDateAdjustmentRulesForSameCampList;
        for(CM_CampaignExpiryDateLogic__mdt innerexpiryDateAdjustmentRule : expiryDateAdjustmentRulesList) {
            if (expiryDateAdjustmentRule.CampRecordTypeName__c == innerexpiryDateAdjustmentRule.CampRecordTypeName__c) {
                expiryDateAdjustmentRules_SameCampList = expiryDateAdjustmentRuleSets.get(expiryDateAdjustmentRule.CampRecordTypeName__c);
                expiryDateAdjustmentRules_SameCampList = (expiryDateAdjustmentRules_SameCampList == null)? new List <CM_CampaignExpiryDateLogic__mdt>():expiryDateAdjustmentRules_SameCampList;
                expiryDateAdjustmentRules_SameCampList.add(innerexpiryDateAdjustmentRule);
            }
            expiryDateAdjustmentRuleSets.put(expiryDateAdjustmentRule.CampRecordTypeName__c, expiryDateAdjustmentRules_SameCampList);
            
        }
        return expiryDateAdjustmentRuleSets;
    }

    // helper method to retrieve numbers of days to bump Campaign expirationdate based on Campaign startdate and type
    private static integer getBumpDays(Campaign parentCampaign) {
        List<CM_CampaignExpiryDateLogic__mdt> duplicateExpiryDateAdjustmentRuleForSameCampList = expiryDateAdjustmentRuleSets.get(parentCampaign.RecordType.DeveloperName);
        integer daysToBump = null;                    
        if (duplicateExpiryDateAdjustmentRuleForSameCampList!= null) {
            for (CM_CampaignExpiryDateLogic__mdt expiryDateAdjustmentRule : duplicateExpiryDateAdjustmentRuleForSameCampList) {
                if (parentCampaign.StartDate >= expiryDateAdjustmentRule.ActivationDate__c && parentCampaign.StartDate <= expiryDateAdjustmentRule.DeactivationDate__c) {
                    daysToBump = expiryDateAdjustmentRule.Days__c.intValue();
                    break;
                }
            }
        }
        return daysToBump;  
    }
    // helper method to query parent Campaigns
    private static void compileParentCampaignMap (List<CampaignMessage__c> campMessages) {
        campIdToCampMap = UTIL_CampaignData.getCampaignsFromCampaignMessages(campMessages);
    }

    private class AP_CampaignMessageTriggerTestWrapper{
        private Boolean checkCampaignStatusForLeadAndCorporate(CampaignMessage__c campaignMessagetoUpdate, Boolean isAssigned){
            Boolean is_Assigned = isAssigned;
            if('campMessage2'.equals(campaignMessagetoUpdate.Name)){
                is_Assigned = campaignMessageStatusSent(campaignMessagetoUpdate, is_Assigned);
            }
           
           else if('campMessage3'.equals(campaignMessagetoUpdate.Name)){
            is_Assigned = campaignMessageStatusCancelled(campaignMessagetoUpdate, is_Assigned);
            }

           else if(is_Assigned == false){
               checkCampaignStatusForCustomerProspect(campaignMessagetoUpdate);
           }
           return is_Assigned;
       }

       /**
        * @description campaignMessageStatusSent
        * @param campaignMessagetoUpdate 
        * @param isAssigned 
        * @return  `Boolean`
        */
       private Boolean campaignMessageStatusSent(CampaignMessage__c campaignMessagetoUpdate, Boolean isAssigned){
        Boolean is_Assigned = isAssigned;
        if(('leadUploadIndividualTest'.equals(campaignMessagetoUpdate.campaign__r.Name) || 'leadUploadOrganizationTest'.equals(campaignMessagetoUpdate.campaign__r.Name))){

            campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_SENT;
        
            is_Assigned = true;
        
        }
        return is_Assigned;
       }

       private Boolean campaignMessageStatusCancelled(CampaignMessage__c campaignMessagetoUpdate, Boolean isAssigned){
        Boolean is_Assigned = isAssigned;
        if(('corporateCampaignSecondTest'.equals(campaignMessagetoUpdate.campaign__r.Name) || 'leadCampaignSecondTest'.equals(campaignMessagetoUpdate.campaign__r.Name) || 'eventLeadTest'.equals(campaignMessagetoUpdate.campaign__r.Name))){
            
            campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_CANCELLED;
        
            is_Assigned = true;
        }
       return is_Assigned;
        }
    }

        private class AP_CampaignMessageTESTWrapper{
            private void testTwoCampaignMessagesStatusUpdateToSent(List<CampaignMessage__c> campaignMessagestoUpdate){
                for(CampaignMessage__c campaignMessagetoUpdate : campaignMessagestoUpdate){
                    campaignMessagetoUpdate.TransmissionDate__c = System.today()+75;
                    campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_SENT;                
                }
            }

            private void testCampaignMessagesListStatusUpdateToSentandCancel(List<Campaign> campaignList, List<CampaignMessage__c> campaignMessageList){
                for (Campaign parentCmp : campaignList) {
                    List<CampaignMessage__c> innerMsgList = new List<CampaignMessage__c>();
                    innerMsgList = buildCampaignMessagesForCampaign(parentCmp);  
                    campaignMessageList.addall(innerMsgList);
                }
            }

            private void campaignMessagetoUpdateStatus(List<CampaignMessage__c> campaignMessagesListtoUpdate, Boolean isAssigned){
                Boolean is_Assigned = isAssigned;
                for(CampaignMessage__c campaignMessagetoUpdate : campaignMessagesListtoUpdate){
                    is_Assigned = false;
                    if('campMessage4'.equals(campaignMessagetoUpdate.name) && ('leadCampaignTest'.equals(campaignMessagetoUpdate.campaign__r.Name) || 'customerProspectCampaignTest'.equals(campaignMessagetoUpdate.campaign__r.Name))){
                        campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_SENT;
                        is_Assigned = true;
                    }
                    else if('campMessage1'.equals(campaignMessagetoUpdate.name) && 'corporateCampaignTest'.equals(campaignMessagetoUpdate.campaign__r.Name)){
                        campaignMessagetoUpdate.Status__c = CAMPAIGNMESSAGE_STATUS_SENT;
                        is_Assigned = true;
                    }
                    else if (is_Assigned == false){
                        checkCampaignStatusForLeadAndCorporate(campaignMessagetoUpdate);
                    }
                }
            }

            private void validateExpirationDate(ValidateExpirationDateWrapper validateWrapper){
                 if('leadCampaignSecondTest'.equals(validateWrapper.campaignMessageAfterUpdate.campaign__r.Name)){
                     system.assertEquals(validateWrapper.campRecord9.LastMessageSentDate__c.adddays(validateWrapper.daysToBump), validateWrapper.campaignMessageAfterUpdate.campaign__r.Enddate, 'Unexpected Expiration Date');
                 }
                 else if('corporateCampaignSecondTest'.equals(validateWrapper.campaignMessageAfterUpdate.campaign__r.Name)){
                     system.assertEquals(validateWrapper.campRecord7.StartDate.adddays(validateWrapper.daysToBump), validateWrapper.campaignMessageAfterUpdate.campaign__r.Enddate, 'Unexpected Expiration Date');
                 }
                 else {
                     system.assertEquals(System.today().adddays(60), validateWrapper.campaignMessageAfterUpdate.campaign__r.Enddate, 'Unexpected Expiration Date');
                 }                
             }
        }
}
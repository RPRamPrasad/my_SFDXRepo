/****************************************************************************************
Name: LeadVendorMessageService_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: Test class written for code coverage for LeadVendorMessageService  class
Team: ImpactForce
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Wyatt Lansdale (F0AS)     09/12/2016             Initial Development
2.0             Taylor Bolden             09/12/2016             Modified to add logic   
3.0             Kalimatha Mandadi         09/12/2016             Modified to add logic 
4.0             Zeev Feldbeine            09/29/2016             Modified to add logic
5.0       		Jonathan Elliott    	  10/11/2016             Modified run as user and add logic
6.0         Wyatt Lansdale/Joseph Abell   12/08/2016			 Added Exceptions 
7.0				Billy Neumann			  5/2/2019				 Changed record type id retrieval for FSC
8.0             Krishna Kumari Sanaboina  6/22/2022              Updated external id
******************************************************************************************/
/**
 * @description WS_LeadVendorMessageService_TEST
 */
@isTest(SeeAllData = false)
private class WS_LeadVendorMessageService_TEST {
    
    private static User agentUser;
    private static User processId;
    private static User proxyUser;
    private static String setup_Method_Name = 'setupUserData';
    
    private static String process_Id_Username = 'lvmsProcId@sfa.com';
    private static String agent_Username = 'TestlvmsAgentTest@sfa.com';
    private static String valid_Chatter_Group_Name = 'NewHotProspectNotifications-';
    
    private static String lead_Message_Service_Perm_Set = 'SF_CRM_LeadMessageService_PermSetID';
    
    private static Integer countOfOpportunities = [Select count() From Opportunity];
    private static Integer countOfAccounts = [SELECT count() FROM Account];
    private static Integer countOfAgentRoles = [SELECT count() FROM AgentRole__c];
    private static Integer countOfChatterPosts = [SELECT count() FROM FeedItem];
    
    private static String unittest_Custom_Setting_Url = 'ICP_TP_ENV';
    private static String unittest_Setup_Url = 'unittest.statefarm.com';
    private static WS_LeadVendorMessageService_Wrapper lendorMsgWrap = new WS_LeadVendorMessageService_Wrapper();

    
    @testSetup
    private static void setupUserData() {
        CS001_ByPassTriggerAll__c bypassTriggerAll = new CS001_ByPassTriggerAll__c();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        bypassTriggerAll.Override_All__c = true;
        insert bypassTriggerAll;

        agentUser = setupAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        proxyUser= setupProxyUser();
        processId = setupProcessUser();
        CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
        envCS.name = 'ICP_TP_ENV';
        envCS.value__c = unittest_Setup_Url;
        insert envCS;
    }
    
    //method setup Process User for testing
    /**
     * @description setupProcessUser
     * @return  `User`
     */
    public static User setupProcessUser() {
        String apiDataUserProfileId = getProfileId(UTIL_Constants.API_DATA_USER_ADMIN);
        String adminUserProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        User sysAdminUser = buildUser('lvmsTestAdminUser1@sfa.com', adminUserProfileId);
        User procIDUser;
        System.runAs(sysAdminUser) {
            procIDUser = createUser(buildUser(process_Id_Username, apiDataUserProfileId));
            assignPermissionSet(procIDUser, lead_Message_Service_Perm_Set);
        } 
        return procIdUser;
    }
    //method setup proxy user for testing
    /**
     * @description setupProxyUser
     * @return  `User`
     */
    public static User setupProxyUser()
    {
        String agentUserProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
        String adminUserProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        User sysAdminUser = buildUser('lvmsTestAdminUser3@sfa.com', adminUserProfileId);
        User agent;
        System.runAs(sysAdminUser) {
            User agentTemp = [select id,Proxy_External_ID__c from user where id=:agentUser.id limit 1];
            agent = createUser(buildAgentUser(lendorMsgWrap.proxy_Username , agentUserProfileId, 'lvmsagent', agentTemp.Proxy_External_ID__c, 'lvmsagent', 'lvmsagent', 'lvmsagent', 'lvmsagent'));
        } 
        return agent;
    }
    
    //method setup Agent User for testing
    /**
     * @description setupAgentUser
     * @return  `User`
     */
    public static User setupAgentUser() {
        String agentUserProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
        String adminUserProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        User sysAdminUser = buildUser('lvmsTestAdminUser2@sfa.com', adminUserProfileId);
        User agent;
        System.runAs(sysAdminUser) {
            agent = createUser(buildAgentUser(agent_Username, agentUserProfileId, 'lvmsagent', 'lvmsagent_lvmsagent', 'lvmsagent', 'lvmsagent', 'lvmsagent', 'lvmsagent'));
        } 
        return agent;
    }
    //setupproxyuser
    
    //method to build generic user with the given parameter value
    private static User buildUser(String param_UserName, String param_profileId) {
        User testUser = new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                                 languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                                 username= param_UserName, profileId = param_profileId);
        return testUser;
    }
    
    //method to build agent user with the given parameter value
    /**
     * @description buildAgentUser
     * @param param_userName 
     * @param param_profileId 
     * @param param_associateId 
     * @param param_userExternalId 
     * @param param_servicingAgentAssocId 
     * @param param_territoryAssocId 
     * @param param_servicingAgentAssocIdList 
     * @param param_territoryAssocIdList 
     * @return  `User`
     */
    public static User buildAgentUser(String param_userName, String param_profileId,
                                      String param_associateId, String param_userExternalId,
                                      String param_servicingAgentAssocId, String param_territoryAssocId, 
                                      String param_servicingAgentAssocIdList, String param_territoryAssocIdList) {
                                          User agent = new User(alias = '12345', email='12345@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName', 
                                                                languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Chicago', 
                                                                username= param_userName, profileId = param_profileId, 
                                                                Associate_ID__c=param_associateId, 
                                                                UserExternalID__c= param_userExternalId,
                                                                Servicing_Agent_Associate_ID__c = param_servicingAgentAssocId,
                                                                Territory_Associate_ID__c= param_territoryAssocId,
                                                                Servicing_Agent_Associate_ID_List__c=param_servicingAgentAssocIdList,
                                                                Territory_Associate_ID_List__c=param_territoryAssocIdList);
                                          return agent;
                                      }
    
    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        return profileId;
    }
    
    //method to create user with the given user parameter value
    private static User createUser(User testUser) {
        insert testUser;
        return testUser;
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    //setting up leadAddress for the tests
    private static HLPR_LeadAddress setLeadAddress() {
        HLPR_LeadAddress la = new HLPR_LeadAddress();
        la.address1 = '345 kjsdkfj lkjsdf';
        la.address2 = 'xcnvb';
        la.careOf = 'xcnvb';
        la.city = 'xcnvb';
        la.country = 'xcnvb';
        la.state = 'xx';
        la.type = 'xcnvb';
        la.zip = '872395487';
        
        return la;
    }
    
    //setting up leadClaim for the tests
    private static HLPR_LeadClaim setLeadClaim() {
        HLPR_LeadClaim lc = new HLPR_LeadClaim();
        lc.AmountPaid = '1234';
        lc.ClaimDate = '32488988';
        lc.Description = 'xcnvb';
        lc.TypeOfLoss = 'xcnvb';
        
        return lc;
    }
    
    //setting up HLPR_LeadDriver for the tests
    private static HLPR_LeadDriver setLeadDriver() {
        HLPR_LeadDriver ld = new HLPR_LeadDriver();
        ld.AgeFirstDrivingLicenseIssued = 'xcnvb';
        ld.Bankruptcy = 'xcnvb';
        ld.BankruptcyDate = '23423423';
        ld.BirthDate = '23423423';
        ld.CreditStanding = 'xcnvb';
        ld.DateLicenseWasIssued = '34534534';
        ld.Discounts = '45';
        ld.Education = 'xcnvb';
        ld.Employed = 'xcnvb';
        ld.EmployerAddress = 'xcnvb';
        ld.EmployerName = 'xcnvb';
        ld.FirstName = 'xcnvb';
        ld.Gender = 'M';
        ld.GoodStudent = 'xcnvb';
        ld.LastName = 'xcnvb';
        ld.LicenseNumber = 'xcnvb';
        ld.MaritalStatus = 'xcnvb';
        ld.MiddleName = 'xcnvb';
        ld.RelationToOpportunity = 'xcnvb';
        ld.StateLicenseIssued = 'xcnvb';
        ld.TimeWithEmployer = 'xcnvb';
        ld.Training = 'xcnvb';
        ld.TrainingCompletedDate = '34534534';
        
        return ld;
    }
    
    //setting up HLPR_LeadMovingViolation for the tests
    private static HLPR_LeadMovingViolation setLeadMovingViolation() {
        HLPR_LeadMovingViolation lmv = new HLPR_LeadMovingViolation();
        lmv.ViolationDate = '34534534';
        lmv.ViolationDescription = 'xcnvb';
        lmv.ViolationType = 'xcnvb';
        
        return lmv;
    }
    
    //setting up HLPR_LeadVehicle for the tests
    private static HLPR_LeadVehicle setLeadVehicle() {
        HLPR_LeadVehicle lv= new HLPR_LeadVehicle();
        lv.AirbagType = 'xcnvb';
        lv.CustomizationAmount = '3454';
        lv.Discounts = '45';
        lv.EstimatedAnnualMileage = '3454';
        lv.Make = 'xcnvb';
        lv.MileageOneWay = '23';
        lv.Model = 'xcnvb';
        lv.OdometerReading = '23433';
        lv.Ownership = 'xcnvb';
        lv.Submodel = 'xcnvb';
        lv.VIN = 'xcnvb';
        lv.Year = '2345';
        
        return lv;
    }
    
    //setting up HLPR_LeadDwelling forthe tests
    private static HLPR_LeadDwelling setLeadDwelling() {
        HLPR_LeadDwelling ld = new HLPR_LeadDwelling();
        ld.ConstructionType = 'xcnvb';
        ld.DistanceFireHydrant = '34';
        ld.DistanceFireStation = '34';
        ld.FoundationType = 'xcnvb';
        ld.HasCarportOrGarage = 'xcnvb';
        ld.HasCentralAir = 'xcnvb';
        ld.HasCoveredPatio = 'xcnvb';
        ld.HasDeadboltLocks = 'xcnvb';
        ld.HasDog = 'xcnvb';
        ld.HasFireExtinguisher = 'xcnvb';
        ld.HasFireSprinkler = 'xcnvb';
        ld.HasPool = 'xcnvb';
        ld.HasPoolFence = 'xcnvb';
        ld.HasSecuritySystem = 'xcnvb';
        ld.HasSmokeAlarm = 'xcnvb';
        ld.HeatingType = 'xcnvb';
        ld.NumberOfBathrooms = '4';
        ld.NumberOfBedrooms = '4';
        ld.NumberOfFireplaces = '4';
        ld.NumberOfFloors = '4';
        ld.NumberOfUnits = '4';
        ld.PurchaseDate = 'xcnvb';
        ld.RoofType = 'xcnvb';
        ld.Type = 'xcnvb';
        ld.Value = 'xcnvb';
        ld.WiringType = 'xcnvb';
        ld.WithinCityLimits = 'xcnvb';
        ld.YearBuilt = '4345';
        
        return ld;
    }
    
    //setting up HLPR_LeadBusinessInfo for the tests
    private static HLPR_LeadBusinessInfo setLeadBusinessInfo() {
        HLPR_LeadBusinessInfo lbi = new HLPR_LeadBusinessInfo();
        lbi.AnnualGrossSale = '345';
        lbi.Description = 'xcnvb';
        lbi.EstimatedAnnualCostRentLease = '3455';
        lbi.HasRentedLeasedVehicle = 'xcnvb';
        lbi.JobDuties = 'xcnvb';
        lbi.NumberOfEmployees = '345';
        lbi.PayrollCosts = '435653';
        lbi.SubcontractedDuties = 'xcnvb';
        lbi.TotalCosts = '3454';
        lbi.Type = 'xcnvb';
        lbi.YearsInBusiness = '3454';
        
        return lbi;
    }
    
    //setting up HLPR_LeadLifeInsuredInfo for the tests
    private static HLPR_LeadLifeInsuredInfo setLeadLifeInsuredInfo() {
        HLPR_LeadLifeInsuredInfo llii = new HLPR_LeadLifeInsuredInfo();
        llii.BirthDate = '34534534';
        llii.Employer = 'xcnvb';
        llii.FirstName = 'xcnvb';
        llii.Gender = 'xcnvb';
        llii.HealthCategory = 'xcnvb';
        llii.Height = 'xcnvb';
        llii.LastName = 'xcnvb';
        llii.MaritalStatus = 'xcnvb';
        llii.MiddleName = 'xcnvb';
        llii.Occupation = 'xcnvb';
        llii.RelationshipToOpportunity = 'xcnvb';
        llii.Smoker = 'xcnvb';
        llii.TimeWithEmployer = 'xcnvb';
        llii.Weight = 'xcnvb';
        
        return llii;
    }
    
    //setting up HLPR_LeadCoverage for the tests
    private static HLPR_LeadCoverage setLeadCoverage() {
        HLPR_LeadCoverage lc = new HLPR_LeadCoverage();
        lc.Deductible = 'xcnvb';
        lc.Description = 'xcnvb';
        lc.CoverageLimit = 'xcnvb';
        lc.RequestedOrCurrent = 'xcnvb';
        lc.Type = 'xcnvb';
        
        return lc;
    }
    
    //setting up leadGeneralPartyInfo for the tests
    private static HLPR_LeadGeneralPartyInfo setLeadGeneralPartyInfo() {
        HLPR_LeadGeneralPartyInfo lgpi = new HLPR_LeadGeneralPartyInfo();
        lgpi.Citizenship = 'US';
        lgpi.ContactPreference = 'Home';
        lgpi.Designation = '';
        lgpi.Email = '';
        lgpi.FirstName = '';
        lgpi.HomePhone = '';
        lgpi.InsuranceCancellation = '';
        lgpi.InsuranceCancellationDate = '';
        lgpi.InsuranceCancellationReason = '';
        lgpi.InsuranceRenewalDate = '';
        lgpi.Language = '';
        lgpi.LastName = '';
        lgpi.MiddleName = '';
        lgpi.MilitaryService = '';
        lgpi.MobilePhone = '';
        lgpi.MonthsWithCarrier = '';
        lgpi.NameOfCarrier = '';
        lgpi.TDDPhone = '';
        lgpi.TotalYearsInsured = '';
        lgpi.WorkExtension = '';
        lgpi.WorkPhone = '';
        
        HLPR_LeadAddress la = setLeadAddress();
        lgpi.leadAddressList = new List<HLPR_LeadAddress>{la};
            
            HLPR_LeadClaim lc = setLeadClaim();
        lgpi.leadClaimList = new List<HLPR_LeadClaim>{lc};
            
            HLPR_LeadDriver ld = setLeadDriver();
        lgpi.leadDriverList = new List<HLPR_LeadDriver>{ld};
            
            HLPR_LeadMovingViolation lmv = setLeadMovingViolation();
        lgpi.leadMovingViolationList = new List<HLPR_LeadMovingViolation>{lmv};
            
            HLPR_LeadVehicle lv = setLeadVehicle();
        lgpi.leadVehicleList = new List<HLPR_LeadVehicle>{lv};
            
            HLPR_LeadDwelling ldw = setLeadDwelling();
        lgpi.leadDwellingList = new List<HLPR_LeadDwelling>{ldw};
            
            HLPR_LeadBusinessInfo lbi = setLeadBusinessInfo();
        lgpi.leadBusinessInfoList = new List<HLPR_LeadBusinessInfo>{lbi};
            
            HLPR_LeadLifeInsuredInfo llii = setLeadLifeInsuredInfo();
        lgpi.leadLifeInsuredInfoList = new List<HLPR_LeadLifeInsuredInfo>{llii};
            
            HLPR_LeadCoverage lcv = setLeadCoverage();
        lgpi.leadCoverageList = new List<HLPR_LeadCoverage>{lcv};
            
            return lgpi;
    }
    
    //setting up leadVendorResponse for the tests
    private static HLPR_LeadVendorMessage setLeadVendorMessage(User agent) {   
        HLPR_LeadAccount la=new HLPR_LeadAccount();
        la.ClientID='965751';
        la.AccountType='Individual';
        
        HLPR_LeadAgentRole lar=new HLPR_LeadAgentRole();
        lar.AgentAssociateID=agent.Associate_ID__c;        
        
        HLPR_LeadOpportunity  lo=NEW HLPR_LeadOpportunity();
        lo.Name='lvms-first lastzzz';
        lo.Email = 'lvmsEmail@NOEMAIL.com';
        lo.LeadId = 'lvmsLeadIdzzz';
        lo.LeadTransactionId = 'lvmsLeadTransaIdzzz';
        lo.LeadType = 'Auto';
        lo.LOB = 'Auto';
        lo.Opportunity_Originator = 'Internet Lead Provider';
        lo.OpportunityDetail = 'lvmsOppDetailzzz';
        lo.Phone = '(438) 555-0112';
        lo.Product = 'Floor';
        lo.ProspectCost = 1;
        lo.StageName = 'New';
        lo.Subsidy = 'lvmsSubsizzz';
        lo.ValidatorID  =  'lvmsValidaIdzzz';
        lo.VendorId = 'ILP1';
        lo.externalId = 'lvmsExternalIdzzz';
        lo.leadGeneralPartyInfo = setLeadGeneralPartyInfo();
        
        HLPR_LeadVendorMessage lvm=new HLPR_LeadVendorMessage();
        lvm.leadaccount=la;
        lvm.leadagentrole=lar;
        lvm.leadopportunity=lo;
        lvm.Status='';
        
        
        return lvm;
    } 
    
    //Description: Passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity to test success scenario
    @isTest
    private static void verifySuccessOpportuity() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        HLPR_LeadVendorResponse lvr = new HLPR_LeadVendorResponse();
        
        System.runAs(processId) {
            Test.starttest();
            lvr=WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
            Test.stoptest();
        }
        
        System.assertEquals(countOfAccounts+1, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
        System.assertEquals(countOfAgentRoles+1, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
        System.assertEquals(countOfOpportunities+1, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
        System.assertEquals(2000,lvr.response_code,'Expected value is 2000, but actual value is'+lvr.response_code);
        
    } 
    
    //Description: Passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity to test success scenario
    @isTest
    private static void verifySuccessOpportuityOrganizationSingleName() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadaccount.AccountType='Organization';
        lvm.leadopportunity.Name='lvms-first';
        HLPR_LeadVendorResponse lvr = new HLPR_LeadVendorResponse();
        
        System.runAs(processId) {
            Test.starttest();
            lvr=WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
            Test.stoptest();
        }
        
        System.assertEquals(countOfAccounts+1, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
        System.assertEquals(countOfAgentRoles+1, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
        System.assertEquals(countOfOpportunities+1, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
        System.assertEquals(lendorMsgWrap.countOfLeadGeneralPartyInfos+1, [SELECT count() FROM ILP_Opportunity_General_Party_Info__c],'Expected no.of.records of LeadGeneralPartyInfos should be equal to the actual no.of.records of LeadGeneralPartyInfos'); 
        System.assertEquals(lendorMsgWrap.countOfLeadAddresses+1, [SELECT count() FROM ILP_Opportunity_Address__c],'Expected no.of.records of LeadAddresses should be equal to the actual no.of.records of LeadAddresses'); 
        System.assertEquals(lendorMsgWrap.countOfLeadClaims+1, [SELECT count() FROM ILP_Opportunity_Claim__c],'Expected no.of.records of LeadClaims should be equal to the actual no.of.records of LeadClaims'); 
        System.assertEquals(lendorMsgWrap.countOfLeadDrivers+1, [SELECT count() FROM ILP_Opportunity_Driver__c],'Expected no.of.records of LeadDrivers should be equal to the actual no.of.records of LeadDrivers'); 
        System.assertEquals(lendorMsgWrap.countOfLeadVehicles+1, [SELECT count() FROM ILP_Opportunity_Vehicle__c],'Expected no.of.records of LeadVehicles should be equal to the actual no.of.records of LeadVehicles'); 
        System.assertEquals(lendorMsgWrap.countOfLeadDwellings+1, [SELECT count() FROM ILP_Opportunity_Dwelling__c],'Expected no.of.records of LeadDwellings should be equal to the actual no.of.records of LeadDwellings'); 
        System.assertEquals(lendorMsgWrap.countOfLeadBusinessInfos+1, [SELECT count() FROM ILP_Opportunity_BusinessInfo__c],'Expected no.of.records of LeadBusinessInfos should be equal to the actual no.of.records of LeadBusinessInfos'); 
        System.assertEquals(lendorMsgWrap.countOfLeadLifeInsuredInfos+1, [SELECT count() FROM ILP_Opportunity_LifeInsuredInfo__c],'Expected no.of.records of LeadLifeInsuredInfos should be equal to the actual no.of.records of LeadLifeInsuredInfos'); 
        System.assertEquals(lendorMsgWrap.countOfLeadCoverages+1, [SELECT count() FROM ILP_Opportunity_Coverage__c],'Expected no.of.records of LeadCoverages should be equal to the actual no.of.records of LeadCoverages'); 
        System.assertEquals(lendorMsgWrap.countOfLeadMovingViolations+1, [SELECT count() FROM ILP_Opportunity_Moving_Violation__c],'Expected no.of.records of LeadMovingViolations should be equal to the actual no.of.records of LeadMovingViolations'); 
        System.assertEquals(2000,lvr.response_code,'Expected value is 2000, but actual value is'+lvr.response_code);
        
    } 
    
    //Description: Passing invalid user and trying to Upsert Account,Agent Role and Insert Opportunity to test fail scenario
    @isTest
    private static void verifyFailedOpportunityInvalidAgent() {      
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadagentrole.AgentAssociateID = '';
        System.runAs(processId) {     
            
            Test.starttest();
            
            try {
                WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception e) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(e.getMessage(),System.Label.CL_AgentAssociateID_Invalid_Message,'Expected value is '+e.getMessage()+ ', but actual value is '+System.Label.CL_AgentAssociateID_Invalid_Message);
            }
            Test.stoptest();  
        }    
        
        
        
    }
    
    //Description: Not passing name and trying to Upsert Account,Agent Role and Insert Opportunity to test fail scenario
    @isTest
    private static void verifyFailedOpportunityAccount() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        HLPR_LeadVendorResponse lvr = new HLPR_LeadVendorResponse();
        lvm.leadopportunity.Name = null;
        System.runAs(processId) {
            
            Test.starttest();
            try{    
                lvr=WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
            }
            Test.stoptest();          
        }    
        System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
        System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
        System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
    }
    
    //Description:: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with empty name to test fail scenario
    @isTest
    private static void verifyFailedOpportuityEmptyNameAccount() {        
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        HLPR_LeadVendorResponse lvr = new HLPR_LeadVendorResponse();
        lvm.leadopportunity.Name = '';
        
        System.runAs(processId) {
            
            Test.starttest();
            try {    
                lvr=WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
            }
            Test.stoptest();               
        }       
    }
    
    //Description: passing valid user and trying to Upsert Account,Agent Role with alias null and Insert Opportunity to test fail scenario
    @isTest
    private static void verifyFailedAgentRoleWrithEmpyAliasAccount() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadagentrole.AgentAssociateID = null;
        System.runAs(processId) {        
            Test.starttest();
            try {
                WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception e) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(e.getMessage(),System.Label.CL_AgentAssociateID_Invalid_Message,'Expected value is '+e.getMessage()+ ', but actual value is '+System.Label.CL_AgentAssociateID_Invalid_Message);
            }
            Test.stoptest();  
        }    
    }
    
    //Description: Verify that the post to chatter is not successful (invalid chatter group)
    @isTest
    private static void verifyPostMessagesToChatterFail(){
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = 'invalidCollabGroupLVMS-invl';
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        HLPR_LeadVendorResponse lvr = new HLPR_LeadVendorResponse();
        
        System.runAs(processId) {  
            
            Test.starttest();
            lvr=WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
            Test.stopTest();        
        } 
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem];
        
        System.assertEquals(2000,lvr.response_code,'Expected value is 2000, but actual value is'+lvr.response_code);
        System.assertEquals(countOfChatterPosts, actualCountOfChatterPosts,'Expected value is'+countOfChatterPosts+', but actual value is'+actualCountOfChatterPosts);  
    }
    
    
    
    //Description: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with empty VendorID to test fail scenario
    @isTest
    private static void verifyfailwithemptyVendorID() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadopportunity.VendorId = '';
        System.runAs(processId) {
            
            Test.starttest();
            try {
                WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception e) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
                System.assertEquals(e.getMessage(),System.Label.CL_VendorID_Null_Message,'Expected value is '+e.getMessage()+ ', but actual value is '+System.Label.CL_VendorID_Null_Message); 
            }
            Test.stoptest();         
        }   
    }    
    //Description: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with null VendorID to test fail scenario
    @isTest
    private static void verifyfailwithnullVendorID() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadopportunity.VendorId = null;
        System.runAs(processId) {
            
            Test.starttest();
            try {
                WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception e) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
                System.assertEquals(e.getMessage(),System.Label.CL_VendorID_Null_Message,'Expected value is '+e.getMessage()+ ', but actual value is '+System.Label.CL_VendorID_Null_Message); 
            }
            Test.stoptest();         
        }   
        
        
        
    }
    
    //Description: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with invalid VendorID to test fail scenario
    @isTest
    private static void verifyfailwithinvalidVendorID() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadopportunity.VendorId = 'zzzzzzzzzzzzzzzzz';
        System.runAs(processId) {
            
            Test.starttest();
            try {
                WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception e) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
                System.assertEquals(e.getMessage(),System.Label.CL_VendorID_Invalid_Message,'Expected value is '+e.getMessage()+ ', but actual value is '+System.Label.CL_VendorID_Invalid_Message); 
            }
            Test.stoptest();         
        }   
        
        
        
    }
    
    //Description: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with invalid AccountType to test fail scenario
    @isTest
    private static void verifyfailwithinvalidAccountType() {
        
        processId = [SELECT id FROM User WHERE Username=:process_Id_Username LIMIT 1];
        agentUser = [SELECT id, Alias, Associate_ID__c FROM User WHERE Username=:agent_Username LIMIT 1];
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = valid_Chatter_Group_Name+agentUser.Alias;
            chatterGroup.OwnerId = agentUser.Id;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        HLPR_LeadVendorMessage lvm = setLeadVendorMessage(agentUser);
        lvm.leadaccount.AccountType = 'zzzzzzz';
        System.runAs(processId) {
            
            Test.starttest();
            try {
                WS_LeadVendorMessageService.createLeadVendorMessage(lvm);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception e) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Accounts should be equal to the actual no.of.records of Accounts');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
                System.assertEquals(e.getMessage(),System.Label.CL_AccountType_Invalid_Message,'Expected value is '+e.getMessage()+ ', but actual value is '+System.Label.CL_AccountType_Invalid_Message); 
            }
            Test.stoptest();         
        }           
    }  
    
    private class WS_LeadVendorMessageService_Wrapper{
        private Integer countOfLeadGeneralPartyInfos = [SELECT count() FROM ILP_Opportunity_General_Party_Info__c];
        private Integer countOfLeadAddresses = [SELECT count() FROM ILP_Opportunity_Address__c];
        private Integer countOfLeadClaims = [SELECT count() FROM ILP_Opportunity_Claim__c];
        private Integer countOfLeadDrivers = [SELECT count() FROM ILP_Opportunity_Driver__c];
        private Integer countOfLeadVehicles = [SELECT count() FROM ILP_Opportunity_Vehicle__c];
        private Integer countOfLeadDwellings = [SELECT count() FROM ILP_Opportunity_Dwelling__c];
        private Integer countOfLeadBusinessInfos = [SELECT count() FROM ILP_Opportunity_BusinessInfo__c];
        private Integer countOfLeadLifeInsuredInfos = [SELECT count() FROM ILP_Opportunity_LifeInsuredInfo__c];
        private Integer countOfLeadCoverages = [SELECT count() FROM ILP_Opportunity_Coverage__c];
        private Integer countOfLeadMovingViolations = [SELECT count() FROM ILP_Opportunity_Moving_Violation__c];
        private String proxy_Username= 'TestlvmsProxyTest@sfa.com';
        private String class_Name = 'WS_LeadVendorMessageService_TEST';
    }
}
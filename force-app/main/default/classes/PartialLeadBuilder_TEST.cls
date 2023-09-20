/**
 * @Name: PartialLeadBuilder_TEST
 * Author : Golden Spikes Team
 * @description : Test class for PartialLeadBuilder apex class.
 */
@isTest(SeeAllData=false)
private class PartialLeadBuilder_TEST {
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static final String LEAD_SOURCE_MAPPING_TYPE = 'External Lead Service';
    private static final String EVENT_LEAD_SERVICE_PERM_SET = 'SF_CRM_EventLeadOppMgmt_PermSetPID';

    @TestSetup
    private static void setUpUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User agentUser;
        CS001_ByPassTriggerAll__c byPassAllTrigger;
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'sysemAdmin', 'LdCrAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        System.runAs(adminUser) {
            byPassAllTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert byPassAllTrigger;
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;
            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser1 = new User(Alias='CrLd',LastName='CrLd1',Username='CrLd' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='11d11122zzc',UserExternalID__c='11d11122zzc_11d11122zzc',Servicing_Agent_Associate_ID__c='11d11122zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            User testProxyUser1 = new User(Alias='LdMt',LastName='LdAgnt',Username='LdPrx' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='11d11122zzcP',Servicing_Agent_Associate_ID__c='11d11122zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User procIdUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('ev2tLd2PrId1Us123@sfa222.test.com');
            insert procIdUser;
            PermissionSet queryPermissionSet = [SELECT id FROM PermissionSet WHERE Name = :EVENT_LEAD_SERVICE_PERM_SET LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = procIdUser.id, PermissionSetId = queryPermissionSet.id);
            CS001_ByPassTriggerAll__c passTriggerAll = [SELECT Override_All__c FROM CS001_ByPassTriggerAll__c];
            passTriggerAll.Override_All__c = false;
            update passTriggerAll;
            Lead partialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUser.Id, External_Lead_ID__c = 'P1234', 
                LastName = 'TestPartialLead', Status = 'Open', LeadSource = 'Enterprise Facebook Lead', DateCaptured__c = System.today(),
                RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert partialLeadRecord;
        }
    }

    //method to test the Partial Lead scenario
    @isTest private static void testBuildLeadForPartialLead() {
        User procIdUser = [SELECT Id FROM User WHERE username = 'ev2tLd2PrId1Us123@sfa222.test.com' LIMIT 1];
        User proxyUser = [SELECT Id FROM User WHERE UserExternalId__c = '11d11122zzcP' LIMIT 1];
        CMOpportunityMapping__mdt optyMappingMDT = [SELECT Description__c, ExternalLeadSource__c,
            LeadSource__c, OpportunityOriginator__c, MarketingSource__c, MarketingSubSource__c FROM CMOpportunityMapping__mdt
            WHERE MappingType__c = :LEAD_SOURCE_MAPPING_TYPE AND ExternalLeadSource__c = 'FB' LIMIT 1];
        HLPR_CreateLeadRequest.LeadInformation newLead = new HLPR_CreateLeadRequest.LeadInformation();
        List<HLPR_CreateLeadRequest.LineOfBusinessDetails> leadLobList = new List<HLPR_CreateLeadRequest.LineOfBusinessDetails>();
        HLPR_CreateLeadRequest.LineOfBusinessDetails leadsLobDetails1 = new HLPR_CreateLeadRequest.LineOfBusinessDetails();
        leadsLobDetails1.lob = 'Auto';
        leadsLobDetails1.product = 'Private Passenger';
        HLPR_CreateLeadRequest.LineOfBusinessDetails leadsLobDetails2 = new HLPR_CreateLeadRequest.LineOfBusinessDetails();
        leadsLobDetails2.lob = 'Fire';
        leadsLobDetails2.product = '';
        leadLobList.add(leadsLobDetails1);
        leadLobList.add(leadsLobDetails2);
        newLead.firstName = 'TestFName';
        newLead.lastName = 'TestLName';
        HLPR_LeadAddressInfo leadAddressInfo = new HLPR_LeadAddressInfo();
        leadAddressInfo.street = '1234 Main St.';
        leadAddressInfo.city = 'Bloomington';
        leadAddressInfo.state = 'IL';
        leadAddressInfo.postalCode = '61704';
        newLead.addressInfo = leadAddressInfo;
        HLPR_LeadEstimationInfo leadEstimateInformation = new HLPR_LeadEstimationInfo();
        leadEstimateInformation.typeOfBusiness = 'Yogurt Shop';
        leadEstimateInformation.workLocation = 'I lease my space.';
        leadEstimateInformation.contentsAmount = '$74';
        leadEstimateInformation.additionalLiabilityAmount = '$87';
        leadEstimateInformation.premium = '$67 - 78/ month';
        leadEstimateInformation.liabilityAmount = '$27';
        leadEstimateInformation.payrollAmount = '$37';
        leadEstimateInformation.squareFootageAmount = '$47';
        leadEstimateInformation.numberOfOwners = 17;
        leadEstimateInformation.numberOfDens = '87';
        leadEstimateInformation.estimatedAnnualSales = '$57 - 68/ month';
        newLead.leadEstimatorInfo = leadEstimateInformation;
        newLead.email = 'agt8@statefarm.com';
        newLead.mobilePhone = '222-333-4444';
        newLead.phone = '800-555-1212';
        newLead.externalLeadId = 'P1234';
        newLead.externalLeadSource = 'FB';
        newLead.capturedDateTime = Datetime.newInstance(2019, 4, 16, 0, 0, 0);
        newLead.sCode = 'S17377';
        newLead.leadScore = 7;
        newLead.agentAssociateID = '11d11122zzc';
        newLead.lobDetails = leadLobList;
        PartialLeadBuilder.LeadRequest request = new PartialLeadBuilder.LeadRequest();
        request.ldInfo = newLead;
        request.agentProxySFDCID = proxyUser.Id;
        request.isCCCEligible = true;
        request.ldSourceMapping = optyMappingMDT;
        Lead newFBLead;
        System.runAs(procIdUser) {
            Test.starttest();
            newFBLead = PartialLeadBuilder.buildLead(request);
            Test.stoptest();
            System.assertEquals('TestFName', newFBLead.FirstName, 'Lead First Name is Incorrect.');
            System.assertEquals('TestLName', newFBLead.LastName, 'Lead Last Name is Incorrect.');
            System.assertEquals(leadRecordTypeMap.get('PartialLead').getRecordTypeId(), newFBLead.RecordTypeId, 'Lead Record Type is Incorrect.');
            System.assertEquals(proxyUser.Id, newFBLead.OwnerId, 'Lead Owner Id is Incorrect.');
            System.assertEquals('US', newFBLead.Country, 'Lead Country is Incorrect.');
            System.assertEquals('61704', newFBLead.PostalCode, 'Lead Postal Code is Incorrect.');
            System.assertEquals('agt8@statefarm.com', newFBLead.Email, 'Lead Email is Incorrect.');
            System.assertEquals(Datetime.newInstance(2019, 4, 16, 0, 0, 0), newFBLead.DateCaptured__c, 'Lead Date Captured is Incorrect.');
            System.assertEquals('11d11122zzc', newFBLead.AgentAssociateId__c, 'Lead Agent Associate Id is Incorrect.');
            System.assert((newFBLead.Description).contains('Auto-Private Passenger / Fire'), 'Lead Description is Incorrect.');
            System.assertEquals('Auto;Fire', newFBLead.MultiLOB__c, 'Lead Multi LOB is Incorrect.');
            System.assertEquals('Private Passenger;', newFBLead.Product__c, 'Lead Product is Incorrect.');
            System.assertEquals(optyMappingMDT.LeadSource__c, newFBLead.LeadSource, 'Lead Lead Source is Incorrect.');
            System.assertEquals('1234 Main St.', newFBLead.Street, 'Lead Street is Incorrect.');
            System.assertEquals('Bloomington', newFBLead.City, 'Lead City is Incorrect.');
            System.assertEquals(newLead.externalLeadId, newFBLead.External_Lead_ID__c, 'Lead External Lead Id is Incorrect.');
            System.assertEquals(newLead.mobilePhone, newFBLead.SubmittedMobilePhoneNumber__c, 'Lead Mobile Phone is Incorrect.');
            System.assertEquals(newLead.phone, newFBLead.Submitted_Phone_Number__c, 'Lead Phone is Incorrect.');
            System.assertEquals(newLead.leadScore, newFBLead.LeadScore__c, 'Lead Score is Incorrect.');
            System.assertEquals('Hot', newFBLead.LeadTemperature__c, 'Lead Temperature is Incorrect.');
            System.assertEquals('Yogurt Shop', newFBLead.BusinessType__c, 'Business Type is Incorrect.');
            System.assertEquals('I lease my space.', newFBLead.WorkLocation__c, 'Work Location is Incorrect.');
            System.assertEquals('$74', newFBLead.InventoryEquipmentCoverage__c, 'Inventory Equipment Coverage is Incorrect.');
            System.assertEquals('$87', newFBLead.LiabilityCoveragelimit__c, 'Liability Coverage Limit is Incorrect.');
            System.assertEquals('$67 - 78/ month', newFBLead.EstimatedPremium__c, 'Estimated Premium is Incorrect.');
            System.assertEquals('$27', newFBLead.LiabilityAmount__c, 'Liability Amount is Incorrect.');
            System.assertEquals('$37', newFBLead.PayrollAmount__c, 'Payroll Amount is Incorrect.');
            System.assertEquals('$47', newFBLead.SquareFootageAmount__c, 'Square Footage Amount is Incorrect.');
            System.assertEquals(17, newFBLead.NumberOfOwners__c, 'Number of Owners is Incorrect.');
            System.assertEquals('87', newFBLead.NumberOfDens__c, 'Number of Dens is Incorrect.');
            System.assertEquals('$57 - 68/ month', newFBLead.EstimatedAnnualSales__c, 'Estimated Annual Sales is Incorrect.');
        }
    }
}

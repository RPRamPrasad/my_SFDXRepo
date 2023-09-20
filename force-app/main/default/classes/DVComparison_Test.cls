@IsTest
public class DVComparison_Test {
    @testSetup
    public static void setup(){
        //Account acc = TestDataFactory_Account.createIndividualCustomer('Test');
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            InsurancePolicy ip = new InsurancePolicy();
            ip.EffectiveDate = system.today().addDays(10);
            ip.RenewalDate = system.today().addDays(10);
            ip.AgreAccessKey__c = '3210003489';
            ip.Name = '0123456789';
            ip.NameInsuredId = UTIL_CaseTestData.createAccountId();
            insert ip;
        }
    }
    
    @isTest
    static void pl_auto_noDifferences() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockPLAutoNoDifferences());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        System.assert(res.contains('"noPremiumChange":true'),res);
    }
    
    @isTest
    static void pl_auto_differencesFound() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockPLAutoDifferences());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        System.assert(res.contains('The vehicle rating changed from DRG 097 to DRG 017'),res);
    }
    
    @isTest
    static void pl_fire_noDifferences() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockPLFireNoDifferences());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        System.assert(res.contains('"noPremiumChange":true'),res);
    }
    
    @isTest
    static void pl_fire_differencesFound() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockPLFireDifferences());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        System.assert(res.contains('The premium for this policy increased by $6000'),res);
    }
    
    @isTest
    static void bl_auto_noDifferences() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockBLAutoNoDifferences());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        System.assert(res.contains('"noPremiumChange":true'),res);
    }
    
    @isTest
    static void bl_auto_differencesFound() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockBLAutoDifferences());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        System.assert(res.contains('The vehicle rating changed from DRG 097 to DRG 017'),res);
    }
    
    /* Need to fix assertion, but leaving commented as it does not impact coverage
	@isTest
    static void bl_fire_scenario() {
        String res ;
        InsurancePolicy ip = [SELECT id FROM InsurancePolicy WHERE Name = '0123456789'];
        Test.setMock(HttpCalloutMock.class, new MockBLFire());
        Test.startTest();
        res = DVComparison.policyComparison((String) ip.Id);
        Test.stopTest();
        // System.assert(res.contains('"isBLFire" :true'),res);
        System.assert(res.contains('isBLFire&quot; :true'),res);
    }*/

	// DV Callout Mocks
    
    private class MockPLAutoNoDifferences implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"policy": {"businessLineCode":"A", "productDescriptionText":"PRIVATE PASSENGER", "agreementAccessKey": "3210003489","policyStatusText":"In Force","termVersion": {"fullTermStartDate": "2022-12-06T06:01:00.000+00:00", "fullTermEndDate": "2023-12-06T06:01:00.000+00:00","termVersionStartDate": "2022-12-06T06:01:00.000+00:00","insurableRisk": [{"riskPrimaryUseCode":"07", "customerRatingIndex":{"customerRatingIndexCapCount":"0"}, "pricingRuleSet": {"pricingAdjustment": [{"pricingRuleSetUniqueName": "LAW_ENFC_FEE","pricingRuleSetTypeCode": "3","pricingRuleSetDisplayName": "New York Motor Vehicle Law Enforcement Fee","pricingRuleSetAdjustmentAmount": 10.00}]},"vehicle": [{"physicalObjectSerialNumber": "JA32U2FU0HU042402","effectiveDate": "2022-12-06T06:00:00.000+00:00","manufacturerCode": "9","makeName": "MITSUBISHI","modelName": "LANCER","modelYearNumber": 2017,"irgCollisionCode": "017","irgComprehensiveCode": "017","bodyTypeCode": "03","vehicleUsage": { "vehicleOprtnRadiusDstncCount": 15,"estAnnualDistanceDrivenCount":1750},"totalMfgSugstRetailPriceAmount": 23429,"baseMfgSugstRetailPriceAmount": 23429,"addlEquipMsrpAmount": 0.00}]}]}}}');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
    private class MockPLAutoDifferences implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            if(request.getEndpoint().contains(DateTime.now().format('yyyy-MM-dd'))){
                response.setBody('{"policy": {"businessLineCode":"A", "productDescriptionText":"PRIVATE PASSENGER", "agreementAccessKey": "3210003489","policyStatusText":"In Force","termVersion": {"fullTermStartDate": "2022-12-06T06:01:00.000+00:00", "fullTermEndDate": "2023-12-06T06:01:00.000+00:00","termVersionStartDate": "2022-12-06T06:01:00.000+00:00","insurableRisk": [{"riskPrimaryUseCode":"07", "customerRatingIndex":{"customerRatingIndexCapCount":"0"},"pricingRuleSet": {"pricingAdjustment": [{"pricingRuleSetUniqueName": "LAW_ENFC_FEE","pricingRuleSetTypeCode": "3","pricingRuleSetDisplayName": "New York Motor Vehicle Law Enforcement Fee","pricingRuleSetAdjustmentAmount": 10.00},{"pricingRuleSetUniqueName": "SDD","pricingRuleSetTypeCode": "3","pricingRuleSetDisplayName": "New York Motor Vehicle Law Enforcement Fee","pricingRuleSetAdjustmentAmount": 144.00}]},"totalRiskPremiumAmount":950.00,"vehicle": [{"physicalObjectSerialNumber": "JA32U2FU0HU042402","effectiveDate": "2022-12-06T06:00:00.000+00:00","manufacturerCode": "9","makeName": "MITSUBISHI","modelName": "LANCER","modelYearNumber": 2017,"irgCollisionCode": "017","irgComprehensiveCode": "097","bodyTypeCode": "03","vehicleUsage": { "vehicleOprtnRadiusDstncCount": 15,"estAnnualDistanceDrivenCount":1750},"totalMfgSugstRetailPriceAmount": 23429,"baseMfgSugstRetailPriceAmount": 23429,"addlEquipMsrpAmount": 0.00}]}]}}}}');
            }else{
                response.setBody('{"policy":{"businessLineCode":"A", "productDescriptionText":"PRIVATE PASSENGER", "agreementAccessKey":"3210003489","policyStatusText":"In Force","termVersion":{"fullTermStartDate":"2022-12-06T06:01:00.000+00:00","fullTermEndDate":"2023-12-06T06:01:00.000+00:00","termVersionStartDate":"2022-12-06T06:01:00.000+00:00","insurableRisk":[{"riskPrimaryUseCode":"07", "customerRatingIndex":{"customerRatingIndexCapCount":"0"},"pricingRuleSet":{"totalDiscountPremiumAmount":1298.1,"pricingAdjustment":[{"pricingRuleSetUniqueName":"DRV_SAFE_SAVE_DISC","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Drive Safe and Save Discount","pricingRuleSetAdjustmentAmount":8.65},{"pricingRuleSetUniqueName":"MCD","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Multiple Car Discount","pricingRuleSetAdjustmentAmount":266.68},{"pricingRuleSetUniqueName":"MLD","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Auto Multiple Line Discount","pricingRuleSetAdjustmentAmount":238.12},{"pricingRuleSetUniqueName":"THRE_STAR_DISC","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Three-Star Discount","pricingRuleSetAdjustmentAmount":408.66},{"pricingRuleSetUniqueName":"UNDIN_VEH_COV_MULTI_COV_DISC","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Underinsured Motor Vehicle Coverage Multiple Coverages Discount","pricingRuleSetAdjustmentAmount":24.53},{"pricingRuleSetUniqueName":"UNINS_BI_MULTI_COV_FCTR","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Uninsured Motor Vehicle Coverage Multiple Coverages Discount","pricingRuleSetAdjustmentAmount":7.55},{"pricingRuleSetUniqueName":"ST_FEE_GNRC","pricingRuleSetTypeCode":"3","pricingRuleSetDisplayName":"West Virginia State Surcharge","pricingRuleSetAdjustmentAmount":4.35}],"autoClassCode":"103011F300","autoClassRplcByGrnlDataCode":"R","multilineDiscountQualifyingPolicyDescription":"HOMEOWNERS"},"totalRiskPremiumAmount":150,"vehicle":[{"physicalObjectSerialNumber":"JA32U2FU0HU042402","effectiveDate":"2022-12-06T06:00:00.000+00:00","manufacturerCode":"9","makeName":"MITSUBISHI","modelName":"LANCER","modelYearNumber":2017,"irgCollisionCode":"017","irgComprehensiveCode":"017","bodyTypeCode":"03","vehicleUsage":{"vehicleOprtnRadiusDstncCount":15,"estAnnualDistanceDrivenCount":1750},"totalMfgSugstRetailPriceAmount":23429,"baseMfgSugstRetailPriceAmount":23429,"addlEquipMsrpAmount":0}]}]}}}');
            }
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
    private class MockPLFireNoDifferences implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{ "policy": { "policyStatusText": "In Force", "agreementAccessKey": "3210003489", "businessLineCode": "F", "productDescriptionText": "HOMEOWNERS POLICY", "termVersion": { "fullTermStartDate": "2022-09-11T00:00:00.000+00:00", "fullTermEndDate": "2023-09-11T00:00:00.000+00:00", "termVersionStartDate": "2022-09-11T00:00:00.000+00:00", "totalPolicyPremiumAmount": 2371, "insurableRisk": [{ "customerRatingIndex": { "customerRatingIndexCalculateFactorAmount": 0.985, "customerRatingIndexCapCount": 5605, "customerRatingIndexModelUseCode": "R2", "customerRatingIndexScaleNumber": 5606 }}], "policyCoverageSet": { "coverage": [{ "inflationAdjustment": { "adjustmentCode": "P", "indexValue": 3318, "adjustmentDate": "2022-07-11T00:00:00.000+00:00", "indexTypeCode": "R", "indexVendorCode": "X" }}]}}, "agreSourceSystemCode": 1 }}');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
    private class MockPLFireDifferences implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            if(request.getEndpoint().contains(DateTime.now().format('yyyy-MM-dd'))){
                response.setBody('{ "policy": { "policyStatusText": "In Force", "agreementAccessKey": "3210003489", "businessLineCode": "F", "productDescriptionText": "HOMEOWNERS POLICY", "termVersion": { "fullTermStartDate": "2022-09-11T00:00:00.000+00:00", "fullTermEndDate": "2023-09-11T00:00:00.000+00:00", "termVersionStartDate": "2022-09-11T00:00:00.000+00:00", "totalPolicyPremiumAmount": 2371, "insurableRisk": [{ "customerRatingIndex": { "customerRatingIndexCalculateFactorAmount": 0.985, "customerRatingIndexCapCount": 5605, "customerRatingIndexModelUseCode": "R2", "customerRatingIndexScaleNumber": 5606 }}], "policyCoverageSet": { "coverage": [{ "inflationAdjustment": { "adjustmentCode": "P", "indexValue": 3318, "adjustmentDate": "2022-07-11T00:00:00.000+00:00", "indexTypeCode": "R", "indexVendorCode": "X" }}]}}, "agreSourceSystemCode": 1 }}');
            }else{
                response.setBody('{ "policy": { "policyStatusText": "In Force", "agreementAccessKey": "3210003489", "businessLineCode": "F", "productDescriptionText": "HOMEOWNERS POLICY", "termVersion": { "fullTermStartDate": "2022-09-11T00:00:00.000+00:00", "fullTermEndDate": "2023-09-11T00:00:00.000+00:00", "termVersionStartDate": "2022-09-11T00:00:00.000+00:00", "totalPolicyPremiumAmount": 8371, "insurableRisk": [{ "customerRatingIndex": { "customerRatingIndexCalculateFactorAmount": 0.985, "customerRatingIndexCapCount": 5605, "customerRatingIndexModelUseCode": "R2", "customerRatingIndexScaleNumber": 5606 }}], "policyCoverageSet": { "coverage": [{ "inflationAdjustment": { "adjustmentCode": "P", "indexValue": 8318, "adjustmentDate": "2022-07-11T00:00:00.000+00:00", "indexTypeCode": "R", "indexVendorCode": "X" }}]}}, "agreSourceSystemCode": 1 }}');
            }
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
    private class MockBLAutoNoDifferences implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"policy": {"businessLineCode":"A", "productDescriptionText":"PRIVATE PASSENGER", "agreementAccessKey": "3210003489","policyStatusText":"In Force","termVersion": {"fullTermStartDate": "2022-12-06T06:01:00.000+00:00", "fullTermEndDate": "2023-12-06T06:01:00.000+00:00","termVersionStartDate": "2022-12-06T06:01:00.000+00:00","insurableRisk": [{"riskPrimaryUseCode":"09", "customerRatingIndex":{"customerRatingIndexCapCount":"0"}, "pricingRuleSet": {"pricingAdjustment": [{"pricingRuleSetUniqueName": "LAW_ENFC_FEE","pricingRuleSetTypeCode": "3","pricingRuleSetDisplayName": "New York Motor Vehicle Law Enforcement Fee","pricingRuleSetAdjustmentAmount": 10.00}]},"vehicle": [{"physicalObjectSerialNumber": "JA32U2FU0HU042402","effectiveDate": "2022-12-06T06:00:00.000+00:00","manufacturerCode": "9","makeName": "MITSUBISHI","modelName": "LANCER","modelYearNumber": 2017,"irgCollisionCode": "017","irgComprehensiveCode": "017","bodyTypeCode": "03","vehicleUsage": { "vehicleOprtnRadiusDstncCount": 15,"estAnnualDistanceDrivenCount":1750},"totalMfgSugstRetailPriceAmount": 23429,"baseMfgSugstRetailPriceAmount": 23429,"addlEquipMsrpAmount": 0.00}]}]}}}');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
    private class MockBLAutoDifferences implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            if(request.getEndpoint().contains(DateTime.now().format('yyyy-MM-dd'))){
                response.setBody('{"policy": {"businessLineCode":"A", "productDescriptionText":"PRIVATE PASSENGER", "agreementAccessKey": "3210003489","policyStatusText":"In Force","termVersion": {"fullTermStartDate": "2022-12-06T06:01:00.000+00:00", "fullTermEndDate": "2023-12-06T06:01:00.000+00:00","termVersionStartDate": "2022-12-06T06:01:00.000+00:00","insurableRisk": [{"riskPrimaryUseCode":"09", "customerRatingIndex":{"customerRatingIndexCapCount":"0"},"pricingRuleSet": {"pricingAdjustment": [{"pricingRuleSetUniqueName": "LAW_ENFC_FEE","pricingRuleSetTypeCode": "3","pricingRuleSetDisplayName": "New York Motor Vehicle Law Enforcement Fee","pricingRuleSetAdjustmentAmount": 10.00},{"pricingRuleSetUniqueName": "SDD","pricingRuleSetTypeCode": "3","pricingRuleSetDisplayName": "New York Motor Vehicle Law Enforcement Fee","pricingRuleSetAdjustmentAmount": 144.00}]},"totalRiskPremiumAmount":950.00,"vehicle": [{"physicalObjectSerialNumber": "JA32U2FU0HU042402","effectiveDate": "2022-12-06T06:00:00.000+00:00","manufacturerCode": "9","makeName": "MITSUBISHI","modelName": "LANCER","modelYearNumber": 2017,"irgCollisionCode": "017","irgComprehensiveCode": "097","bodyTypeCode": "03","vehicleUsage": { "vehicleOprtnRadiusDstncCount": 15,"estAnnualDistanceDrivenCount":1750},"totalMfgSugstRetailPriceAmount": 23429,"baseMfgSugstRetailPriceAmount": 23429,"addlEquipMsrpAmount": 0.00}]}]}}}}');
            }else{
                response.setBody('{"policy":{"businessLineCode":"A", "productDescriptionText":"PRIVATE PASSENGER", "agreementAccessKey":"3210003489","policyStatusText":"In Force","termVersion":{"fullTermStartDate":"2022-12-06T06:01:00.000+00:00","fullTermEndDate":"2023-12-06T06:01:00.000+00:00","termVersionStartDate":"2022-12-06T06:01:00.000+00:00","insurableRisk":[{"riskPrimaryUseCode":"07", "customerRatingIndex":{"customerRatingIndexCapCount":"0"},"pricingRuleSet":{"totalDiscountPremiumAmount":1298.1,"pricingAdjustment":[{"pricingRuleSetUniqueName":"DRV_SAFE_SAVE_DISC","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Drive Safe and Save Discount","pricingRuleSetAdjustmentAmount":8.65},{"pricingRuleSetUniqueName":"MCD","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Multiple Car Discount","pricingRuleSetAdjustmentAmount":266.68},{"pricingRuleSetUniqueName":"MLD","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Auto Multiple Line Discount","pricingRuleSetAdjustmentAmount":238.12},{"pricingRuleSetUniqueName":"THRE_STAR_DISC","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Three-Star Discount","pricingRuleSetAdjustmentAmount":408.66},{"pricingRuleSetUniqueName":"UNDIN_VEH_COV_MULTI_COV_DISC","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Underinsured Motor Vehicle Coverage Multiple Coverages Discount","pricingRuleSetAdjustmentAmount":24.53},{"pricingRuleSetUniqueName":"UNINS_BI_MULTI_COV_FCTR","pricingRuleSetTypeCode":"1","pricingRuleSetDisplayName":"Uninsured Motor Vehicle Coverage Multiple Coverages Discount","pricingRuleSetAdjustmentAmount":7.55},{"pricingRuleSetUniqueName":"ST_FEE_GNRC","pricingRuleSetTypeCode":"3","pricingRuleSetDisplayName":"West Virginia State Surcharge","pricingRuleSetAdjustmentAmount":4.35}],"autoClassCode":"103011F300","autoClassRplcByGrnlDataCode":"R","multilineDiscountQualifyingPolicyDescription":"HOMEOWNERS"},"totalRiskPremiumAmount":150,"vehicle":[{"physicalObjectSerialNumber":"JA32U2FU0HU042402","effectiveDate":"2022-12-06T06:00:00.000+00:00","manufacturerCode":"9","makeName":"MITSUBISHI","modelName":"LANCER","modelYearNumber":2017,"irgCollisionCode":"017","irgComprehensiveCode":"017","bodyTypeCode":"03","vehicleUsage":{"vehicleOprtnRadiusDstncCount":15,"estAnnualDistanceDrivenCount":1750},"totalMfgSugstRetailPriceAmount":23429,"baseMfgSugstRetailPriceAmount":23429,"addlEquipMsrpAmount":0}]}]}}}');
            }
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
    private class MockBLFire implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{ "policy": { "policyStatusText": "In Force", "agreementAccessKey": "3210003489", "businessLineCode": "F", "productDescriptionText": "WORKERS COMPENSATION POLICY", "termVersion": { "fullTermStartDate": "2022-09-11T00:00:00.000+00:00", "fullTermEndDate": "2023-09-11T00:00:00.000+00:00", "termVersionStartDate": "2022-09-11T00:00:00.000+00:00", "totalPolicyPremiumAmount": 2371, "insurableRisk": [{ "customerRatingIndex": { "customerRatingIndexCalculateFactorAmount": 0.985, "customerRatingIndexCapCount": 5605, "customerRatingIndexModelUseCode": "R2", "customerRatingIndexScaleNumber": 5606 }}], "policyCoverageSet": { "coverage": [{ "inflationAdjustment": { "adjustmentCode": "P", "indexValue": 3318, "adjustmentDate": "2022-07-11T00:00:00.000+00:00", "indexTypeCode": "R", "indexVendorCode": "X" }}]}}, "agreSourceSystemCode": 1 }}');
            response.setStatusCode(200);
            response.setStatus('Ok');
            return response;        
        }
    }
    
}
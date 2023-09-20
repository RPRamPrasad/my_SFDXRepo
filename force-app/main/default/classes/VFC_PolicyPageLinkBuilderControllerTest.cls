@isTest
(seeAllData=false)
public class VFC_PolicyPageLinkBuilderControllerTest {
    
    @isTest
    private static void testRedirectToAutoPolicyPage() {
        setTestDataPageParams('110', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyData = setupMockQueryResult();
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=13'), 'Redirect URL should re-use/re-direct to LinkId 13');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testRedirectToAutoPolicyPageUsingSNI() {
        setTestDataPageParams('110', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyParticipantData = setupMockParticipantQueryResult();
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=13'), 'Redirect URL should re-use/re-direct to LinkId 13');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testNoPolicyFoundException() {
        setTestDataPageParams('110', 'ABC');
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        policyPageLinkBuilder.redirectToPolicyPageLink();
        List<ExceptionLog__c> testException = getException();
        System.assert(testException.size() == 1, 'Exception not thrown');
        Test.stopTest();
    }
    
    @isTest
    private static void testRedirectToFirePolicyPage() {
        setTestDataPageParams('113', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyData = setupMockQueryResult();
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=9'), 'Redirect URL should re-use/re-direct to LinkId 9');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testRedirectToFirePolicyPageUsingSNI() {
        setTestDataPageParams('113', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyParticipantData = setupMockParticipantQueryResult();
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=9'), 'Redirect URL should re-use/re-direct to LinkId 9');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testRedirectToFireHomeownersPolicyPage() {
        setTestDataPageParams('113', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyData = setupMockQueryResult();
        ApexPages.currentPage().getParameters().put('productDescription', 'homeowners');
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=24'), 'Redirect URL should re-use/re-direct to LinkId 24');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testRedirectToFireHomeownersPolicyPageUsingSNI() {
        setTestDataPageParams('113', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyParticipantData = setupMockParticipantQueryResult();
        ApexPages.currentPage().getParameters().put('productDescription', 'homeowners');
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=24'), 'Redirect URL should re-use/re-direct to LinkId 24');
        Test.stopTest(); 
    }

    @isTest
    private static void testRedirectToHagertyPolicyPage() {
        setTestDataPageParams('267', 'ABC');
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyData = setupMockQueryResult();
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=267'), 'Redirect URL should re-use/re-direct to LinkId 267');
        System.assert(redirectPolicyPage.getUrl().contains('&agentAssocId='), 'Redirect URL should contain agent associate id');
        Test.stopTest();
    }
    
    @isTest
    private static void testRedirectToHealthPolicyPage() {       
        setTestDataPageParams('114', 'ABC');
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('LinkId=9'), 'Redirect URL should re-use/re-direct to Health LinkId on Account Page ');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testHealthMethodException() {       
        setTestDataPageParams('114', 'ABC');
        ApexPages.currentPage().getParameters().put('accountId', null);
        Test.startTest();
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        List<ExceptionLog__c> testException = getException();
        System.assert(testException.size() == 1, 'Exception not thrown');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testEmptyAgentAssocIdShouldBeOutOfBook() {       
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyData = setupMockQueryResult();
        VFC_PolicyPageLinkBuilderController.currentUser = new User(Servicing_Agent_Associate_ID__c = '1234');
        setTestDataPageParams('111', '');
        Test.startTest();       
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('outOfBookIndicator=TRUE'), 'Redirect URL should be Out of Book');
        Test.stopTest(); 
    }
    
    @isTest
    private static void testEmptyAgentAssocIdShouldBeOutOfBookUsingSNI() {       
        VFC_PolicyPageLinkBuilderController.mockInsurancePolicyParticipantData = setupMockParticipantQueryResult();
        VFC_PolicyPageLinkBuilderController.currentUser = new User(Servicing_Agent_Associate_ID__c = '1234');
        setTestDataPageParams('111', '');
        Test.startTest();       
        VFC_PolicyPageLinkBuilderController policyPageLinkBuilder = new VFC_PolicyPageLinkBuilderController();
        policyPageLinkBuilder.initPolicyPageLink();
        PageReference redirectPolicyPage = policyPageLinkBuilder.redirectToPolicyPageLink();
        System.assert(redirectPolicyPage.getUrl().contains('outOfBookIndicator=TRUE'), 'Redirect URL should be Out of Book');
        Test.stopTest(); 
    }
    
    private static void setTestDataPageParams(String linkId, String agentAssocId) {
        ApexPages.currentPage().getParameters().put('recordId', '5002f000007nSH0AAM');
        ApexPages.currentPage().getParameters().put('LinkId', linkId);
        ApexPages.currentPage().getParameters().put('accountId', 'accountId');
        ApexPages.currentPage().getParameters().put('agentAssocId', agentAssocId);
        ApexPages.currentPage().getParameters().put('webNechoDisplayPolicy', 'webNechoDisplayPolicy');
        ApexPages.currentPage().getParameters().put('webNechoAgreementNum', 'webNechoAgreementNum');
        ApexPages.currentPage().getParameters().put('productDescription', 'productDescription');
        ApexPages.currentPage().getParameters().put('agi', 'agreementindex');
    }
    
    private static List<InsurancePolicy> setupMockQueryResult(){
        String insurancePolicyListJSON = '[{"attributes":{"type":"InsurancePolicy","url":"/services/data/v53.0/sobjects/InsurancePolicy/0YT6w000000CagFAKE"},"SourceSystemIdentifier":"48832424"}]';
        
        List<InsurancePolicy> insurancePolicyData = (List<InsurancePolicy>)JSON.deserialize(insurancePolicyListJSON, List<InsurancePolicy>.class );
        return insurancePolicyData;
    }
    
    private static List<InsurancePolicyParticipant> setupMockParticipantQueryResult(){
        String insurancePolicyListJSON = '[{"attributes":{"type":"InsurancePolicyParticipant","url":"/services/data/v53.0/sobjects/InsurancePolicyParticipant/0YT6w000000CagTEST"},"InsurancePolicy.SourceSystemIdentifier":"48832424"}]';
        
        List<InsurancePolicyParticipant> insurancePolicyData = (List<InsurancePolicyParticipant>)JSON.deserialize(insurancePolicyListJSON, List<InsurancePolicyParticipant>.class );
        return insurancePolicyData;
    }
    
    private static List<ExceptionLog__c> getException(){
        return [SELECT Id FROM ExceptionLog__c WHERE CreatedDate = TODAY AND Method__c = 'initPolicyPageLink'];
    }
}
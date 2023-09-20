/**
* @author Baby Yoda
* @name VFC_PolicyPageLinkBuilderController
* @date Created 09/10/2020
* @description VFP_PolicyPageLinkBuilder controller class. 
* This class will re-assign LinkId 110, 111, 113,  114 to use the same URLGateway on Account Prouct page Policy Number
*/
public with sharing class VFC_PolicyPageLinkBuilderController {
    
    private static final String WIL_AUTO_LINK_ID    = '110';
    private static final String WIL_FLEET_LINK_ID   = '111';
    private static final String WIL_FIRE_LINK_ID    = '113';
    private static final String WIL_HAGERTY_LINK_ID = '267';
    
    private static final String AUTO_LINK_ID = '13';
    private static final String FLEET_LINK_ID = '198';
    private static final String HEALTH_FIRE_LINK_ID = '9';
    private static final String FIRE_HOMEOWNERS_LINK_ID = '24';

    private static final String NECHO_POLICY_PAGE = 'policy';

    @TestVisible private static User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
    @TestVisible private static List<InsurancePolicy> mockInsurancePolicyData = new List<InsurancePolicy>();
    @TestVisible private static List<InsurancePolicyParticipant> mockInsurancePolicyParticipantData = new List<InsurancePolicyParticipant>();
    
    private static final String CLASS_NAME = 'VFC_PolicyPageLinkBuilderController';
    private static final String AGREEMENT_INDEX_ID = '&agreementIndexId=';
    private static final String ACCOUNT_ID = '&accountId=';
    private static final String AGENT_ASSOC_ID = '&agentAssocId=';
    private static final String LINE_OF_BUSINESS = '&lineOfBusiness=';
    /**
     * @description This method get and set finalPolicyPageLink
     * @name finalPolicyPageLink
     * @return String
	 */
    public String finalPolicyPageLink {get;set;}
    /**
    * @author Baby Yoda
    * @name PolicyLinkException
    * @description PolicyLinkException
    */
    public with sharing class PolicyLinkException extends Exception{}
    
    /**
     * @description initPolicyPageLink
     * @name initPolicyPageLink
	 */
    public void initPolicyPageLink(){
        String methodName = 'initPolicyPageLink';
        String recordId = ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        try{
            if(ApexPages.currentPage().getParameters().get('LinkId') == '114'){
                buildHealthPolicyLink();
            } else{
                buildAutoFirePolicyLink(); 
            }
        } catch(PolicyLinkException ple){
            ApexPages.Message policyLinkExceptionError= new ApexPages.Message(ApexPages.Severity.ERROR, ple.getMessage());
            ApexPages.addMessage(policyLinkExceptionError);
            ple.setMessage('Failure record: ' + recordId + ', ' + ple.getMessage());      
            LoggingService.logHandledException(ple,CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        } catch(Exception e){
            ApexPages.Message unknownExceptionError= new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+'. Please contact support if issue persists.');
            ApexPages.addMessage(unknownExceptionError);
            e.setMessage('Failure record: ' + recordId + ', ' + e.getMessage());
            LoggingService.logHandledException(e,CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
    }

    private void buildAutoFirePolicyLink() {
        finalPolicyPageLink = '';
        String linkId = ApexPages.currentPage().getParameters().get('LinkId').escapeHtml4();
        
        if(WIL_AUTO_LINK_ID.equals(linkId) || WIL_FLEET_LINK_ID.equals(linkId) || WIL_HAGERTY_LINK_ID.equals(linkId)){
            finalPolicyPageLink = buildAutoPolicyLinks(linkId);
        }else if(WIL_FIRE_LINK_ID.equals(linkId)) {
            finalPolicyPageLink = buildFirePolicyLinks(linkId);
        }
    }

    private String buildAutoPolicyLinks(String linkId){
        String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();  
        String agentAssocId = ApexPages.currentPage().getParameters().get('agentAssocId').escapeHtml4();  
        String policyNumber = ApexPages.currentPage().getParameters().get('webNechoDisplayPolicy').escapeHtml4();  
        String webNechoAgreementNum = ApexPages.currentPage().getParameters().get('webNechoAgreementNum').escapeHtml4(); 
        String agreAccessKey = ((WIL_FLEET_LINK_ID.equals(linkId) || WIL_AUTO_LINK_ID.equals(linkId)) && webNechoAgreementNum.length() > 10) ? webNechoAgreementNum.left(10): webNechoAgreementNum;
        String outOfBookIndicator = getOutOfBookIndicator(agentAssocId);
        String lineOfBusiness = getLineOfBusiness(linkId);
        String productDescription = ApexPages.currentPage().getParameters().get('productDescription').escapeHtml4();
        String agreementIndexId = getAgreementData(agreAccessKey, accountId, lineOfBusiness);

        if(WIL_AUTO_LINK_ID.equals(linkId)){
            finalPolicyPageLink = '/apex/VFP_ExternalLink?LinkId=' + AUTO_LINK_ID + LINE_OF_BUSINESS + lineOfBusiness 
                + ACCOUNT_ID + accountId + AGENT_ASSOC_ID + agentAssocId + '&policyNumber=' + policyNumber 
                + AGREEMENT_INDEX_ID + agreementIndexId + '&outOfBookIndicator=' + outOfBookIndicator + '&productDescription=' + productDescription;
        }
        
        if(WIL_FLEET_LINK_ID.equals(linkId) ){
            finalPolicyPageLink = '/apex/VFP_ExternalLink?LinkId=' + FLEET_LINK_ID + LINE_OF_BUSINESS + lineOfBusiness 
                + ACCOUNT_ID + accountId + AGENT_ASSOC_ID + agentAssocId + '&policyNumber=' + policyNumber + '&pmrNumber=' +agreAccessKey
                + AGREEMENT_INDEX_ID + agreementIndexId + '&outOfBookIndicator=' + outOfBookIndicator + '&productDescription=Fleet';
        }

        if(WIL_HAGERTY_LINK_ID.equals(linkId)){
            finalPolicyPageLink = '/apex/VFP_ExternalLink?LinkId=267' + ACCOUNT_ID + accountId + AGREEMENT_INDEX_ID + agreementIndexId
                                    + '&clientnamelinkdisabled=Y&NechoAppName=' + NECHO_POLICY_PAGE + '&key=' + policyNumber
                                    + LINE_OF_BUSINESS + lineOfBusiness + AGENT_ASSOC_ID + agentAssocId;
        }

        return finalPolicyPageLink;
    }

    private String buildFirePolicyLinks(String linkId){
        String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();  
        String agentAssocId = ApexPages.currentPage().getParameters().get('agentAssocId').escapeHtml4();  
        String policyNumber = ApexPages.currentPage().getParameters().get('webNechoDisplayPolicy').escapeHtml4();  
        String webNechoAgreementNum = ApexPages.currentPage().getParameters().get('webNechoAgreementNum').escapeHtml4(); 
        String agreAccessKey = ((WIL_FLEET_LINK_ID.equals(linkId) || WIL_AUTO_LINK_ID.equals(linkId)) && webNechoAgreementNum.length() > 10) ? webNechoAgreementNum.left(10): webNechoAgreementNum;
        String outOfBookIndicator = getOutOfBookIndicator(agentAssocId);
        String lineOfBusiness = getLineOfBusiness(linkId);
        String productDescription = ApexPages.currentPage().getParameters().get('productDescription').escapeHtml4();
        String agreementIndexId = getAgreementData(agreAccessKey, accountId, lineOfBusiness);

        if(productDescription.containsIgnoreCase(AT_UTIL_ProductConstants.HOMEOWNERS)){
            finalPolicyPageLink = '/apex/VFP_ExternalLink?LinkId=' + FIRE_HOMEOWNERS_LINK_ID + LINE_OF_BUSINESS + lineOfBusiness 
                + ACCOUNT_ID + accountId + AGENT_ASSOC_ID + agentAssocId + '&policyNumber=' + policyNumber 
                + AGREEMENT_INDEX_ID + agreementIndexId + '&outOfBookIndicator=' + outOfBookIndicator + '&productDescription=' + productDescription;
        }else{
            finalPolicyPageLink = '/apex/VFP_ExternalLink?lineOfBusiness=' + lineOfBusiness + ACCOUNT_ID + accountId 
                + '&clientnamelinkdisabled=Y&agentAssocId=' + agentAssocId + AGREEMENT_INDEX_ID + agreementIndexId 
                + '&NechoAppName=policy&LinkId=' + HEALTH_FIRE_LINK_ID + '&key=' + policyNumber;
        }

        return finalPolicyPageLink;
    }
    
    private void buildHealthPolicyLink() {
        String lineOfBusiness = getLineOfBusiness(ApexPages.currentPage().getParameters().get('LinkId').escapeHtml4());
        String accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
        String agentAssocId = ApexPages.currentPage().getParameters().get('agentAssocId').escapeHtml4();
        String agreementIndexId = ApexPages.currentPage().getParameters().get('agi').escapeHtml4().right(9);
        String policyKey = ApexPages.currentPage().getParameters().get('webNechoDisplayPolicy').escapeHtml4().right(4); 
        finalPolicyPageLink = '/apex/VFP_ExternalLink?lineOfBusiness=' + lineOfBusiness + ACCOUNT_ID + accountId 
            + '&clientnamelinkdisabled=Y&agentAssocId=' + agentAssocId + AGREEMENT_INDEX_ID + agreementIndexId 
            + '&NechoAppName=policy&LinkId=' + HEALTH_FIRE_LINK_ID + '&key=XXXXXXXX ' + policyKey;
    }
    
    /**
     * @description redirectToPolicyPageLink
     * @name redirectToPolicyPageLink
     * @return PageReference
	 */
    public PageReference redirectToPolicyPageLink() {
        PageReference policyPageLink = new PageReference(string.valueOf(finalPolicyPageLink));
        policyPageLink.setRedirect(false);
        return policyPageLink;
    }
    
    private String getLineOfBusiness(String linkID) {
        String lineOfBusiness = '';
        
        switch on LinkID {
            when '110', '111', '267' {
                lineOfBusiness = 'A';
            }
            when '113' {
                lineOfBusiness = 'F';
            }
            when '114' {
                lineOfBusiness = 'H';
            }
        }
        
        return lineOfBusiness;
    }
    
    private String getOutOfBookIndicator(String agentAssocId){
        String outOfBookIndicator = 'TRUE';
        
        if(String.isEmpty(agentAssocId)){
            return outOfBookIndicator;
        }
        
        if (FeatureManagement.checkPermission('Agency_User') && 
            (agentAssocId.equalsIgnoreCase(currentUser.Servicing_Agent_Associate_ID__c))) {
                outOfBookIndicator = 'FALSE';     
            }
        
        return outOfBookIndicator; 
    }
    
    private String getAgreementData(String agreAccessKey, String accountId, String lineOfBusiness ){
        
        String policyToReturn;
        List<InsurancePolicy> queryReturn = Security.stripInaccessible(AccessType.READABLE, 
                                                                       
                                                                       [SELECT SourceSystemIdentifier
                                                                        FROM InsurancePolicy 
                                                                        WHERE AgreAccessKey__c = :agreAccessKey 
                                                                        AND AgreSourceSysCd__c = '1' 
                                                                        AND ProdLineCd__c = :lineOfBusiness 
                                                                        AND NameInsuredId = :accountId LIMIT 1] ).getRecords();
        
        if(Test.isRunningTest()){
            queryReturn = mockInsurancePolicyData;
        }
        if (queryReturn.size() == 1) {
            policyToReturn = queryReturn[0].SourceSystemIdentifier;
        } else{
            policyToReturn = getSNI(agreAccessKey, accountId, lineOfBusiness);
        }
        
        return policyToReturn;
    }
    
    private String getSNI(String agreAccessKey, String accountId, String lineOfBusiness){
        List<InsurancePolicyParticipant> queryReturn = Security.stripInaccessible(AccessType.READABLE, 
                                                                                  
                                                                                  [SELECT InsurancePolicy.SourceSystemIdentifier
                                                                                   FROM InsurancePolicyParticipant
                                                                                   WHERE InsurancePolicy.AgreAccessKey__c = :agreAccessKey 
                                                                                   AND InsurancePolicy.AgreSourceSysCd__c = '1' 
                                                                                   AND InsurancePolicy.ProdLineCd__c = :lineOfBusiness 
                                                                                   AND PrimaryParticipantAccountId = :accountId LIMIT 1] ).getRecords();
        
        if(Test.isRunningTest()){
            queryReturn = mockInsurancePolicyParticipantData;
        }
        if (queryReturn.size() != 1) {
            throw new PolicyLinkException('No Policy found.');
        }
        
        return queryReturn[0].InsurancePolicy.SourceSystemIdentifier;
    }
}
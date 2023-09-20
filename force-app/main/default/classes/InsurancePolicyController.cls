/**
* Author : Team Kraken
* Date Created : 1/27/21
* @description InsurancePolicyController: Used by policy related LWCs for retrieving InsurancePolicy data
* Version : 1.0
*/

public with sharing class InsurancePolicyController extends InsurancePolicyClasses {
    private static final String CLASS_NAME = 'InsurancePolicyController';
    @TestVisible private static PA_CaseUtil caseUtil = new PA_CaseUtil();
    @TestVisible private static List<InsurancePolicy> mockPolicies = new List<InsurancePolicy>();
    @TestVisible private static Boolean isCatch = false;
    private static InsurancePolicyControllerWrapper insuranceWrap = new InsurancePolicyControllerWrapper();
/**
 * @description getInsurancePolicyAssets
 * @param recordId 
 * @return  `List<InsurancePolicyAsset>`
 */
    @AuraEnabled(cacheable=true)
    public static List<InsurancePolicyAsset> getInsurancePolicyAssets(String recordId) {
        // Called by policyContainer
        List<InsurancePolicyAsset> assets;
        assets = insuranceWrap.getInsurancePolicyAssets(recordId, assets);
		return assets;        
    }
/**
 * @description getPrimaryInsurancePolicyParticipant
 * @param recordId 
 * @param lob 
 * @return  `InsurancePolicyParticipant`
 */
    @AuraEnabled(cacheable=true)
    public static InsurancePolicyParticipant getPrimaryInsurancePolicyParticipant(String recordId, String lob) {
        // Called by policyActions
        try{
        List<InsurancePolicyParticipant> participants = Security.stripInaccessible(AccessType.READABLE, [
            SELECT Id, RoleNameCd__c, SecondaryRoleNameCd__c, PrimaryParticipantAccountId, PrimaryParticipantAccount.ClientIdentifier__c, PrimaryParticipantAccount.Name, PrimaryParticipantAccount.PersonEmail
            FROM InsurancePolicyParticipant 
            WHERE InsurancePolicyId = :recordId
        ]).getRecords();

        if(isCatch){
            throw new DMLException();
        }
        if (participants != null && !participants.isEmpty()) {
            return getPrimaryNamedInsured(participants, lob);
        }
        return null;
    }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info(CLASS_NAME, e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return null;
        }
    }
/**
 * @description getAccountData
 * @param clientIdList 
 * @return  `List<AccountWrapper>`
 */
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAccountData(List<String> clientIdList) {
        // Called by policyDetailsDrivers
        List<AccountWrapper> accountData = new List<AccountWrapper>();
        try{
        List<Account> accounts = Security.stripInaccessible(AccessType.READABLE, [SELECT Name, FirstName, Id, Gender__pc, ClientIdentifier__c, PersonBirthdate, DriversLicenseStateProvince__c, DriversLicenseNumber__c FROM Account WHERE ClientIdentifier__c IN :clientIdList LIMIT :clientIdList.size()]).getRecords();

        for (Account account : accounts) {
            AccountWrapper accountWrapper = new AccountWrapper();
            accountWrapper.recordId = String.valueOf(account.Id);
            accountWrapper.name = account.Name;
            accountWrapper.firstName = account.FirstName;
            accountWrapper.gender = account.Gender__pc;
            accountWrapper.clientId = account.ClientIdentifier__c;
            accountWrapper.birthdate = String.valueOf(account.PersonBirthdate);
            accountWrapper.driversLicenseState = account.DriversLicenseStateProvince__c;
            accountWrapper.driversLicenseNumber = account.DriversLicenseNumber__c;

            accountData.add(accountWrapper);
        }
        return accountData;
    }
        catch(Exception e){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, e.getMessage() + System.now());
        logHolder.writeToLogExceptionObject();
        return new List<AccountWrapper>();
        }
    }
/**
 * @description getPrimaryNamedInsured
 * @param participants 
 * @param lineOfBusiness 
 * @return  `InsurancePolicyParticipant`
 */
    public static InsurancePolicyParticipant getPrimaryNamedInsured(List<InsurancePolicyParticipant> participants, String lineOfBusiness) {
        InsurancePolicyParticipant participant = insuranceWrap.getPrimaryNamedInsured(participants, lineOfBusiness);
        return participant;
    }
    /**
     * @description createPolicyTransactionCase
     * @param inputData 
     * @return  `String`
     */
    @AuraEnabled
    public static String createPolicyTransactionCase(InsurancePolicyData inputData){
        try{
        caseUtil.parentRecordId = inputData.accountRecordId;
        caseUtil.isCaseMigrationAction = inputData.isCaseMigrationAction; //flag to use legacy template or CaseMigration template
        caseUtil.isLegacyPolicy = inputData.isLegacyPolicy; //flag to determine legacy vs mod policy case
        caseUtil.caseContactAccountId = inputData.accountRecordId;
        caseUtil.setLOB(inputData.lob);
        caseUtil.setPolicyNumber(inputData.policyNumber);
        caseUtil.setReason(inputData.actionValue);
        caseUtil.setProductDescription(inputData.productDescription);
        caseUtil.agentAssociateId = inputData.agentAssociateId;
        caseUtil.agreementIndexId = inputData.agreementIndexId;
        caseUtil.sourceSystemCode = inputData.sourceSystemCode;
        caseUtil.agreAccessKey = inputData.agreAccessKey;

        return caseUtil.setupPolicyTransactionCase();
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info(CLASS_NAME, e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return null;
        }
    }
    /**
     * @description buildGroupPolicyTypes
     * @return  `List<String>`
     */
    public static List<String> buildGroupPolicyTypes() {
        List<CM_Group_Policy_Type__mdt> groups = Security.stripInaccessible(AccessType.READABLE, 
        [Select Label From CM_Group_Policy_Type__mdt Where Label != null Limit 100]).getRecords();
        
        List<String> groupNames = new List<String>();
        groupNames = insuranceWrap.buildGroupPolicyTypes(groups, groupNames);       
        return groupNames;
    }
    /**
     * @description groupPolicyInList
     * @param inputName 
     * @return  `Boolean`
     */
    public static Boolean groupPolicyInList(String inputName) {
        Boolean foundGroup = false;
        List<String> groupNames = buildGroupPolicyTypes();
        foundGroup = insuranceWrap.groupPolicyInList(inputName, groupNames, foundGroup);
        return foundGroup;
    }
/**
 * @description getGroupPolicyStatus
 * @param policyDescription 
 * @return  `Boolean`
 */
    @AuraEnabled(cacheable=true)
    public static Boolean getGroupPolicyStatus(String policyDescription) {
        try{
            if(isCatch){
                throw new DMLException();
            }
        return groupPolicyInList(policyDescription);
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info(CLASS_NAME, e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return null;
        }
    }
/**
 * @description encodeProductDescription
 * @param productDescription 
 * @return  `String`
 */
    @AuraEnabled(cacheable=true)
    public static String encodeProductDescription(String productDescription) {
        try{
            if(isCatch){
                throw new DMLException();
            }
        return EncodingUtil.urlEncode(productDescription, LinkConstants.ENCODING_UTF_8);
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info(CLASS_NAME, e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return null;
        }
    }
/**
 * @description emailAutoIdCardCallout
 * @param customerEmail 
 * @param customerName 
 * @param policyNumber 
 * @return  `String`
 */
    @AuraEnabled
    public static String emailAutoIdCardCallout(String customerEmail, String customerName, String policyNumber) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Email_AutoId_Card_API');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String body = '{"customerEmail":"' + customerEmail + '","customerName":"' + customerName + '", "policyNumber":"' + policyNumber + '"}';
		req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
/**
 * @description logException
 * @param message 
 * @param method 
 */
    @AuraEnabled
    public static void logException(String message, String method){
        LoggingService.logHandledException(new InvalidInputException(message), CLASS_NAME, method, System.LoggingLevel.ERROR);
    }
/**
 * @description getPLMStatus
 * @return  `CS_PLM_Case_Config__c`
 */
    @AuraEnabled
    public static CS_PLM_Case_Config__c getPLMStatus() {
        try{
            if(isCatch){
            throw new DMLException();
        }
        return CS_PLM_Case_Config__c.getInstance();
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info(CLASS_NAME, e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return null;
          }
    }
    /**
     * @description getPLMStatusForState
     * @param stateAgentCode 
     * @return  `boolean`
     */
    @AuraEnabled 
    public static boolean getPLMStatusForState(string stateAgentCode) {
        boolean stateIsActivated = false;
        try{
            if(isCatch){
            throw new DMLException();
        }
        CS_Case_PLM_Activation__c plmStateMetadata = CS_Case_PLM_Activation__c.getValues(stateAgentCode);
        if(plmStateMetadata != null) {
            DateTime dT = System.now();
			Date currentDate = Date.newInstance(dT.year(), dT.month(), dT.day());
            Date activationDate = Date.newInstance((Integer)plmStateMetadata.Activation_Year__c, (Integer)plmStateMetadata.Activation_Month__c, (Integer)plmStateMetadata.Activation_Day__c);
            stateIsActivated = currentDate >= activationDate;
        }
        return stateIsActivated;
    }
    catch(Exception e){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, e.getMessage() + System.now());
        logHolder.writeToLogExceptionObject();
        return null;
      }
    }
    /**
     * @description getTargetAutoPolicyForState
     * @param agentAssocId 
     * @param accountId 
     * @return  `boolean`
     */
    @AuraEnabled
    public static boolean getTargetAutoPolicyForState(string agentAssocId, Id accountId) {
        boolean hasTargetPolicy = false;
        try{
        List<InsurancePolicy> policiesInSameState = Security.stripInaccessible(AccessType.READABLE,
            [Select AgreSourceSysCd__c, AgreAccessKey__c FROM InsurancePolicy 
			    WHERE NameInsuredId =: accountId AND Servicing_Agent__r.Associate_ID__c =: agentAssocId AND AgreSourceSysCd__c = '24']).getRecords();
                
        if(isCatch){
                    throw new DMLException();
                }
        if(!policiesInSameState.isEmpty()) {
            hasTargetPolicy = true;
        }
        return hasTargetPolicy;
    }
    catch(Exception e){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, e.getMessage() + System.now());
        logHolder.writeToLogExceptionObject();
        return null;
      }
    }

    private without sharing class InsurancePolicyControllerWrapper{
        private List<InsurancePolicyAsset> getInsurancePolicyAssets(String recordId, List<InsurancePolicyAsset> assets) {
            List<InsurancePolicyAsset> insurancePolicyAssets = assets;
        try{
            insurancePolicyAssets = Security.stripInaccessible(AccessType.READABLE, [
            SELECT Id, RiskNumber__c, PhysicalObjectId__c, Description__c, RiskStatusText__c, VIN__c
            FROM InsurancePolicyAsset
            WHERE InsurancePolicyId = :recordId
            ORDER BY RiskStatusText__c
          ]).getRecords();  
            
            if(isCatch){
                throw new DMLException();
            }
            if (insurancePolicyAssets != null && !insurancePolicyAssets.isEmpty()) {
                return insurancePolicyAssets;
            }
           return new List<InsurancePolicyAsset>();  
        }
        catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
            logHolder.info(CLASS_NAME, e.getMessage() + System.now());
            logHolder.writeToLogExceptionObject();
            return new List<InsurancePolicyAsset>();
        }
    }

    private InsurancePolicyParticipant getPrimaryNamedInsured(List<InsurancePolicyParticipant> participants, String lineOfBusiness) {
        for (InsurancePolicyParticipant participant : participants) {
            if (lineOfBusiness.equalsIgnoreCase('L') && '12'.equals(participant.RoleNameCd__c) && '29'.equals(participant.SecondaryRoleNameCd__c)) {
                return participant;
            }
        }
        return null;
    }

    private List<String> buildGroupPolicyTypes(List<CM_Group_Policy_Type__mdt> groups, List<String> groupNames) {
        for (CM_Group_Policy_Type__mdt groupName: groups) {
            groupNames.add(groupName.Label);
        }
        return groupNames;
    }

    private Boolean groupPolicyInList(String inputName, List<String> groupNames, Boolean foundGroup) {
        Boolean policyFoundGroup = foundGroup;
        if (String.isNotBlank(inputName) && groupNames.contains(inputName.toUpperCase())) {
            policyFoundGroup = true;
        }
        return policyFoundGroup;
    }
}
}
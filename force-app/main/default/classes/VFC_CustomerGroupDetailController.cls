/****************************************************************************************
Name: VFC_CustomerGroupDetailController
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class to Customer Group Details page.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                1/18/2018             2018 R1 Release

******************************************************************************************/

/**
 * @description VFC Customer Group Detail Controller
 */
public with sharing class VFC_CustomerGroupDetailController {

    private static final String ACCID_PARAM = 'accIdInContext';
    private static final String GROUP_ID_PARAM = 'groupId';
    private static final String S1_THEME = 'Theme4t';
    public static final String SELF = 'Self';
    private static final String CLASS_NAME = 'VFC_CustomerGroupDetailController';
    private static final String HH_COMMENTS_API_NAME = 'HouseholdComments__c';
    private static final String HHM_PRIMARY_CONTACT_API_NAME = 'MemberPrimaryContact__c';
    VFC_CustomerGroupDetailController_Wrapper grpWrap = new VFC_CustomerGroupDetailController_Wrapper();
    
    /**
     * @description getters and setters of the property customergroupRecord
     * @return CustomerGroup__c
     */
    public CustomerGroup__c customergroupRecord {get; set;}
    private List<CustomerGroupMember__c> custGrpMemberList {get; set;}

    /**
     * @description getters and setters of the property accIdInContext
     * @return Id
     */
    public Id accIdInContext {get; set;}

    /**
     * @description getters and setters of the property isS1Request
     * @return Boolean
     */
    public Boolean isS1Request {get; set;}

    /**
     * @description getters and setters of the property isPoliciesSectionVisible
     * @return Boolean
     */
    public Boolean isPoliciesSectionVisible {get; set;}

    /**
     * @description getters and setters of the property primaryContactMember
     * @return String
     */
    public String primaryContactMember {get; set;}

    /**
     * @description getters and setters of the property redirectUrl
     * @return String
     */
    public String redirectUrl {get; private set;}
    private String initPrimaryContactMember {get; set;}

    /**
     * @description Grp Member Relation Wrapper List
     * @return List<HLPR_GroupMemberRelationWrapper>
     */
    public List<HLPR_GroupMemberRelationWrapper> grpMemberRelationWrapperList {get; set;}
    private String oldGroupName {get; set;}
    private Map<Id, CustomerGroupMember__c> grpMemberMapByAccId {get; set;}
    private Map<Id, String> relationshipMapbyAccId {get; set;}
    
    private enum Methods {INIT, SAVEGROUPCHANGES}

    /**
     * @description Is HH Comments Visible
     * @return Boolean
     */
    public Boolean isHHCommentsVisible {get; set;}

    /**
     * @description Is Primary Contact Edit
     * @return Boolean
     */
    public Boolean isPrimaryContactEdit {get; set;} 

    /**
     * @description VFC Customer Group Detail Controller
     * @param stdController
     */
    public VFC_CustomerGroupDetailController(ApexPages.StandardController stdController) {
        customergroupRecord = (CustomerGroup__c)stdController.getRecord();
        AP_ClickJackPrevention.setRequiredHeaders();
        isS1Request = false; 
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isS1Request = true;
        }
        isPoliciesSectionVisible = false;
        CS_FeatureToggle__c skipFeature = CS_FeatureToggle__c.getInstance();
        if(!(skipFeature.Policy_Summary__c && skipFeature.Billing_Summary__c && skipFeature.Claim_Summary__c && skipFeature.ABS_Activities_Summary__c)){
        	isPoliciesSectionVisible = true;
        }
        redirectUrl = UTIL_CreateCustomerConstants.EMPTY_STRING;
        relationshipMapbyAccId = new Map<Id, String>();
        grpMemberRelationWrapperList = new List<HLPR_GroupMemberRelationWrapper>();
        primaryContactMember = UTIL_CreateCustomerConstants.EMPTY_STRING;
        initPrimaryContactMember = UTIL_CreateCustomerConstants.EMPTY_STRING;
        populateCustGroupDetails(customergroupRecord.id);
    }
    
    private void populateCustGroupDetails(Id custgrpId) {
        customergroupRecord = [SELECT Id, Name, SFGroupIdentifier__c, GroupCategory__c, HouseholdComments__c, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name, CreatedDate, LastModifiedDate FROM CustomerGroup__c WHERE id = :custgrpId LIMIT 1];
        oldGroupName = customergroupRecord.Name;
    }
    
    /**
     * @description Init
     */
    public void init() {
        try {
            String accIdFromPage = UTIL_PageParameterHelper.retrieveCurrentPageParameter(ACCID_PARAM, ParameterType.SALESFORCE_ID);
            if(String.isNotBlank(accIdFromPage)) {
                UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(ACCID_PARAM, accIdFromPage, Account.class);
                accIdInContext = accIdFromPage;
            }
            populateGroupMemberMap();
            if((String.isBlank(accIdInContext) || !String.valueOf(accIdInContext).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix())) 
                && !(custGrpMemberList == null || custGrpMemberList.isEmpty())){
                    accIdInContext = custGrpMemberList.get(0).Customer__c;
            }
            if(accIdInContext!=null){
                populateRelationshipMap();
            }
            grpMemberRelationWrapperList = populateGroupMemberRelationWrapperList();
        }
        catch(InvalidParameterValueException ex){
            LoggingService.logHandledException(ex, CLASS_NAME, Methods.INIT.name(), System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
        }
    }
    
    private void populateGroupMemberMap() {
        grpMemberMapByAccId = new Map<Id, CustomerGroupMember__c>();
        custGrpMemberList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Customer__c, Customer__r.Name,  customer__r.personbirthdate, customer__r.gender__pc, MemberPrimaryContact__c FROM CustomerGroupMember__c WHERE Group__c = :customergroupRecord.Id]).getRecords();
        if(!(custGrpMemberList == null || custGrpMemberList.isEmpty())){
            for(CustomerGroupMember__c grpMember : custGrpMemberList) {
                grpMemberMapByAccId.put(grpMember.Customer__c, grpMember);
                if(grpMember.MemberPrimaryContact__c) {
                    primaryContactMember = grpMember.Customer__c;
                }
            }
        }
        initPrimaryContactMember = primaryContactMember;
    }
    
    private void populateRelationshipMap() {
        List<Relationship__c> relationtoAccount = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, AccountOne__c, RelationshipType__c FROM Relationship__c WHERE AccountTwo__c = :accIdInContext and AccountOne__c in :grpMemberMapByAccId.keySet()]).getRecords();
        if(!(relationtoAccount == null || relationtoAccount.isEmpty())){
            for(relationship__c rel : relationtoAccount) {
                relationshipMapbyAccId.put(rel.AccountOne__c, rel.RelationshipType__c);
            }
        }
    }
    
    private List<HLPR_GroupMemberRelationWrapper> populateGroupMemberRelationWrapperList(){
        List<HLPR_GroupMemberRelationWrapper> grpmemberWrapperList = new List<HLPR_GroupMemberRelationWrapper>();
        if(!(grpMemberMapByAccId == null || grpMemberMapByAccId.isEmpty())) {
            for(Id accountId : grpMemberMapByAccId.keySet()){
                if(accIdInContext!=null && accountId == accIdInContext) {
                    HLPR_GroupMemberRelationWrapper grpMemWrapper = new HLPR_GroupMemberRelationWrapper();
                    grpMemWrapper.custGrpMember = grpMemberMapByAccId.get(accountId);
                    grpMemWrapper.relationshipType = SELF;
                    grpmemberWrapperList.add(grpMemWrapper);
                    break;
                }
            }
            VFC_CustomerGroupDetailController_VariableWrapper varWrap = new VFC_CustomerGroupDetailController_VariableWrapper();
            varWrap.grpmemberWrapperList = grpmemberWrapperList;
            varWrap.accIdInContext = accIdInContext;
            varWrap.relationshipMapbyAccId = relationshipMapbyAccId;
            varWrap.grpMemberMapByAccId = grpMemberMapByAccId;
            grpWrap.createGrpMemberWrapperList(varWrap);
        }
        return grpmemberWrapperList;
    }   
    
    /**
     * @description Save Group Changes
     */
    public void saveGroupChanges() {
        VFC_CustomerGroupDetailController_VariableWrapper wrap = new VFC_CustomerGroupDetailController_VariableWrapper();
        wrap.customergroupRecord = this.customergroupRecord;
        wrap.oldGroupName = this.oldGroupName;
        wrap.primaryContactMember = this.primaryContactMember;
        wrap.initPrimaryContactMember = this.initPrimaryContactMember;
        wrap.grpMemberMapByAccId = this.grpMemberMapByAccId;
        wrap.grpMemberRelationWrapperList = this.grpMemberRelationWrapperList;
        
        try {
            if(String.isNotBlank(customergroupRecord.Name)) {
                List<SObject> recordsToUpdate = new List<SObject>();
                wrap.recordsToUpdate = recordsToUpdate;
                grpWrap.getRecordsToUpdate(wrap);
                SObjectAccessDecision ad = Security.stripInaccessible(AccessType.UPDATABLE, recordsToUpdate);

                if(!recordsToUpdate.isEmpty()) {
                    Database.update(ad.getRecords(), true);
                    populateCustGroupDetails(customergroupRecord.Id);
                    populateGroupMemberMap();
                    grpMemberRelationWrapperList = populateGroupMemberRelationWrapperList();
                }
            }
            else {
                customergroupRecord.Name.addError(System.Label.CL_CustomerGroupNameMandatory);
            }
        }
        catch(DMLException dmlExp) {
            LoggingService.logHandledException(dmlExp, CLASS_NAME, Methods.SAVEGROUPCHANGES.name(), System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
        }
    }

    /**
     * @description Reset Changes
     */
    public void resetChanges() {
        customergroupRecord.name = oldGroupName;
        primaryContactMember = initPrimaryContactMember;
    }
    
    /**
     * @description Get Has Error Messages
     * @return boolean
     */
    public boolean getHasErrorMessages() {
        return ApexPages.hasMessages();
    }
    
    /**
     * @description Redirect To Household Move Page
     * @return PageReference
     */
    public PageReference redirectToHouseholdMovePage(){
        PageReference pageRef = Page.VFP_CustomerGroupMemberMoves;
        pageRef.getParameters().put(GROUP_ID_PARAM, customergroupRecord.id); 
        pageRef.getParameters().put(ACCID_PARAM, accIdInContext); 
        pageRef.setRedirect(true);
        pageRef = grpWrap.getRedirectUrl(pageRef, isS1Request, redirectUrl);
        return pageRef;        
    }
    
    /**
     * @description Redirect To Create Customer Page
     * @return PageReference
     */
    public PageReference redirectToCreateCustomerPage(){
    	PageReference returnPage = new ApexPages.StandardController(new CustomerGroup__c(Id=customergroupRecord.Id)).view();
    	returnPage.getParameters().put(ACCID_PARAM, accIdInContext);
        PageReference pageRef = Page.VFP_CustomerRedirect;
        pageRef.getParameters().put(GROUP_ID_PARAM, customergroupRecord.Id);
        pageRef.getParameters().put(UTIL_CreateCustomerConstants.GROUP_EXT_ID_PARAM, customergroupRecord.SFGroupIdentifier__c);
        pageRef.getParameters().put(UTIL_CreateCustomerConstants.RETURN_URL, returnPage.getUrl()); 
        pageRef.setRedirect(true);
        pageRef = grpWrap.getRedirectUrl(pageRef, isS1Request, redirectUrl);
        return pageRef;        
    }

    private with sharing class VFC_CustomerGroupDetailController_VariableWrapper{
        private CustomerGroup__c customergroupRecord;
        private String oldGroupName;
        private String primaryContactMember;
        private String initPrimaryContactMember;
        private Map<Id, CustomerGroupMember__c> grpMemberMapByAccId;
        private List<HLPR_GroupMemberRelationWrapper> grpMemberRelationWrapperList; 
        
        private List<HLPR_GroupMemberRelationWrapper> grpmemberWrapperList;
		private Id accIdInContext;
		private Map<Id, String> relationshipMapbyAccId;
        private List<SObject> recordsToUpdate;
    }
    
    private with sharing class VFC_CustomerGroupDetailController_Wrapper{
        		                
        private CustomerGroup__c customergroupRecord;
        private String oldGroupName;
        private String primaryContactMember;
        private String initPrimaryContactMember;
        private Map<Id, CustomerGroupMember__c> grpMemberMapByAccId;
        private List<HLPR_GroupMemberRelationWrapper> grpMemberRelationWrapperList;  
        
        private List<HLPR_GroupMemberRelationWrapper> grpmemberWrapperList;
		private Id accIdInContext;
		private Map<Id, String> relationshipMapbyAccId;
        List<SObject> recordsToUpdate;
        
        private PageReference getRedirectUrl(PageReference pageRef, Boolean isS1Request, String redirectUrl){

            if(isS1Request && pageRef != null){
                redirectUrl = pageRef.getUrl();
                pageRef = null;
            }
            return pageRef;
        }

        private void assignPrimaryContact(List<SObject> recordsToUpdate, Map<Id, CustomerGroupMember__c> grpMemberMapByAccId, 
                                          String initPrimaryContactMember){
            if(String.isNotBlank(initPrimaryContactMember)) {
                CustomerGroupMember__c unCheckMember = grpMemberMapByAccId.get(initPrimaryContactMember);
                unCheckMember.MemberPrimaryContact__c = false;
                recordsToUpdate.add(unCheckMember);
            }
        }

        /**
        * @description Save Group Changes
        * @param wrap
        */
        public void getRecordsToUpdate(VFC_CustomerGroupDetailController_VariableWrapper wrap) {
            
            customergroupRecord = wrap.customergroupRecord;
            oldGroupName = wrap.oldGroupName;
            primaryContactMember = wrap.primaryContactMember;
            initPrimaryContactMember = wrap.initPrimaryContactMember;
            grpMemberMapByAccId = wrap.grpMemberMapByAccId;
            grpMemberRelationWrapperList = wrap.grpMemberRelationWrapperList; 
            recordsToUpdate = wrap.recordsToUpdate;
            
            if(!customergroupRecord.Name.equals(oldGroupName)){
                recordsToUpdate.add(customergroupRecord); 
            }
            if(String.isNotBlank(primaryContactMember) && (String.isBlank(initPrimaryContactMember) || !primaryContactMember.equalsIgnoreCase(initPrimaryContactMember))) {
                CustomerGroupMember__c checkMember = grpMemberMapByAccId.get(primaryContactMember);
                checkMember.MemberPrimaryContact__c = true;
                recordsToUpdate.add(checkMember);
                assignPrimaryContact(recordsToUpdate, grpMemberMapByAccId, initPrimaryContactMember);
            }
        }

        private void assignGrpMemberRelType(Id accountId, HLPR_GroupMemberRelationWrapper grpMemWrapper, 
                                           Map<Id, String> relationshipMapbyAccId){
            if(String.isNotBlank(relationshipMapbyAccId.get(accountId))){
                grpMemWrapper.relationshipType = relationshipMapbyAccId.get(accountId);
            }
            else {
                grpMemWrapper.relationshipType = UTIL_CreateCustomerConstants.EMPTY_STRING;
            }
        }

        /**
        * @description Create Group Member Wrapper List
        * @param varWrap
        */                                                  
        private void createGrpMemberWrapperList(VFC_CustomerGroupDetailController_VariableWrapper varWrap){
            List<HLPR_GroupMemberRelationWrapper> grpmemberWrapperList = varWrap.grpmemberWrapperList;
			Id accIdInContext = varWrap.accIdInContext; 
            Map<Id, String> relationshipMapbyAccId = varWrap.relationshipMapbyAccId; 
			Map<Id, CustomerGroupMember__c> grpMemberMapByAccId = varWrap.grpMemberMapByAccId;
            
            for(Id accountId : grpMemberMapByAccId.keySet()){
                if(accIdInContext == null || (accIdInContext!= null && accountId != accIdInContext)) {
                    HLPR_GroupMemberRelationWrapper grpMemWrapper = new HLPR_GroupMemberRelationWrapper();
                    grpMemWrapper.custGrpMember = grpMemberMapByAccId.get(accountId);
                    assignGrpMemberRelType(accountId, grpMemWrapper, relationshipMapbyAccId);
                    grpmemberWrapperList.add(grpMemWrapper);
                }
            }
        }
    }
}
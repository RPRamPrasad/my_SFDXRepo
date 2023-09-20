/****************************************************************************************
Name: VFC_CustomerGroupMemberMovesCtrl
Copyright © State Farm
=========================================================================================
Purpose:
-------
Custome Group Members Moves

Team: Loco Motivated
=========================================================================================
History
-------
VERSION         AUTHOR                  DATE              DETAIL
1.0             LocoMotivated           01/22/2018        Initial test(s) for Add or Move
														  customer group members controller
******************************************************************************************/
/**
 * @description VFC_CustomerGroupMemberMovesCtrl
 */
public with sharing class VFC_CustomerGroupMemberMovesCtrl {

    private Id customerGroupId;
    private Id accountId;
    @TestVisible private Set<String> existingGoupMemberNamesSet = new Set<String>();
    @TestVisible private Set<String> newGoupMemberNamesSet = new Set<String>();
    @TestVisible private Set<CustomerGroupMember__c> initGroupMemberSetToDisplay = new Set<CustomerGroupMember__c>();
    @TestVisible private Set<CustomerGroupMember__c> relatedGMSetToDisplay = new Set<CustomerGroupMember__c>();
    private Set<CustomerGroupMember__c> actualCurrentGroupMemberSet = new Set<CustomerGroupMember__c>();
    private Set<CustomerGroupMember__c> actualSecondaryGMSet = new Set<CustomerGroupMember__c>();
    private static final String S1_THEME = 'Theme4t';
    private static final String ADD_MEMBERS='Add Members';
    private static final String MOVE_MEMBERS='Move Members';
    private static final String SEARCHED_GROUP_MEMBERS_LABEL='\''+'s Group Member(s)';
    private static final String MOVE_GROUP_MEMBERS_LABEL='New Group Member(s)';
    private static final String SAME_GROUP_SEARCH_ERROR_LABEL='Please select an account not already in the Current Group';
    private static final String MOVE_MEMBERS_BETWEEN_TWO_GROUPS='Move Member(s) between two groups';
    private static final String MOVE_MEMBERS_TO_NEW_GROUP='Move Member(s) to a New Group';
    private static final String BACK_SLASH='/';
    private static final String GROUP_ID_PARAM = 'groupId';
    private static final String ACCOUNT_ID_PARAM = 'accIdInContext';
    private static final String CLASS_NAME = 'VFC_CustomerGroupMemberMovesCtrl';
    private static final String EMPTY_STRING ='';
    private static final String BLANK_SPACE =' ';
    private static final String COMMA =',';
    private static final String DOB_STRING =' | DOB: ';
    private static final String HHMGMT_NAMED_CREDENTIALS = 'callout:HouseHold_Management';
    private static final String CALLBACK_METHOD = 'processCustomerGroupingResponse';
    private static final String METHOD_NAME = 'processCustomerGroupingResponse';
    private static final String PARAM_VALUE = ' Param Values: ';
    @TestVisible private String requestLabel;
    private String primaryGroupIdentifier;
    private String secondaryGroupIdentifier;
    private String agentAssocIdInContext;
    private String agentUserExternalID;

    private VFC_CustomerGroupMemberMovesCtrl_Wrapper vfcWrap = new VFC_CustomerGroupMemberMovesCtrl_Wrapper();
    private VFC_CustomerGroupMemberMovesCtrl_Wrapper2 vfcWrap2 = new VFC_CustomerGroupMemberMovesCtrl_Wrapper2();

    /**
     * @description isSearchEnabled
     */
    public Boolean isSearchEnabled{get;private set;}

    /**
     * @description isAccountSpillEnabled
     */
    public Boolean isAccountSpillEnabled{get;private set;}

    /**
     * @description isAddMemberAction
     */
    public Boolean isAddMemberAction{get;private set;}

    /**
     * @description isMoveMemberAction
     */
    public Boolean isMoveMemberAction{get;private set;}

    /**
     * @description isResetANDSaveButtonDisabled
     */
    public Boolean isResetANDSaveButtonDisabled{get;private set;}

    /**
     * @description isSuccess
     */
    public Boolean isSuccess {get; private set;}

    /**
     * @description isS1Request
     */
    public Boolean isS1Request {get; private set;}

    /**
     * @description searchKeyWord
     */
    public transient String searchKeyWord{get;set;}

    /**
     * @description selectedCurrentGMs
     */
	public transient List<Id> selectedCurrentGMs{get;set;}

    /**
     * @description selectedSecondaryGMs
     */
    public transient List<Id> selectedSecondaryGMs{get;set;}

    /**
     * @description accountList
     */
    public transient List<Account> accountList{get;private set;}

    /**
     * @description currentCustomerGroupMemSize
     */
    public transient Integer currentCustomerGroupMemSize{get;private set;}

    /**
     * @description selectedCustomerGroupMemSize
     */
    public transient Integer selectedCustomerGroupMemSize{get;private set;}

    /**
     * @description relatedCustomerName
     */
    public transient String relatedCustomerName{get;set;}

    /**
     * @description relatedCustomerId
     */
    public transient String relatedCustomerId{get;set;}

    /**
     * @description radioButtonValue
     */
    public String radioButtonValue{get;set;}

    /**
     * @description outputTitle
     */
    public String outputTitle{get;private set;}

    /**
     * @description outputLabelName
     */
    public String outputLabelName{get;private set;}

    /**
     * @description VFC_CustomerGroupMemberMovesCtrl
     */
    public VFC_CustomerGroupMemberMovesCtrl() {
        AP_ClickJackPrevention.setRequiredHeaders();
        isS1Request = evaluateIsS1Request();
        try {
            customerGroupId = UTIL_PageParameterHelper.retrieveCurrentPageParameter(GROUP_ID_PARAM, ParameterType.SALESFORCE_ID);
            accountId = UTIL_PageParameterHelper.retrieveCurrentPageParameter(ACCOUNT_ID_PARAM, ParameterType.SALESFORCE_ID);
                      
            vfcWrap.validateSalesforceId(customerGroupId, accountId);
            
            initGroupMemberSetToDisplay.addAll(getGroupMembersInOrder(accountId,customerGroupId,true));
            actualCurrentGroupMemberSet.addAll(initGroupMemberSetToDisplay);
            currentCustomerGroupMemSize = actualCurrentGroupMemberSet.size();
            vfcWrap.loadCustomerGroupMemberDataToDisplay(initGroupMemberSetToDisplay,existingGoupMemberNamesSet);
            isResetANDSaveButtonDisabled=true;
        }
        catch(InvalidParameterValueException ex){
            ex.setMessage(PARAM_VALUE+customerGroupId+BLANK_SPACE+accountId+ex.getMessage());
            LoggingService.logHandledException(ex, CLASS_NAME, CLASS_NAME, System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
        }
    }
    
    /**
     * @description evaluateIsS1Request
     * @return Boolean 
     */
    public Boolean evaluateIsS1Request(){
        
        return vfcWrap.evaluateIsS1Request(isS1Request);
    }

    /**
     * @description Retrive Selected Account Information
     */
    public void retriveSelectedAccountInfo(){
        isAccountSpillEnabled =false;
        newGoupMemberNamesSet.removeAll(newGoupMemberNamesSet);
        List<CustomerGroupMember__c> relatedGM=[SELECT Id, Group__c,Customer__r.name,Group__r.SFGroupIdentifier__c
                                                FROM CustomerGroupMember__c where Customer__C=:relatedCustomerId AND Group__r.Agent__r.UserExternalID__c=:agentUserExternalID];
        if(relatedGM!=null && !relatedGM.isEmpty() && string.isNotEmpty(customerGroupId)){

            if(customerGroupId.equals(relatedGM.get(0).Group__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SAME_GROUP_SEARCH_ERROR_LABEL));
            }else{
                outputLabelName = relatedGM.get(0).Customer__r.Name+ SEARCHED_GROUP_MEMBERS_LABEL;
                isMoveMemberAction=false;
                isAddMemberAction=true;

                relatedGMSetToDisplay.addAll(getGroupMembersInOrder(relatedCustomerId,relatedGM.get(0).Group__c,false));
                actualSecondaryGMSet.addAll(relatedGMSetToDisplay);
                selectedCustomerGroupMemSize = actualSecondaryGMSet.size();
                vfcWrap.loadCustomerGroupMemberDataToDisplay(relatedGMSetToDisplay,newGoupMemberNamesSet);
            }
        }else{
            LoggingService.logHandledException(new DataNotFoundException('Group Information not found for: '+relatedCustomerId+' , '+agentAssocIdInContext), CLASS_NAME, CLASS_NAME, System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
        }
    }

    private Set<CustomerGroupMember__c> getGroupMembersInOrder(Id firstGMAccountId,id groupId,boolean isPrimaryAction){
        Set<CustomerGroupMember__c> gmListToDisplay=new Set<CustomerGroupMember__c>();
        List<CustomerGroupMember__c> listGM=[Select Id, Customer__c, Customer__r.Name,Customer__r.PersonBirthdate,Customer__r.ClientIdentifier__c,GroupMemberId__c,
                                             Group__r.SFGroupIdentifier__c,Group__r.Agent__r.Associate_ID__C, Group__r.Agent__r.UserExternalID__c From CustomerGroupMember__c where Group__c=:groupId];
        if(isPrimaryAction){
            primaryGroupIdentifier = listGM.get(0).Group__r.SFGroupIdentifier__c;
            agentAssocIdInContext = listGM.get(0).Group__r.Agent__r.Associate_ID__C;
            agentUserExternalID = listGM.get(0).Group__r.Agent__r.UserExternalID__c;
        }else{
           secondaryGroupIdentifier = listGM.get(0).Group__r.SFGroupIdentifier__c;
        }

        vfcWrap.getGMListToDisplay(listGM, gmListToDisplay, firstGMAccountId);
        gmListToDisplay.addAll(listGM);
        return gmListToDisplay;
    }

    // Create the select options for the two select lists on the page
    /**
     * @description getExistingGMOptionsListToDisplay
     * @return  `List<SelectOption>`
     */
    public List<SelectOption> getExistingGMOptionsListToDisplay() {
        return selectOptionsFromSet(initGroupMemberSetToDisplay);
    }
    /**
     * @description getNewGMOptionsListToDisplay
     * @return  `List<SelectOption>`
     */
    public List<SelectOption> getNewGMOptionsListToDisplay() {
        return selectOptionsFromSet(relatedGMSetToDisplay);
    }

    private List<SelectOption> selectOptionsFromSet(set <CustomerGroupMember__c> groupMemberList) {
        return vfcWrap.selectOptionsFromSet(groupMemberList);
    }

    // Handle the actual button clicks. Page gets updated via a rerender on the form
    /**
     * @description addingToNewGMList
     */
    public void addingToNewGMList() {
        moveBetweenGroups(selectedCurrentGMs,true);
        isResetANDSaveButtonDisabled=(initGroupMemberSetToDisplay.equals(actualCurrentGroupMemberSet) && relatedGMSetToDisplay.equals(actualSecondaryGMSet));
        currentCustomerGroupMemSize = initGroupMemberSetToDisplay.size();
        selectedCustomerGroupMemSize = relatedGMSetToDisplay.size();
    }
    /**
     * @description removeFromNewGMList
     */
    public void removeFromNewGMList() {
        moveBetweenGroups(selectedSecondaryGMs,false);
        isResetANDSaveButtonDisabled=(initGroupMemberSetToDisplay.equals(actualCurrentGroupMemberSet) && relatedGMSetToDisplay.equals(actualSecondaryGMSet));
        currentCustomerGroupMemSize = initGroupMemberSetToDisplay.size();
        selectedCustomerGroupMemSize = relatedGMSetToDisplay.size();
    }

    private void moveBetweenGroups(List<Id> selectedIds,boolean fromCurrentGroup){
        VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap = new VFC_CustomerGroupMemberMovesCtrlVariableWrapper();
        varWrap.initGroupMemberSetToDisplay = initGroupMemberSetToDisplay;
        varWrap.relatedGMSetToDisplay = relatedGMSetToDisplay;
        
        vfcWrap.moveBetweenGroups(selectedIds, fromCurrentGroup, varWrap);
    }

    /**
     * @description renderingSelectedContent
     */
    public void renderingSelectedContent(){
        currentCustomerGroupMemSize = actualCurrentGroupMemberSet.size();
        isAddMemberAction=false;
        relatedCustomerName=EMPTY_STRING;
        actualSecondaryGMSet.removeAll(actualSecondaryGMSet);
        reArragingGroupMemberSections();
        if(radioButtonValue.equalsIgnoreCase(ADD_MEMBERS)){
            selectedCustomerGroupMemSize = actualSecondaryGMSet.size();
            isSearchEnabled=true;
            isResetANDSaveButtonDisabled=true;
            isMoveMemberAction=false;
            outputTitle=MOVE_MEMBERS_BETWEEN_TWO_GROUPS ;
        }else if(radioButtonValue.equalsIgnoreCase(MOVE_MEMBERS)){
            selectedCustomerGroupMemSize = 0;
            isSearchEnabled=false;
            isMoveMemberAction=true;
            outputLabelName = MOVE_GROUP_MEMBERS_LABEL;
            outputTitle = MOVE_MEMBERS_TO_NEW_GROUP ;
        }
    }
    /**
     * @description resettingCustomerGroupMemberSection
     */
    public void resettingCustomerGroupMemberSection(){
        currentCustomerGroupMemSize = actualCurrentGroupMemberSet.size();
        selectedCustomerGroupMemSize = actualSecondaryGMSet.size();
        isResetANDSaveButtonDisabled=true;
        if(radioButtonValue.equalsIgnoreCase(ADD_MEMBERS)){
            reArragingGroupMemberSections();
            relatedGMSetToDisplay.addAll(actualSecondaryGMSet);
            vfcWrap.loadCustomerGroupMemberDataToDisplay(relatedGMSetToDisplay,newGoupMemberNamesSet);
        }else if(radioButtonValue.equalsIgnoreCase(MOVE_MEMBERS)){
            reArragingGroupMemberSections();
        }
    }

    private void reArragingGroupMemberSections(){
        initGroupMemberSetToDisplay.removeAll(initGroupMemberSetToDisplay);
        initGroupMemberSetToDisplay.addAll(actualCurrentGroupMemberSet);
        existingGoupMemberNamesSet.removeAll(existingGoupMemberNamesSet);
        vfcWrap.loadCustomerGroupMemberDataToDisplay(initGroupMemberSetToDisplay,existingGoupMemberNamesSet);
        relatedGMSetToDisplay.removeAll(relatedGMSetToDisplay);
        newGoupMemberNamesSet.removeAll(newGoupMemberNamesSet);
    }
    /**
     * @description emptyingGroupMemberListOnClearAction
     */
    public void emptyingGroupMemberListOnClearAction(){
        this.relatedCustomerName=EMPTY_STRING;
        isMoveMemberAction=false;
		isAddMemberAction=false;
        isResetANDSaveButtonDisabled=true;
        currentCustomerGroupMemSize = actualCurrentGroupMemberSet.size();
        reArragingGroupMemberSections();
        actualSecondaryGMSet.removeAll(actualSecondaryGMSet);
    }
    /**
     * @description goBackToGroupDetialsPage
     * @return  `PageReference`
     */
    public PageReference goBackToGroupDetialsPage(){
        PageReference pageRef = new PageReference(BACK_SLASH+customerGroupId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    //Getter method to verify if any error messages are present for current state of the page
    /**
     * @description getErrorsPresent
     * @return  `Boolean`
     */
    public Boolean getErrorsPresent(){
        return ApexPages.hasMessages();
    }

  /**
    * @description fetchAccountOnKeySearch
    * @method fetchAccountOnKeySearch: Gets the List of Account on search
    * @param : none
     */
    public void fetchAccountOnKeySearch(){
        searchKeyWord=searchKeyWord.trim();
        accountList=fetchAccountRecords(searchKeyWord);
        isAccountSpillEnabled = vfcWrap.getIsAccountSpillEnabled(accountList, isAccountSpillEnabled);
    }

    /**
     * @description fetchAccountRecords
     * @param searchKeyWord
     * @return  `List<Account>`
     */
    private List<Account> fetchAccountRecords(String searchKeyWord){
        return vfcWrap.fetchAccountRecords(searchKeyWord);
    }

    /**
     * @description buildQueryForAccountSearch
     * @param lastName
     * @param firstName
     * @param searchKeyWord
     * @return  `String`
     */
    private String buildQueryForAccountSearch(String lastName, String firstName,string searchKeyWord){
        return vfcWrap.buildQueryForAccountSearch(lastName, firstName, searchKeyWord);
    }

  //Apex continuation set up method
    /**
     * @description invokeContinuation
     * @return  `Object`
     */
    public Object invokeContinuation() {
        Continuation con = new Continuation(20);
        con.continuationMethod = CALLBACK_METHOD;

        HttpRequest req = TechnicalPlatformDetails.buildHttpRequestForTP();
        req.setEndpoint(HHMGMT_NAMED_CREDENTIALS);
        req = vfcWrap2.setVfcRequest(req, radioButtonValue, ADD_MEMBERS);
        req.setHeader(TechnicalPlatformDetails.CONTENT_TYPE, TechnicalPlatformDetails.JSON_TYPE);

        String reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
        reqBody = getCustomerMovesToSave();

        req.setBody(reqBody);
        System.debug(LoggingLevel.INFO, 'Request -->> '+reqBody);
        this.requestLabel = con.addHttpRequest(req);
        return con;
    }

    //Apex Response method for Continuation
    /**
     * @description processCustomerGroupingResponse
     * @return  `object`
     */
    public object processCustomerGroupingResponse() {

        try {
            isSuccess = false;
            HttpResponse response = Continuation.getResponse(this.requestLabel);
            System.debug(LoggingLevel.INFO, 'Response -->> '+response.getBody());
            AP_CustomerGroupMemberResponse custGMRes =  AP_CustomerGroupMemberResponse.parse(response.getBody());
            if(response.getStatusCode()>=2000 || custGMRes.errors!= null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
                LoggingService.logHandledException(new CustomerAggregatorException(primaryGroupIdentifier+BLANK_SPACE+secondaryGroupIdentifier+BLANK_SPACE+custGMRes.errors.get(0)), CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            }else{

                AP_CustomerGroupMemberResponse.CustomerGroupResponseData groupMemberData= custGMRes.data;
                List<AP_CustomerGroupMemberResponse.CustomerGroupData> groupMemberValues=groupMemberData.groupings;


                //Customer Group List to upsert
                List<CustomerGroup__c> custGroupList = getNewCustomerGroupToInsert(groupMemberValues);
                UTIL_CustomerGroupDAO.upsertCustomerGroupList(custGroupList);
                //Customer Group Member List to upsert
                List<CustomerGroupMember__c> listofGroupMemberRecords = HLPR_CustomerGroupMemberResponse.getCustomerGroupMemberFromHHMgmtResponse(groupMemberValues);
                UTIL_CustomerGroupMemberDAO.upsertCustomerGroupMemberList(listofGroupMemberRecords);
                isSuccess = true;
            }
        }
        catch(Exception exp) {
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));

        }
        return null;
    }

    private string getCustomerMovesToSave(){
        AP_CustomerGroupMemberRequest req = new AP_CustomerGroupMemberRequest();
        req.data = new AP_CustomerGroupMemberRequest.CustomerGroupPayloadData();
        AP_CustomerGroupMemberRequest.CustomerGroupPayloadData data = new AP_CustomerGroupMemberRequest.CustomerGroupPayloadData();
        data.groups = new List<AP_CustomerGroupMemberRequest.CustomerGroupModification>();

        VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap = new VFC_CustomerGroupMemberMovesCtrlVariableWrapper();
        varWrap.actualCurrentGroupMemberSet = actualCurrentGroupMemberSet;
        varWrap.actualSecondaryGMSet = actualSecondaryGMSet;
        varWrap.data = data;
        varWrap.initGroupMemberSetToDisplay = initGroupMemberSetToDisplay;
        varWrap.primaryGroupIdentifier = primaryGroupIdentifier;
        varWrap.relatedGMSetToDisplay = relatedGMSetToDisplay;
        varWrap.secondaryGroupIdentifier = secondaryGroupIdentifier;

        vfcWrap2.getDataGroups(varWrap);

        data.agent=agentAssocIdInContext;
        req.data = data;
        return HLPR_CustomerGroupMovesRequest.getCustomerGroupMovesRequest(req);
    }

    private List<CustomerGroup__c> getNewCustomerGroupToInsert(List<AP_CustomerGroupMemberResponse.CustomerGroupData> groupMemberValues){
        List<string> groupId = new List<string>();
        List<CustomerGroup__c> custGroupList=new List<CustomerGroup__c>();
        set<string> jsonHouseholdIdSet=new set<String>();

        VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap = new VFC_CustomerGroupMemberMovesCtrlVariableWrapper();
        varWrap.groupId = groupId;
        varWrap.custGroupList = custGroupList;
        varWrap.jsonHouseholdIdSet = jsonHouseholdIdSet;
        varWrap.groupMemberValues = groupMemberValues;
        varWrap.agentAssocIdInContext = agentAssocIdInContext;

        vfcWrap2.getGroupIdAndCustGrpList(varWrap);
        return custGroupList;
    }
    /**
     * @description redirectToGroupDetialsPage
     * @return  `PageReference`
     */
    public PageReference redirectToGroupDetialsPage(){
        CustomerGroupMember__c primaryGM=[SELECT Id, Group__c FROM CustomerGroupMember__c where Customer__C=:accountId LIMIT 1];
        PageReference pageRef = new PageReference(BACK_SLASH+primaryGM.Group__c);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private with sharing class VFC_CustomerGroupMemberMovesCtrl_Wrapper{

        private Boolean evaluateIsS1Request(Boolean isS1Request){
        
            if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
                isS1Request = true;
            }else {
                isS1Request = false;
            }
    
            return isS1Request;
        }

        private void validateSalesforceId(Id customerGroupId, Id accountId){
            if(String.isNotBlank(customerGroupId) && String.isNotBlank(accountId)) {
                UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(GROUP_ID_PARAM, customerGroupId, CustomerGroup__c.class);
                UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(ACCOUNT_ID_PARAM, accountId, Account.class);
            }      
        }

        private void getGMListToDisplay(List<CustomerGroupMember__c> listGM, Set<CustomerGroupMember__c> gmListToDisplay, Id firstGMAccountId){
            for(CustomerGroupMember__c groupMember:listGM){
                if(groupMember.Customer__c.equals(firstGMAccountId)){
                    gmListToDisplay.add(groupMember);
                    break;
                }
            }            
        }

        private void loadCustomerGroupMemberDataToDisplay(Set<CustomerGroupMember__c> groupMemberList,Set<String> setOfGroupMemberListToAdd) {

            for(CustomerGroupMember__c groupMember :groupMemberList){
                if (groupMember.Customer__r.PersonBirthdate!=null ){
                    setOfGroupMemberListToAdd.add(groupMember.Customer__r.Name +DOB_STRING+String.valueOf(groupMember.Customer__r.PersonBirthdate.format()));
                }else{
                    setOfGroupMemberListToAdd.add(groupMember.Customer__r.Name);
                }
            }
        }

        private List<SelectOption> selectOptionsFromSet(set <CustomerGroupMember__c> groupMemberList) {
            List<SelectOption> optionsToDisplay = new List<SelectOption>();
            if(!groupMemberList.isEmpty() && groupMemberList!=null){
                for(CustomerGroupMember__c groupMember :groupMemberList){
                    if (groupMember.Customer__r.PersonBirthdate!=null ){
                        optionsToDisplay.add(new SelectOption(groupMember.Customer__c, groupMember.Customer__r.Name +DOB_STRING+String.valueOf(groupMember.Customer__r.PersonBirthdate.format())));
                    }else{
                        optionsToDisplay.add(new SelectOption(groupMember.Customer__c,groupMember.Customer__r.Name));
                    }
                }
            }
            return optionsToDisplay;
        }

        private void moveBetweenGroups(List<Id> selectedIds,boolean fromCurrentGroup, 
                                       VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap){
            for(Id groupMemberId:selectedIds){
                if(fromCurrentGroup){
                    moveGroupMemberFromCurrentToSecondarySet(groupMemberId, varWrap);
                }else{
                    moveGroupMemberFromSecondaryToCurrentSet(groupMemberId, varWrap);
                }
            }
        }

        private void moveGroupMemberFromCurrentToSecondarySet(Id customerGMId, VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap){
            for(CustomerGroupMember__c custGM: varWrap.initGroupMemberSetToDisplay){
                if(custGM.Customer__c.equals(customerGMId)){
                    varWrap.initGroupMemberSetToDisplay.remove(custGM);
                    varWrap.relatedGMSetToDisplay.add(custGM);
                    break;
                }
            }
        }
    
        private void moveGroupMemberFromSecondaryToCurrentSet(Id customerGMId, VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap){
            for(CustomerGroupMember__c custGM: varWrap.relatedGMSetToDisplay){
                if(custGM.Customer__c.equals(customerGMId)){
                    varWrap.relatedGMSetToDisplay.remove(custGM);
                    varWrap.initGroupMemberSetToDisplay.add(custGM);
                    break;
                }
            }
        }

        private Boolean getIsAccountSpillEnabled(List<Account> accountList, Boolean isAccountSpillEnabled){
            
            if(accountList!=null && !accountList.isEmpty()){
                isAccountSpillEnabled=true;
            }else{
                isAccountSpillEnabled=false;
            }

            return isAccountSpillEnabled;
        }

        private List<Account> fetchAccountRecords(String searchKeyWord){
            List<Account> listofIndividualAccountRecord=new List<Account>();
            String queryString=EMPTY_STRING;
            if(!searchKeyWord.containsWhitespace() && !searchKeyWord.contains(COMMA)){
                queryString=buildQueryForAccountSearch(searchKeyWord,EMPTY_STRING,EMPTY_STRING);
                listofIndividualAccountRecord=database.query(queryString);
            }else{
                //if search string contains whitspace logic will be handled here
                VFC_CustomerGroupMemberMovesCtrl_Wrapper2 wrap2 = new VFC_CustomerGroupMemberMovesCtrl_Wrapper2();
                queryString=buildQueryForAccountSearch(wrap2.getNameStringFromSearch(searchKeyWord,true),wrap2.getNameStringFromSearch(searchKeyWord,false),searchKeyWord);
                listofIndividualAccountRecord=database.query(queryString);
            }
            return listofIndividualAccountRecord;
        }

        private String buildQueryForAccountSearch(String lastName, String firstName,string searchKeyWord){
            String queryAccounts='Select ClientIdentifier__c,Name,IsPersonAccount,BillingStreet, BillingCity,PersonBirthdate, BillingState, BillingPostalCode, BillingCountry FROM Account where ';
            String openParanthesis='(';
            String lastNameLike=' Lastname like \'';
            String andFirstNameLike=' AND Firstname like \'';
            String wildCardString='%\'';
            String closedParanthesis=')';
            String orString=' OR ';
            string orderBy = ' ORDER BY Name ';
            String limitString=' LIMIT 150';
    
            queryAccounts+=openParanthesis+lastNameLike+String.escapeSingleQuotes(lastName)+wildCardString;
            if(String.isNotEmpty(firstName)){
                queryAccounts+=andFirstNameLike+String.escapeSingleQuotes(firstname)+wildCardString;
            }
            queryAccounts+=closedParanthesis;
            if(String.isNotEmpty(searchKeyWord)){
                searchKeyWord = searchKeyWord.replace(COMMA,BLANK_SPACE);
                queryAccounts+=orString+lastNameLike+String.escapeSingleQuotes(searchKeyWord)+wildCardString;
            }
            queryAccounts+=orderBy+limitString;
            return queryAccounts;
        }
    }

    private class VFC_CustomerGroupMemberMovesCtrl_Wrapper2{
        private string getNameStringFromSearch(String searchKeyWord,boolean isLastName){
            String name=EMPTY_STRING;
            if(searchKeyWord.containsWhitespace()){
                name=getNameFromSearchString(searchKeyWord,isLastName,BLANK_SPACE);
            }else if(searchKeyWord.contains(COMMA)){
                name=getNameFromSearchString(searchKeyWord,isLastName,COMMA);
            }
            return name;
        }
    
        private String getNameFromSearchString(String searchKeyWord,boolean isLastName,string separateString){
            String name=EMPTY_STRING;
            if(isLastName){
                name=searchKeyWord.substringBefore(separateString);
            }else{
                name=searchKeyWord.substringAfter(separateString);
                If(name.containsWhitespace() || name.contains(COMMA)){
                    name=name.substringBefore(separateString);
                }
            }
            return name;
        }

        private void getDataGroups(VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap){
            for(CustomerGroupMember__c custGrpMem : varWrap.initGroupMemberSetToDisplay){
                if(!varWrap.actualCurrentGroupMemberSet.contains(custGrpMem)){
                    AP_CustomerGroupMemberRequest.CustomerGroupModification groupUpdatesForPrimary = new AP_CustomerGroupMemberRequest.CustomerGroupModification();
                    groupUpdatesForPrimary.customer =custGrpMem.Customer__r.clientIdentifier__c;
                    groupUpdatesForPrimary.newGroup =varWrap.primaryGroupIdentifier;
                    groupUpdatesForPrimary.oldGroup =custGrpMem.Group__r.SFGroupIdentifier__c;
                    varWrap.data.groups.add(groupUpdatesForPrimary);
                }
            }

            for(CustomerGroupMember__c custGrpMem : varWrap.relatedGMSetToDisplay){
                if(!varWrap.actualSecondaryGMSet.contains(custGrpMem)){
                    AP_CustomerGroupMemberRequest.CustomerGroupModification groupUpdatesForSecondary = new AP_CustomerGroupMemberRequest.CustomerGroupModification();
                    groupUpdatesForSecondary.customer =custGrpMem.Customer__r.clientIdentifier__c;
                    groupUpdatesForSecondary.newGroup =varWrap.secondaryGroupIdentifier ;
                    groupUpdatesForSecondary.oldGroup =custGrpMem.Group__r.SFGroupIdentifier__c;
                    varWrap.data.groups.add(groupUpdatesForSecondary);
                }
            }
        }

        private void getGroupIdAndCustGrpList(VFC_CustomerGroupMemberMovesCtrlVariableWrapper varWrap){
            
            for(AP_CustomerGroupMemberResponse.CustomerGroupData jsonGroupMemberValue : varWrap.groupMemberValues){
                if(!varWrap.jsonHouseholdIdSet.contains(jsonGroupMemberValue.groupId)){
                    varWrap.jsonHouseholdIdSet.add(jsonGroupMemberValue.groupId);
                    varWrap.groupId.add(jsonGroupMemberValue.groupId);
                    varWrap.custGroupList.add(UTIL_OrchestrationJSONtoGroupDetails.createGroupRecord(jsonGroupMemberValue.groupId, varWrap.agentAssocIdInContext));
                }
            }
        }

        private HttpRequest setVfcRequest(HttpRequest req, String radioButtonValue, String addMembers){
            if(radioButtonValue.equalsIgnoreCase(addMembers)){
                req.setMethod(TechnicalPlatformDetails.PUT);
            }else{
                req.setMethod(TechnicalPlatformDetails.POST);
            }
            
            return req;
        } 
    }

    private class VFC_CustomerGroupMemberMovesCtrlVariableWrapper{
        private Set<CustomerGroupMember__c> initGroupMemberSetToDisplay;
        private Set<CustomerGroupMember__c> actualCurrentGroupMemberSet;
        private Set<CustomerGroupMember__c> relatedGMSetToDisplay;
        private Set<CustomerGroupMember__c> actualSecondaryGMSet;
        private String secondaryGroupIdentifier;
        private String primaryGroupIdentifier;
        private String agentAssocIdInContext;
        private AP_CustomerGroupMemberRequest.CustomerGroupPayloadData data;

        List<string> groupId;
        List<CustomerGroup__c> custGroupList;
        set<string> jsonHouseholdIdSet;
        List<AP_CustomerGroupMemberResponse.CustomerGroupData> groupMemberValues;
    }
}
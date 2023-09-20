/**
 * @name VFC_C2CRelationshipController
 * @author Team LocoMotivated
 * @date 11/01/2017
 * @description Customer Relationship create update Controller
 */
public with sharing class VFC_C2CRelationshipController{

    public account accountRecord;
    public string primaryAccountClientId;
    public String requestLabel;
    public static final String EMPTY_STRING ='';
    public static final String BLANK_SPACE =' ';
    public static final String COMMA =',';
    public static final String BACK_SLASH ='/';


    private static final String S1_THEME = 'Theme4t';
    private static final String LIGHTNING_MODERN_THEME = 'Theme4d';
    private static final String LIGHTNING_CONSOLE_THEME = 'Theme4u';
    public static final String C2CRELATIONSHIPS_RESOURCE_DEVELOPER_NAME='Customer_Relationships_Resource';
    private static final String CUST_AGGT_NAMED_CREDENTIALS = 'callout:Customer_Aggregator_Process_Id';
    private static final String CALLBACK_METHOD = 'processC2CRelationshipAggregatorResponse';
    private static final String CLASS_NAME = 'VFC_C2CRelationshipController';
    private static final String METHOD_NAME = 'processC2CRelationshipAggregatorResponse';
    private static final String INIT_METHOD_NAME = 'init';
    private static final String DELID_STR = 'delId';
    private static final String ID_STR = 'id';
    private static final String RELATED_CUSTOMER_MANDATORY ='Please select Related Customer';
    private static final String EMPTY_RELATED_CUSTOMER ='Please select a Related Customer from the search results before clicking Save';
    private static final String RELATIONSHIP_NATURE_MANDATORY ='Please select Relationship Nature';
    private static final String ORGANIZATION_RESTRICT_MESSAGE ='At this time organization relationships cannot be updated or deleted';
    private static final String ORGANIZATION_CREATE_C2C_MESSAGE ='Create New Customer to Customer Relationship for Organization currently is not available!';
    private String deleteId;
    private String editId;
    private static final String INDIVIDUAL='Individual';
    private static final String C2C_RELATIONSHIP_INDIVIDUAL_TO_INDIVIDUAL ='Individual-Individual';
    private static final String C2C_RELATIONSHIP_INDIVIDUAL_TO_ORGANIZATION ='Individual-Organization';
    private static final String C2C_RELATIONSHIP_ORGANIZATION_TO_INDIVIDUAL ='Organization-Individual';
    private static final String C2C_RELATIONSHIP_ORGANIZATION_TO_ORGANIZATION ='Organization-Organization';
    private static final String C2C_POSSIBLE_DUPLICATE ='Possible Duplicate (Action Required)';
    private static final String C2C_SYSTEM_DEFAULT_RELATIONSHIP ='System Default';
    private static final String INDUSTRIES_HOUSEHOLD = 'IndustriesHousehold';

    /**
     * @description customerRelationshipRecord
     */
    public Relationship__c customerRelationshipRecord {get; private set;}

     /**
     * @description isNewRelationship
     */
    public Boolean isNewRelationship {get; private set;}

     /**
     * @description isSuccess
     */
    public Boolean isSuccess {get; private set;}

    /**
     * @description isS1Request
     */
    public Boolean isS1Request {get; private set;}

    /**
     * @description isLightningRequest
     */
    @TestVisible public Boolean isLightningRequest {get; private set;}

    /**
     * @description isSearchEnabled
     */
    public boolean isSearchEnabled{get; private set;}

    /**
     * @description isDeleteIndicator
     */
    public boolean isDeleteIndicator{get;private set;}

    /**
     * @description isDeleteDuplicateDisclaimer
     */
    public boolean isDeleteDuplicateDisclaimer{get;private set;}

    /**
     * @description isDeleteSysDefaultDisclaimer
     */
    public boolean isDeleteSysDefaultDisclaimer{get;private set;}

    /**
     * @description isOrganizationRestrictIndicator
     */
    public boolean isOrganizationRestrictIndicator{get;private set;}

    /**
     * @description isCreateOrganizationRelationshipInClassic
     */
    public boolean isCreateOrganizationRelationshipInClassic{get;private set;}

    /**
     * @description accountList
     */
    public transient List<Account> accountList{get;private set;}

    /**
     * @description searchKeyWord
     */
    public string searchKeyWord{get; set;}

    /**
     * @description customer
     */
    public String customer{get;private set;}

    /**
     * @description relatedCustomerName
     */
    public String relatedCustomerName {get;set;}

    /**
     * @description relatedCustomerClientId
     */
    public string relatedCustomerClientId {get;set;}

    /**
     * @description relationshipNature
     */
    public String relationshipNature{get;set;}
    

    /**
     * @description titleName
     */
    public String titleName{get;private set;}

    //constructor
    /**
     *
     * @param stdController
     * @description VFC_C2CRelationshipController(ApexPages.StandardController stdController)
     */
    public VFC_C2CRelationshipController(ApexPages.StandardController stdController){
        AP_ClickJackPrevention.setRequiredHeaders();
        customerRelationshipRecord = (Relationship__c)stdController.getRecord();
       
        evaluateS1RequestAndLtngRequest();
        VFC_C2CRelationshipControllerWrapper relWrap = new VFC_C2CRelationshipControllerWrapper();
        deleteId = relWrap.evaluateDeleteId(deleteId, DELID_STR);
        editId = relWrap.evaulateEditId(editId, ID_STR);

        isSuccess=false;
        isDeleteIndicator=false;
        isNewRelationship=false;
        isOrganizationRestrictIndicator=false;
        customer=EMPTY_STRING;
        relatedCustomerName=EMPTY_STRING;
        relationshipNature=EMPTY_STRING;
    }
    
    void evaluateS1RequestAndLtngRequest(){
        
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isS1Request = true;
        }else if(LIGHTNING_MODERN_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed()) ||LIGHTNING_CONSOLE_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())){
            isLightningRequest=true;
        }
        else {
            isS1Request = false;
            isLightningRequest=false;
        }
    }

    //Init method to initialize required field values
    /**
     * @description init
     */
    public void init(){
        try{
        if(string.isEmpty(deleteId) && string.isEmpty(editId)){
            createC2CRelationshipSetup();
        }else if(editId<>null && string.isEmpty(deleteId)){
            updateC2CRelationshipSetup();
        }else{
            deleteC2CRelationshipSetup();
        }
        }catch(Exception ex){
            isNewRelationship=false;
            LoggingService.logHandledException(ex, CLASS_NAME, INIT_METHOD_NAME, System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
        }
    }

  /**
    * @method createC2CRelationshipSetup: Gets the new picklist values for related customer nature
    * @description createC2CRelationshipSetup
    * @param : none
    */
    private void createC2CRelationshipSetup() {
        isNewRelationship=true;
      	accountRecord = getAccountRecord(string.escapeSingleQuotes(customerRelationshipRecord.AccountTwo__c));
        customer=accountRecord.name;
        primaryAccountClientId=accountRecord.ClientIdentifier__c;
        titleName = System.Label.CL_CreateCustomerRelationshipLabel;
        string accountTwoRecordtypeName=accountRecord.recordType.name;

        if(!isLightningRequest && !accountTwoRecordtypeName.equalsIgnoreCase(INDIVIDUAL)){
            isCreateOrganizationRelationshipInClassic=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ORGANIZATION_CREATE_C2C_MESSAGE));
        }
    }

  /**
    * @method updateC2CRelationshipSetup: Gets the new picklist values for related customer nature
    * @param : none
    * @return : none
    */
    /**
     * @description updateC2CRelationshipSetup
     */
    public void updateC2CRelationshipSetup() {
        //Calling helper class to get the Relationship record for a give record Id
        customerRelationshipRecord = getRelationshipRecord(editId);
        Account relatedAccount=UTIL_AccountDAO.getAccountDetails(customerRelationshipRecord.accountOne__c);
        string accountOneRecordtypeName = relatedAccount.recordType.name;
        string accountTwoRecordtypeName = getRecordTypeName(customerRelationshipRecord.accountTwo__r.recordTypeId);

        if((!accountOneRecordtypeName.equalsIgnoreCase(INDIVIDUAL) || !accountTwoRecordtypeName.equalsIgnoreCase(INDIVIDUAL)) && !isLightningRequest){
            isOrganizationRestrictIndicator=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ORGANIZATION_RESTRICT_MESSAGE));
        }
        customer=customerRelationshipRecord.accountTwo__r.name;
        primaryAccountClientId=customerRelationshipRecord.accountTwo__r.ClientIdentifier__c;
        relatedCustomerName=relatedAccount.name;
        relatedCustomerClientId = relatedAccount.ClientIdentifier__c;
        relationshipNature=customerRelationshipRecord.RelationshipType__c;
        titleName=System.Label.CL_UpdateCustomerRelationshipLabel;
    }

  /**
    * @method deleteC2CRelationshipSetup: Gets the new picklist values for related customer nature
    * @param : none
    * @return : none
    */
    /**
     * @description deleteC2CRelationshipSetup
     */
    public void deleteC2CRelationshipSetup() {
        isDeleteIndicator=true;
        //Calling helper class to get the Relationship record for a give record Id
        customerRelationshipRecord = getRelationshipRecord(deleteId);
        Account relatedAccount=UTIL_AccountDAO.getAccountDetails(customerRelationshipRecord.accountOne__c);
        string accountOneRecordtypeName = relatedAccount.recordType.name;
        string accountTwoRecordtypeName = getRecordTypeName(customerRelationshipRecord.accounttwo__r.recordTypeId);

        if((!accountOneRecordtypeName.equalsIgnoreCase(INDIVIDUAL) || !accountTwoRecordtypeName.equalsIgnoreCase(INDIVIDUAL)) && !isLightningRequest){
            isOrganizationRestrictIndicator=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ORGANIZATION_RESTRICT_MESSAGE));
        }
        customer=customerRelationshipRecord.accountTwo__r.name;
        primaryAccountClientId=customerRelationshipRecord.accountTwo__r.ClientIdentifier__c;
        relatedCustomerName=relatedAccount.name;
        relatedCustomerClientId = relatedAccount.ClientIdentifier__c;
        relationshipNature=customerRelationshipRecord.RelationshipType__c;
        if(relationshipNature.equals(C2C_POSSIBLE_DUPLICATE)){
            isDeleteDuplicateDisclaimer = true;
        }else if(relationshipNature.contains(C2C_SYSTEM_DEFAULT_RELATIONSHIP)){
            isDeleteSysDefaultDisclaimer = true;
        }
        titleName=System.Label.CL_DeleteCustomerRelationshipLabel;
    }

  /**
    * @method getRelationshipPickList: Gets the new picklist values for related customer nature
    * @param : none
    * @return : List of SelectOption
    */
    /**
     * @description getRelationshipPickList
     * @return  `List<SelectOption>`
     */
    public List<SelectOption> getRelationshipPickList() {
        List<SelectOption> relationshipPLOptions = new List<SelectOption>();
        relationshipPLOptions.add(new SelectOption(UTIL_CreateCustomerConstants.EMPTY_STRING, UTIL_CreateCustomerConstants.NONE_SELECT_OPTION));
        Schema.DescribeFieldResult fieldResult = Relationship__c.RelationshipType__c.getDescribe();
        List<Schema.PicklistEntry> relationshipTypeListEntries = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry relationshipType : relationshipTypeListEntries) {
            relationshipPLOptions.add(new SelectOption(relationshipType.getValue(), relationshipType.getLabel()));
        }
        return relationshipPLOptions;
    }

  /**
    * @method fetchAccountOnKeySearch: Gets the List of Account on search
    * @param : none
    * @return : List of Accounts
    */
    /**
     * @description fetchAccountOnKeySearch
     */
    public void fetchAccountOnKeySearch(){
        searchKeyWord=searchKeyWord.trim();
        accountList=fetchIndividualAccountRecord(searchKeyWord,primaryAccountClientId);
        if(accountList!=null && !accountList.isEmpty()){
            isSearchEnabled=true;
        }else{
            isSearchEnabled=false;
        }
    }

  /**
    * @method fetchIndividualAccountRecord: Gets the List of Account on search
     *
     * @param searchKeyWord
     * @param primaryKeyClientID
     * @description fetchIndividualAccountRecord
     * @return  `List<Account>`
     */
    private List<Account> fetchIndividualAccountRecord(String searchKeyWord,String primaryKeyClientID){
        List<Account> listofIndividualAccountRecord=new List<Account>();
        String queryString=EMPTY_STRING;
        if(!searchKeyWord.containsWhitespace() && !searchKeyWord.contains(COMMA)){
            queryString=buildQueryForAccountSearch(searchKeyWord,EMPTY_STRING,primaryKeyClientID);
            listofIndividualAccountRecord=Security.stripInaccessible(AccessType.READABLE, database.query(queryString)).getRecords();
        }else{
            //if search string contains whitspace logic will be handled here
            queryString=buildQueryForAccountSearch(getNameStringFromSearch(searchKeyWord,true),getNameStringFromSearch(searchKeyWord,false),primaryKeyClientID);
            listofIndividualAccountRecord=Security.stripInaccessible(AccessType.READABLE, database.query(queryString)).getRecords();
        }
        return listofIndividualAccountRecord;
    }

  /**
    * @method buildQueryForAccountSearch: Query builder for lookup on accounts
    * @param : lastName, firstName and primaryKeyClientID
    * @return : Query String
    */
    /**
     *
     * @param lastName
     * @param firstName
     * @param primaryKeyClientID
     * @description buildQueryForAccountSearch
     * @return  `String`
     */
    private String buildQueryForAccountSearch(String lastName, String firstName,string primaryKeyClientID){
        String queryAccounts='Select ClientIdentifier__c,Name,IsPersonAccount,BillingStreet, BillingCity,PersonBirthdate, BillingState, BillingPostalCode, BillingCountry FROM Account where Lastname like \'';
        String escapeChar='\'';
        String limitString=' LIMIT 500';
        String andRecordtypeNameEqualTo=' AND RecordType.Name=\'';
        String andIdNotEqualTo=' AND ClientIdentifier__c<>\'';
        String andFirstNameLike='AND Firstname like \'';
        String wildCardString='%\'';
        string orderBy = ' ORDER BY Name ';

        queryAccounts=queryAccounts+String.escapeSingleQuotes(lastName)+wildCardString;
        if(String.isNotEmpty(firstName)){
            queryAccounts=queryAccounts+andFirstNameLike+String.escapeSingleQuotes(firstname)+wildCardString;
        }
        queryAccounts=queryAccounts+andIdNotEqualTo+String.escapeSingleQuotes(primaryKeyClientID)+escapeChar+andRecordtypeNameEqualTo
            +UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME+escapeChar+orderBy+limitString;
        return queryAccounts;
    }

  /**
    * @method getNameStringFromSearch: Split search keyword on keypress
    * @param : searchKeyWord and isLastName
    * @return : Name String
    */
    /**
     *
     * @param searchKeyWord
     * @param isLastName
     * @description getNameStringFromSearch
     * @return  `string`
     */
    private string getNameStringFromSearch(String searchKeyWord,boolean isLastName){
        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        return vfcWrap.getNameStringFromSearch(searchKeyWord, isLastName);
    }

    /**
     * @description disableSearch
     */
    public void disableSearch(){
        //assigning selected account info to class varialbles
        this.isSearchEnabled =false;
    }
    /**
     * @description clearSelectedAccount
     */
    public void clearSelectedAccount(){
        this.relatedCustomerName=EMPTY_STRING;
        this.relatedCustomerClientId =EMPTY_STRING;
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
    * @method fieldValidations: Field validation if any/both of the field(s) is empty
    * @param : none
    * @return : void
    */
    /**
     * @description fieldValidations
     */
    public void fieldValidations(){
        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        vfcWrap.fieldValidations(relatedCustomerName, relationshipNature);
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
        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        req = vfcWrap.setHttpMethod(req, isNewRelationship, isDeleteIndicator);

        CM_Customer_Aggregator_Resource__mdt c2cResource = getCustomerAggregatorMetadata();
        req.setEndpoint(CUST_AGGT_NAMED_CREDENTIALS+c2cResource.Resource_Path__c);
        req.setHeader(TechnicalPlatformDetails.CONTENT_TYPE, TechnicalPlatformDetails.JSON_TYPE);

        String reqBody = UTIL_CreateCustomerConstants.EMPTY_STRING;
        User currentUser = getLoggedInUser(userInfo.getUserId());
        string associateId=currentUser.Associate_ID__c;

        if(string.isBlank(relatedCustomerClientId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, EMPTY_RELATED_CUSTOMER));
        }else{

            HLPR_C2CRelationshipAggregator.C2CRelationshipReqWrapper relWrap = new HLPR_C2CRelationshipAggregator.C2CRelationshipReqWrapper();
            relWrap.primaryclientId = primaryAccountClientId;
            relWrap.relatedClientId = relatedCustomerClientId;
            relWrap.relationshipNature = relationshipNature;
            relWrap.associateId = associateId;

            reqBody = HLPR_C2CRelationshipAggregator.getC2CRelationshipRequest(relWrap);            
            req.setBody(reqBody);
            this.requestLabel = con.addHttpRequest(req);
        }
        return con;
    }

     //Apex Response method for Continuation
     /**
      * @description processC2CRelationshipAggregatorResponse
      * @return  `object`
      */
    public object processC2CRelationshipAggregatorResponse() {

        List<String> listofClientIds = new List<String> {primaryAccountClientId,relatedCustomerClientId};
        try {
            isSuccess = false;
            HttpResponse response = Continuation.getResponse(this.requestLabel);
            AP_C2CRelationshipAggregatorResponse custRelAggtRes = AP_C2CRelationshipAggregatorResponse.parse(response.getBody());

            if(response.getStatusCode()>=2000 ||!custRelAggtRes.errors.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
                list<AP_C2CRelationshipAggregatorResponse.C2CRelationshipErrors> errorList=custRelAggtRes.getErrorList();
                string accIdStringsToLog = UTIL_C2CRelationshipDAO.getAccountIdStringToLogForGiveClientIds(listofClientIds);
                string errorMsg=titleName+' Failures: '+accIdStringsToLog+' Nature: '+relationshipNature;
                for(AP_C2CRelationshipAggregatorResponse.C2CRelationshipErrors error: errorList){
                    errorMsg=errorMsg+BLANK_SPACE+error.detail;
                }
                LoggingService.logHandledException(new CustomerAggregatorException(errorMsg), CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            }
            else {
                if(!isDeleteIndicator) {
                    List<Relationship__c> listofC2CRelationshipRecords = HLPR_C2CRelationshipAggregatorResponse.getC2CRelationshipFromAggregatortResponse(custRelAggtRes.getDataList());
                    UTIL_C2CRelationshipDAO.upsertC2CRelationships(listofC2CRelationshipRecords);
                    isSuccess=true;
                }else {
                    deleteC2CResponse();
                    isSuccess=true;
                }
            }
        }
        catch(Exception exp) {
            string accIdStringsToLog = UTIL_C2CRelationshipDAO.getAccountIdStringToLogForGiveClientIds(listofClientIds);
            string errorMsg=titleName+' Failures: '+accIdStringsToLog+' Nature: '+relationshipNature;
            exp.setMessage(errorMsg);
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CL_Exception_Message));
        }
        return null;
    }


    private void deleteC2CResponse(){
        string primaryRelationshipIdentifier=primaryAccountClientId+'~'+relatedCustomerClientId;
        string reciprocalRelationshipIdentifier=relatedCustomerClientId+'~'+primaryAccountClientId;
       	List<Relationship__c> deletedC2CList = getC2CRecords(primaryRelationshipIdentifier, reciprocalRelationshipIdentifier);
        UTIL_C2CRelationshipDAO.deleteCustomerRelationships(deletedC2CList);
    }

  /**
    * @method delCancel: PageReference on cancel
    * @param : none
    * @return : PageReference
    */
    /**
     * @description delCancel
     * @return  `PageReference`
     */
    public PageReference delCancel() {
        PageReference accountPage = new PageReference(BACK_SLASH + customerRelationshipRecord.accountTwo__r.Id);
        accountPage.setRedirect(true);
        return accountPage;
    }

      /**
    * @method getC2CRelationshipRecordForLightning
    * @param : relId
    * @return : Relationship__c
    */
    /**
     *
     * @param relId
     * @description getC2CRelationshipRecordForLightning
     * @return  `RelationshipAndUserIdWrapper`
     * @exception
     */
    @AuraEnabled
    public static RelationshipAndUserIdWrapper getC2CRelationshipRecordForLightning(Id relId) {
        Relationship__C rel1 = getRelationshipRecord(relId);
        User currentUser = getLoggedInUser(userInfo.getUserId());
        RelationshipAndUserIdWrapper relationshipAndUserIdWrapper = new RelationshipAndUserIdWrapper();
        relationshipAndUserIdWrapper.relationshipRecord = rel1;
        relationshipAndUserIdWrapper.userId = currentUser.Associate_ID__c;
        try{
        relationshipAndUserIdWrapper.primaryAccountType = getRecordTypeName(rel1.accountTwo__r.recordTypeId);
        relationshipAndUserIdWrapper.relatedAccountType = getRecordTypeName(rel1.accountOne__r.recordTypeId);
        return relationshipAndUserIdWrapper;
        }catch(NullPointerException e){
            throw new AuraHandledException('NOT ALLOWED');
        }
    }
    /**
     *
     * @param recordId
     * @description getPrimaryAccount
     * @return  `AccountAndAgentAssocIdWrapper`
     */
    @AuraEnabled
    public static AccountAndAgentAssocIdWrapper getPrimaryAccount(Id recordId){
        Account primaryAccountRecord = getPrimaryAccountDetail(recordId);
        User currentUser = getLoggedInUser(userInfo.getUserId());
        AccountAndAgentAssocIdWrapper accountAgentAssocIdWrapper = new AccountAndAgentAssocIdWrapper();
        accountAgentAssocIdWrapper.accountRecord = primaryAccountRecord ;
        accountAgentAssocIdWrapper.associateID = currentUser.Associate_ID__c;

        return  accountAgentAssocIdWrapper;
    }
    /**
     * @description upsertC2CRelationship
     * @param responseBody
     */
     @AuraEnabled
     public static void upsertC2CRelationship(String responseBody) {
         AP_C2CRelationshipAggregatorResponse custRelAggtRes = AP_C2CRelationshipAggregatorResponse.parse(responseBody);
         List<Relationship__c> listofC2CRelationshipRecords = HLPR_C2CRelationshipAggregatorResponse.getC2CRelationshipFromAggregatortResponse(custRelAggtRes.getDataList());
         UTIL_C2CRelationshipDAO.upsertC2CRelationships(listofC2CRelationshipRecords);
    }
    /**
     *
     * @param recordTypeForPrimaryAccount
     * @param recordTypeForRelatedAccount
     * @description getOptions
     * @return  `List<String>`
     */
    @AuraEnabled
    public static List<String> getOptions(String recordTypeForPrimaryAccount , String recordTypeForRelatedAccount){
        List<String> optionList = new List<String>();
        String keyCategory=getKeyCategory(recordTypeForPrimaryAccount,recordTypeForRelatedAccount);
        optionList=getOptionValues(keyCategory);
        return optionList;
    }

    private static Relationship__C getRelationshipRecord(Id relId) {
        Relationship__C relationship;
        List<Relationship__C> relationshipList =  Security.stripInaccessible(AccessType.READABLE,[select Id, accountTwo__r.name, accountOne__c, accountOne__r.recordTypeId,
                                                  accountOne__r.ClientIdentifier__c, accountTwo__c, accountTwo__r.recordTypeId, accountTwo__r.ClientIdentifier__c, RelationshipType__c
                                                  from Relationship__c where Id =:relId limit 1]).getRecords();

        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        relationship = vfcWrap.getRelationship(relationshipList);

        return relationship;
    }

    private  Account getAccountRecord(Id accountTwoId) {
        Account accountRecord;
        List<Account> accountList =  Security.stripInaccessible(AccessType.READABLE,[select Id, ClientIdentifier__c, name, recordType.name
                                                                                     from Account where Id =:accountTwoId limit 1]).getRecords();

        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        accountRecord = vfcWrap.getAccountRecord(accountList);

        return accountRecord;
    }

    private CM_Customer_Aggregator_Resource__mdt getCustomerAggregatorMetadata() {
        CM_Customer_Aggregator_Resource__mdt c2cResource;
        List<CM_Customer_Aggregator_Resource__mdt> mdtList =  Security.stripInaccessible(AccessType.READABLE,[select Resource_Path__c, DeveloperName from CM_Customer_Aggregator_Resource__mdt
                                                                                                              where DeveloperName =:C2CRELATIONSHIPS_RESOURCE_DEVELOPER_NAME limit 1]).getRecords();
        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        c2cResource = vfcWrap.getMdtRecord(mdtList);

        return c2cResource;
    }

    private static List<Relationship__c> getC2CRecords(String primaryRelationshipId, String secondaryRelationshipId){

		List<Relationship__c> deletedC2CList = Security.stripInaccessible(AccessType.READABLE,[select Id from Relationship__c where RelationshipIdentifier__c =:primaryRelationshipId OR RelationshipIdentifier__c =:secondaryRelationshipId]).getRecords();
        return deletedC2CList;
    }
    private static String getRecordTypeName(Id recordTypeId){
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Account;
        Map<Id,Schema.RecordTypeInfo> rtMapById = describe.getRecordTypeInfosById();
        Schema.RecordTypeInfo rtById =  rtMapById.get(recordTypeId);
        return rtById.getName();
    }

    private static User getLoggedInUser(String userId){
        List<User> loggedInUser = Security.stripInaccessible(AccessType.READABLE,[select Id, Name, Associate_ID__c from user where Id =:userId limit 1]).getRecords();
        return loggedInUser.get(0);
    }

    private static Account getPrimaryAccountDetail(Id recordId){
        List<Account> accountDetails = Security.stripInaccessible(AccessType.READABLE,[select Id, Name, LastName, FirstName, clientIdentifier__c, RecordType.Name
                                                                                        from Account where Id =:recordId limit 1]).getRecords();
        return accountDetails.get(0);
    }

    private static String getKeyCategory(String recordTypeForPrimaryAccount , String recordTypeForRelatedAccount){

        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        return vfcWrap.getKeyCategory(recordTypeForPrimaryAccount, recordTypeForRelatedAccount);
    }

    private static List<String> getOptionValues(String keyCategory){
        List<String> c2cOptions = new List<String>();
        //String c2cOptionValue='';
        List<CM_C2C_Relationship_AV_Mapping__mdt> mappingForC2COptions = new List<CM_C2C_Relationship_AV_Mapping__mdt>();

        mappingForC2COptions = Security.stripInaccessible(AccessType.READABLE,[select Value__c from CM_C2C_Relationship_AV_Mapping__mdt where Category__c =:keyCategory]).getRecords();
        VFC_C2CRelationshipControllerWrapper vfcWrap = new VFC_C2CRelationshipControllerWrapper();
        vfcWrap.getMappingForC2COptions(mappingForC2COptions, c2cOptions);
        return c2cOptions;
    }
    /**
     *
     * @param selectedAccountId
     * @description checkForHousehold
     * @return  `AccountAndIsHouseholdWrapper`
     */
    @AuraEnabled
    public static AccountAndIsHouseholdWrapper checkForHousehold(Id selectedAccountId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', selectedAccountId, Account.class);
        Account selectedAccountRecord = getPrimaryAccountDetail(selectedAccountId);
        List<Account> selectedAccountDetails = Security.stripInaccessible(AccessType.READABLE, [select id, RecordType.DeveloperName from Account where id =:selectedAccountId limit 1]).getRecords();
        Boolean isRecordHousehold = selectedAccountDetails.get(0).RecordType.DeveloperName.equalsIgnoreCase(INDUSTRIES_HOUSEHOLD);
        AccountAndIsHouseholdWrapper accountAndIsHouseholdWrapper = new AccountAndIsHouseholdWrapper();
        accountAndIsHouseholdWrapper.selectedAccount = selectedAccountRecord;
        accountAndIsHouseholdWrapper.isHousehold = isRecordHousehold;

        return accountAndIsHouseholdWrapper;
    }

    /**
     * @description AccountAndAgentAssocIdWrapper
     */
    public with sharing class AccountAndAgentAssocIdWrapper {
        @AuraEnabled
        /**
         * @description accountRecord
         */
        @TestVisible public Account accountRecord {get; set;}
        @AuraEnabled
        /**
         * @description associateID
         */
        @TestVisible public String associateID {get; set;}
    }
    /**
     * @description RelationshipAndUserIdWrapper
     */
    public with sharing class RelationshipAndUserIdWrapper {
        
        /**
         * @description relationshipRecord
         */
         @AuraEnabled
        public Relationship__C relationshipRecord {get; set;}
        
        /**
         * @description userId
         */
         @AuraEnabled
        public String userId {get; set;}
        
        /**
         * @description primaryAccountType
         */
         @AuraEnabled
        public String primaryAccountType {get; set;}
        
        /**
         * @description relatedAccountType
         */
         @AuraEnabled
        public String relatedAccountType {get; set;}
    }
    /**
     * @description AccountAndIsHouseholdWrapper
     */
    public with sharing class AccountAndIsHouseholdWrapper {
        
        /**
         * @description selectedAccount
         */
        @AuraEnabled
        @TestVisible public Account selectedAccount {get; set;}
        /**
         * @description isHousehold
         */
        @AuraEnabled
        @TestVisible public Boolean isHousehold {get; set;}
    }

    private class VFC_C2CRelationshipControllerWrapper{

        private String evaluateDeleteId(String deleteId, String delIdStr){
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get(delIdStr))){
                deleteId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(delIdStr).escapeHtml4(), UTIL_CreateCustomerConstants.UTF_08);
            }
            return deleteId;
        }

        private String evaulateEditId(String editId, String idStr){
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get(idStr))){
                editId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(idStr).escapeHtml4(), UTIL_CreateCustomerConstants.UTF_08);
            }
            return editId;
        }

        private string getNameStringFromSearch(String searchKeyWord,boolean isLastName){
            String name=VFC_C2CRelationshipController.EMPTY_STRING;
            if(searchKeyWord.containsWhitespace()){
                name=getNameFromSearchString(searchKeyWord,isLastName,VFC_C2CRelationshipController.BLANK_SPACE);
            }else if(searchKeyWord.contains(VFC_C2CRelationshipController.COMMA)){
                name=getNameFromSearchString(searchKeyWord,isLastName,VFC_C2CRelationshipController.COMMA);
            }
            return name;
        }
    
        private String getNameFromSearchString(String searchKeyWord,boolean isLastName,string separateString){
            String name=VFC_C2CRelationshipController.EMPTY_STRING;
            if(isLastName){
                name=searchKeyWord.substringBefore(separateString);
            }else{
                name=searchKeyWord.substringAfter(separateString);
                If(name.containsWhitespace() || name.contains(VFC_C2CRelationshipController.COMMA)){
                    name=name.substringBefore(separateString);
                }
            }
            return name;
        }

        private void fieldValidations(String relatedCustomerName, String relationshipNature){
            
            String relatedCustomerMandatory = VFC_C2CRelationshipController.RELATED_CUSTOMER_MANDATORY;
            String relationshipNatureMandatory = VFC_C2CRelationshipController.RELATIONSHIP_NATURE_MANDATORY;

            if(string.isBlank(relatedCustomerName)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, relatedCustomerMandatory));
            }
    
            if(string.isBlank(relationshipNature)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, relationshipNatureMandatory));
            }    
        }

        private HttpRequest setHttpMethod(HttpRequest req, Boolean isNewRelationship, Boolean isDeleteIndicator){
            
            if(isNewRelationship) {
                req.setMethod(TechnicalPlatformDetails.POST);
            }else if(!isNewRelationship && !isDeleteIndicator ){
                req.setMethod(TechnicalPlatformDetails.PUT);
            }else {
                req.setMethod(TechnicalPlatformDetails.HTTP_DELETE);
            }

            return req;
        }

        private Relationship__c getRelationship(List<Relationship__C> relationshipList){

            Relationship__C relationship;

            if(!relationshipList.isEmpty()){
                relationship = relationshipList.get(0);
            }

            return relationship;
        }

        private Account getAccountRecord(List<Account> accountList){

            Account accountRecord;

            if(!accountList.isEmpty()){
                accountRecord = accountList.get(0);
            }

            return accountRecord;
        }

        private CM_Customer_Aggregator_Resource__mdt getMdtRecord(List<CM_Customer_Aggregator_Resource__mdt> mdtList){
            CM_Customer_Aggregator_Resource__mdt c2cResource;
            if(!mdtList.isEmpty()){
                c2cResource = mdtList.get(0);
            }

            return c2cResource;
        }

        private String getKeyCategory(String recordTypeForPrimaryAccount , String recordTypeForRelatedAccount){
            String optionCategory;
            if(recordTypeForPrimaryAccount.equalsIgnoreCase(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME) && recordTypeForRelatedAccount.equalsIgnoreCase(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME)){
                optionCategory=C2C_RELATIONSHIP_INDIVIDUAL_TO_INDIVIDUAL;
            } else if(recordTypeForPrimaryAccount.equalsIgnoreCase(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME) && recordTypeForRelatedAccount.equalsIgnoreCase(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME)){
                optionCategory=C2C_RELATIONSHIP_INDIVIDUAL_TO_ORGANIZATION;
            }else if(recordTypeForPrimaryAccount.equalsIgnoreCase(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME) && recordTypeForRelatedAccount.equalsIgnoreCase(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME)){
                optionCategory=C2C_RELATIONSHIP_ORGANIZATION_TO_INDIVIDUAL;
            }else{
                optionCategory=C2C_RELATIONSHIP_ORGANIZATION_TO_ORGANIZATION;
            }
            return optionCategory;
        }

        private void getMappingForC2COptions(List<CM_C2C_Relationship_AV_Mapping__mdt> mappingForC2COptions, List<String> c2cOptions){

            String c2cOptionValue='';            

            for(CM_C2C_Relationship_AV_Mapping__mdt singleOption:mappingForC2COptions){
                    c2cOptionValue=singleOption.Value__c;
                    c2cOptions.add(c2cOptionValue);
            }
        }
    }
}
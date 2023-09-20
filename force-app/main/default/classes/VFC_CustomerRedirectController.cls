/****************************************************************************************
Name: VFC_CustomerRedirectController
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class for customer record type selection page

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                10/23/2017             R4 Major Release
******************************************************************************************/

/**
 * @description VFC Customer Redirect Controller
 */
public with sharing class VFC_CustomerRedirectController {
    private Account customer;
    private String leadId;
    private String lobValues;
    private static final String LEAD_SOQL_1 = 'Select Company from Lead Where Id = \'';
    private static final String LEAD_SOQL_2 = '\' Limit 1';
    private static final String S1_THEME = 'Theme4t';
    private static final String LIGHTNING_DESKTOP_THEME = 'Theme4d';
    private static final String SPAN_OPEN_1 = '<span title="';
    private static final String SPAN_OPEN_2 = '">';
    private static final String SPAN_CLOSE = '</span>';

    private VFC_CustomerRedirectControllerWrapper customerWrapper = new VFC_CustomerRedirectControllerWrapper();

    /**
     * @description getters and setters of the property recordTypeId
     * @return String
     */
    public String recordTypeId {get; set;}
    private Map<String, String> rtMapById {get; set;}
    private List<Recordtype> recTypes {get; set;}
    private Boolean isCCCUser {get; set;}

    /**
     * @description getters and setters of the property isLightning
     * @return Boolean
     */
    public Boolean isLightning {get; set;}

    /**
     * @description getters and setters of the property retUrl
     * @return String
     */
    public String retUrl {get; set;}

    /**
     * @description getters and setters of the property groupId
     * @return String
     */
    public String groupId {get; set;}

    /**
     * @description getters and setters of the property redirectUrl
     * @return String
     */
    public String redirectUrl {get; private set;}
    private String groupExtId {get; set;}

    /**
     * @description VFC Customer Redirect Controller
     * Constructor overloaded with account standard controller
     * @param stdController
     */
    public VFC_CustomerRedirectController (ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()) {
            stdController.addFields(new String[]{UTIL_CreateCustomerConstants.RECORD_TYPE_ID});
        }
        customer = (Account) stdController.getRecord();
        AP_ClickJackPrevention.setRequiredHeaders();
        readUrlParameters();
        retUrl = ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.RETURN_URL);
        if(String.isBlank(retUrl)) {
            retUrl = UTIL_CreateCustomerConstants.CUSTOMER_LIST_PAGE;
        }
        User currentUser = [Select Associate_ID__c, Profile.Name from User Where Id = :UserInfo.getUserId()];
        String loggedInProfile = currentUser.Profile.Name;
        redirectUrl = UTIL_CreateCustomerConstants.EMPTY_STRING;
        //Check if Logged in user is a CCC User
        isCCCUser = checkIsCCCUser(loggedInProfile);
        //To check if the user is in Lightning console or Salesforce1
        isLightning = checkLoggedInUserUITheme();
        //Fetching record type id's available for Account object
        List<Id> rtInfoDescList = new List<Id>();
        rtMapById = new Map<String, String>();
        fetchRecordTypeIds(rtInfoDescList);
        recTypes = [Select Id, DeveloperName, Description from RecordType Where Id = :rtInfoDescList];
    }

    /**
     * @description Customer Redirect Controller
     */
    void readUrlParameters(){
        customerWrapper.leadId = leadId;
        customerWrapper.lobValues = lobValues;
        customerWrapper.recordTypeId = recordTypeId;
        customerWrapper.groupId = groupId;
        customerWrapper.groupExtId = groupExtId;
        customerWrapper.readUrlParameters();
        
        leadId = customerWrapper.leadId;
        lobValues = customerWrapper.lobValues;
        recordTypeId = customerWrapper.recordTypeId;
        groupId = customerWrapper.groupId;
        groupExtId = customerWrapper.groupExtId;
    }

    /**
     * @description Logged in user is a CCC User
     * @param loggedInProfile
     * @return  `Boolean`
     */
    public Boolean checkIsCCCUser(String loggedInProfile){
        isCCCUser = customerWrapper.checkIsCCCUser(loggedInProfile);
        
        return isCCCUser;
    }

    /**
     * @description user is in Lightning console
     * @return  `Boolean`
     */
    public Boolean checkLoggedInUserUITheme(){
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed()) || LIGHTNING_DESKTOP_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
             isLightning = true;
        }
        else {
            isLightning = false;
        }
        return isLightning;
    }

    void fetchRecordTypeIds(List<Id> rtInfoDescList){
        for(Schema.RecordTypeInfo rtInfo : Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfos()) {
            if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equalsIgnoreCase(rtInfo.getDeveloperName()) ||
                UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME.equalsIgnoreCase(rtInfo.getDeveloperName())){
                    rtMapById.put(String.valueOf(rtInfo.getRecordTypeId()).subString(0, 15), rtInfo.getName());
                    rtInfoDescList.add(rtInfo.getRecordTypeId());
            }
        }
    }

    /**
     * @description Handle Redirect
     * @return PageReference
     * Init method to handle the redirection appropriately according to record type
     */
    public PageReference handleRedirect() {
        PageReference returnPage = null;

        // Lead Conversion Scenario
        if(String.isNotBlank(leadId)){
            VFC_CustomerRedirectControllerWrapper wrap = new VFC_CustomerRedirectControllerWrapper();
            wrap.leadId = leadId;
            wrap.returnPage = returnPage;
            wrap.accountRecordTypesMap = rtMapById;
            wrap.lobValues = lobValues;

            returnPage= redirectToRightPageForLeadConversion(wrap);
        }

        else{
            returnPage=customerCreateEditScenario(recordTypeId,returnPage,rtMapById);
        }

        if(isLightning && returnPage != null){
            redirectUrl = returnPage.getUrl();
            returnPage = null;
        }

        return returnPage;
    }

    private PageReference customerCreateEditScenario(String recordTypeId,PageReference returnPage,Map<String, String> rtMapById){
        if(customer.Id!=null) {
            recordTypeId = String.valueOf(customer.RecordTypeId).subString(0,15);
        }
        //Checking the record type and creating the page reference accordingly.
        if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equalsIgnoreCase(rtMapById.get(recordTypeId))) {
            returnPage = new PageReference('/apex/vfp_individualcustomercreateedit');
        }
        else if(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME.equalsIgnoreCase(rtMapById.get(recordTypeId))) {
            returnPage = new PageReference('/apex/vfp_organizationcustomercreateedit');
        }
        else {
            //Show the record type selection page
            returnpage = null;
        }
        return populateParameters(returnPage, recordTypeId);
    }

    //Setting the required parameters for next page
    private PageReference populateParameters(PageReference returnPage, String recordTypeId) {
        if(returnpage!=null) {
            String returnURL = ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.RETURN_URL);
            if(!String.isBlank(returnURL)) {
                returnURL = EncodingUtil.urlDecode(returnURL.escapeHtml4(), UTIL_CreateCustomerConstants.UTF_08);
                returnPage.getParameters().put(UTIL_CreateCustomerConstants.RETURN_URL,
                                               EncodingUtil.urlEncode(returnURL.escapeHtml4(), UTIL_CreateCustomerConstants.UTF_08));
            }
            else {
                returnPage.getParameters().put(UTIL_CreateCustomerConstants.RETURN_URL,
                                               EncodingUtil.urlEncode(UTIL_CreateCustomerConstants.CUSTOMER_LIST_PAGE, UTIL_CreateCustomerConstants.UTF_08));
            }
            if(String.isNotBlank(groupId)) {
                groupId = EncodingUtil.urlDecode(groupId, UTIL_CreateCustomerConstants.UTF_08);
                returnPage.getParameters().put(UTIL_CreateCustomerConstants.GROUP_ID,
                                               EncodingUtil.urlEncode(groupId, UTIL_CreateCustomerConstants.UTF_08));
            }
            if(String.isNotBlank(groupExtId)) {
                groupExtId = EncodingUtil.urlDecode(groupExtId, UTIL_CreateCustomerConstants.UTF_08);
                returnPage.getParameters().put(UTIL_CreateCustomerConstants.GROUP_EXT_ID_PARAM,
                                               EncodingUtil.urlEncode(groupExtId, UTIL_CreateCustomerConstants.UTF_08));
            }
            returnPage.getParameters().put(UTIL_CreateCustomerConstants.RECORD_TYPE, recordTypeId);
            if(customer.Id!=null) {
                returnPage.getParameters().put(UTIL_CreateCustomerConstants.ID, customer.Id);
            }
            returnPage.setRedirect(true);
        }
        return returnPage;
    }

    private PageReference redirectToRightPageForLeadConversion(VFC_CustomerRedirectControllerWrapper wrap) {

        id leadId = wrap.leadId;
        PageReference returnPage = wrap.returnPage;
        Map<String,String> accountRecordTypesMap = wrap.accountRecordTypesMap;
        String lobValues = wrap.lobValues;

        //Fetching the required parameters for Lead object
        Lead providedLeadForConversion=database.query(LEAD_SOQL_1 + String.escapeSingleQuotes(leadId) + LEAD_SOQL_2);
        String recordTypeId;
        if(String.isNotBlank(providedLeadForConversion.Company)){
            returnPage = new PageReference('/apex/vfp_organizationcustomercreateedit');
            for(String id : accountRecordTypesMap.keySet()){
                if(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME.equals(accountRecordTypesMap.get(id))) {
                    recordTypeId=id;
                }
            }
        }
        else{
            returnPage = new PageReference('/apex/vfp_individualcustomercreateedit');
            for(String id : accountRecordTypesMap.keySet()) {
                if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equals(accountRecordTypesMap.get(id))) {
                    recordTypeId = id;
                }
            }
        }
        returnPage.getParameters().put(UTIL_CreateCustomerConstants.LEAD_ID, leadId);
        returnPage.getParameters().put(UTIL_CreateCustomerConstants.LOB, lobValues);
        return populateParameters(returnPage, recordTypeId);
    }

    /**
     * @description Get RecordType Options
     * @return List<SelectOption>
     * Getter method to show the account record types details on the page
     */
    public List<SelectOption> getRecordTypeOptions() {
        List<SelectOption> recordTypeOptions = new List<SelectOption>();
        for(RecordType recType : recTypes) {
            String recTypeId = String.valueOf(recType.Id).subString(0, 15);
            SelectOption opt = new SelectOption(recTypeId, SPAN_OPEN_1 + recType.description + SPAN_OPEN_2 +recType.DeveloperName + SPAN_CLOSE);
            opt.setEscapeItem(false);
            recordTypeOptions.add(opt);

            if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equals(recType.DeveloperName)) {
                recordTypeId=recTypeid;
            }
        }
        return recordTypeOptions;
    }

    /**
     * @description VFC Customer Redirect Controller Wrapper
     */
    class VFC_CustomerRedirectControllerWrapper{
        Id leadId;
        PageReference returnPage;
        Map<String,String> accountRecordTypesMap;
        String lobValues;
        String recordTypeId;
        String groupId;
        String groupExtId;

        private void readUrlParameters(){

            if(String.isNotBlank(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.LEAD_ID))) {
                leadId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.LEAD_ID).escapeHtml4(),
                                                    UTIL_CreateCustomerConstants.UTF_08);
            }
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.LOB))) {
                lobValues = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.LOB).escapeHtml4(),
                                                    UTIL_CreateCustomerConstants.UTF_08);
            }
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.RECORD_TYPE))) {
                recordTypeId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.RECORD_TYPE).escapeHtml4(),
                                                    UTIL_CreateCustomerConstants.UTF_08);
            }
            if(!String.isEmpty(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.GROUP_ID))) {
                groupId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.GROUP_ID).escapeHtml4(),
                                                UTIL_CreateCustomerConstants.UTF_08);
            }
            if(!String.isEmpty(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.GROUP_EXT_ID_PARAM))) {
                groupExtId = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(UTIL_CreateCustomerConstants.GROUP_EXT_ID_PARAM).escapeHtml4(),
                                                UTIL_CreateCustomerConstants.UTF_08);
            }
        }

        private Boolean checkIsCCCUser(String loggedInProfile){
            Boolean isCCCUser;

            if(Label.CL_CCCUnlicensedProfile.equals(loggedInProfile) || Label.CL_CCCLicensedProfile.equals(loggedInProfile) || loggedInProfile.contains(Label.CL_SysAdmin)
                    || Label.CL_TechSupport_Profile.equals(loggedInProfile) || Label.CL_108BSUPPORT_PROFILE.equals(loggedInProfile)){
                isCCCUser=true;
            }
            else {
                isCCCUser=false;
            }
            return isCCCUser;
        }
    }

}
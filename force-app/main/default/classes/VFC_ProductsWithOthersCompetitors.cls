 /**
  * @description VFC_ProductsWithOthersCompetitors 
  */
public with sharing class VFC_ProductsWithOthersCompetitors {
@TestVisible private List<ProductsWithOthersCompetitors__x> mockODATAProductsWithOthersCompetitorsList = new List<ProductsWithOthersCompetitors__x>();
    private static final String EMPTY_STRING = '';
    private static final String CLASS_NAME = 'VFC_ProductsWithOthersCompetitors';
    private static final string LINK_TO_DETAIL_PAGE ='/apex/VFP_PwocDetails?createMode=false';
    private Map<String, Account> accountMapByClientId;
    private String loggedInPrimaryStateAgentCode;
    private static final String S1_THEME = 'Theme4t';
    private enum METHOD_NAMES {FETCHPRODUCTSWITHOTHERSCOMPETITORS}
     /**
         * @description accountMapByClientIdObj 
         */
    public Object accountMapByClientIdObj {get; set;}
     /**
         * @description accountIdInContext 
         */
    public String accountIdInContext {get; set;}
     /**
         * @description accountClientIdInContext
         */
    public String accountClientIdInContext {get; set;}
     /**
         * @description groupId 
         */
    public String groupId {get; set;}
     /**
         * @description displayMessage 
         */
    public String displayMessage {get; set;}
     /**
         * @description isWebContext
         */
    public Boolean isWebContext {get;set;}
     /**
         * @description isPWOCAccessible 
         */
    public boolean isPWOCAccessible {get; set;}

    /**
     * @description productsWithOthersCompetitorsList
     */
    public List<ProductsWithOthersCompetitorsWrapper> productsWithOthersCompetitorsList {get; private set;}
    
    // constants
    /**
     * @description VFC_ProductsWithOthersCompetitors
     */
    public VFC_ProductsWithOthersCompetitors() {
        AP_ClickJackPrevention.setRequiredHeaders();
        displayMessage = EMPTY_STRING;
        User currentUser = [Select State_Agent_Code__c, Servicing_Agent_External_ID__c,Servicing_Agent_Associate_ID__c, Associate_ID__c from User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
        if(String.isNotBlank(currentUser.State_Agent_Code__c)) {
            //Updated query to retrieve Servicing Agent based on new Shared Agent design
            String stateAgentCode = [SELECT Id, State_Agent_Code__c FROM User WHERE UserExternalID__c =: currentUser.Servicing_Agent_External_ID__c AND UserType__c = 'Agent'].State_Agent_Code__c ;
            String[] code = stateAgentCode.split('-');
            loggedInPrimaryStateAgentCode = code[0] + code[1];
        }
        //Finding the context for the screen launch
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isWebContext = false;
        }
        else {
            isWebContext = true;
        }
    }
    
    private void buildInitialValuesForGroup(){
        List<CustomerGroupMember__c> custGrpMember;
    if(String.isNotEmpty(groupId)){
        custGrpMember = [SELECT Id, customer__r.Id, customer__r.Name, customer__r.clientIdentifier__c FROM CustomerGroupMember__c where Group__c = :groupId WITH SECURITY_ENFORCED LIMIT 100];
    }
    
    if(String.isNotEmpty(groupId) && !custGrpMember.isEmpty()){
        accountMapByClientId = new Map<String, Account>();
        for(CustomerGroupMember__c grpMember: custGrpMember){
            accountMapByClientId.put(grpMember.customer__r.clientIdentifier__c, new Account(Id=grpMember.customer__r.Id, Name=grpMember.customer__r.Name));             
            If(accountIdInContext != null && accountIdInContext.subString(0,15).equalsIgnoreCase(String.valueOf(grpMember.customer__r.Id).subString(0,15))){
                accountClientIdInContext = grpMember.customer__r.clientidentifier__c;
            }
        }
    }
}
    
    //Method to query productwithotherscompetitors from external object based on selected account and/or logged in agent associate id
    /**
         * @description fetchProductsWithOthersCompetitors
         */
    public void fetchProductsWithOthersCompetitors() {
        accountMapByClientId = (Map<String, Account>)accountMapByClientIdObj;
        List<ProductsWithOthersCompetitors__x> oDataProductsWithOthersCompetitorsList;
        productsWithOthersCompetitorsList = new List<ProductsWithOthersCompetitorsWrapper>();
        try {
            if(isPWOCAccessible) {
                if (accountMapByClientId == null || accountMapByClientId.isEmpty()) {
                    buildInitialValuesForGroup();
                }
              //  String selectPWOCQuery = 'Select Id, ClientID__c, StateAgentCode__c, CarrierName__c, ExternalAgreementId__c, ProductLine__c, ExpirationDate__c, ProductComments__c, ProductType__c'
                             //   + ' From ProductsWithOthersCompetitors__x Where ClientID__c  in :clientIdList And StateAgentCode__c = :loggedInPrimaryStateAgentCode ORDER BY ProductLine__c';
                Set<String> clientIdList = accountMapByClientId.keySet();
                if (clientIdList.isEmpty()) {
                    throw new InvalidInputException('Client Id Not found');
                }
                if (Test.isRunningTest()) {
                    oDataProductsWithOthersCompetitorsList = mockODATAProductsWithOthersCompetitorsList;  
                } else {
                        oDataProductsWithOthersCompetitorsList = Database.query('Select Id, ClientID__c, StateAgentCode__c, CarrierName__c, ExternalAgreementId__c, ProductLine__c, ExpirationDate__c, ProductComments__c, ProductType__c'
                        + ' From ProductsWithOthersCompetitors__x Where ClientID__c  in :clientIdList And StateAgentCode__c = :loggedInPrimaryStateAgentCode ORDER BY ProductLine__c');
                }
                                
            } 
            else {
                displayMessage = Label.CL_FEATURE_DOWN;
            } 
            
            displayMessage = addingProductsWithOthersCompetitorsList(oDataProductsWithOthersCompetitorsList);
        } catch(Exception e) {
            displayMessage = Label.CL_TRY_LATER;
            LoggingService.logHandledException(e, CLASS_NAME, METHOD_NAMES.FETCHPRODUCTSWITHOTHERSCOMPETITORS.name(), System.LoggingLevel.ERROR);
        }
    }

    /**
     * @description addingProductsWithOthersCompetitorsList
     * @param oDataProductsWithOthersCompetitorsList 
     * @return String
     */
    public String addingProductsWithOthersCompetitorsList(List<ProductsWithOthersCompetitors__x> oDataProductsWithOthersCompetitorsList){
        if(isPWOCAccessible == true && !oDataProductsWithOthersCompetitorsList.isEmpty()){
            displayMessage = EMPTY_STRING;
                for (ProductsWithOthersCompetitors__x oDataPWOC : oDataProductsWithOthersCompetitorsList) {
                    if (String.isNotEmpty(oDataPWOC.ExternalAgreementId__c)) {
                        productsWithOthersCompetitorsList.add(buildPWOCWrapperRecord(oDataPWOC));
                    }
                }
        }else if(isPWOCAccessible == true && oDataProductsWithOthersCompetitorsList.isEmpty()){
            displayMessage = Label.CL_NO_RECORDS;
        }
        return displayMessage;
    }

    private ProductsWithOthersCompetitorsWrapper buildPWOCWrapperRecord(ProductsWithOthersCompetitors__x oDataPWOC) {
        ProductsWithOthersCompetitorsWrapper aPWOCWrapper = new ProductsWithOthersCompetitorsWrapper();
        aPWOCWrapper.id = oDataPWOC.id;
        aPWOCWrapper.productLine = oDataPWOC.ProductLine__c;
        aPWOCWrapper.carrierName = oDataPWOC.CarrierName__c;
        aPWOCWrapper.productType = oDataPWOC.ProductType__c;
        if(oDataPWOC.ExpirationDate__c != null) {
            aPWOCWrapper.expirationDate = oDataPWOC.ExpirationDate__c.format();
        }
        aPWOCWrapper.productComments = oDataPWOC.ProductComments__c;
        aPWOCWrapper.externalAgreementId = oDataPWOC.ExternalAgreementID__c;
        aPWOCWrapper.stateAgentCode = oDataPWOC.StateAgentCode__c.substring(0,2) + '-' + oDataPWOC.StateAgentCode__c.substring(2,oDataPWOC.StateAgentCode__c.length());
        aPWOCWrapper.clientId = oDataPWOC.ClientID__c;
        
        return aPWOCWrapper;     
    }
    /**
         * @description ProductsWithOthersCompetitorsWrapper
         */
    public with sharing class ProductsWithOthersCompetitorsWrapper {
        /**
         * @description id 
         */
        public String id {get; private set;}
        /**
         * @description productLine 
         */
        public String productLine {get; private set;}
        /**
         * @description carrierName 
         */
        public String carrierName {get; private set;}
        /**
         * @description productType 
         */
        public String productType {get;private set;}
        /**
         * @description expirationDate  
         */
        public String expirationDate {get; private set;}
        /**
         * @description productComments 
         */
        public String productComments {get; private set;}
        /**
         * @description stateAgentCode 
         */
        public String stateAgentCode {get; private set;}
        /**
         * @description clientId 
         */
        public String clientId {get; private set;}
        /**
         * @description externalAgreementId 
         */
        
        public String externalAgreementId {get; private set;}
    }

}
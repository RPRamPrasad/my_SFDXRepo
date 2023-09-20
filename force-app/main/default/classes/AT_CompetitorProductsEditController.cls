/**
 * @description AT_CompetitorProductsEditController 
 */
public with sharing class AT_CompetitorProductsEditController {
    
    private static final String CLASS_NAME = 'AT_CompetitorProductsEditController';
    private static final User CURRENTUSER = getCurrentUser();
    @TestVisible public static Database.SaveResult mockResult;
    @TestVisible public static User mockedAgent = new User();
    @TestVisible public static User mockedUser = new User();
    @TestVisible public static String loggedInProfile = UTIL_LtngProfileDataAccess.getProfileName();

    /**
     * @description AT_CompetitorProductsEditControllerWrapperClass
     */
     public class AT_CompetitorProductsEditControllerWrapperClass{
      @AuraEnabled
      public  String recordId;
      @AuraEnabled
      public  String clientId;
      @AuraEnabled
      public  String productComments;
      @AuraEnabled
      public  String carrierName;
      @AuraEnabled
      public  String externalAgreementId;
      @AuraEnabled
      public  String productLine;
      @AuraEnabled
      public  String productType;
      @AuraEnabled
      public  String stateAgentCode;
      @AuraEnabled
      public  String expirationDateString;
     }
    /**
     * @description saveCompetitorProducts
     * @param wrapperjsonStringsave
     * @return  `Boolean`
     */
    @AuraEnabled 
    public static Boolean saveCompetitorProducts (String wrapperjsonStringsave) {
        AT_CompetitorProductsEditControllerWrapperClass wrap= (AT_CompetitorProductsEditControllerWrapperClass)JSON.deserialize(wrapperjsonStringsave,AT_CompetitorProductsEditControllerWrapperClass.class);  
        ProductsWithOthersCompetitors__x pwoc;
        Date expirationDate;
        Database.SaveResult result;
        if (String.isBlank(wrap.expirationDateString)) {
            expirationDate = Date.newInstance(9999, 12, 31);                                      
        }
        else {
            expirationDate = Date.valueOf(wrap.expirationDateString);
        }
        if (String.isBlank(wrap.productComments)) {
            wrap.productComments = '';
        }
        if(Test.isRunningTest()) {
            pwoc = new ProductsWithOthersCompetitors__x();
            result = mockResult;
        }
        else {
            pwoc = new ProductsWithOthersCompetitors__x(Id=wrap.recordId,ProductComments__c=wrap.productComments,CarrierName__c=wrap.carrierName,ExternalAgreementID__c=wrap.externalAgreementId,ProductLine__c=wrap.productLine,ProductType__c=wrap.productType,StateAgentCode__c=wrap.stateAgentCode,ExpirationDate__c=expirationDate,User__c=currentUser.Alias);
            result = Database.updateImmediate(pwoc);
        }
        if (!result.isSuccess()) {
            List<Database.SaveResult> listOfResults = new List<Database.SaveResult>{result};
                List<ProductsWithOthersCompetitors__x> pwocList = new List<ProductsWithOthersCompetitors__x>{pwoc};
                    LoggingService.logDatabaseResult(listOfResults,pwocList, 'AT_CompetitorProductsEditController', 'saveCompetitorProducts', System.LoggingLevel.ERROR);
        }
        return result.isSuccess();
    }

/**
 * @description AT_CompetitorProductsEditControllerWrapper
 */
    public class AT_CompetitorProductsEditControllerWrapper{
      @AuraEnabled
      public String comments;
      @AuraEnabled
      public String carrierName;
      @AuraEnabled
      public String productLine;
      @AuraEnabled
      public String productType;
      @AuraEnabled
      public String expirationDateString;
      @AuraEnabled
      public String agent;
      @AuraEnabled
      public String accountRecordId;
    }
    /**
     * @description createCompetitorProduct
     * @param wrapperjsonString 
     * @return  `String`
     */
    @AuraEnabled
    public static String createCompetitorProduct(String wrapperjsonString) {   
        AT_CompetitorProductsEditControllerWrapper wrapper= (AT_CompetitorProductsEditControllerWrapper)JSON.deserialize(wrapperjsonString,AT_CompetitorProductsEditControllerWrapper.class);  
        ProductsWithOthersCompetitors__X pwoc;
        Database.SaveResult result;
        String clientId = getClientId(wrapper.accountRecordId);
        String stateAgentCode;
        if(String.isBlank(wrapper.agent)) {
            stateAgentCode = formatStateAgentCode(currentUser.State_Agent_Code__c);
        } else {
            stateAgentCode = getStateAgentCodeForAgent(wrapper.agent);
        }
        Date expirationDate;
        if (String.isBlank(wrapper.expirationDateString)) {
            expirationDate = Date.newInstance(9999, 12, 31);                                      
        } else {
            expirationDate = Date.valueOf(wrapper.expirationDateString);
        }
        
        if (String.isBlank(wrapper.comments)) {
            wrapper.comments = '';
        }
        if(Test.isRunningTest()) {
            pwoc = new ProductsWithOthersCompetitors__X();
            result = mockResult;
        }
        else {
            pwoc = new ProductsWithOthersCompetitors__X(ClientId__c = clientId,ProductComments__c = wrapper.comments,CarrierName__c = wrapper.carrierName,ProductLine__c = wrapper.productLine,ProductType__c = wrapper.productType,StateAgentCode__c = stateAgentCode,ExpirationDate__c = expirationDate,User__c = currentUser.Alias);
            result = Database.insertImmediate(pwoc);
        }
        if (!result.isSuccess()) {
            List<Database.SaveResult> listOfResults = new List<Database.SaveResult>{result};
            List<ProductsWithOthersCompetitors__x> pwocList = new List<ProductsWithOthersCompetitors__x>{pwoc};
            LoggingService.logDatabaseResult(listOfResults,pwocList, 'AT_CompetitorProductsEditController', 'saveCompetitorProducts', System.LoggingLevel.ERROR);
        }
        return result.getId();
    }
    /**
     * @description getStateAgentCodeForAgent
     * @param agentRecordId 
     * @return  `String`
     * @exception 
     */
    @AuraEnabled
    public static String getStateAgentCodeForAgent(String agentRecordId) {

        List<User> agentList = null;
        String stateAgentCode = null;
        if(Test.isRunningTest()) {
            agentList = new List<User>();
            mockedAgent.State_Agent_Code__c  = '13-4295'; 
            mockedAgent.SubUserType__c = 'Agent';
            agentList.add(mockedAgent);
        }
        else {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', agentRecordId, User.class);
            try {
                agentList = Security.stripInaccessible(
                    AccessType.READABLE,
                    [SELECT State_Agent_Code__c,SubUserType__c from User where id=:agentRecordId LIMIT 10
                    ]
                ).getRecords();
            }
            catch (Exception e) {LoggingService.logHandledException(e, CLASS_NAME, 'getStateAgentCodeForAgent', System.LoggingLevel.ERROR);
            }
        }
        if (null != agentList && null != agentList[0].State_Agent_Code__c && agentList[0].SubUserType__c.equals('Agent')) {
            stateAgentCode = formatStateAgentCode(agentList[0].State_Agent_Code__c);
        } else {
            throw new AuraHandledException('INVALID AGENT');
        }
        return stateAgentCode;
    }
    /**
     * @description formatStateAgentCode
     * @param code 
     * @return  `String`
     */
    @AuraEnabled
    public static String formatStateAgentCode(String code) {
        if (code.contains('-')) {
            return code.left(2) + code.right(4);
        }
        else {
            return code;
        }
    }
    /**
     * @description validateField
     * @param fieldValue 
     * @return  `String`
     */
    @AuraEnabled 
    public static String validateField(String fieldValue) {
        return AT_SpiFieldValidator.validate(fieldValue);
    }
    /**
     * @description getCurrentUser
     * @return  `User`
     */
    public static User getCurrentUser() {
        Map<String,Object> currentUserQueryKey = new Map<String, Object>();
        String currentUserId = UserInfo.getUserId();
        currentUserQueryKey.put('currentUserId', currentUserId);
        List<User> currentUserList = null;
        User current_User = null;
        
        if(Test.isRunningTest()) {
            currentUserList = new List<User>();
            currentUserList.add(mockedUser);
        }
        else {
            try {
                currentUserList = Security.stripInaccessible(
                    AccessType.READABLE,
                    [SELECT Alias,State_Agent_Code__c,Servicing_Agent_Associate_Id__c from User where id=:currentUserId LIMIT 100
                    ]
                ).getRecords();
            }
            catch (Exception e) {LoggingService.logHandledException(e, CLASS_NAME, 'getCurrentUser', System.LoggingLevel.ERROR);
            }
        }
        if (null != currentUserList) {
            current_User = currentUserList[0];
        }
        return current_User;
    } 
    /**
     * @description getClientId
     * @param recordId 
     * @return  `String`
     */
    public static String getClientId(String recordId) {
        Map<String,Object> clientIdQueryKey = new Map<String, Object>();
        clientIdQueryKey.put('recordId', recordId);
        List<Account> clientIdQueryList;
        String clientId = null;
        
        if(Test.isRunningTest()) {
            RecordType recordType = new RecordType(Name = 'Individual', DeveloperName = 'Individual', SobjectType = 'Account');
            Account account = new Account(firstname = 'accountName', lastname= 'accountName', ClientIdentifier__c = '12345678901',RecordTypeId=recordType.Id);
            clientIdQueryList = new List<Account>();
            clientIdQueryList.add(account);
        }
        else {
            clientIdQueryList = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT ClientIdentifier__c from account where id=:recordId LIMIT 100
                ]
            ).getRecords();
        }
        
        if (null != clientIdQueryList) {
            clientId = clientIdQueryList[0].ClientIdentifier__c;
        }
        return clientId;
    }
    /**
     * @description checkIfNonAgencyUser
     * @return  `boolean`
     */
    @AuraEnabled
    public static boolean checkIfNonAgencyUser() {
//        String loggedInProfile = Util_LtngProfileDataAccess.getProfileName();
        if (Label.CL_Agent_Profile.equals(loggedInProfile) || Label.CL_ATM_Profile.equals(loggedInProfile)) {
            return false;
        }
        else {
            return true;
        }
    }
}
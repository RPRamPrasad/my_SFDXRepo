/**
Author Team Incognito
Name - CMP_RetrieveAccountMessages
@description This class will be invoked by OppMessageTimline Lightning Component to retrieve account messages
Team: Incognito
========================================================================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                12/05/2018              Initial Development
2.0             Team ClubCar                01/15/2018              Added logic to retrieve Account level Account Messages
3.0             Team ClubCar                03/20/2020              Updated with SECURITY_ENFORCED feature
4.0             Team ClubCar                04/06/2020              Updated Account Message query to fix Prod Defect
5.0             Team Incognito              04/03/2023              Adding ITRs to Account Messages Timeline
******************************************************************************************************************************************/

public with sharing class CMP_RetrieveAccountMessages {
    
    private static final String CLASS_NAME = 'CMP_RetrieveAccountMessages ';
    private static final String METHOD_NAME = 'getAccountMessageResults';
    private static final String AGENT = 'Agency_User'; 
    
    /**
    * @description  Inner Class to return Account Message Details required by OppMessageTimline Lightning Component
    */
    public with sharing class AccMessageQueryWrapper {
        
        @AuraEnabled
        public List<AccountMessage__c> accMessageQueryResults = null;

        @AuraEnabled
        public List<MessageDataWrapper> messageTimelineDataResp = null;
        
        @AuraEnabled
        public Boolean apexExceptionOccured = false;
        
        @AuraEnabled
        public Boolean isValidUser = false;
    }
    /**
    * @description  Inner Class to return Account Message & Individual Email Result Details required by OppMessageTimeline LWC Component
    */
    public with sharing class MessageDataWrapper {
        
        @AuraEnabled
        public String status;

        @AuraEnabled
        public String type;
        
        @AuraEnabled
        public String itemNumber;
        @AuraEnabled
        public String itemNumberURL;
        
        @AuraEnabled
        public Date dateSent;

        @AuraEnabled
        public String initiatedBy;
    } 


    /**
    * @method- Invoked by  OppMessageTimline Lightning Component
    *          This method will return Account Message Details based on passed OpportunityId or AccountId. This helps us to use the same 
    *          OppMessageTimline components on both pages, Account and opportunity.
    * @description  This helps us to use the same OppMessageTimline components on both pages, Account and opportunity.
    * @name  getAccountMessageResults
    * @param  passedOppOrAccId - passed Opportunity or Account Id
    * @return accMessResp - AccMessageQueryWrapper
    */
    @AuraEnabled
    public static AccMessageQueryWrapper getAccountMessageResults(Id passedOppOrAccId) {
        AccMessageQueryWrapper accMessResp = new AccMessageQueryWrapper();        
        try {
            accMessResp.accMessageQueryResults  = queryAccountMessages(passedOppOrAccId);
            accMessResp.isValidUser = isUserAnAgent();
        } catch (Exception accMessageException) {
            accMessResp.apexExceptionOccured = true;
            LoggingService.logHandledException(accMessageException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return accMessResp;
    }
    /**
    * @method- Invoked by  OppMessageTimline Lightning Component
    *          This method will return Individual Email Results based on passed OpportunityId or AccountId. This helps us to use the same 
    *          OppMessageTimline components on both pages, Account and opportunity.
    * @description  This helps us to use the same OppMessageTimline components on both pages, Account and opportunity.
    * @name  getMessagesTimelineResults
    * @param  passedOppOrAccId - passed Opportunity or Account Id
    * @return accMessResp - AccMessageQueryWrapper
    */
    @AuraEnabled
    public static AccMessageQueryWrapper getMessagesTimelineResults(Id passedOppOrAccId) {
        AccMessageQueryWrapper accMessResp = new AccMessageQueryWrapper();        
        try {
            accMessResp.isValidUser = isUserAnAgent();
            accMessResp.messageTimelineDataResp  = queryMessagesTimeline(passedOppOrAccId);
        } catch (Exception accMessageException) {
            accMessResp.apexExceptionOccured = true;
            LoggingService.logHandledException(accMessageException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return accMessResp;
    }
    /**
    * @method- Invoked by  OppMessageTimline Lightning Component
    *          This method will return Account Message Details based on passed OpportunityId or AccountId. This helps us to use the same 
    *          OppMessageTimline components on both pages, Account and opportunity.
    * @description  This helps us to use the same OppMessageTimline components on both pages, Account and opportunity.
    * @name  getMessagesTimelineResults
    * @param  passedOppOrAccId - passed Opportunity or Account Id
    * @return messageDataResp - List<MessageDataWrapper> 
    */
    @AuraEnabled
    public static List<MessageDataWrapper> queryMessagesTimeline(Id passedOppOrAccId) {
        List<MessageDataWrapper> messageDataResp = new List<MessageDataWrapper>();
        
        try {
          List<MessageDataWrapper> accountMessageRecords = getAccountMessageRecords(passedOppOrAccId);
          List<MessageDataWrapper> ierRecords = getIERRecords(passedOppOrAccId);
          List<MessageDataWrapper> itrRecords = getITRRecords(passedOppOrAccId);
            
          messageDataResp.addAll(ierRecords);
          messageDataResp.addAll(itrRecords);
          messageDataResp.addAll(accountMessageRecords);
       	} catch (Exception accMessageException) {
            LoggingService.logHandledException(accMessageException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return messageDataResp;
    }

    //method to validate status 
    /**
     * @description returnStatus 
     * @param status 
     * @return  `String`
     */
    public static String returnStatus(String status) {
        String validateStatus = status;
        if('Sent'.equals(validateStatus)){
            validateStatus = 'Past';
        }
        else if('Scheduled'.equals(validateStatus)){
            validateStatus = 'Next';
        }
        else if('Cancelled - stopped journey'.equals(validateStatus)){
            validateStatus = 'Cancelled';
        }
        return validateStatus;
    } 
    //
    //method to validate type
    /**
     * @description returnType
     * @param type 
     * @return  `String`
     */
    public static String returnType(String type) {
        String validateType = type;
        if('Mailing'.equals(validateType)){
            validateType = 'Mail';
        }
        return validateType;
    } 
    //method to validate Agent custom permission
    /**
     * @description isUserAnAgent
     * @return  `Boolean`
     */ 
    public static Boolean isUserAnAgent() {
        return FeatureManagement.checkPermission(AGENT);
    } 
    
    private static List<MessageDataWrapper> getAccountMessageRecords(Id passedOppOrAccId){
        List<MessageDataWrapper> messageDataResp = new List<MessageDataWrapper>();
        List<AccountMessage__c> accMessageQueryResults  = queryAccountMessages(passedOppOrAccId);
        
            if(accMessageQueryResults != null){
				for(AccountMessage__c am : accMessageQueryResults){
                    MessageDataWrapper accountMessageRecordWrapper = new MessageDataWrapper();
                    if(String.isNotEmpty(am.ItemID__c)){
                        accountMessageRecordWrapper.itemNumberURL = '/c/ExternalLinkApp.app?linkId=5&itemNo='+am.ItemID__c;
                    }
                    
                    accountMessageRecordWrapper.itemNumber = am.ItemID__c;
                    accountMessageRecordWrapper.dateSent = am.TransmissionDate__c;
                    accountMessageRecordWrapper.initiatedBy = am.JourneyName__c;
                   	accountMessageRecordWrapper.status = returnStatus(am.Status__c);
                   	accountMessageRecordWrapper.type = returnType(am.ContactMethodName__c);
                    messageDataResp.add(accountMessageRecordWrapper);
                }
            }
        
        return messageDataResp;
    }
    
    private static List<MessageDataWrapper> getITRRecords(Id passedOppOrAccId){
        List<MessageDataWrapper> messageDataResp = new List<MessageDataWrapper>();
        List<IndividualTextResult__c> indTextListToDisplay  = queryIndividualTextResult(passedOppOrAccId);
        
            if(indTextListToDisplay != null){
                for(IndividualTextResult__c indText : indTextListToDisplay){
                    MessageDataWrapper itrRecordWrapper = new MessageDataWrapper();
                    Datetime dT = indText.CreatedDate;
                    Date dateSent;
                    if(dt != null){
                        dateSent =  date.newinstance(dT.year(), dT.month(), dT.day());
                    }
                    
  
                    if(String.isNotEmpty(indText.ItemNumber__c)){
                        itrRecordWrapper.itemNumberURL = '/c/ExternalLinkApp.app?linkId=5&itemNo='+indText.ItemNumber__c;
                    }
                    
                    itrRecordWrapper.itemNumber = indText.ItemNumber__c;
                    itrRecordWrapper.dateSent = dateSent;
                    itrRecordWrapper.initiatedBy = indText.InitiatedBy__c;
                    itrRecordWrapper.status = returnStatus(indText.Status__c);
                    itrRecordWrapper.type = returnType(indText.Type__c);
                    
                    messageDataResp.add(itrRecordWrapper);
                }
        	}
        
        return messageDataResp;
    }
    
    private static List<MessageDataWrapper> getIERRecords(Id passedOppOrAccId){
        List<MessageDataWrapper> messageDataResp = new List<MessageDataWrapper>();
 		List<et4ae5__IndividualEmailResult__c> indEmailListToDisplay  = queryIndividualEmailResult(passedOppOrAccId);
        
            if(indEmailListToDisplay != null){
                for(et4ae5__IndividualEmailResult__c indEmail : indEmailListToDisplay){
                    MessageDataWrapper ierRecordWrapper = new MessageDataWrapper();
                    Datetime dT = indEmail.et4ae5__DateSent__c;
                    Date dateSent;
                    if(dt != null){
                    	dateSent =  date.newinstance(dT.year(), dT.month(), dT.day());
                    }
                    
                    
                    if(String.isNotEmpty(indEmail.ItemNumber__c)){
                        ierRecordWrapper.itemNumberURL = '/c/ExternalLinkApp.app?linkId=5&itemNo='+indEmail.ItemNumber__c;
                    }
                    
                    ierRecordWrapper.itemNumber = indEmail.ItemNumber__c;
                    ierRecordWrapper.dateSent = dateSent;
                    ierRecordWrapper.initiatedBy = indEmail.InitiatedBy__c;
                    ierRecordWrapper.status = returnStatus(indEmail.Status__c);
                    ierRecordWrapper.type = returnType(indEmail.Type__c);
                    messageDataResp.add(ierRecordWrapper);
                }
            }
        
        
        return messageDataResp;
    }
    
    
    //Helper method to query Account Messages
    private static  List<AccountMessage__c> queryAccountMessages(Id passedOppOrAccId){
        List<AccountMessage__c> accMessageListToDisplay;              
        String whereConditions;
        String queryStart = 'Select Id, AgentOnlineMessageURL__c, TransmissionDate__c, ContactMethodName__c, Status__c, OpportunityId__c, CreatedBy.Name,JourneyName__c, ItemID__c from AccountMessage__c ';
        String orderByAndLimit = 'ORDER BY Status__c ASC,TransmissionDate__c ASC LIMIT 100';
        if (String.valueOf(passedOppOrAccId).substring(0, 3).equalsIgnoreCase('001')) {
            whereConditions = ' WHERE Account__c =:passedOppOrAccId WITH SECURITY_ENFORCED ';
        } else {
            whereConditions = ' WHERE OpportunityId__c =:passedOppOrAccId WITH SECURITY_ENFORCED ';
        }
        String query =  queryStart + whereConditions + orderByAndLimit;
        accMessageListToDisplay = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(query))).getRecords();

        return accMessageListToDisplay;
    }
    //Helper method to query Account Messages
    private static  List<et4ae5__IndividualEmailResult__c> queryIndividualEmailResult(Id passedOppOrAccId){
        List<et4ae5__IndividualEmailResult__c> indEmailListToDisplay;              
        String whereConditions;
        String queryStart = 'Select Id, Status__c, Type__c, ItemNumber__c, et4ae5__DateSent__c, InitiatedBy__c,Opportunity__r.Journey_Name__c from et4ae5__IndividualEmailResult__c ';
        String orderByAndLimit = 'ORDER BY Status__c LIMIT 100';
        if (String.valueOf(passedOppOrAccId).substring(0, 3).equalsIgnoreCase('001')) {
            //Account account = [Select PersonContactId from Account where ID =: passedOppOrAccId WITH SECURITY_ENFORCED LIMIT 1];
            //ID contactID = account.PersonContactId;
            whereConditions = ' WHERE et4ae5__Contact__c =:contactID WITH SECURITY_ENFORCED ';
        } else {
            whereConditions = ' WHERE Opportunity__c =:passedOppOrAccId WITH SECURITY_ENFORCED ';
            String query =  queryStart + whereConditions + orderByAndLimit;
        	indEmailListToDisplay = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(query))).getRecords();
        }
        
        return indEmailListToDisplay;
    }
    
    //Helper method to query ITR Records
    private static  List<IndividualTextResult__c> queryIndividualTextResult(Id passedOppOrAccId){
        List<IndividualTextResult__c> indTextListToDisplay;              
        String whereConditions;
        String queryStart = 'Select Id, Status__c, Type__c, ItemNumber__c, InitiatedBy__c,Opportunity__r.Journey_Name__c,CreatedDate from IndividualTextResult__c ';
        String orderByAndLimit = 'ORDER BY Status__c LIMIT 100';
        if (String.valueOf(passedOppOrAccId).substring(0, 3).equalsIgnoreCase('001')) {
            whereConditions = ' WHERE Account__c =:passedOppOrAccId WITH SECURITY_ENFORCED ';
        } else {
            whereConditions = ' WHERE Opportunity__c =:passedOppOrAccId WITH SECURITY_ENFORCED ';
        }
        String query =  queryStart + whereConditions + orderByAndLimit;
        indTextListToDisplay = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(query))).getRecords();
            
        return indTextListToDisplay;
    }    
}
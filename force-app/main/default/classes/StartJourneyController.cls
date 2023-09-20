/**
  * @description StartJourneyController
  * @Author ITIC
  * @createdDate 04/02/2020
  * @Name This class contains is used to retrieve and 
  * process Journey and Journey Step details
  */
public with sharing class StartJourneyController {
    private static final Integer QUERY_LIMIT = 5000;
    private static final String CUSTOMER_PROSPECT_CAMPAIGN= 'Customer_Prospect_Campaign';
    private static final String LEAD_CAMPAIGN= 'Lead_Campaign';
/**
         * @description JourneyPreviewData
         */
    // Class to store details of journey preview data such as All Journey Step details and total cost calculated
    public with sharing class JourneyPreviewData {
        public List<Journey_Step__c> journeyStepList = new List<Journey_Step__c>();
        @AuraEnabled
        public List<JourneyStepPreviewDetails> journeyStepPreviewDetailsList =  new List<JourneyStepPreviewDetails>();
        @AuraEnabled
        /**
         * @description totalCost
         */
        public Double totalCost {get;set;}
        
    }
 /**
         * @description JourneyStepPreviewDetails
         */
    // Class to store esch Journey Step details 
    public with sharing class JourneyStepPreviewDetails{
        @AuraEnabled
         /**
         * @description journeyStepId
         */
        public Decimal journeyStepId {get;set;}
        @AuraEnabled
        /**
         * @description deliveryType
         */
        public String deliveryType {get;set;}
        @AuraEnabled
        /**
         * @description contactMethod
         */
        public String contactMethod {get;set;}
        @AuraEnabled
        /**
         * @description estimatedDate
         */
        public Date estimatedDate {get;set;}
        @AuraEnabled
        /**
         * @description stepCost
         */
        public Decimal stepCost {get;set;}
        @AuraEnabled
        /**
         * @description stepItemId
         */
        public String stepItemId {get;set;}
        @AuraEnabled
        /**
         * @description stepItemIdUrl
         */
        
        public String stepItemIdUrl {get;set;}
    }
    
    // This method is used to retrieve the Journey details based on the SObject record type
    @AuraEnabled(cacheable=true)
    /**
     * @description queryJourneys 
     * @param selectedJourneyStartDate 
     * @param recordTypeName 
     * @return  `List<Journey__c>`
     */
    
    public static List<Journey__c> queryJourneys(Date selectedJourneyStartDate, String recordTypeName){
        String record_TypeName = recordTypeName;
        List<Journey__c> journeyList = new List<Journey__c>();
        UTIL_ParameterValidator_LongString longStringValidation = new UTIL_ParameterValidator_LongString();
        longStringValidation.validateParameter('recordTypeName',record_TypeName);
        record_TypeName = retrieveRecordType(record_TypeName);
        List<CM_Journey__mdt> journeyCategoryTypeCMList = getJourneyCategoryType(record_TypeName);
        String[] journeyCategoryList = journeyCategoryTypeCMList.get(0).JourneyCategory__c.split(',');
        String[] journeyTargetTypeCodeList = journeyCategoryTypeCMList.get(0).JourneyTargetTypeCode__c.split(',');
        Double timingTypeCode = journeyCategoryTypeCMList.get(0).JourneyTimingTypeCode__c;
        
        String stateCode = retrieveStateCodeOfAgent();
        journeyList = Security.stripInaccessible(AccessType.READABLE, 
                                                    [SELECT Id, Name, JourneyName__c, EffectiveDate__c FROM Journey__c
                                                    WHERE Categoryname__c IN :journeyCategoryList AND StateCode__c=:stateCode 
                                                    AND CustomDemographicsInd__c=false AND EffectiveDate__c <=:selectedJourneyStartDate 
                                                    AND ExpirationDate__c>=:selectedJourneyStartDate AND
                                                    TargetGroupCode__c IN :journeyTargetTypeCodeList AND TimingTypeCode__c =:timingTypeCode 
                                                    LIMIT 5000]).getRecords();
        return journeyList;  
    }
    // This method is used to retrieve the Journey Preview data and calculate the total cost of Journey
    @AuraEnabled(cacheable=true)
    /**
     * @description retrieveJourneyPreviewData
     * @param selectedJourneyId 
     * @param numberOfMembers 
     * @param journeyStartDate 
     * @return  `JourneyPreviewData`
     */
    
    public static JourneyPreviewData retrieveJourneyPreviewData(String selectedJourneyId, Double numberOfMembers, Date journeyStartDate){
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('JourneyId', selectedJourneyId, Journey__c.Class);
        JourneyPreviewData journeyPreviewData = new JourneyPreviewData();
        journeyPreviewData.journeyStepList = Security.stripInaccessible(AccessType.READABLE,
                                                    [SELECT Id,Name,JourneyName__c,JourneyStepID__c,StepTypeCode__c, 
                                                    ContactMethodName__c, ItemEffectiveDate__c,Cost__c,DaysNum__c,Bundle_ID__c,MailClassCode__C  ,ItemID__c 
                                                    FROM Journey_Step__c WHERE JourneyID__c=:selectedJourneyId ORDER BY JourneyStepID__c asc 
                                                    LIMIT 50]).getRecords();
        caculateJourneyTotalCostAndDeliveryType(journeyPreviewData, numberOfMembers,journeyStartDate);
        return journeyPreviewData;
    }

    private static void caculateJourneyTotalCostAndDeliveryType(JourneyPreviewData journeyPreviewData, Double numberOfMembers,Date journeyStartDate){
        Decimal stepCost = 0.00;
        String deliveryType = '';
        Map<String,String> contactMethodToStepMap = contactMethodToStepTypeMap();
        for(journey_step__c journeyStep: journeyPreviewData.journeyStepList){
            JourneyStepPreviewDetails journeyStepPreviewDetails = new JourneyStepPreviewDetails();
            stepCost = stepCost + retrieveCostValue(journeyStep.Cost__c);
            String methodClass = retrieveStringValue(journeyStep.ContactMethodName__c) + retrieveStringValue(journeyStep.MailClassCode__c);
            if(contactMethodToStepMap.containsKey(methodClass)){
                deliveryType = contactMethodToStepMap.get(methodClass);
            }
            journeyStepPreviewDetails.journeyStepId = Double.valueOf(journeyStep.JourneyStepID__c);
            journeyStepPreviewDetails.contactMethod = journeyStep.ContactMethodName__c;
            journeyStepPreviewDetails.deliveryType = deliveryType;
            journeyStepPreviewDetails.stepCost = retrieveCostValue(journeyStep.Cost__c);
            journeyStepPreviewDetails.estimatedDate = journeyStartDate + Integer.valueOf(journeyStep.DaysNum__c);
            journeyStepPreviewDetails.stepItemId = retrieveStringValue(journeyStep.ItemID__c);
            journeyStepPreviewDetails.stepItemIdUrl = retrieveAgentOnlineCatalogUrl(journeyStepPreviewDetails.stepItemId);
            journeyPreviewData.journeyStepPreviewDetailsList.add(journeyStepPreviewDetails);
        }
        //calculate total cost of the campaign (total cost of steps x number of members)
            JourneyPreviewData.totalCost = stepCost * (numberOfMembers==null?0:numberOfMembers);
    }

    private static Decimal retrieveCostValue(String journeyCost){
        if(String.isNotEmpty(journeyCost)){
            return Decimal.valueOf(journeyCost);
        }
        return 0.00;
    }

    private static String retrieveAgentOnlineCatalogUrl(String stepItemId){
       if(String.isNotEmpty(stepItemId)){
        return '/c/ExternalLinkApp.app?linkId=5&itemNo='+stepItemId;
        }
        return null;
    }

    private static String retrieveStringValue(String inputString){
        if(String.isNotEmpty(inputString)){
            return inputString;
        }
        return null;
    }

    private static String retrieveRecordType(String recordTypeName){
        if(CUSTOMER_PROSPECT_CAMPAIGN.equals(recordTypeName)){
            return recordTypeName;
        }
        return LEAD_CAMPAIGN;
    }
    
    private static List<CM_Journey__mdt> getJourneyCategoryType(String recordTypeName){
        List<CM_Journey__mdt> journeyCategoryTypeCMList = [SELECT JourneyCategory__c, JourneyTimingTypeCode__c, JourneyTargetTypeCode__c, RecordType__c 
                                                            FROM CM_Journey__mdt 
                                                                WHERE RecordType__c=:recordTypeName WITH SECURITY_ENFORCED limit 1];
        return journeyCategoryTypeCMList;
}

    private static String retrieveStateCodeOfAgent(){
        List<User> userList = [SELECT State_Agent_Code__c FROM User
                              WHERE id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        String stateAgentCode = userList.get(0).State_Agent_Code__c;
        if(String.isNotBlank(stateAgentCode)){
            return stateAgentCode.left(2);
        }
        return null;
    }
/**
	* @description Method to create a map with method+classcode as key to get the corresponding delivery type  
	* @return mailCodeMap - returns contact and steptype map
	*/ 
    public static Map<String,String> contactMethodToStepTypeMap(){
        Map<String,String> mailCodeMap = new Map<String,String>();
        mailCodeMap.put('Mailing1','1st Class');
        mailCodeMap.put('Mailing3','3rd Class');
        mailCodeMap.put('MailingE','Email');
        mailCodeMap.put('Appointment','Task');
        mailCodeMap.put('Call','Task');
        mailCodeMap.put('Other','Task');
        return mailCodeMap;        
    }

}
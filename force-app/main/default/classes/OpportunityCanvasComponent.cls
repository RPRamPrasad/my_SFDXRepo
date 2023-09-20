/** 
@Author Team AKITA
@Name OpportunityCanvasComponent
@CreateDate 09/22/2020  
@description This class is used to get the required parameters based on the record Id.
@Version 6.3
    -most recent update: agentContext bug fix and query optimization
*/
public with sharing class OpportunityCanvasComponent {
    
    static final String CLASS_NAME = 'OpportunityCanvasComponent';
    static final String ROUTE_REQUEST_METHOD_NAME_NEXT = 'getRequiredParams';
    static final String OPP_MANAGEMENT_PARTITION = 'local.OpportunityManagementPartition.';
    static final String SHOULD_SHOW_MESSAGE = 'shouldShowMessage';
    static final String DISPLAY_INTERMEDIATE_SCREEN = 'displayIntermScreen';
    static final String CANVAS_OPPMGMNT_PARTITION = 'local.CanvasIntmdtScreenPartition.';

    /**
    * @description Method to get the required parameters for Bundle API
    * @param recordId
    * @return string of bundleData parameters in JSON format
    */
    @AuraEnabled
    public static String getRequiredParams(Id recordId) {  
        String returnValue = '';
        try {
            Opportunity primaryOpp;
            List<Opportunity> sortedList = new List<Opportunity>();
            primaryOpp = OpportunityCanvasComponentDataRetriever.oppQuery(recordId).get(0);
            if (primaryOpp.Account.IsHealthSourced__pc) {
                throw new DataNotFoundException('ApexError:Customer Health Information cannot be used to pre-populate a non-HIPAA product quote or application. Please re-enter the customer information.');
            }
            if (primaryOpp.StageName == 'Closed') {
                throw new DataNotFoundException('ApexError:Integrated Quoting not available for Closed Opportunities.' + '\n\n' + 'To view the quote, change the Stage of the Opportunity to Quoting. If you change to any other stage, you will need to refresh the browser.');
            }
            List<String> clientIdList = OpportunityCanvasComponentDataRetriever.getClientIdList(primaryOpp);
            sortedList.add(primaryOpp);
            sortedList.addAll(OpportunityCanvasComponentDataRetriever.oppsForAccountQuery(primaryOpp));
            
            List<BundleData> finalBundleDataList = new List<BundleData>();
            finalBundleDataList = populateBundleData(sortedList);
            
            OppList oppList = new OppList();
            oppList.clientIdList = clientIdList;
            oppList.hideIntermediateScreen=shouldIntermediateScreenDisplayOrNot(primaryOpp.Id);
            removeKeyFromCache(primaryOpp.Id);
            oppList.opportunityList = finalBundleDataList;

            returnValue = JSON.serialize(oppList);  
        }
        catch (DataNotFoundException dne) {
            returnValue = dne.getMessage();
        }
        catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, ROUTE_REQUEST_METHOD_NAME_NEXT,System.LoggingLevel.ERROR); 
            throw new AuraHandledException(e.getMessage());
        }    
        return returnValue;
    }

    /**
     * @description shouldShowCheckoutInProgress
     * @param opportunityId 
     * @return  `Boolean`
     */
    @AuraEnabled
    public static Boolean shouldShowCheckoutInProgress(Id opportunityId) {
        String key = OPP_MANAGEMENT_PARTITION + opportunityId;
        try {
            String cacheVal = (String)Cache.Session.get(key);
            return SHOULD_SHOW_MESSAGE.equals(cacheVal);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description persistShouldShowCheckoutInProgress
     * @param opportunityId 
     * @param shouldShowMessage 
     */
    @AuraEnabled
    public static void persistShouldShowCheckoutInProgress(Id opportunityId, Boolean shouldShowMessage) {
        String key = OPP_MANAGEMENT_PARTITION + opportunityId;
        try {
            if (shouldShowMessage) {
                Cache.Session.put(key, SHOULD_SHOW_MESSAGE);
            } else {
                Cache.Session.remove(key);
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description helper method that loops through the opps on an Account and sets fields on bundleData
     * @param allOppsForAccount
     * @return list of bundleData classes holding each individual opp's details
     */
    private static List<BundleData> populateBundleData(List<Opportunity> allOppsForAccount) {
        List<AgentContext__c> agentContextResult = new List<AgentContext__c>();
        List<User> userResult;

        userResult = OpportunityCanvasComponentDataRetriever.loggedInUsrQuery();

        if (userResult[0].SubUserType__c == 'CCC Sales') {
            String agentContextIdentifier = userResult[0].Associate_ID__c +'~'+allOppsForAccount[0].Account.ClientIdentifier__c;
            agentContextResult = OpportunityCanvasComponentDataRetriever.agentContextQuery(agentContextIdentifier);
        }
        
        List<BundleData> bundleDataList = new List<BundleData>();

        for (Opportunity opp : allOppsForAccount) {
            BundleData bundleData = new BundleData();
            bundleData.bookCode = (String.isBlank(opp.State_Code__c)) ? null : opp.State_Code__c.right(7);
            bundleData.opportunityId = opp.Id;
            bundleData.interactionId = (agentContextResult.isEmpty())? null: agentContextResult[0].InteractionId__c;
            bundleData.clientId = opp.Account.ClientIdentifier__c;
            bundleData.lob = OpportunityCanvasComponentDataRetriever.getlobCode(opp);
            bundleData.effectiveDate = (opp.Requested_Effective_Date__c == null) ? Date.Today() : opp.Requested_Effective_Date__c;
            bundleData.productSystemName = OpportunityCanvasComponentDataRetriever.getProductSystemName(opp);
            bundleDataList.add(bundleData);
        }
        return bundleDataList;
    }
    
    /**
    * @description Helper class to pass the parameters for bundle API
    */
    public with sharing class BundleData {
        /** @description opportunityId */
        public String opportunityId{get;set;}
        /** @description interactionId */
        public String interactionId{get;set;}
        /** @description clientId */
        public String clientId{get;set;}
        /** @description bookCode */
        public String bookCode{get;set;}
        /** @description productSystemName */
        public String productSystemName{get;set;}
        /** @description lob */
        public String lob{get;set;}
        /** @description effectiveDate */
        public date effectiveDate{get;set;}
    } 

    /**
    * @description Helper class to pass the oppList to bundle API
    */
    public with sharing class OppList {
        /** @description opportunityList */
        public List<BundleData> opportunityList{get;set;}
        /** @description clientIdList */
        public List<String> clientIdList{get;set;}
        /** @description hideIntermediateScreen */
        public Boolean hideIntermediateScreen{get;set;}
    }
    private static Boolean shouldIntermediateScreenDisplayOrNot(Id opportunityId) {  
        String key = CANVAS_OPPMGMNT_PARTITION + opportunityId;
        String cacheVal = (String) Cache.Session.get(key);
        return DISPLAY_INTERMEDIATE_SCREEN.equals(cacheVal);
    }

    private static void removeKeyFromCache(Id opportunityId) {
        String key = CANVAS_OPPMGMNT_PARTITION + opportunityId;
        String cacheVal = (String) Cache.Session.get(key);
        if(cacheVal != null){
            Cache.Session.remove(key);
        }
    }
}
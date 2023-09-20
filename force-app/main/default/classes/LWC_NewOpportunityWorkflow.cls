/**
@Author Team AKITA
@Name LWC_NewOpportunityWorkflow
@CreateDate 08/14/2019
@description This class is used to create opportunity, Upsert Agent Context and return the list of ordered opportunites.
@Version 1.0
Copyright © StateFarm
Version     Author        Date           Description
1.1          Akita        01-08-2020     Updated saveOpp Method, Added getExceptionMessage() Method And ApexResponse class
1.2          QuadCore     05-18-2020     Updated saveOpp Method with Stage as Quoting and Status as Quote In Progress
1.3          Akita        01-1-2020      Updated saveOpp Method and added class, to accept product & effective data and avoid PMD violations.
1.4          Opptimizers  4/10/2022      Updated saveOpp Method and added additional classes for PS-MOD Effort
1.5          Opptimizers  8/16/2022      updated saveOpp Method and inner classes to accept new fields   
*/
public with sharing class LWC_NewOpportunityWorkflow {
    static final String CLASS_NAME = 'lWC_NewOpportunityWorkflow';
    static final String ROUTE_REQUEST_METHOD_NAME_NEXT = 'saveOpp';
    static final String ROUTE_REQUEST_METHOD_NAME_ACCOUNT = 'retrieveAccount';
    static final String ACCOUNT_OBJ_NAME = 'Account';
    static final String USER_OBJ_NAME = 'User';
    static ProductData productData = new ProductData();
    /**
     * @description Class to return the state abbreviation
     */
    public static final Map<String, String> STATECODETOABBREVIATIONS = new Map<String, String>{
        '23' => 'MN',
        '19' => 'ME',
        '25' => 'MO',
        '21' => 'MA',
        '36' => 'OK',
        '28' => 'NV',
        '27' => 'NE',
        '37' => 'OR',
        '05' => 'CA',
        '01' => 'AL',
        '18' => 'LA',
        '20' => 'MD',
        '33' => 'NC',
        '48' => 'WV',
        '16' => 'KS',
        '06' => 'CO',
        '45' => 'VT',
        '31' => 'NM',
        '49' => 'WI',
        '46' => 'VA',
        '07' => 'CT',
        '22' => 'MI',
        '40' => 'SC',
        '17' => 'KY',
        '02' => 'AK',
        '26' => 'MT',
        '14' => 'IN',
        '35' => 'OH',
        '24' => 'MS',
        '51' => 'HI',
        '15' => 'IA',
        '47' => 'WA',
        '39' => 'RI',
        '42' => 'TN',
        '32' => 'NY',
        '12' => 'ID',
        '59' => 'FL',
        '03' => 'AZ',
        '08' => 'DE',
        '43' => 'TX',
        '34' => 'ND',
        '04' => 'AR',
        '11' => 'GA',
        '41' => 'SD',
        '30' => 'NJ',
        '50' => 'WY',
        '38' => 'PA',
        '13' => 'IL',
        '44' => 'UT',
        '29' => 'NH',
        '09' => 'DC',
        '53' => 'TX',
        '55' => 'CA',
        '75' => 'CA',
        '52' => 'NY'
    };
    static final String NEW_STAGE = 'New';

    /**
     * @description This method is used to create and save the opportunities based on the selection of LOBs, upserts Agent Context,
					and returns the list of opportunities by sorting them based on LOB metadata.
     * @param saveData
     * @return List of Ordered Opportunites, created by the end user.
     */
    @AuraEnabled
    public static String saveOpp(String saveData) {
        List<opportunity> newOppList = new List<Opportunity>();
        ApexResponse response;
        try {
            User loggedInUserInfo = HLPR_LWC_NewOpportunityWorkflow.getLoggedInUser();
            String profileName = HLPR_LWC_NewOpportunityWorkflow.getLoggedInUserProfileName();

            if (String.isNotBlank(loggedInUserInfo.Associate_ID__c)) {
                SaveData parsedData = (SaveData) JSON.deserialize(saveData, SaveData.class);
                UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(
                    ACCOUNT_OBJ_NAME,
                    parsedData.accId,
                    Type.forName(ACCOUNT_OBJ_NAME)
                );
                String selectedAgentContextAssociateID = string.isEmpty(parsedData.selectedAgentContext)
                    ? ''
                    : parsedData.selectedAgentContext.split('-')[0];
                Account accountInfo = HLPR_LWC_NewOpportunityWorkflow.getAccountRecord(parsedData.accId);

                newOppList = createOpportunityInstance(accountInfo, selectedAgentContextAssociateID, parsedData);
                if (!'Save'.equalsIgnoreCase(parsedData.saveNquote)) {
                    newOppList[0].StageName = 'Quoting';
                    newOppList[0].Status__c = 'Quote In Progress';
                    newOppList[0].Assigned_To__c =  UserInfo.getUserId();
                    newOppList[0].OppQuoteInProgressDateTime__c = System.now();
                    newOppList[0].OppContactEstablishedDateTime__c = System.now();
                    newOppList[0].OppAssignedDateTime__c = System.now();
                    newOppList[0].Sales_Attempts__c=1;
                }
                HLPR_LWC_NewOpportunityWorkflow.performCreate(newOppList);
                if (parsedData.isguided) {
                    UTIL_AccountAgentContext.LoggedInUserDetails userdetailS = new UTIL_AccountAgentContext.LoggedInUserDetails();
                    userdetailS.agentAssociateId = selectedAgentContextAssociateID;
                    userdetailS.loggedInUserProfileName = profileName;
                    UTIL_AccountAgentContext.createAgentContextForCCCUser(
                        parsedData.accId,
                        false,
                        JSON.serialize(userdetailS)
                    );
                }

                response = new ApexResponse('Success', 'Success', newOppList);
            } else {
                response = new ApexResponse(
                    'Error',
                    'There was an error creating the opportunity, please contact the normal support channel.',
                    null
                );
            }
        } catch (Exception e) {
            LoggingService.logHandledException(
                e,
                CLASS_NAME,
                ROUTE_REQUEST_METHOD_NAME_NEXT,
                System.LoggingLevel.ERROR
            );
            response = new ApexResponse('Error', getExceptionMessage(e), null);
        }
        return JSON.serialize(response);
    }

    /**
     * @description Method to get the exception message
     * @param e
     * @return Exception Message
     */
    private static String getExceptionMessage(Exception e) {
   if (e.getMessage().contains('Sensitive Personal Information (SPI)')) {
            return 'Sensitive Personal Information (SPI) is not allowed to be entered in the Opportunity Source Comments field.';
        } else {
            return 'There was an error creating the opportunity, please contact the normal support channel.';
        }
    }

    /**
     * @description Method to get the Priority LOB by comparing custom metadata.
     * @param lobList
     * @return Priority LOB
     */
    public static List<ProductLineItem> sortLOBsBasedOnPriority(List<ProductLineItem> lobList) {
        Map<String, List<ProductLineItem>> lobToLobItemMap = new Map<String, List<ProductLineItem>>();
        for (ProductLineItem lobItem : lobList) {
            if (!lobToLobItemMap.containsKey(lobItem.selectedLineOfBusiness)) {
                lobToLobItemMap.put(lobItem.selectedLineOfBusiness, new List<ProductLineItem>());
            }
            lobToLobItemMap.get(lobItem.selectedLineOfBusiness).add(lobItem);
        }

        Map<String, List<ProductLineItem>> withProductMap = new Map<String, List<ProductLineItem>>();
        Map<String, List<ProductLineItem>> withoutProductMap = new Map<String, List<ProductLineItem>>();
        for (CM_LOB_Priority_Mapping__mdt lob : HLPR_LWC_NewOpportunityWorkflow.getPriorityLob()) {
            if (lobToLobItemMap.containsKey(lob.Label)) {
                List<ProductLineItem> lobItems = lobToLobItemMap.get(lob.Label);
                AddItemToMapMethodWrapper addWrap =new AddItemToMapMethodWrapper();
                addWrap.withProductMap = withProductMap;
                addWrap.withOutProductMap = withOutProductMap;
                addItemToMapMethod(lobItems, addWrap, lob);
            }
        }

        List<ProductLineItem> sortedLobs = new List<ProductLineItem>();
        addItemsToList(withProductMap, sortedLobs);
        addItemsToList(withOutProductMap, sortedLobs);
        return sortedLobs;
    }

    /**
     * @description AddItemToMapMethodWrapper
     */
    private class AddItemToMapMethodWrapper{
        Map<String, List<ProductLineItem>> withProductMap;
        Map<String, List<ProductLineItem>> withoutProductMap;
    }
    
    /**
     * @description addItemToMapMethod
     * @param lobItems 
     * @param addItem 
     * @param lob 
     */
    private static void addItemToMapMethod(List<ProductLineItem> lobItems, AddItemToMapMethodWrapper addItem, CM_LOB_Priority_Mapping__mdt lob){
        for (ProductLineItem lineItem : lobItems) {
            if (lineItem.selectedProduct == null || String.isEmpty(lineItem.selectedProduct.productDescription)) {
                addItemToMap(addItem.withOutProductMap, lineItem, lob.Label);
            } else {
                addItemToMap(addItem.withProductMap, lineItem, lob.Label);
            }
        }
    }

    /**
     * @description addItemsToList
     * @param lineItems Map<String, List<ProductLineItem>> 
     * @param sortedLobs List<ProductLineItem> 
     */
    private static void addItemsToList(Map<String, List<ProductLineItem>> lineItems, List<ProductLineItem> sortedLobs) {
        productData.addItemsToList(lineItems, sortedLobs);
    }

    /**
     * @description addItemToMap
     * @param mapData Map<String, List<ProductLineItem>> 
     * @param item ProductLineItem 
     * @param lob String 
     */
    private static void addItemToMap(Map<String, List<ProductLineItem>> mapData, ProductLineItem item, String lob) {
        productData.addItemToMap(mapData, item, lob);
    }

    /**
     * @description Method to contruct Opportunities.
     * @param accountInfo
     * @param selectedAgentContextAssociateID
     * @param parsedData
     * @return List of created opportunities.
     */
    private static List<Opportunity> createOpportunityInstance(
        Account accountInfo,
        String selectedAgentContextAssociateID,
        SaveData parsedData
    ) {
        List<opportunity> newOppList = new List<opportunity>();
        List<ProductLineItem> sortedLOBs = sortLOBsBasedOnPriority(parsedData.lobSelection);
        ProductLineItem priorityLOB;
        priorityLOB = sortedLOBs[0];

        newOppList = productData.createOpportunityInstance(accountInfo, selectedAgentContextAssociateID, parsedData);
        return newOppList;
    }

    /**
     * @description Class to wrap the agent context value.
     */
    public with sharing class WrapperAgentRole {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String selectedContextAgentId;

        wrapperAgentRole(string a, string b, string c) {
            this.label = b;
            this.value = a;
            this.selectedContextAgentId = c;
        }
    }

    /**
     * @description Class to wrap the agent context value.
     */
    public with sharing class StateWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String stateAgentCode;
        @AuraEnabled
        public String stateCodeValue;

        StateWrapper(String labelIn, String valueIn, String stateAgentCode) {
            this.label = labelIn + ' / ' + stateAgentCode;
            this.value = valueIn + ' / ' + stateAgentCode;
            this.stateAgentCode = stateAgentCode;
            this.stateCodeValue = labelIn;
        }
    }

    /**
     * @description Method to query the AgentRole and AgentContext information based on Account Id.
     * @param paramAccountId
     * @return Agent Context Options.
     */
    @AuraEnabled
    public static WrapperAgentRoleSelectedContext lwcqueryAgentRolePicklistOptions(String paramAccountId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(
            ACCOUNT_OBJ_NAME,
            paramAccountId,
            Type.forName(ACCOUNT_OBJ_NAME)
        );

        List<wrapperAgentRole> wrapperList = new List<wrapperAgentRole>();
        String selectedAgent = '';
        string selectedContextAgentId = '';
        for (AgentRole__c agntRole : HLPR_LWC_NewOpportunityWorkflow.getAgentRoleOptions(paramAccountId)) {
            User agent = agntRole.Agent__r;
            if (agent != null && String.isNotBlank(agent.Associate_ID__c)) {
                wrapperList.add(new wrapperAgentRole(agent.Associate_ID__c + '-' + agent.Alias, agent.Name, agent.Id));
            }
        }

        if (wrapperList.size() > 0) {
            for (
                AgentContext__c agntContext : HLPR_LWC_NewOpportunityWorkflow.getAgentContextOptions(
                    paramAccountId,
                    userInfo.getuserid()
                )
            ) {
                User agent = agntContext.Agent__r;
                if (agent != null && String.isNotBlank(agent.Associate_ID__c)) {
                    selectedAgent = agent.Associate_ID__c + '-' + agent.Alias;
                    selectedContextAgentId = agent.Id;
                }
            }
        }
        return new WrapperAgentRoleSelectedContext(wrapperList, selectedAgent, selectedContextAgentId);
    }

    /**
     * @description class to return state code options
     * @param selectedContextAgentId
     * @return StateSelectionOptions
     */
    @AuraEnabled(cacheable=true)
    public static StateSelectionOptions getStateSelectionOptions(string selectedContextAgentId) {
        string userId;

        if (String.isNotBlank(selectedContextAgentId)) {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(
                USER_OBJ_NAME,
                selectedContextAgentId,
                Type.forName(USER_OBJ_NAME)
            );
            userId = selectedContextAgentId;
        } else {
            userId = UserInfo.getUserId();
        }

        List<User> users = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT State_Agent_Code_List__c, State_Agent_Code__c FROM User WHERE Id = :userId LIMIT 1]
            )
            .getRecords();

        return getStateCodeWrapperList(users);
    }

    /**
     * @description class to get the state code wrapperlist
     * @param users List<User> 
     * @return StateSelectionOptions
     */
    public static StateSelectionOptions getStateCodeWrapperList(List<User> users) {
        List<StateWrapper> wrapperList = new List<StateWrapper>();
        List<String> stateAgentCodes = users.get(0).State_Agent_Code_List__c.split(',');

        Map<String, String> stateCodes = new Map<String, String>();
        for (String code : stateAgentCodes) {
            List<String> stateAgentCodeParsed = code.split('-');
            stateCodes.put(stateAgentCodeParsed.get(0), code);
        }
        Map<String, String> stateList = getStateAbbreviations(stateCodes.keySet());
        Set<String> primaryStateCode = new Set<String>{ users.get(0).State_Agent_Code__c.split('-').get(0) };
        List<String> primaryList = getStateAbbreviations(primaryStateCode).values();

        for (String state : stateList.keySet()) {
            wrapperList.add(new StateWrapper(stateList.get(state), stateList.get(state), stateCodes.get(state)));
        }
        return new StateSelectionOptions(wrapperList, primaryList.get(0) + ' / ' + users.get(0).State_Agent_Code__c);
    }

    /**
     * @description Method to wrap AgentRole and Selected Agent Context.
     */
    public with sharing class WrapperAgentRoleSelectedContext {
        @AuraEnabled
        public List<wrapperAgentRole> wrapperList;
        @AuraEnabled
        public String selectedAgentContext;
        @AuraEnabled
        public String selectedContextAgentId;

        WrapperAgentRoleSelectedContext(List<wrapperAgentRole> a, string b, string c) {
            this.wrapperList = a;
            this.selectedAgentContext = b;
            this.selectedContextAgentId = c;
        }
    }

    /**
     * @description Inner class to wrap State Selection Values to be returned to LWC.
     */
    public with sharing class StateSelectionOptions {
        @AuraEnabled
        public List<StateWrapper> stateList;
        @AuraEnabled
        public String selectedState;

        StateSelectionOptions(List<StateWrapper> stateListIn, String selectedStateIn) {
            this.stateList = stateListIn;
            this.selectedState = selectedStateIn;
        }
    }


    /**
     * @description class to get the state abbreviations
     * @param stateCodes 
     * @return Map<String, String>
     */
    @TestVisible
    public static Map<String, String> getStateAbbreviations(Set<String> stateCodes) {
        Map<String, String> retVal = new Map<String, String>();

        for (String stateCode : stateCodes) {
            retVal.put(stateCode, STATECODETOABBREVIATIONS.get(stateCode));
        }
        return retVal;
    }

    /**
     * @description Class to control the return response from saveOpp Method.
     */
    private with sharing class ApexResponse {
        /**
        @description test
        @comment test
        */
        public String status { get; set; }

        /**
         * @description message
         */
        public String message { get; set; }

        /**
         * @description result
         */
        public List<Opportunity> result { get; set; }

        /**
         * @description ApexResponse
         * @param status 
         * @param message 
         * @param result 
         */
        public ApexResponse(String status, String message, List<Opportunity> result) {
            this.status = status;
            this.message = message;
            this.result = result;
        }
    }

    /**
     * @description check for valid profiles for New App Quote and Production Manager
     * @param loggedInProfile
     * @return boolean
     */
    private static boolean supportprofileForNewAppQuoteAndProductionManager(String loggedInProfile) {
        Boolean isAllowedProfile = false;
        for (
            CM_NewAppQuoteAndProdMgrAllowedProfile__mdt allowedProfile : UTIL_LtngProfileDataAccess.getSupportProfilesFromMetadata()
        ) {
            if (loggedInProfile.equals(allowedProfile.Profile__c)) {
                isAllowedProfile = true;
            }
        }
        return isAllowedProfile;
    }

    /**
     * @description Class to parse the data from LWC
     */
    @TestVisible
    public with sharing class SaveData {
        public List<ProductLineItem> lobSelection;
        public String accId;
        public String stateCode;
        public String sourceComments;
        public String marketSource;
        public String saveNquote;
        public String marketSourceSub;
        public String oppOrg;
        public String selectedAgentContext;
        public Boolean isguided;
        public String campaignId;
        public Date effectiveDate;
        public Integer appCode;
        public String simpleConId;
        public String customerReferrer;
        public String relationshipToReferrer;
        public String nonCustomerReferrer;
    }

    /**
     * @description Class to parse ProductLineItem
     */
    public with sharing class ProductLineItem {
        public String selectedLineOfBusiness;
        public Date selectedEffectiveDate;
        public ProductData selectedProduct;
        public String keyField;
        public String jointType;
        public String additionalOwner;
    }

    /**
     * @description Class to parse Product Data
     */
    public with sharing class ProductData {
            public String productSystemName;
            public String productDescription;

            private boolean getAgentValue() {
                boolean isAgent;
                String profileName = HLPR_LWC_NewOpportunityWorkflow.getLoggedInUserProfileName();
    
                if (supportprofileForNewAppQuoteAndProductionManager(profileName)) {
                    isAgent = false;
                } else if (profileName.equals(label.CL_Agent_Profile) || profileName.equals(label.CL_ATM_Profile)) {
                    isAgent = true;
                }
                return isAgent;
            }

         private List<Opportunity> createOpportunityInstance(
            Account accountInfo,
            String selectedAgentContextAssociateID,
            SaveData parsedData
        ) {
            List<opportunity> newOppList = new List<opportunity>();
            Boolean agentValue = getAgentValue();
            List<ProductLineItem> sortedLOBs = sortLOBsBasedOnPriority(parsedData.lobSelection);
            ProductLineItem priorityLOB;
            priorityLOB = sortedLOBs[0];
            for (ProductLineItem lob : sortedLOBs) {
                newOppList.add(
                    new Opportunity(
                        AccountId = accountInfo.Id,
                        Name = lob.selectedLineOfBusiness + '-' + accountInfo.name,
                        lob__c = lob.selectedLineOfBusiness,
                        JointType__c = String.isNotEmpty(lob.jointType) ? lob.jointType : null,
                        AdditionalOwner__c = String.isNotEmpty(lob.additionalOwner) ? lob.additionalOwner: null,
                        CloseDate = date.today() + 60,
                        Opportunity_Originator__c = parsedData.oppOrg,
                        Marketing_Source__c = parsedData.marketSource,
                        Marketing_Sub_Source__c = parsedData.marketSourceSub,
                        Customer_Referrer__c = parsedData.customerReferrer,
                        Relationship_to_Referrer__c = parsedData.relationshipToReferrer,
                        Non_Customer_Referrer__c = parsedData.nonCustomerReferrer,
                        Source_Comments__c = parsedData.sourceComments,
                        CampaignId = parsedData.campaignId,
                        Requested_Effective_Date__c = lob.selectedEffectiveDate,
                        AppCode__c = parsedData.appCode,
                        Simple_Conversation__c = parsedData.simpleConId,
                        Product__c = lob.selectedProduct.productDescription,
                         State_Code__c = parsedData.stateCode,
                        Product_System_Name__c = lob.selectedProduct.productSystemName,
                        StageName = NEW_STAGE,
                        Owner = (!agentValue) ? new User(UserExternalID__c = selectedAgentContextAssociateID + 'P') : null
                    )
                );
            }
            return newOppList;
         } 

         private void addItemsToList(Map<String, List<ProductLineItem>> lineItems, List<ProductLineItem> sortedLobs) {
               for (String lob : lineItems.keySet()) {
                  sortedLobs.addAll(lineItems.get(lob));
              }
          }

          private void addItemToMap(Map<String, List<ProductLineItem>> mapData, ProductLineItem item, String lob) {
            if (!mapData.containsKey(lob)) {
                mapData.put(lob, new List<ProductLineItem>());
            }
            mapData.get(lob).add(item);
        }
    }
}
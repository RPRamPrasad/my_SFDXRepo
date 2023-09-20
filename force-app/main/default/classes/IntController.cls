/**
* @author Data Blazers
* @name IntController
* @description Apex Controller Class used to retrieve  AssociateId & Client-ID
* from User & Account Object and to create the header body for the interaction callout
*/

public with sharing class IntController extends ContinuationCalloutLwcBase {
    
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    
    /**
    * @name: fetchAssociateIdValue
    * @description retrieves the Associate Id from the Corresponding Client id from Account
    * @return Servicing_Agent_Associate_ID
    */
    
    @AuraEnabled(Cacheable=true)
    public static String fetchAssociateIdValue() {
        List<User> lCurrentUser = new List<User>();
        try {
            lCurrentUser = Security.stripInaccessible(
                AccessType.READABLE,
                [
                    SELECT Id, Alias, Servicing_Agent_Associate_ID__c
                    FROM User
                    WHERE id = :UserInfo.getUserId()
                    LIMIT 1
                ]
            )
                .getRecords();
            
            return lCurrentUser[0].Servicing_Agent_Associate_ID__c;
        }
        catch (Exception err) {
            throw new AuraHandledException('Could Not Fetch Associate ID: ' + err.getMessage());
        }
    }
    
    /**
    * @name: getAgentType
    * @description get current logged in user details
    * @param N/A
    * @return Boolean 
    */
    @AuraEnabled(Cacheable=true)
    public static Boolean getAgentType() {
        Boolean userExist = false;
        try {
            User loggedInUser = UTIL_CurrentUser.retrieveCurrentUser();
            
            if (loggedInUser.Servicing_Agent_Associate_ID__c == null || loggedInUser.Servicing_Agent_Associate_ID__c == '' ) {
                userExist = true;
            }
            return userExist;
        }
        catch (Exception err) {
            throw new AuraHandledException('Could not retrieve logged in user: ' + err.getMessage());
        }
    }
    
    /**
    * @name: isSFConnectInteractionsOff
    * @description To check if SFConnect component is disable
    * @param N/A
    * @return Boolean
    */    
    @AuraEnabled(Cacheable=true)
    public static boolean isSFConnectInteractionsOff() {
        try{
            return IntController.toggleContext.isActive(UTIL_Toggles.SF_CONNECT_INT);
        }
        catch (Exception err) {
            throw new AuraHandledException('isSFConnectInteractionsOff : ' + err.getMessage());
        }
     
    }
    
    /**
    * @name: getDateRange
    * @description To check the date range
    * @param N/A
    * @return Date list
    */ 
    @AuraEnabled(Cacheable=true)
    public static List<String> getDateRange() {
        try {
            DateTime currDate = DateTime.Now();
            DateTime fromDate = currDate.addDays(1);
            DateTime toDate = currDate.addMonths(-6);
            return new List<String>{fromDate.format('yyyy-MM-dd\'T\'23:59:59'), toDate.format('yyyy-MM-dd\'T\'00:00:00')};
        }
        catch (Exception err) {
            throw new AuraHandledException('Could not get date range: ' + err.getMessage());
        }
    }
    
    /**
    * @name: getContinuationSFConnect
    * @description retrieves continuation callout result using input
    * @param input
    * @return Object
    */     
    @AuraEnabled(continuation=true)
    public static Object getContinuationSFConnect(Map<String, Object> input) {
        // will either be the cached result, or the continuation object when returned
        try{
        Object result;
        
        String calloutName = (String)input.get('calloutName');
        Continuation_Callout__c calloutConfig = getCalloutConfiguration(calloutName);
        
        List<Object> objects = (List<Object>)input.get('calloutParams');
        List<String> parameters = new List<String>();
        for (Object o : objects) {
            parameters.add((String)o);
        }
        
        List<String> escapedParameters = getEscapedParameters(parameters);
        
        // build key out of unique callout name + parameters
        String hashKey = buildHashKey(calloutName, parameters);
        
        // does this callout allow caching?
        if (calloutConfig.CachingTTL__c != 0) {
            // check org cache for a value
            result = (CalloutResponse) Cache.Org.getPartition(ContinuationCalloutLwcBase.CACHE_PARTITION).get(hashKey);
        }
        
        // if there was a valid item cached then use it, otherwise start the callout
        if (result == null) {
            StateInfo si = new StateInfo();
            si.hashKey = hashKey;
            si.timeToLive = calloutConfig.CachingTTL__c.intValue();
            
            Continuation continuation = new Continuation(120);
            continuation.continuationMethod = 'processCalloutResponse';
            
            // pull record
            HttpRequest request = new HttpRequest();
            request.setMethod(calloutConfig.RestVerb__c);
            request.setEndpoint(String.format(calloutConfig.EndpointURLTemplate__c, escapedParameters));
            String tokenVal = getCachedValue();
            
            // headers
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-SF_AD_OIDC_TOKEN', tokenVal);
            for (Continuation_Callout_Header__c header : calloutConfig.Continuation_Callout_Headers__r) {
                request.setHeader(header.Key__c, header.Value__c);
            }
            if (String.isNotBlank(calloutConfig.BodyTemplate__c)) {
                request.setBody(String.format(calloutConfig.BodyTemplate__c, parameters));
            }
            
            continuation.state = si;
            continuation.addHttpRequest(request);
            result = continuation;
        }
        
        return result;
        }
        catch (Exception err) {
            throw new AuraHandledException('Could not get date range: ' + err.getMessage());
        }
    }
    /**
    * @name: getCachedValue
    * @description retrieves Token
    * @param N/A
    * @return Object
    */    
    @AuraEnabled
    public static String getCachedValue() {
        try {
            String inputTime = String.valueOf(Cache.Org.get('local.SFToken.inputTime'));
            if(Cache.Org.get('local.SFToken.accessToken') == null || String.isEmpty(inputTime)){  
                Cache.Org.put('local.SFToken.accessToken',getAzureToken()); 
                Cache.Org.put('local.SFToken.inputTime',DateTime.now());       
            } else if(inputTime != null && DateTime.now() > DateTime.valueOfGmt(inputTime).addSeconds(3599)) {
                Cache.Org.put('local.SFToken.accessToken',getAzureToken()); 
                Cache.Org.put('local.SFToken.inputTime',DateTime.now());   
            }
            String tokenVal = String.valueOf(Cache.Org.get('local.SFToken.accessToken'));
            return tokenVal;
        }
        catch (Exception err) {
            throw new AuraHandledException('Could not retrieve cached value: ' + err.getMessage());
        }
    }
    
    /**
    * @name: getAzureToken
    * @description retrieves Azure access token using Azure Callout
    * @param N/A
    * @return access token
    */ 
    @AuraEnabled
    public static String getAzureToken() {
        try{
        Map<String,CS_SFScopeStorage__c> allScope = CS_SFScopeStorage__c.getAll();
        String scope = allScope.get('DevScope').Scope__c;
        HttpRequest req = new HttpRequest();
        http h = new http();
        req.setMethod('POST');
        req.setEndpoint('callout:SFAzure');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String payload = 'grant_type='+EncodingUtil.urlEncode('client_credentials','UTF-8')+'&scope='+EncodingUtil.urlEncode(scope,'UTF-8');
        req.setBody(payload);
        httpresponse response = h.send(req);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getbody());
        string accessToken = (string) m.get('access_token'); 
        return accessToken;
        }
        catch (Exception err) {
            throw new AuraHandledException('Could not retrieve Azure token value: ' + err.getMessage());
        }
    }
    
    /**
    * @name processCalloutResponse
    * @description returns processed callout response
    * @param labels
    * @param state
    * @return Object
    */
    @AuraEnabled
    public static Object processCalloutResponse(List<String> labels, Object state) {
        try{
        StateInfo si = (StateInfo)state;
        HttpResponse response = Continuation.getResponse(labels[0]);
        
        CalloutResponse result = new CalloutResponse();
        result.statusCode = response.getStatusCode();
        result.body = response.getBody();
        
        if (si.timeToLive != 0) {
            // save in cache
            Cache.Org.getPartition(ContinuationCalloutLwcBase.CACHE_PARTITION).put(si.hashKey, result, si.timeToLive);
        }
        
        return result;
    }
    catch (Exception err) {
            throw new AuraHandledException('Could not process Callout Response: ' + err.getMessage());
        }
    }
      
}
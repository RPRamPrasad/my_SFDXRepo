/**
* @name NBA_JoesiCallout
* @author Team Skynet
* @createDate 02/01/2022
* @description This Apex class make an callout to Azure AD to get the access token and pass the access token in header then makes a
* callout to JOESI API for Next Best Action feedback API
*/
public with sharing class NBA_JoesiCallout {

    private static final String CLASS_NAME = 'NBA_JoesiCallout';
    private static final String METHOD_NAME = 'getJoesiNBACallout';
    private static final String METHOD_TYPE ='POST';
    private static final String CALLOUT_SFAZURENBA ='callout:SFAzureNBA';
    private static final String CALLOUT_JOESIAPI ='callout:JoesiAPI';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String AZURE_JSON_TYPE ='application/x-www-form-urlencoded';
    private static final String JSON_TYPE ='application/json';
    private static final String DEV_SCOPE ='DevScope';
    private static final String ACCESS_TOKEN ='access_token';
    private static final String CACHE_TOKEN ='local.NBAAzureToken.accessToken';
    private static final String CACHE_TOKEN_TIME ='local.NBAAzureToken.inputTime';
    private static final String OIDC_TOKEN = 'X-SF_AD_OIDC_TOKEN';
    private static final String FORWARD_SLASH = '/';
    private static final String FEEDBACK_ENDPOINT = '/recommendations/feedback';
    private static final String CONTAINER_NAME = 'ECRM';
    private static final String JOESI_TYPE = 'recommendations_pega';
    private static final String ACCEPT = 'Accept';
    private static final String DECLINE = 'Decline';
    private static final String SUCCESSFUL = 'Successful';

    @TestVisible private NBA_JoesiCallout(){}

    /**
    * @name: FlowInputs
    * @description Input class for the Future callout method
    */
    public with sharing class FlowInputs {
        @InvocableVariable (label='isRecommendationAccepted' description='Value determining if recommendation was accepted')
        public Boolean isRecommendationAccepted;

        @InvocableVariable (label='sfRecommendationId' description='ID of the custom recommendation record')
        public String sfRecommendationId;

    }

    /**
    * @name: calloutAzureToken
    * @description retrieves Azure access token using Azure AD Callout
    * @param N/A
    * @return access token
    */
    public static String calloutAzureToken() {
        String accessToken = null;
        Map<String,CS_SFScopeStorage__c> allScope = CS_SFScopeStorage__c.getAll();
        String scope = allScope.get(DEV_SCOPE).Scope__c;
        HttpRequest request = new HttpRequest();
        http h = new http();
        request.setMethod(METHOD_TYPE);
        request.setEndpoint(CALLOUT_SFAZURENBA);
        request.setHeader(CONTENT_TYPE, AZURE_JSON_TYPE);
        String payload = 'grant_type='+EncodingUtil.urlEncode('client_credentials','UTF-8')+'&scope='+EncodingUtil.urlEncode(scope,'UTF-8');
        request.setBody(payload);
        HttpResponse response = h.send(request);
        Map<String, Object> mapJson = (Map<String, Object>) JSON.deserializeUntyped(response.getbody());
        accessToken = (String) mapJson.get(ACCESS_TOKEN);
        return accessToken;
    }

    /**
    * @name: getAzureTokenFromCache
    * @description retrieves Token from cache or sets to cache if token expired
    * @param N/A
    * @return tokenValue string
    */
    public static String getAzureTokenFromCache() {
        String inputTime = String.valueOf(Cache.Org.get(CACHE_TOKEN_TIME));
        if(Cache.Org.get(CACHE_TOKEN) == null) {
            Cache.Org.put(CACHE_TOKEN,calloutAzureToken());
            Cache.Org.put(CACHE_TOKEN_TIME,DateTime.now());
        } else if(inputTime != null && DateTime.now() > DateTime.valueOfGmt(inputTime).addSeconds(3599)) {
            Cache.Org.put(CACHE_TOKEN,calloutAzureToken());
            Cache.Org.put(CACHE_TOKEN_TIME,DateTime.now());
        }
        //String tokenValue = String.valueOf(Cache.Org.get(CACHE_TOKEN));

        return String.valueOf(Cache.Org.get(CACHE_TOKEN));
    }

    /**
    * @name: invokeJoesiNBAFeedback
    * @description Invokable method for NBA_Feedback_Subflow
    * @param flowInputs from flow
    */
    @InvocableMethod(label ='InvokeNBA Joesi Feedback call' description='Call Joesi Feedback endpoint')
    public static void invokeJoesiNBAFeedback(List<FlowInputs> flowInputs) {

        Boolean isRecommendationAccepted = false;
        String sfRecommendationId = '';

        if (!flowInputs.isEmpty()) {
            isRecommendationAccepted = flowInputs.get(0).isRecommendationAccepted;
            sfRecommendationId = flowInputs.get(0).sfRecommendationId;
        }

        getJoesiNBACallout(isRecommendationAccepted, sfRecommendationId);
    }

    /**
    * @name: getJoesiNBACallout
    * @description Future callout method to call the JOESI Feedback API
    * @param isRecommendationAccepted whether the recommendation is accepted or rejected
    * @param sfRecommendationId the id of the custom recommendation
    */
    @future(callout = true)
    public static void getJoesiNBACallout(Boolean isRecommendationAccepted, String sfRecommendationId) {

        // Query the SF Custom Recommendation object using the id
        List<SFCustomRecommendation__c> recommendations = Security.stripInaccessible(AccessType.READABLE,
                                                        [SELECT Id, EIID__c, Account__r.ClientIdentifier__c, External_Interaction_ID__c,
                                                         Rank__c, Direction__c, Channel__c, Status__c, Treatment__c, Action_ID__c,
                                                         Recommendation__r.Group__c, Recommendation__r.Issue__c, Recommendation__r.Name
                                                         FROM SFCustomRecommendation__c
                                                         WHERE Id =: sfRecommendationId]).getRecords();

        SFCustomRecommendation__c recommendation;

        try {
            if (recommendations.isEmpty() == false) {
                recommendation = recommendations.get(0);
            } else {
                throw new HandledException('No recommendation was found for ' + sfRecommendationId);
            }

            processJoesiCallout(isRecommendationAccepted, recommendation);
            List<SFCustomRecommendation__c> recommendationsToUpdate = new List<SFCustomRecommendation__c>();
            SFCustomRecommendation__c recordToUpdate = new SFCustomRecommendation__c();
            recordToUpdate.Id = recommendation.Id;
            recordToUpdate.FeedbackAPICalloutSuccess__c = SUCCESSFUL;
            recommendationsToUpdate.add(recordToUpdate);
            List<Database.SaveResult> recommendationSaveResults = Database.update(Security.stripInaccessible(AccessType.UPDATABLE, recommendationsToUpdate, true).getRecords(), false);
            LoggingService.logDatabaseResult(recommendationSaveResults, recommendationsToUpdate, CLASS_NAME, 'processJoesiCallout', LoggingLevel.ERROR);

        } catch (HandledException ex){
            LoggingService.logHandledException(ex, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
        } catch (Exception exp) {
            String eiid = recommendation.EIID__c;
            reinvocateJoesiCallout(recommendation, isRecommendationAccepted,eiid);
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
        }
    }

    /**
    * @name: reinvocateJoesiCallout
    * @description Callout method to retry a failed call to the JOESI Feedback API
    * @param recommendation the referenced recommendation object
    * @param isRecommendationAccepted the accepted status of the referenced recommendation
    * @param eiid the id of rec obj.
    */
    public static void reinvocateJoesiCallout (SFCustomRecommendation__c recommendation, Boolean isRecommendationAccepted, String eiid) {
        System.enqueueJob(new NBA_JoesiFeedbackQueuable(1, recommendation, isRecommendationAccepted));
    }

    /**
    * @name: processJoesiCallout
    * @description calls the method from a batchable class
    * @param isRecommendationAccepted whether the recommendation is accepted or rejected
    * @param recommendation the custom recommendation
    */
    public static void processJoesiCallout(Boolean isRecommendationAccepted, SFCustomRecommendation__c recommendation) {
        String clientId;
        clientId = recommendation.Account__r.ClientIdentifier__c;
        String eiid = recommendation.EIID__c;
        HttpResponse response = callJoesiFeedback(recommendation, isRecommendationAccepted, eiid);

        if (response.getStatusCode() != 200) {
            //Logging an exception for Invalid response code on JOESI Feedback Callout.
            throw new CalloutException('Status: ' + response.getStatusCode() + ' Response:' + response.getBody() + ' ClientId: ' + clientId + ' EIID: ' + recommendation.EIID__c +
                                        ' ActionID:' + recommendation.Action_ID__c);
        }
    }

     /**
    * @name: callJoesiFeedback
    * @description calls the JOESI api with feedback data
    * @param recommendation the custom recommendation
    * @param isRecommendationAccepted whether the recommendation is accepted or rejected
    * @param eiid eiid of the recommendation
    * @return response - HttpResponse
    */
    @TestVisible
    public static HttpResponse callJoesiFeedback(SFCustomRecommendation__c recommendation, Boolean isRecommendationAccepted, String eiid) {

        HttpRequest request = new HttpRequest();
        request.setMethod(METHOD_TYPE);
        request.setEndpoint(CALLOUT_JOESIAPI + FORWARD_SLASH + eiid + FEEDBACK_ENDPOINT);
        request.setHeader(CONTENT_TYPE, JSON_TYPE);
       	request.setHeader(OIDC_TOKEN, getAzureTokenFromCache());
        String clientId = recommendation.Account__r.ClientIdentifier__c;
        request.setBody(buildJSONPayload(recommendation, isRecommendationAccepted, clientId));
        Http http = new Http();
        //HttpResponse response = http.send(request);

        return http.send(request);
    }

    private static String buildJSONPayload(SFCustomRecommendation__c recommendation, Boolean isRecommendationAccepted, String clientId) {
        NBA_JoesiFeedbackRequest request = new NBA_JoesiFeedbackRequest();
        List<NBA_JoesiCallout.Data> dataList = new List<NBA_JoesiCallout.Data>();
        NBA_JoesiCallout.Data data = new NBA_JoesiCallout.Data();
        NBA_JoesiCallout.Attributes attributes = new NBA_JoesiCallout.Attributes();
        List<NBA_JoesiCallout.RankedResults> results = new List<NBA_JoesiCallout.RankedResults>();
        NBA_JoesiCallout.RankedResults rankedResult = new NBA_JoesiCallout.RankedResults();
        String recommendationOutcome = DECLINE;

        rankedResult.SubjectID = clientId;
        rankedResult.Name = recommendation.Recommendation__r.Name;
        rankedResult.Issue = recommendation.Recommendation__r.Issue__c;
        rankedResult.nbaGroup = recommendation.Recommendation__r.Group__c;
        rankedResult.InteractionID = recommendation.External_Interaction_ID__c;
        rankedResult.Rank = Decimal.valueOf(String.valueOf(recommendation.Rank__c));
        rankedResult.Direction = recommendation.Direction__c;
        rankedResult.Channel = recommendation.Channel__c;

        if (isRecommendationAccepted) {
            recommendationOutcome = ACCEPT;
        }
        rankedResult.Outcome = recommendationOutcome;
        rankedResult.Treatment = recommendation.Treatment__c;
        rankedResult.ActionID = recommendation.Action_ID__c;

        results.add(rankedResult);

        attributes.ContainerName = CONTAINER_NAME;
        attributes.SubjectID = clientId;
        attributes.RankedResults = results;

        data.type = JOESI_TYPE;
        data.attributes = attributes;
        dataList.add(data);

        request.data = dataList;
        String jsonRequest = JSON.serialize(request);

        // Replacing nbaGroup data element with reserved word Group
        jsonRequest = jsonRequest.replaceAll('"nbaGroup":', '"Group":');

        return jsonRequest;
    }

    /**
    * @name: NBA_JoesiFeedbackRequest
    * @description JSON serializable class for wrapping the data array
    */
    public with sharing class NBA_JoesiFeedbackRequest {
        public List<Data> data;
    }

    /**
    * @name: Data
    * @description JSON serializable class for wrapping the Attributes and type
    */
    public with sharing class Data {
        public String type;
        public Attributes attributes;
    }

    /**
    * @name: Attributes
    * @description JSON serializable class for wrapping the RankedResults
    */
    public with sharing class Attributes {
        public String ContainerName;
        public String SubjectID;
        public List<RankedResults> RankedResults;
    }

    /**
    * @name: RankedResults
    * @description JSON serializable class for the elements of RankedResults
    */
    public with sharing class RankedResults {
        public String SubjectID;
        public String Name;
        public String Issue;
        public String nbaGroup;
        public String InteractionID;
        public Decimal Rank;
        public String Direction;
        public String Channel;
        public String Outcome;
        public String Treatment;
        public String ActionID;

    }

}

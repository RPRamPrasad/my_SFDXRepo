/**
 * @description This class will process the InsightWrapper
 */
public with sharing class InsightWrapper{

    /**
     * @description This getters and setters method will process the insightList
     */
    @AuraEnabled
    public List<Insight_Indicator__mdt> insightList {get;set;}

    /**
     * @description This getters and setters method will process the claimMapList
     */
    @AuraEnabled
    public Map<string,String> claimMapList {get;set;}

    /**
     * @description This getters and setters method will process the pastDueMapList
     */
    @AuraEnabled
    public Map<string,String> pastDueMapList {get;set;}
   }
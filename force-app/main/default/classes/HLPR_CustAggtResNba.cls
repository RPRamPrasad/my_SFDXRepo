/**
 * @name HLPR_CustAggtResNba
 * @description This is a helper class to build NBA recommendations from the JOESI response recived via aggregator
 * @author Team: Stark
 * @createdDate 11/22/2021
 * @modifiedDate 11/22/2021
 */
public with sharing class HLPR_CustAggtResNba {
    private static final String CLASS_NAME = 'HLPR_CustAggtResNba';
    private static final String METHOD_NAME = 'buildSFCustomRecommendations';

    /**
     * @name buildNbaRecommendations
     * @description Populate NBA recommendations from JOESI response
     * @param custAggtRes
     */
    public static void buildSFCustomRecommendations(AP_CustAggtRes custAggtRes) {
        List<SFCustomRecommendation__c> sfCustomRecommentations = new List<SFCustomRecommendation__c>();
        if(custAggtRes.data.nbaResponse != null) {
            for(AP_CustAggtRes.cls_nbaResults  nbaResult : custAggtRes.data.nbaResponse.data[0].attributes.ContainerList[0].RankedResults) {
                NBA_RecommendationBuilder nbaRankedResult = new NBA_RecommendationBuilder();
                nbaRankedResult.setAccountId(custAggtRes.data.nbaResponse.data[0].attributes.salesforce.salesforce_account_id);
                // nbaRankedResult.setAgentOfficeUserId(null); // Team Skynet will query
                nbaRankedResult.setServicingAgentAssociateId(custAggtRes.data.nbaResponse.data[0].attributes.salesforce.associate_id_agent);
                nbaRankedResult.setContextType(custAggtRes.data.nbaResponse.data[0].attributes.context_type);
                nbaRankedResult.setExternalClientId(custAggtRes.data.clientId);
                nbaRankedResult.setEnterpriseInteractionId(custAggtRes.data.nbaResponse.data[0].attributes.interaction_id);
                nbaRankedResult.setPropensity(nbaResult.Propensity);
                nbaRankedResult.setActionGroup(nbaResult.NBAGroup);
                nbaRankedResult.setActionIssue(nbaResult.Issue);
                nbaRankedResult.setActionCategory(nbaResult.Category);
                nbaRankedResult.setExternalInteractionID(nbaResult.InteractionID);
                nbaRankedResult.setPriority(nbaResult.Priority);
                nbaRankedResult.setChannel(nbaResult.Channel);
                nbaRankedResult.setActionLabel(nbaResult.Label);
                nbaRankedResult.setRank(nbaResult.Rank);
                nbaRankedResult.setDirection(nbaResult.Direction);
                nbaRankedResult.setActionName(nbaResult.Name);
                nbaRankedResult.setActionVariant(nbaResult.Variant);
                nbaRankedResult.setTreatment(nbaResult.Treatment);
                nbaRankedResult.setPlacement(nbaResult.Placement);
                nbaRankedResult.setActionId(nbaResult.ActionID);
                nbaRankedResult.setActionIdText(nbaResult.Identifier);
                //  nbaRankedResult.setIdentifier();
                nbaRankedResult.setPriority(nbaResult.Placement);
                // nbaRankedResult.setSubjectId();
                nbaRankedResult.setDecisionTime(nbaResult.DecisionTime);

                SFCustomRecommendation__c rec = new SFCustomRecommendation__c(); 
                rec = nbaRankedResult.build();
                sfCustomRecommentations.add(rec);
            }
        }
        try {
            if(!sfCustomRecommentations.isEmpty()){
                NBA_RecommendationService.saveRecommendations(sfCustomRecommentations);
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('saveSFCustomRecommendations Error: ' + e.getMessage());
        }
    }
}
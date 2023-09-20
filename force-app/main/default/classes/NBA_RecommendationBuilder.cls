/**
* @description NBA_RecommendationBuilder will help build SF Custom Recommendation object.
*/
public with sharing class NBA_RecommendationBuilder {

    private static final String STATUS_NEW = 'New';

    private String accountId;
    private String agentOfficeUserId;
    private String servicingAgentAssociateId;
    private String contextType;

    //NBA Response Data
    private String enterpriseInteractionId;
    private NBA_RankedResult rankedResult;

    /**
     * @description NBA_RecommendationBuilder Constructor
     */
    public NBA_RecommendationBuilder() {
        this.rankedResult = new NBA_RankedResult();
    }

    private with sharing class NBA_RankedResult{

        private String propensity;
        private String externalInteractionID;
        private String priority;
        private String channel;
        private Integer rank;
        private String direction;
        private String treatment;
        private String placement;
        private String externalClientId;
        private String decisionTime;
        private NBA_ActionData actionData;

        private NBA_RankedResult(){
            this.actionData = new NBA_ActionData();
        }
    }

    private with sharing class NBA_ActionData{

        private String actionID;
        private String actionGroup;
        private String actionIssue;
        private String actionCategory;
        private String actionLabel;
        private String actionName;
        private String actionVariant;
        private String actionIdText;
    }

    /**
     * @description set Account Id
     * @param accountId
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setAccountId(String accountId){
        this.accountId = accountId;
        return this;
    }

    /**
     * @description set agentOfficeUserId
     * @param agentOfficeUserId
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setAgentOfficeUserId(String agentOfficeUserId){
        this.agentOfficeUserId = agentOfficeUserId;
        return this;
    }

    /**
     * @description set servicingAgentAssociateId
     * @param servicingAgentAssociateId
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setServicingAgentAssociateId(String servicingAgentAssociateId){
        this.servicingAgentAssociateId = servicingAgentAssociateId;
        return this;
    }

    /**
     * @description set contextType
     * @param contextType
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setContextType(String contextType){
        this.contextType = contextType;
        return this;
    }

    /**
     * @description set enterpriseInteractionId
     * @param enterpriseInteractionId
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setEnterpriseInteractionId(String enterpriseInteractionId){
        this.enterpriseInteractionId = enterpriseInteractionId;
        return this;
    }


    /**
     * @description set propensity
     * @param propensity
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setPropensity(String propensity){
        this.rankedResult.propensity = propensity;
        return this;
    }

    /**
     * @description set externalInteractionID
     * @param externalInteractionID
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setExternalInteractionID(String externalInteractionID){
        this.rankedResult.externalInteractionID = externalInteractionID;
        return this;
    }

    /**
     * @description set priority
     * @param priority
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setPriority(String priority){
        this.rankedResult.priority = priority;
        return this;
    }

    /**
     * @description set channel
     * @param channel
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setChannel(String channel){
        this.rankedResult.channel = channel;
        return this;
    }

    /**
     * @description set rank
     * @param rank
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setRank(String rank){
        this.rankedResult.rank = Integer.valueOf(rank);
        return this;
    }

    /**
     * @description set direction
     * @param direction
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setDirection(String direction){
        this.rankedResult.direction = direction;
        return this;
    }

    /**
     * @description set treatment
     * @param treatment
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setTreatment(String treatment){
        this.rankedResult.treatment = treatment;
        return this;
    }

    /**
     * @description set placement
     * @param placement
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setPlacement(String placement){
        this.rankedResult.placement = placement;
        return this;
    }

    /**
     * @description set externalClientId
     * @param externalClientId
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setExternalClientId(String externalClientId){
        this.rankedResult.externalClientId = externalClientId;
        return this;
    }

    /**
     * @description set decisionTime
     * @param decisionTime
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setDecisionTime(String decisionTime){
        this.rankedResult.decisionTime = decisionTime;
        return this;
    }

    /**
     * @description set actionID
     * @param actionID
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionID(String actionID){
        this.rankedResult.actionData.actionID = actionID;
        return this;
    }

    /**
     * @description set nbaGroup
     * @param actionGroup
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionGroup(String actionGroup){
        this.rankedResult.actionData.actionGroup = actionGroup;
        return this;
    }

    /**
     * @description set issue
     * @param actionIssue
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionIssue(String actionIssue){
        this.rankedResult.actionData.actionIssue = actionIssue;
        return this;
    }

    /**
     * @description set category
     * @param actionCategory
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionCategory(String actionCategory){
        this.rankedResult.actionData.actionCategory = actionCategory;
        return this;
    }

    /**
     * @description set label
     * @param actionLabel
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionLabel(String actionLabel){
        this.rankedResult.actionData.actionLabel = actionLabel;
        return this;
    }

    /**
     * @description set name
     * @param actionName
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionName(String actionName){
        this.rankedResult.actionData.actionName = actionName;
        return this;
    }

    /**
     * @description set variant
     * @param actionVariant
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionVariant(String actionVariant){
        this.rankedResult.actionData.actionVariant = actionVariant;
        return this;
    }

    /**
     * @description set identifier
     * @param actionIdText
     * @return NBA_RecommendationBuilder
     */
    public NBA_RecommendationBuilder setActionIdText(String actionIdText){
        this.rankedResult.actionData.actionIdText = actionIdText;
        return this;
    }

    /**
     * @description build custom recommendation object record
     * @return SFCustomRecommendation__c
     */
    public SFCustomRecommendation__c build(){
        SFCustomRecommendation__c recommendation = new SFCustomRecommendation__c();
        recommendation.Account__c = this.accountId;

        if (!String.isBlank(this.agentOfficeUserId)) {
            recommendation.OwnerId = this.agentOfficeUserId;
        } else {
            recommendation.OwnerId = UserInfo.getUserId();
        }

        if(!String.isBlank(this.servicingAgentAssociateId)){
            recommendation.Servicing_Agent_Associate_ID__c = this.servicingAgentAssociateId;
        }

        recommendation.Channel__c = this.rankedResult.channel;
        recommendation.Direction__c = this.rankedResult.direction;
        recommendation.EIID__c = this.enterpriseInteractionId;
        recommendation.External_Interaction_ID__c = this.rankedResult.externalInteractionID;
        recommendation.Propensity__c = this.rankedResult.propensity;
        recommendation.Rank__c = this.rankedResult.rank;
        recommendation.Status__c = STATUS_NEW;
        recommendation.Action_ID__c = this.rankedResult.actionData.actionID;
        recommendation.Treatment__c = this.rankedResult.treatment;
        recommendation.Context_Type__c = this.contextType;

        return recommendation;
    }

}
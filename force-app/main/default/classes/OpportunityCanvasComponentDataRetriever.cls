/** 
@Author Team AKITA
@Name OpportunityCanvasComponentDataRetriever
@CreateDate 07/15/2021  
@description something goes here
@Version 3.2
Copyright © StateFarm  
*/
public with sharing class OpportunityCanvasComponentDataRetriever {
    /**
    * @description Queries fields from the opp
    * @param recordId
    * @return opp with fields
    */
    public static List<Opportunity> oppQuery(Id recordId) {
        return Security.stripInaccessible(
           AccessType.READABLE,
            [SELECT Id, AccountId, Account.ClientIdentifier__c, Account.IsHealthSourced__pc, LOB__c, OwnerId, Requested_Effective_Date__c, Owner.Servicing_Agent_Associate_ID__c, Product_System_Name__c, StageName, State_Code__c
             FROM Opportunity WHERE Id = :recordId
             AND IsQuoteCanvasable__c = true]
        ).getRecords();
    }

    /**
    * @description Queries all opps for a given Account
    * @param primaryOpp
    * @return list of opps with fields
    */
    public static List<Opportunity> oppsForAccountQuery(Opportunity primaryOpp) {
        return Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, AccountId, Account.ClientIdentifier__c, LOB__c, OwnerId, Requested_Effective_Date__c, Owner.Servicing_Agent_Associate_ID__c, Product_System_Name__c, State_Code__c FROM Opportunity 
                WHERE AccountId IN (SELECT Id FROM Account WHERE Id =: primaryOpp.AccountId) 
                AND StageName !='Closed' AND StageName !='Closed Won' AND IsQuoteCanvasable__c = true AND Id NOT IN (:primaryOpp.Id) 
                AND OwnerId =: primaryOpp.OwnerId ORDER BY Id LIMIT 485]
        ).getRecords();
    }

    /**
    * @description Queries fields from the logged in user
    * @return user with fields
    */
    public static List<User> loggedInUsrQuery() {
        return Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,Associate_ID__c,SubUserType__c,State_Agent_Code__c FROM User WHERE Id =: UserInfo.getUserId()]
        ).getRecords();
    }

    /**
    * @description Queries fields from the agentContext
    * @param agentContextIdentifier
    * @return agentContext with fields
    */
    public static List<AgentContext__c> agentContextQuery(String agentContextIdentifier) {
        return Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT InteractionId__c,AgentContextIdentifier__c FROM AgentContext__c WHERE AgentContextIdentifier__c =:agentContextIdentifier]
        ).getRecords();
    }

    /**
    * @description Queries fields for opp owner
    * @param opp
    * @return user with fields
    */
    public static List<User> oppOwnerQuery(List<Opportunity> opp) {
        String agentExternalID = opp[0].Owner.Servicing_Agent_Associate_ID__c + '_' + opp[0].Owner.Servicing_Agent_Associate_ID__c;
        return Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT State_Agent_Code_List__c, Associate_ID__c FROM User WHERE UserExternalID__c =: agentExternalID AND isActive = TRUE]
        ).getRecords();
    }


    /**
     * @description helper method that gets the productSystemName for a given opp
     * @param opp
     * @return String productSystemName
     */
    public static String getProductSystemName(Opportunity opp) {
        String productSystemName = null;
        if (String.isNotBlank(opp.Product_System_Name__c)) {
            productSystemName = opp.Product_System_Name__c;
        }
        return productSystemName;
    }

    /**
     * @description helper method that gets the clientIdList for a given opp
     * @param opp
     * @return String clientIdList
     */
    public static List<String> getClientIdList(Opportunity opp) {
        List<String> clientIdList = new List<String>();

        LinkBean canvasLinkBean = new LinkBean();
        canvasLinkBean = LWC_LinkBuilderExtension.setIdentifiedCustomerAccount(opp.AccountId, canvasLinkBean);

        clientIdList = LWC_LinkBuilderExtension.retrieveFSCHouseholdClientIds(canvasLinkBean).split(',');
       
        return clientIdList;
    }
    
    /**
    * @description Method to get the lobCode
    * @param opp
    * @return string lobCode
    */
    public static String getlobCode(Opportunity opp){
        String lobCode;
        
        switch on opp.LOB__c {
            when 'Auto' { lobCode = 'A';}
            when 'Fire' {lobCode = 'F';} 
            /**commenting out until future work makes these LOBs canvasable 
            when 'Life' {lobCode = 'L';}
            when 'Health' { lobCode = 'H';}      
            when 'Bank' {lobCode = 'B';}       
            when 'Mutual Funds' {lobCode = 'MF';} **/
        }
        return lobCode;
    }
}
/**
* @description Posts New ILP Messages to Chatter and Skype through the LeadVendor
* Message Service and ILP_Opportunity_Stage_Management_Unclaim FLOW (Dream Builders).
* TEST CLASS: UTIL_OpportunityNotificationManager_TEST
* @author Team Opptimizers 
*/  
public without sharing class UTIL_OpportunityNotificationManager {    

    private static final String CHATTER_GROUP_API_NAME = 'NewHotProspectNotifications-';  

    /**
     * @description postOppNotifications
     * @param opportunityId 
     */
    @InvocableMethod 
    public static void postOppNotifications(List<String> opportunityId) {

        if(!opportunityId.isEmpty()){            
            List<Opportunity> opp = Security.stripInaccessible(
                AccessType.READABLE, 
                [SELECT id, AccountId, LOB__c, OwnerId, Opportunity_Originator__c, Assigned_To__c, StageName, Marketing_Source__c, Marketing_Sub_Source__c, Temperature__c FROM Opportunity WHERE id =: opportunityId.get(0) LIMIT 1])
                .getRecords();

            List<User> proxy = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Servicing_Agent_External_ID__c, Servicing_Agent_Associate_ID__c FROM User WHERE id =: opp[0].OwnerId LIMIT 1])
                .getRecords();

            List<User> agentUser = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT id, Servicing_Agent_External_ID__c, Alias FROM User WHERE UserExternalid__c =:proxy[0].Servicing_Agent_External_ID__c LIMIT 1])
                .getRecords();

           OppNotificationSender.sendOppNotifications(opp[0], agentUser[0]);
        }  
    }

    /**
     * @description getChatterGroup
     * @param agentTiedToOpp 
     * @return  `List<CollaborationGroup>`
     */
    public static List<CollaborationGroup> getChatterGroup(User agentTiedToOpp) {
        
        List<CollaborationGroup> retVal = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id FROM CollaborationGroup WHERE Name =: CHATTER_GROUP_API_NAME + agentTiedToOpp.Alias AND OwnerId = :agentTiedToOpp.Id LIMIT 1]) 
            .getRecords(); 
        
        return retVal;
    }

    /**
     * @description getChatterMemberIds
     * @param chatterGroupId 
     * @return  `List<Id>`
     */
    public static List<Id> getChatterMemberIds(Id chatterGroupId) { 

        List<Id> retVal = new List<Id>();
        
        List<CollaborationGroupMember> collabGroupMembers = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId =: chatterGroupId]) 
            .getRecords(); 

        for(CollaborationGroupMember cgm : collabGroupMembers){
            retVal.add(cgm.MemberId);
        }
        return retVal;
    }

    /**
     * @description getChatterGroupMemberEmails
     * @param chatterGroupMemberIds 
     * @return  `Map<Id, String>`
     */
     public static Map<Id, String> getChatterGroupMemberEmails(List<Id> chatterGroupMemberIds){

        Map<Id, String> retVal = new Map<Id, String>();
        
        List<User> groupMembers = Security.stripInaccessible(
            AccessType.READABLE, [SELECT id, email FROM User WHERE id IN: chatterGroupMemberIds AND Email != null])
            .getRecords(); 

        for(User user : groupMembers) {
            retVal.put(user.Id, user.Email);
        }
        return retVal;
    }

    /**
     * @description getEmailsToRecieveSkype
     * @param eligibleForNotifications 
     * @param opp 
     * @param preferences 
     * @return  `Set<String>`
     */
    public static Set<String> getEmailsToRecieveSkype(List<Id> eligibleForNotifications, Opportunity opp, Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> preferences) {
        
        Set<String> retVal = new Set<String>();
        Map<Id, String> emailsEligibleForNotification = getChatterGroupMemberEmails(eligibleForNotifications);
        
        //see if anyone has Skype set to true
        for(Id key : preferences.keySet()) {
            OppNotificationPreferenceRetriever.EmailSkypePreference pref = preferences.get(key);
            String email = emailsEligibleForNotification.get(key);

            if(pref.shouldSendSkypeNotification()){
                    retVal.add(email);  
            }
        }
        return retVal;
    }

    /**
     * @description getUsersToBeMentioned
     * @param preferences 
     * @return  `List<Id>`
     */
    public static List<Id> getUsersToBeMentioned(Map<Id, OppNotificationPreferenceRetriever.EmailSkypePreference> preferences) {

        List<Id> retVal = new List<Id>();

        for(Id key : preferences.keySet()){
            OppNotificationPreferenceRetriever.EmailSkypePreference pref = preferences.get(key);
            if(pref.shouldSendEmailNotification()) {
                retVal.add(key); //user Ids for those to be @mentioned in collab group chatter posts
            }
        }
        return retVal;
    }
}
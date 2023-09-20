/**
*  @Author : Golden Spikes Team
*  @Date Created : 06/19/2016
*  @description This class will prevent deletion of Chatter Group, if there is no Group Feed Item for Agent and Business Support users.
*/
public without sharing class AP_PreventChatterGroupDelete {

    /**
    * @description This method will prevent deletion of Chatter Group, if there is no Group Feed Item.
    * @param chatterGroupList The calling method passes a list of CollaborationGroup records.
    */
    public static void preventChatterGroupDelete(List<CollaborationGroup> chatterGroupList) {
        List<Id> chatterGroupIdList = new List<Id>();
        Set<Id> hasGroupFeedItemSet = new Set<Id>();

        for(CollaborationGroup chGroup: chatterGroupList) {
            chatterGroupIdList.add(chGroup.id);
        }

        for(AggregateResult groupFeedItem: [Select ParentId from CollaborationGroupFeed where ParentId in: chatterGroupIdList
                                            group by ParentId]) {
            hasGroupFeedItemSet.add((Id) groupFeedItem.get('ParentId'));
        }

        if(hasGroupFeedItemSet != null && !hasGroupFeedItemSet.isEmpty()) {
            for(CollaborationGroup deleteChatterGroup: chatterGroupList) {
                if(hasGroupFeedItemSet.contains(deleteChatterGroup.id)) {
                    deleteChatterGroup.addError(Label.CL_ChatterGroup_Prevent_Delete_Message);
                }
            }
        }
    }
}
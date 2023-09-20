@isTest
public with sharing class OppNotificationChatterSender_TEST {

    private static final String CHATTER_GROUP_NAME = 'NewHotProspectNotifications-potato123'; 

    @isTest
    private static void chatterMsgPostedToGroupUsingConnectApi() {
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name = CHATTER_GROUP_NAME;
        chatterGroup.CollaborationType = 'Private';
        insert chatterGroup;

        Id chatterGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = :CHATTER_GROUP_NAME LIMIT 1].Id;
        Integer postCountBeforeInsert = [SELECT count() FROM FeedItem WHERE ParentId =: chatterGroupId];

        List<Id> groupMembers = new List<Id>();
        List<CollaborationGroupMember> cgmRecords = [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId =: chatterGroupId];
        
        for(CollaborationGroupMember cgm : cgmRecords){
            groupMembers.add(cgm.MemberId);
        }

        Map<String, String> chatterMessageProperties = new Map<String, String>();
        chatterMessageProperties.put('title','Look at me, I am the Title!');
        chatterMessageProperties.put('chatterMessage', 'Look at me, I am the chatter message');
        chatterMessageProperties.put('redirectURL', 'https://www.statefarm.com');

        Test.startTest();
        OppNotificationChatterSender.postFeedCollabGroup(chatterGroupId, chatterMessageProperties, groupMembers);
        Test.stopTest();
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem WHERE ParentId =: chatterGroupId];
        Integer expectedChatterPostCount = postCountBeforeInsert;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'Should be one chatter post for the whole chatter group'); 
    }
    
    @isTest
    private static void chatterMsgPostedToGroup() {
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name = CHATTER_GROUP_NAME;
        chatterGroup.CollaborationType = 'Private';
        insert chatterGroup;

        Id chatterGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = :CHATTER_GROUP_NAME LIMIT 1].Id;
        Integer postCountBeforeInsert = [SELECT count() FROM FeedItem WHERE ParentId =: chatterGroupId];

        List<Id> groupMembers = new List<Id>();

        Map<String, String> chatterMessageProperties = new Map<String, String>();
        chatterMessageProperties.put('title','Look at me, I am the Title!');
        chatterMessageProperties.put('chatterMessage', 'Look at me, I am the chatter message');
        chatterMessageProperties.put('redirectURL', 'https://www.statefarm.com');

        Test.startTest();
        OppNotificationChatterSender.postFeedCollabGroup(chatterGroupId, chatterMessageProperties, groupMembers);
        Test.stopTest();
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem WHERE ParentId =: chatterGroupId];
        Integer expectedChatterPostCount = postCountBeforeInsert + 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'Should be one chatter post for the whole chatter group'); 
    }

    // test to see if ILP Chatter Message was inserted for the assigned user
    @isTest
    private static void chatterMsgPostedToAssigned() {

        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name = CHATTER_GROUP_NAME;
        chatterGroup.CollaborationType = 'Private';
        insert chatterGroup;

        Id chatterGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = :CHATTER_GROUP_NAME LIMIT 1].Id;
        Id mockAssignedUserId = [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId =: chatterGroupId LIMIT 1].MemberId;
        Integer postCountBeforeInsert = [SELECT count() FROM FeedItem WHERE ParentId =: mockAssignedUserId];

        List<Id> groupMembers = new List<Id>();
        List<CollaborationGroupMember> cgmRecords = [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId =: chatterGroupId];
        
        for(CollaborationGroupMember cgm : cgmRecords){
            groupMembers.add(cgm.MemberId);
        }

        Map<String, String> chatterMessageProperties = new Map<String, String>();
        chatterMessageProperties.put('title','Look at me, I am the Title!');
        chatterMessageProperties.put('chatterMessage', 'Look at me, I am the chatter message');
        chatterMessageProperties.put('redirectURL', 'https://www.statefarm.com');

        Test.startTest();
        OppNotificationChatterSender.postFeedAssignedTo(mockAssignedUserId, chatterMessageProperties);
        Test.stopTest();
        
        Integer actualCountOfChatterPosts = [SELECT count() FROM FeedItem WHERE ParentId =: mockAssignedUserId];
        Integer expectedChatterPostCount = postCountBeforeInsert + 1;
        System.assertEquals(expectedChatterPostCount, actualCountOfChatterPosts, 'Should be one chatter post for assigned user');        
    }
}

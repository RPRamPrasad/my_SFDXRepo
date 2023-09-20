/**
 * @name LaunchMeetingNotesController
 * @author Team Octonauts
 * @description This class is used when creating a Notes for Simple Conversation meeting on Event record page
 */

public with sharing class LaunchMeetingNotesController {
    @AuraEnabled
    /**
     * @description getLaunchMeetingNotesData
     * @return NotesDataWrapper
     * @param eventId
     */ 
    public static NotesDataWrapper getLaunchMeetingNotesData(String eventId){
        try {
            NotesDataWrapper wrapObj = new NotesDataWrapper();
            wrapObj.notesData = getLaunchMeetingNotes(eventId);
            wrapObj.userData = getUserData();
            Event eventData = new Event();
            List<Event> eventDataList = Security.stripInaccessible(AccessType.READABLE,[Select Id,Subject,Meeting_Name__c from Event where Id=:eventId WITH SECURITY_ENFORCED]).getRecords();
            wrapObj.eventData = eventDataList[0];
            return wrapObj;//Description__c
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description getLaunchMeetingNotes
     * @return List<LaunchMeeting_Note__c>
     * @param eventId
     */
    public static List<LaunchMeeting_Note__c> getLaunchMeetingNotes(String eventId) {
        List<LaunchMeeting_Note__c> notesDataList = new List<LaunchMeeting_Note__c>();
        notesDataList = Security.stripInaccessible(AccessType.READABLE,[
            SELECT Id, Comments__c, CreatedBy.Name, CreatedDate
            FROM LaunchMeeting_Note__c 
            WHERE EventId__c=:eventId WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ]).getRecords();
        return notesDataList;
    }
    /**
     * @description getUserData
     * @return User
     */
    public static User getUserData() {
        List<User> userData = new List<User>();
        userData = Security.stripInaccessible(AccessType.READABLE,[Select Id,Name from User where Id =:userInfo.getUserId() WITH SECURITY_ENFORCED]).getRecords();   
        return userData[0];
    }
    //Wrapper Class
    /**
     * @description NotesDataWrapper
     */
    public class NotesDataWrapper{
        @AuraEnabled
        /**
          * @description notesData
          * @return List<LaunchMeeting_Note__c>
          */
        public List<LaunchMeeting_Note__c> notesData{get;set;}
        @AuraEnabled
        /**
          * @description userData
          * @return User
          */
        public User userData{get;set;}
        @AuraEnabled
        /**
          * @description eventData
          * @return Event
          */
        public Event eventData{get;set;}
    }
}
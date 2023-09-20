/**
 * @name LaunchMeetingController
 * @author Team Octonauts
 * @description This class is used when creating a meeting on Simple Conversation tab on Account record page
 */

 public with sharing class LaunchMeetingController {
    static final String TOEMAILADDRESS = 'toEmailAddress';
	static final String SUBJECT = 'subject';
    static final String STARTDATETIME = 'startDateTime';
    static final String METHOD = 'method';
    static final String BR_TAG = '<br>';
    @AuraEnabled
    /**
     * @description createdEventRecord
     * @return Event 
     * @param eventData
     */
    public static Event createdEventRecord(Event eventData){
        try {
            Event eventObj = new Event();
            eventData.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Create Meeting').getRecordTypeId();
            eventData.Subject = 'Simple Conversation Meeting';
            eventData.Action_Source__c = 'Launch Meeting';
            List<Account> accDetails = new List<Account>();
            accDetails = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Name from Account where Id=:eventData.WhatId WITH SECURITY_ENFORCED]).getRecords();
            
            User userData = getUserData(eventData);
            eventData.Meeting_Name__c = eventData.Meeting_Location__c + ' - ' + accDetails[0].Name;
            if (Event.getSObjectType().getDescribe().isAccessible() == false) {
                throw new DmlException('No permissions to create.');
            }
            List<SObject> eventsData = new List<SObject>{eventData};
            SObjectAccessDecision dec = Security.stripInaccessible(AccessType.CREATABLE, eventsData);
            Database.insert(eventsData = dec.getRecords());
            eventObj = (Event)eventsData[0];
            //insert Security.stripInaccessible(AccessType.CREATABLE, new List<Event>{eventData}).getRecords();
            sendMeetingInviteHelper(userData, eventObj, accDetails[0].Name+'__REQUEST');
            return eventObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }
    private static void sendMeetingInviteHelper(User userData, Event eventData, String requestType) {
        List<String> splitParams = requestType.split('__');
        Map<String,String> meetingInfo = new Map<String,String>();
        meetingInfo.put(TOEMAILADDRESS,userData.Email);
        meetingInfo.put('conductedByName',userData.FirstName + ' ' + userData.LastName);
        meetingInfo.put(SUBJECT,eventData.Meeting_Name__c);                
        meetingInfo.put(STARTDATETIME,eventData.StartDateTime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
        meetingInfo.put('endDateTime',eventData.EndDateTime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
        meetingInfo.put('startDateTimeRaw',String.valueof(eventData.StartDateTime));
        meetingInfo.put('endDateTimeRaw',String.valueof(eventData.EndDateTime));
        meetingInfo.put('accountName',splitParams[0]);
        meetingInfo.put('uid',eventData.Id);
        meetingInfo.put(METHOD,splitParams[1]);
        sendMeetingInvite(meetingInfo);
    }
    @AuraEnabled
    /**
     * @description reScheduleInvite
     * @return Event
     * @param eventData
     */
    public static Event reScheduleInvite(Event eventData){
        try {
            List<Account> accDetails = new List<Account>();
            accDetails = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Name from Account where Id=:eventData.WhatId WITH SECURITY_ENFORCED]).getRecords();
            User userData = getUserData(eventData);
            eventData.Meeting_Name__c = eventData.Meeting_Location__c + ' - ' + accDetails[0].Name;
            if (Event.getSObjectType().getDescribe().isAccessible() == false) {
                throw new DmlException('No permissions to update.');
            }
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Event>{eventData}).getRecords();
            sendMeetingInviteHelper(userData, eventData, accDetails[0].Name+'__REQUEST');
            return eventData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }
    @AuraEnabled
    /**
     * @description cancelInvite
     * @return Event
     * @param eventData
     */
    public static Event cancelInvite(Event eventData){
        try {
            List<Account> accDetails = new List<Account>();
            accDetails = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Name from Account where Id=:eventData.WhatId WITH SECURITY_ENFORCED]).getRecords();
            
            User userData = getUserData(eventData);
            eventData.Meeting_Name__c = eventData.Meeting_Location__c + ' - ' + accDetails[0].Name;   
            sendMeetingInviteHelper(userData, eventData, accDetails[0].Name+'__CANCEL');
            if (Event.getSObjectType().getDescribe().isAccessible() == false) {
                throw new DmlException('No permissions to update.');
            }
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Event>{eventData}).getRecords();
            return eventData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }
    @AuraEnabled
    /**
     * @description completeInvite
     * @return Event
     * @param eventData
     */
    public static Event completeInvite(Event eventData){
        try {
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Event>{eventData}).getRecords();     
            return eventData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }
    @AuraEnabled
    /**
     * @description getAccountEvents
     * @return AccountEventsWrapper
     * @param recordId
     */
    public static AccountEventsWrapper getAccountEvents(String recordId){
        try {
            AccountEventsWrapper accEventWrapperObj = new AccountEventsWrapper();
            List<Event> allEvents = Security.stripInaccessible(AccessType.READABLE,[
                SELECT Id, EndDateTime, StartDateTime, Meeting_Location__c, Meeting_Name__c, Owner.Name, OwnerId, Meeting_Status__c
                FROM Event
                Where WhatId = :recordId AND Action_Source__c = 'Launch Meeting' WITH SECURITY_ENFORCED
                ORDER BY StartDateTime asc 
            ]).getRecords();
            accEventWrapperObj.eventsData = allEvents;
            /*Map<String,LaunchMeeting_Note__c> allEventNotesMap = new Map<String,LaunchMeeting_Note__c>();
            Set<Id> eventIds = new Set<Id>();
            for (Event eachEvent : allEvents) {
                eventIds.add(eachEvent.Id);
            }
            if (!eventIds.isEmpty()) {
                allEventNotesMap = getEventNotesByEventId(eventIds);
                accEventWrapperObj.eventsNotes = allEventNotesMap.values();
                
            }*/
            accEventWrapperObj.eventsColumns = eventsColumns;
            accEventWrapperObj.locationOptions = locationOptions;
            accEventWrapperObj.loggedInUserDetails = loggedInUserDetails;
            accEventWrapperObj.accountDetails = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Name from Account where Id=:recordId WITH SECURITY_ENFORCED]).getRecords();
            return accEventWrapperObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }
    /**
     * @description eventsColumns
     * @return String
     */
    public static String eventsColumns {
        get{ 
        	return '[{"label":"Meeting Name","fieldName":"MeetingUrl","type":"url","sortable":true,"initialWidth":180,'+
                '"typeAttributes":{"label":{"fieldName":"Meeting_Name__c"}}},{"label":"Meeting Status","typeAttributes":{"context":{"fieldName":"Id"}},"cellAttributes": {"class": "meeting-status-drop"},"fieldName":"Meeting_Status__c","type":"dropdownColumn",'+
                '"hideDefaultActions":true,"sortable":true,"initialWidth":150},{"label":"Start Date/Time",'+
                '"fieldName":"StartDateTime","type":"date","hideDefaultActions":true,"sortable":true,"initialWidth":180,'+
                '"typeAttributes":{"day":"numeric","month":"numeric","year":"numeric","hour":"2-digit","minute":"2-digit",'+
                '"hour12":true}},{"label":"End Date/Time","fieldName":"EndDateTime","type":"date","hideDefaultActions":true,"sortable":true,'+
                '"initialWidth":180,"typeAttributes":{"day":"numeric","month":"numeric","year":"numeric","hour":"2-digit","minute":"2-digit",'+
                '"hour12":true}},{"label":"Conducted By","fieldName":"ConductedByUrl","type":"url",'+
                '"sortable":true,"initialWidth":180,"typeAttributes":{"label":{"fieldName":"ConductedByName"}}}]';
        }
    }
    /**
     * @description locationOptions
     * @return String
     */
    public static String locationOptions {
        get{ 
        	return '[{ "label": "Agent Office", "value": "Agent Office" },{ "label": "Customer Home/Office", "value": "Customer Home/Office" },'+
                '{ "label": "Phone", "value": "Phone" },{ "label": "Other Location", "value": "Other Location" }]';
        }
    }
    /**
     * @description loggedInUserDetails
     * @return User
     */
    public static User loggedInUserDetails {
        get {
            List<User> userData = new List<User>();
            userData = Security.stripInaccessible(AccessType.READABLE,[Select Id,Servicing_Agent_Associate_ID__c from User where Id =:userInfo.getUserId() WITH SECURITY_ENFORCED]).getRecords();   
            return userData[0]; 
        }
    }
    private static User getUserData(Event eventData) {
        List<User> userData = new List<User>();
        userData = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, FirstName, LastName, Email from User Where Id = :eventData.OwnerId WITH SECURITY_ENFORCED]).getRecords();   
        return userData[0];
    }
    /*private static Map<String,LaunchMeeting_Note__c> getEventNotesByEventId(Set<Id> eventIds) {
        Map<String,LaunchMeeting_Note__c> allEventNotesMap = new Map<String,LaunchMeeting_Note__c>();
        List<LaunchMeeting_Note__c> allMeetingNotes = new List<LaunchMeeting_Note__c>();
        allMeetingNotes = Security.stripInaccessible(AccessType.READABLE,[
            SELECT Id, Comments__c, CreatedBy.Name, CreatedDate, EventId__c
            FROM LaunchMeeting_Note__c 
            WHERE EventId__c IN :eventIds WITH SECURITY_ENFORCED
            ORDER BY EventId__c, CreatedDate DESC
        ]).getRecords();        
        for (LaunchMeeting_Note__c eachEvnetNote : allMeetingNotes) {
            if (!allEventNotesMap.containsKey(eachEvnetNote.EventId__c)) {
                allEventNotesMap.put(eachEvnetNote.EventId__c,eachEvnetNote);
            }
        }
        return allEventNotesMap;
    }
    /**
     * @description AccountEventsWrapper
     */
    public class AccountEventsWrapper {
        @AuraEnabled
        public List<Event> eventsData = new List<Event>();
        /*@AuraEnabled
        public List<LaunchMeeting_Note__c> eventsNotes = new List<LaunchMeeting_Note__c>();*/
        @AuraEnabled
        public String eventsColumns;
        @AuraEnabled
        public String locationOptions;
        @AuraEnabled
        public User loggedInUserDetails;
        @AuraEnabled
        public List<Account> accountDetails = new List<Account>();
    }
    private static void sendMeetingInvite(Map<String, String> meetingInfo) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{meetingInfo.get(TOEMAILADDRESS)});
        
        String convertedStartDate = DateTime.valueOf(meetingInfo.get('startDateTimeRaw')).format('EEEEE, MMMMMM dd, yyyy @ hh:mm a z');
        String hyperLinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + meetingInfo.get('uid');
        //String hyperLinkAoc = system.Label.CL_SIMPLE_CONV_EMAIL_SUBJECT;
    
        if(meetingInfo.get(METHOD) == 'CANCEL') {
            mail.setSubject('Canceled: '+meetingInfo.get(SUBJECT));
            mail.setHtmlBody('<div style="font-family: Arial, Helvetica, sans-serif;"> '+'<a href="'+hyperLinkUrl+'">Simple Conversation</a>'+' appointment with '+ meetingInfo.get('accountName') +' on <b>' + convertedStartDate + '</b>'+ ' has been moved to a status of' + '<b>' + 'Canceled/No Show' + '</b>' +BR_TAG + BR_TAG +'Consider creating a Task to follow up to reschedule the Simple Conversation appointment.');
        } else {
            mail.setSubject(meetingInfo.get(SUBJECT));
            mail.setHtmlBody('<div style="font-family: Arial, Helvetica, sans-serif;"> '+'<a href="'+hyperLinkUrl+'">Simple Conversation</a>'+' appointment is scheduled with '+ meetingInfo.get('accountName') +' on <b>' + convertedStartDate + '</b>'+BR_TAG +'Reminder: Consider sending Email '+'<a href="">(U667)</a>'+' Planning Conversation Tool: Appointment Confirmation' +BR_TAG+BR_TAG+meetingInfo.get('conductedByName') + BR_TAG + meetingInfo.get(TOEMAILADDRESS) + BR_TAG);
        }
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.filename = 'reminder.ics';
        attach.ContentType = 'text/calendar; charset=utf-8; method=' + meetingInfo.get(METHOD);
        attach.inline = true;
        attach.body = invite(meetingInfo);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
        Messaging.sendEmailResult[] er;
        er = Messaging.sendEmail(new Messaging.Email[] { mail });
    }

    private static Blob invite(Map<String,String> meetingInfo) {
        String txtInvite = '';
        txtInvite +='BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Microsoft Corporation//Outlook MIMEDIR//eN\n';
        txtInvite += 'VERSION:1.0\n';
        txtInvite += 'METHOD:' +meetingInfo.get(METHOD)+'\n';
        txtInvite += 'CALSCALE:GREGORIAN \n';
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'CLASS:PUBLIC\n';
        txtInvite += 'CREATED:' +meetingInfo.get(STARTDATETIME)+'\n';
        txtInvite += 'DTSTAMP:' +meetingInfo.get(STARTDATETIME)+'\n';
        txtInvite += 'DTSTART:' +meetingInfo.get(STARTDATETIME)+'\n';
        txtInvite += 'DTEND:' +meetingInfo.get('endDateTime')+'\n';
        txtInvite += 'ATTENDEE:' +meetingInfo.get(TOEMAILADDRESS)+'\n';
        txtInvite += 'LAST-MODIFIED:' +meetingInfo.get(STARTDATETIME)+'\n';
        txtInvite += 'LOCATION:US\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'SUMMARY;';
        txtInvite += 'LANGUAGE=en-us:' +meetingInfo.get(SUBJECT) + '\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'UID:' +meetingInfo.get('uid') + '\n';
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY><div style="font-family: Arial, Helvetica, sans-serif;"></div></BODY></HTML>\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANTCE:1\n';
        if(meetingInfo.get(METHOD).equalsIgnoreCase('CANCEL')) {
            txtInvite += 'STATUS:CANCLLED\n';
        }
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        return Blob.valueOf(txtInvite);
    }
}
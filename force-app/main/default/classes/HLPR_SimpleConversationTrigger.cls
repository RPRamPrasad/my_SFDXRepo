/**
@Author: Team Octonauts
@Name: HLPR_SimpleConversationTrigger
@CreateDate: 12/24/2020
@description This class is used has a Helper for SimpleConversationAfterInsert
Copyright © StateFarm
*/

public with sharing class HLPR_SimpleConversationTrigger {

    private static final String CLASS_NAME = 'HLPR_SimpleConversationTrigger';
    private static final String GNC_SENDINVITEMETHOD = 'sendCalendarEmail';
    private static final String PROCESS_ID = 'SF_CRM_CLIENTPORTALROUTER';

    /**
     * @description method to create virtual meeting
     * @param simpleConvo
     */
    public static void createVirtualMeeting(List<SimpleConversation__c> simpleConvo){
        try {
            List<Account> accList = Security.stripInaccessible(AccessType.READABLE,[Select Id, Name,ClientIdentifier__c from Account where Id = :simpleConvo[0].Account__c]).getRecords();
            UTIL_GoodNeighborConnect.VirtualMeetingAttributes attr = new UTIL_GoodNeighborConnect.VirtualMeetingAttributes();
            //Host for the virtual meeting
            attr.meetingHost = simpleConvo[0].ConductedBy__c;
            //Pass Meeting purpose value from Simple Conversation Type
            attr.meetingPurpose = simpleConvo[0].SimpleConversationType__c + ' ' + '-' + ' ' +  accList[0].Name + ' ' + '-' + ' ' +  simpleConvo[0].Appointment_Location__c; 
            //Meeting start time
            attr.startDateTime = simpleConvo[0].AppointmentStartDateTime__c;
            // Meeting end time 
            attr.endDateTime = simpleConvo[0].AppointmentEndDateTime__c; 
            //Method to call virtual meeting API for 1-click meeting creation
            if (simpleConvo[0].Appointment_Location__c == 'Virtual Meeting') {
                UTIL_GoodNeighborConnect.createVirtualMeeting(attr,simpleConvo[0].id);
            }
            else{
                sendCalendarEmail(simpleConvo);
            }
        } catch(Exception simpleConvoException) {
            LoggingService.logHandledException(simpleConvoException, CLASS_NAME, 'createVirtualMeeting', System.LoggingLevel.ERROR);
        }
    }

     /**
    * @description Method to send an outlook calendar invite.
    * @param simpleConvList
    */
    public static void sendCalendarEmail(List<SimpleConversation__c> simpleConvList) {
        try {
            User userRecord = getUserDetails();
            if(userRecord.Name != PROCESS_ID && simpleConvList[0].IsSendToOutlook__c == true && simpleConvList[0].AppointmentStartDateTime__c > System.now() && simpleConvList[0].AppointmentEndDateTime__c > System.now()) {
                List<String> calendarInfo = getCalendarInfo(simpleConvList);
                List<String> clientIdList = new List<String>{'5TPP18FJKAL','J1DRR9LY4AK','MQMG89V06AK'};
                    if(!clientIdList.contains(calendarInfo[8])){
                        sendInvite(calendarInfo);
                    }
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, GNC_SENDINVITEMETHOD, System.LoggingLevel.ERROR);
        }
    }

     /**
    * @description Method to send an outlook calendar invite when initiated through quick action.
    * @param simpleConvList
    */
    public static void sendCalendarEmailQuickAction(List<SimpleConversation__c> simpleConvList) {
        try {
            List<String> calendarInfo = getCalendarInfo(simpleConvList);
            List<String> clientIdList = new List<String>{'5TPP18FJKAL','J1DRR9LY4AK','MQMG89V06AK'};
                if(!clientIdList.contains(calendarInfo[8])){
                    sendInvite(calendarInfo);
                }

        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, GNC_SENDINVITEMETHOD, System.LoggingLevel.ERROR);
        }
    }



    /**
    * @description helper method to get user details
    * @return userList
    */
    private static User getUserDetails(){
        List<User> userList = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,Name,Email,Phone FROM User WHERE Id = :userInfo.getUserId() Limit 1]).getRecords();
        return userList[0];
    }

    /**
    * @description helper method to get Conducted By user details
    * @param conductedBy
    * @return userList
    */

    private static User getConductedByUserDetails(Id conductedBy){
        List<User> userList = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id,Name,Email,Phone FROM User WHERE Id = :conductedBy Limit 1]).getRecords();
        return userList[0];
    }


     /**
    * @description helper method to get CalendarInfo
    * @param simpleConvList
    * @return calendarInfo
    */
    private static List<String> getCalendarInfo(List<SimpleConversation__c> simpleConvList){
        List<String> calendarInfo = new List<String>();
        List<Account> accList = Security.stripInaccessible(AccessType.READABLE,[Select Id, Name,ClientIdentifier__c from Account where Id = :simpleConvList[0].Account__c]).getRecords();
        //Meeting Purpose
        calendarInfo.add(simpleConvList[0].SimpleConversationType__c + ' ' + '-' + ' ' +  accList[0].Name + ' '  +  '-' + ' ' +  simpleConvList[0].Appointment_Location__c);
        //Meeting Start Time
        calendarInfo.add(String.valueof(simpleConvList[0].AppointmentStartDateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));
        //Meeting End Time
        calendarInfo.add(String.valueof(simpleConvList[0].AppointmentEndDateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));
        //MeetingID
        calendarInfo.add(simpleConvList[0].Id);
        //Invite Method

        if(simpleConvList[0].Status__c.equals('Customer Cancelled')) {
            calendarInfo.add('CANCEL');
        } else {
            calendarInfo.add('REQUEST');
        }

        //Receipient Email
        User conductedByUser = getConductedByUserDetails(simpleConvList[0].ConductedBy__c);
        calendarInfo.add(conductedByUser.Email);

        //Agent Name for Signature
        calendarInfo.add(conductedByUser.Name);
        //Account Name
        calendarInfo.add(accList[0].Name);
        //ClientIdentifier
        calendarInfo.add(accList[0].ClientIdentifier__c);

        return calendarInfo;
    }

    /**
    * @description Method to send an outlook calendar invite.
    * @param theDateTime
    * @return theDateTime
    */
    private static String convertDateTime(String theDateTime){
        // converting to UTC for Outlook
        String theDateAndTime = theDateTime;
        theDateAndTime = theDateAndTime.replace('-','');
        theDateAndTime = theDateAndTime.replace(':','');
        theDateAndTime = theDateAndTime.replace('.000','');
        return theDateAndTime;
    }

    /**
    * @description Method to send an outlook calendar invite.
    * @param calendarInfo
    */
    private static void sendInvite(List<String>calendarInfo) {

        String sMeetingPurpose = calendarInfo[0];
        String startTime = calendarInfo[1];
        String endTime = calendarInfo[2];
        String sUID = calendarInfo[3]; //Meeting ID
        String sMethod = calendarInfo[4];
        String emailAddress = calendarInfo[5];

        List<String> calendarInviteInfo = new List<String>();
        calendarInviteInfo.add(convertDateTime(startTime));
        calendarInviteInfo.add(convertDateTime(endTime));
        calendarInviteInfo.add(sUID);
        calendarInviteInfo.add(emailAddress);
        calendarInviteInfo.add(sMethod);
        calendarInviteInfo.add(sMeetingPurpose);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{emailAddress});

        Datetime dt1 = Datetime.valueofgmt(String.valueOf(startTime).replace('T',' ').replace('Z',''));
        String convertedStartDate = dt1.format('EEEEE, MMMMM dd, yyyy @ hh:mm a z');
        String hyperLinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sUID;
        String hyperLinkAoc = system.Label.CL_SIMPLE_CONV_EMAIL_SUBJECT;
        //mail.setHtmlBody('<div style="font-family: Arial, Helvetica, sans-serif;"> '+'<a href="'+hyperLinkUrl+'">
        //Simple Conversation</a>'+' appointment is scheduled with '+ calendarInfo[7] +' on <b>' + convertedStartDate + 
        //'</b><br>' +'Reminder: Consider sending Email '+'<a href="'+hyperLinkAoc+'">(U667)</a>'+' 
        //Planning Conversation Tool: Appointment Confirmation' +'<br>'+'<br>'+ calendarInfo[6] + '<br>' + 
        //calendarInfo[5] + '<br>');
        if(sMethod == 'CANCEL') {
            mail.setSubject('Canceled: '+sMeetingPurpose);
            mail.setHtmlBody('<div style="font-family: Arial, Helvetica, sans-serif;"> '+'<a href="'+hyperLinkUrl+'">Simple Conversation</a>'+' appointment with '+ calendarInfo[7] +' on <b>' + convertedStartDate + '</b>'+ ' has been moved to a status of' + '<b>' + ' Canceled/No Show' + '</b>' +'<br>' + '<br>' +'Consider creating a Task to follow up to reschedule the Simple Conversation appointment.');
        } else {
            mail.setSubject(sMeetingPurpose);
            mail.setHtmlBody('<div style="font-family: Arial, Helvetica, sans-serif;"> '+'<a href="'+hyperLinkUrl+'">Simple Conversation</a>'+' appointment is scheduled with '+ calendarInfo[7] +' on <b>' + convertedStartDate + '</b><br>' +'Reminder: Consider sending Email '+'<a href="'+hyperLinkAoc+'">(U667)</a>'+' Planning Conversation Tool: Appointment Confirmation' +'<br>'+'<br>'+ calendarInfo[6] + '<br>' + calendarInfo[5] + '<br>');
        }
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.filename = 'reminder.ics';
        attach.ContentType = 'text/calendar; charset=utf-8; method=' + sMethod;
        attach.inline = true;
        attach.body = invite(calendarInviteInfo);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
        Messaging.SendEmailResult[] er;
        er = Messaging.sendEmail(new Messaging.Email[] { mail });
    }

    //helper method to return the calendar invite string
    private static Blob invite(List<string>calendarInviteInfo) {

        String startTime = calendarInviteInfo[0];
        String endTime = calendarInviteInfo[1];
        String sUID = calendarInviteInfo[2];
        String emailAddress = calendarInviteInfo[3];
        String sMethod = calendarInviteInfo[4];
        String meetingPurpose = calendarInviteInfo[5];
        String txtInvite = '';
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Microsoft Corporation//Outlook MIMEDIR//EN\n';
        txtInvite += 'VERSION:1.0\n';
        txtInvite += 'METHOD:'+sMethod+'\n';
        txtInvite += 'CALSCALE:GREGORIAN \n';
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'CLASS:PUBLIC\n';
        txtInvite += 'CREATED:'+startTime+'\n';
        txtInvite += 'DTSTAMP:'+startTime+'\n';
        txtInvite += 'DTSTART:'+startTime+'\n';
        txtInvite += 'DTEND:'+endTime+'\n';
        txtInvite += 'ATTENDEE:'+emailAddress+'\n';
        txtInvite += 'LAST-MODIFIED:'+startTime+'\n';
        txtInvite += 'LOCATION:US\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'SUMMARY;';
        txtInvite += 'LANGUAGE=en-us:' + meetingPurpose + '\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'UID:'+sUID + '\n';
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY><div style="font-family: Arial, Helvetica, sans-serif;"></div></BODY></HTML>\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
        if(sMethod.equalsIgnoreCase('CANCEL')) {
            txtInvite += 'STATUS:CANCELLED\n';
        }
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        return Blob.valueOf(txtInvite);
    }

}

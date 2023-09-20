/****************************************************************************************
Name: HLPR_CampMailerCostNotifications
=========================================================================================
* @description : Helper class for AP_CampMailerCostNotifications apex class used to form 
                 Html email body and send notifications
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  04/27/2020             Initial Development
2.0             ClubCar                  05/17/2020             Added logic to create html table and send notifications after Start Journey Operation
******************************************************************************************/ 
public with sharing class HLPR_CampMailerCostNotifications {
    
    private static AP_CampMailerCostNotifications.EmailDataWrapper emailData;
    private static final String TDOPEN = '<td align="center">';
    private static final String TDCLOSE = '</td>';
    private static final String LEGENDSTARSTRING = '<font color="red">*</font>';
    private static final String HTMLTABLEFONTCOLOR = '<font color="gray">'; 
    private static final String EMAILHTMLTABLEHEADERBORDER = '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
    private static final String EMAILHTMLTABLEHEADER = '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th> </tr>';
    private static final String DIRECTMAILSTARTEDMESSAGE = 'The following Mail has been started on a Campaign';
    private static final String TROPEN = '<tr>';
    private static final String TRCLOSE = '</tr>';
    private static Decimal totalNumberMembers;
    
    /**
    * @method- Invoked by  AP_CampMailerCostNotifications Class           
    * @description  This method will helps us to form the email body with required campaign message details
    *               and fetch the users who have performed the operation and send the email notifications as required
    * @name  sendEmailNotifications
    * @param  emailDataWrapper - wrapper class with required data from AP_CampMailerCostNotifications Class
    * @param  notificationType - string to identifiy if the method is called from order/upload lead operation or oneoff operation
    */
    public static void sendEmailNotifications(AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper, String notificationType){
        emailData = emailDataWrapper;
        List<Messaging.singleEmailMessage> emailMessages = singleEmailMessageList(notificationType);        
        if(!emailMessages.isEmpty()){
             Messaging.sendEmail(emailMessages);
        }
    }
    
    //Helper method to form email message and add to messages list
    private static List<Messaging.singleEmailMessage> singleEmailMessageList(String notificationType){
        List<Messaging.singleEmailMessage> emailMessages = new List<Messaging.singleEmailMessage>();
        
        for(Id campaignId : emailData.campIdToCampMap.keySet()){
            if((!emailData.campIdToCampaignMessageListMap.get(campaignId).isEmpty() || notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)) && totalCampaignMemberCount(campaignId) > 0){
                Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();                
                emailMessage = setCcEmailAddresses(emailMessage,notificationType,campaignId);
                emailMessage.setToAddresses(new List<String>{emailData.campIdToAgentEmailMap.get(campaignId)});                   
                emailMessage.setSubject(System.Label.CL_CAMP_MAILER_SUBJECT);                
                emailMessage.setSenderDisplayName(System.Label.CL_CAMP_MAILER_SENDERNAME);
                emailMessage.setHtmlBody(getEmailHtmlBody(campaignId,notificationType));
                emailMessages.add(emailMessage);
            }
        }
        return emailMessages;
    }
    
    //Helper method get total number of members
    private static Decimal totalCampaignMemberCount(Id campaignId){
        totalNumberMembers = emailData.campIdToCampMap.get(campaignId).Total_Number_Members__c;
        return totalNumberMembers;
    }
    
    //Helper method to get email addresses for email message
    private static Messaging.singleEmailMessage setCcEmailAddresses(Messaging.singleEmailMessage emailMessage,String notificationType,Id campaignId){        
        if(notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS)){                    
            return emailMessage;
        }
        String agentEmailAddress = emailData.campIdToAgentEmailMap.get(campaignId);
        String ccEmailAddress = emailData.campIdToInitiatedOrLstModfdUserMap.get(campaignId).Email;
        List<String> toCcEmailAddresses = (ccEmailAddress != agentEmailAddress) ? new List<String>{ccEmailAddress} : new List<String>();
        if(!toCcEmailAddresses.isEmpty()){
            emailMessage.setCcAddresses(toCcEmailAddresses);
        }
        return emailMessage ;
    }
    
    //Helper method to form complete Email Body
    private static string getEmailHtmlBody(Id campaignId,String notificationType){
        String htmlBody = '';
        htmlBody += getHtmlTableHeader(campaignId,notificationType);
        htmlBody += getHtmlTableBody(campaignId,notificationType);        
        htmlBody += getCampaignUrlAndLegend(campaignId);
        return htmlBody;
    }    
    
    //Helper method to get Html table header
    private static string getHtmlTableHeader(Id campaignId, String notificationType){
        String headingOpen = '<h3>';
        String headingClose = '</h3>';
        String htmlTableHeader = '';
        htmlTableHeader += HTMLTABLEFONTCOLOR;
        if(notificationType != AP_CampMailerCostNotifications.NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS){
            htmlTableHeader += headingOpen+DIRECTMAILSTARTEDMESSAGE+' by '+emailData.campIdToInitiatedOrLstModfdUserMap.get(campaignId).Name+headingClose;
        }
        else{
            htmlTableHeader += headingOpen+DIRECTMAILSTARTEDMESSAGE+headingClose;
        }
        htmlTableHeader += '<br />' + 'Number of Campaign Members: '+ totalNumberMembers;
        htmlTableHeader += EMAILHTMLTABLEHEADERBORDER;
        htmlTableHeader += '<td colspan="6"><b>'+emailData.campIdToCampMap.get(campaignId).Name+'</b></td> </tr>';
        htmlTableHeader += EMAILHTMLTABLEHEADER;            
        return htmlTableHeader; 
    }
    
    //Helper method to check notification type and get Html Table Body
    private static String getHtmlTableBody(Id campaignId, String notificationType){
        String htmlTableBody = '';
        if(notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)){
            htmlTableBody = getHtmlTableBodyForStartJourneyNotifications(campaignId);
        }
        else{
            htmlTableBody = getHtmlTableBodyForOneOffOrLeadNotifications(campaignId,notificationType);
        }
        return htmlTableBody;
    }
    
    //Helper to get Html Table Body for start journey notifications
    private static String getHtmlTableBodyForStartJourneyNotifications(Id campaignId){
        String htmlTableBody = '';
        Double totalCost = 0.00;
        List<CampaignMessage__c> campMessageList = emailData.campIdToCampaignMessageListMap.get(campaignId);
        List<Journey_Step__c> jrnyStepList = emailData.campIdToJrnyStepListMap.get(campaignId);
        Date journeyStartDate = emailData.campIdToCampMap.get(campaignId).Journey_Start_Date__c;
        List<EmailObjectWrapper> campMessageAndJrnyStepRecs = getSortedCampMessagesAndJrnyStepRecs(campMessageList,jrnyStepList,journeyStartDate);
        for(Journey_Step__c jrnyStep : jrnyStepList){
            totalCost = totalCost + Double.valueOf(jrnyStep.Cost__c);
        }
        htmlTableBody += getCampMessageAndJrnyStepHtmlTableData(campMessageAndJrnyStepRecs);
        htmlTableBody += getTotalCost(totalCost,campaignId);
        return htmlTableBody;        
    }
    
    //Helper method to get Html Table Body for one off or lead notifications
    private static String getHtmlTableBodyForOneOffOrLeadNotifications(Id campaignId, String notificationType){
        String htmlTableBody = '';
        Double totalCost = 0.00;        
        Boolean isLeadNotificatons = notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_LEADNOTIFICATIONS);
        List<CampaignMessage__c> campMessageList = emailData.campIdToCampaignMessageListMap.get(campaignId);        
        for(CampaignMessage__c campaignMessage : campMessageList){
            String starString = '';
            if((isLeadNotificatons && campaignMessage.JourneyID__c !=null) || 
               (!isLeadNotificatons && campaignMessage.Id.equals(emailData.campIdToCampaignMessageMap.get(campaignMessage.Campaign__c).Id))){
                   totalCost = totalCost + Double.valueOf(campaignMessage.Cost__c);
                   starString = LEGENDSTARSTRING;
               }
            htmlTableBody += getCampMessageHtmlTableData(campaignMessage,starString);  
        }
        
        htmlTableBody += getTotalCost(totalCost,campaignId);
        return htmlTableBody;
    }
    
    //Helper method to get total cost row in html table
    private static String getTotalCost(Double totalCost, Id campaignId){
        Double total_Cost = totalCost;
        String totalCostRow = '';
        total_Cost = (total_Cost*totalNumberMembers).setscale(2);      
        totalCostRow += +TROPEN+TDOPEN+'<b>TOTAL COST:</b>'+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+'$'+total_Cost+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+TDCLOSE+'</table>';
        return totalCostRow;
    }
    
    //Helper method to perform journey step and campaign message html table calculations
    private static String getCampMessageAndJrnyStepHtmlTableData(List<EmailObjectWrapper> campMessageAndJrnyStepRecs){
        String htmlTableData = '';
        for(EmailObjectWrapper campMessOrJrnyStep : campMessageAndJrnyStepRecs){
            String starString = campMessOrJrnyStep.campMessOrJrnyStepRecord.getSObjectType() != campaignMessage__c.getSObjectType()?'<font color="red">*</font>':''; 
            String estimatedDate = DateTime.newInstance(campMessOrJrnyStep.estimatedDate.year(), campMessOrJrnyStep.estimatedDate.month(),campMessOrJrnyStep.estimatedDate.day()).format('MM/dd/yy');
            htmlTableData += TROPEN +
                +TDOPEN + starString + estimatedDate + TDCLOSE +
                TDOPEN + (campMessOrJrnyStep.campMessOrJrnyStepRecord.get('JourneyId__c') != null ? campMessOrJrnyStep.campMessOrJrnyStepRecord.get('JourneyName__c') : 'Single Mailer') + TDCLOSE +
                TDOPEN + (campMessOrJrnyStep.campMessOrJrnyStepRecord.get('MailClassCode__c').equals('1') ? '1st Class' : '3rd Class') + TDCLOSE +            
                TDOPEN + '$'+campMessOrJrnyStep.campMessOrJrnyStepRecord.get('cost__c') + TDCLOSE +
                TDOPEN +  campMessOrJrnyStep.campMessOrJrnyStepRecord.get('Itemid__c') + TDCLOSE +
                TDOPEN + (campMessOrJrnyStep.campMessOrJrnyStepRecord.getSObjectType() == campaignMessage__c.getSObjectType() ? campMessOrJrnyStep.campMessOrJrnyStepRecord.get('Status__c') : 'Scheduled') + TDCLOSE +                 
                TRCLOSE;
        }
        return htmlTableData;
    }
    
    //Helper method to perform campaignmessage Html table calculations
    private static String getCampMessageHtmlTableData(CampaignMessage__c campaignMessage,String starString){
        String estimatedDate = DateTime.newInstance(campaignMessage.TransmissionDate__c.year(), campaignMessage.TransmissionDate__c.month(),campaignMessage.TransmissionDate__c.day()).format('MM/dd/yy');
        String htmlTableData = '';
        htmlTableData += TROPEN +            
            +TDOPEN + starString + estimatedDate + TDCLOSE +
            TDOPEN + ((campaignMessage.JourneyId__c != null) ? campaignMessage.JourneyName__c : 'Single Mailer') + TDCLOSE +
            TDOPEN + ((campaignMessage.MailClassCode__c.equals('1')) ? '1st Class' : '3rd Class') + TDCLOSE +            
            TDOPEN + '$'+campaignMessage.cost__c + TDCLOSE +
            TDOPEN +  campaignMessage.Itemid__c + TDCLOSE +
            TDOPEN +  campaignMessage.Status__c + TDCLOSE +
            TRCLOSE;        
        return htmlTableData;        
    } 
    
    //Helper method to get campaign url and legend
    private static String getCampaignUrlAndLegend(Id campaignId){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId;
        String campaignLinkAndMessage = '';
        campaignLinkAndMessage += '<br />'+LEGENDSTARSTRING + ' New Mails'+'<p>'+'View Campaign '+'<a href="'+recordUrl+'">here</a>'+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font>';
        return campaignLinkAndMessage; 
    }
    /**
     * @description getSortedCampMessagesAndJrnyStepRecs
     * @param campMessageList
     * @param jrnyStepList
     * @param journeyStartDate
     * @return List<EmailObjectWrapper> 
     */
    //Helper method to get sorted records based on estimated date
    public static List<EmailObjectWrapper> getSortedCampMessagesAndJrnyStepRecs(List<CampaignMessage__c> campMessageList, List<Journey_Step__c> jrnyStepList, Date journeyStartDate) {
        List<EmailObjectWrapper> sortedcampMessageOrJrnyStepRecs = new List<EmailObjectWrapper>();        
        for(Journey_Step__c jrnystep : jrnyStepList) {
            Integer daysNum = jrnystep.DaysNum__c.intvalue();
            Date estimateDate = Date.newInstance(journeyStartDate.adddays(daysNum).year(), journeyStartDate.adddays(daysNum).month(),journeyStartDate.adddays(daysNum).day());
            sortedcampMessageOrJrnyStepRecs.add(new EmailObjectWrapper(jrnystep, estimateDate));
        }
        for(CampaignMessage__c campMessage : campMessageList) {
            sortedcampMessageOrJrnyStepRecs.add(new EmailObjectWrapper(campMessage, campMessage.TransmissionDate__c));
        }
        sortedcampMessageOrJrnyStepRecs.sort();
        return sortedcampMessageOrJrnyStepRecs;
    }
    
    /**
    * @description - wrapper class to implement comparable and sort campaign message and journey step records based on estimatedate
    */
    public with sharing class EmailObjectWrapper implements Comparable {       
        private SObject campMessOrJrnyStepRecord;
        private Date estimatedDate;
        // Constructor
        /**
         * @description EmailObjectWrapper
         * @param sObjectRecord 
         * @param dateSortFieldValue 
         */
        public EmailObjectWrapper(SObject sObjectRecord, Date dateSortFieldValue) {
            this.campMessOrJrnyStepRecord = sObjectRecord;
            this.estimatedDate = dateSortFieldValue;
        }
        /**
         * @description compareTo
         * @param compareTo
         * @return returnValue
         */
        // Compare records based on date.
        public Integer compareTo(Object compareTo) {
            
            EmailObjectWrapper compareToObj = (EmailObjectWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (estimatedDate > compareToObj.estimatedDate) {
                returnValue = 1;
            } 
            else if (estimatedDate < compareToObj.estimatedDate) {
                returnValue = -1;
            }            
            return returnValue;       
        }
    }
    
}
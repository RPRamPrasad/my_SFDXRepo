/**
* @author Team Skynet
* @date 10/19/2022
* @description Handles any display and saving of AgentQueue WorkAssignmentPreferences objects
*/
public with sharing class AQ_WorkAssignmentPreferencesHandler {

    private static final String CLASS_NAME = 'AQ_WorkAssignmentPreferencesHandler';
    private static List<AQ_WorkAssignmentWrapper> aqWorkWrapperList = new List<AQ_WorkAssignmentWrapper>();
    private static AQ_WorkAssignmentPreferencesHandlerWrapper aq_workassignmentwrap = new AQ_WorkAssignmentPreferencesHandlerWrapper();
    /**
    * @name: getRoutingDataRecord
    * @description Method to return current Work Assginment Rules for an Agents office called by LWC.
    * @return List of Wrapper Assignment Rules
    */
    @AuraEnabled
    public static List<AQ_WorkAssignmentWrapper> getRoutingDataRecord(){
        Map<Id,AQ_WorkAssignmentRule__c> userAQWorkAssignMap = new Map<Id,AQ_WorkAssignmentRule__c>();

        try {
            List<User> currentuser = security.stripInaccessible(AccessType.READABLE,
                                    [SELECT Id,Name, Servicing_Agent_Associate_ID__c
                                        FROM User
                                        WHERE Id=: UserInfo.getUserId()
                                        WITH SECURITY_ENFORCED
                                        limit 1])
                                    .getRecords();
            List<User> getuserList = security.stripInaccessible(AccessType.READABLE,
                                    [SELECT Id,Name,FirstName,LastName,Servicing_Agent_Associate_ID__c,UserType__c
                                        FROM User
                                        WHERE Servicing_Agent_Associate_ID__c=:currentuser[0].Servicing_Agent_Associate_ID__c
                                        AND UserType__c <> 'Agent Proxy' AND IsActive = true AND FederationIdentifier != ''
                                        WITH SECURITY_ENFORCED Order By Name ])
                                    .getRecords();

            List<AQ_WorkAssignmentRule__c> usersRoutingData = Security.stripInaccessible(AccessType.READABLE,
                                    [SELECT Endalpha__c,Id,Task_LOB__c,LOB_Stored__c,Name,StartAlpha__c,Subject__c,
                                            Task_Subject__c,User__c,user__r.name,ownerId,Marketing_Source_Stored__c,
                                            Opp_Originator_Stored__c
                                        FROM AQ_WorkAssignmentRule__c
                                        WHERE User__r.Servicing_Agent_Associate_ID__c =: currentuser[0].Servicing_Agent_Associate_ID__c
                                     	AND User__r.isActive = true AND User__r.FederationIdentifier != ''
                                        WITH SECURITY_ENFORCED order by user__r.name ])
                                    .getRecords();

            try {
                aq_workassignmentwrap.aqWorkAssign(usersRoutingData, userAQWorkAssignMap);
                aqWorkWrapperList = getUserListWrapperList(getuserList, userAQWorkAssignMap);

            } catch(Exception exp){
                LoggingService.logHandledException(exp, CLASS_NAME, 'getRoutingDataRecord', LoggingLevel.ERROR);
            }

        } catch(Exception exp){
            LoggingService.logHandledException(exp, CLASS_NAME, 'getRoutingDataRecord', LoggingLevel.ERROR);
        }

        return aqWorkWrapperList;

    }
    /**
    * @name: saveRoutingDataRecords
    * @description Method to update Work Assginment Rules for an Agents office called by LWC.
    * @param aqWorkWrapperList the wrapper list from LWC to update
    * @return String whether the update was successful or not
    */
    @AuraEnabled
    public static String saveRoutingDataRecords(List<AQ_WorkAssignmentWrapper> aqWorkWrapperList){
        String saveResult;
        List<AQ_WorkAssignmentRule__c> aqWorkAssignmentList = new List<AQ_WorkAssignmentRule__c>();

        try{
            for(AQ_WorkAssignmentWrapper aqWrapper :aqWorkWrapperList){

                AQ_WorkAssignmentRule__c aqWorkAssignment = new AQ_WorkAssignmentRule__c();
                if(String.isNotBlank(aqWrapper.aqId) && aqWrapper.aqId!= 'undefined'){
                    aqWorkAssignment.Id = aqWrapper.aqId;
                }else{
                    aqWorkAssignment.User__c = aqWrapper.userId;
                }
                aqWorkAssignment.Marketing_Source_Stored__c = String.join(new List<String>(aqWrapper.marketingSource),',');
                aqWorkAssignment.Opp_Originator_Stored__c = String.join(new List<String>(aqWrapper.oppOriginator),',');
                aqWorkAssignment.Task_Subject__c = String.join(new List<String>(aqWrapper.taskSubject),',');
                aqWorkAssignment.LOB_Stored__c =  String.join(new List<String>(aqWrapper.lobValues),',');
                aqWorkAssignment.StartAlpha__c = aqWrapper.alphaStart;
                aqWorkAssignment.EndAlpha__c   = aqWrapper.alphaEnd;
                aqWorkAssignment.Last_Assigned_User__c        = UserInfo.getUserId();  // Adding Logic to Track the Last modified User
                aqWorkAssignment.Last_Assigned_Date_Time__c   = Datetime.now(); // Ading Logic to Track Modified Date Time

                aqWorkAssignmentList.add(aqWorkAssignment);
            }

            saveResult = updateRoutingDataRecords(aqWorkAssignmentList);

        } catch(Exception exp){
            LoggingService.logHandledException(exp, CLASS_NAME, 'saveRoutingDataRecords', LoggingLevel.ERROR);
        }

        return saveResult;
    }

    @TestVisible private static List<AQ_WorkAssignmentWrapper> getUserListWrapperList(List<User> userList, Map<Id,AQ_WorkAssignmentRule__c> userRuleAssignMap) {
        for(User user : userList) {
            AQ_WorkAssignmentWrapper aqWrapper = new AQ_WorkAssignmentWrapper();

            if(userRuleAssignMap != null && userRuleAssignMap.containsKey(user.Id)){
                AQ_WorkAssignmentRule__c aq_workAssgn = userRuleAssignMap.get(user.Id);
                aqWrapper.aqId      = aq_workAssgn.Id;
                aqWrapper.userName  = aq_workAssgn.User__r.Name;
                aqWrapper.alphaStart = aq_workAssgn.StartAlpha__c;
                aqWrapper.alphaEnd  = aq_workAssgn.EndAlpha__c;
                aqWrapper.ownerId   = aq_workAssgn.ownerID;
                aqWrapper.userId   = aq_workAssgn.user__c;

              //  System.debug('**name*'+ aq_workAssgn.User__r.Name);
              //  System.debug('**LOB_Stored__c*'+ aq_workAssgn.LOB_Stored__c);
              //  System.debug('**Task_Subject__c*'+ aq_workAssgn.Task_Subject__c);
                addDisableFlags(aq_workAssgn, aqWrapper);

                cleanLobValues(aq_workAssgn, aqWrapper);
                cleanTaskSubjectValues(aq_workAssgn, aqWrapper);
                cleanMarketingSourceValues(aq_workAssgn, aqWrapper);
                cleanOppOriginatorValues(aq_workAssgn, aqWrapper);

            }else{
                aqWrapper.userName  = String.IsBlank(user.firstname)? user.LastName : (user.firstName + ' ' + user.LastName);
                aqWrapper.userId   = user.Id;
                aqWrapper.disableLob = false;
                aqWrapper.disableTaskSubject = false;


                aqWrapper.lobValues = new List<String>();
                aqWRapper.taskSubject = new List<String>();
                aqWRapper.marketingSource = new List<String>();
                aqWRapper.oppOriginator = new List<String>();
            }
            aqWorkWrapperList.add(aqWrapper);
        }
        return aqWorkWrapperList;
    }

    private static void cleanLobValues(AQ_WorkAssignmentRule__c rule, AQ_WorkAssignmentWrapper wrapper) {
        if(String.isNotBlank(rule.LOB_Stored__c) && rule.LOB_Stored__c!= null ){
            rule.LOB_Stored__c = rule.LOB_Stored__c.removeStart('(');
            rule.LOB_Stored__c = rule.LOB_Stored__c.removeEnd(')');
            wrapper.lobValues = rule.LOB_Stored__c.split(',');
        }else{
            wrapper.lobValues = new List<String>();
        }
    }

    private static void addDisableFlags(AQ_WorkAssignmentRule__c aq_workAssgn, AQ_WorkAssignmentWrapper aqWrapper) {
        if(String.isNotBlank(aq_workAssgn.LOB_Stored__c) && aq_workAssgn.LOB_Stored__c!= null &&
        (String.isBlank(aq_workAssgn.Task_Subject__c) || aq_workAssgn.Task_Subject__c == null )){
        // System.debug('**if*');
            aqWrapper.disableLob = false;
            aqWrapper.disableTaskSubject = true;
        }else if( (String.isBlank(aq_workAssgn.LOB_Stored__c) || aq_workAssgn.LOB_Stored__c == null) &&
        String.isNotBlank(aq_workAssgn.Task_Subject__c) && aq_workAssgn.Task_Subject__c != null ){
        //   System.debug('**else if*');
            aqWrapper.disableLob = true;
            aqWrapper.disableTaskSubject = false;
        }else{
            // System.debug('**else*');
            aqWrapper.disableLob = false;
            aqWrapper.disableTaskSubject = false;
        }
    }

    private static void cleanTaskSubjectValues(AQ_WorkAssignmentRule__c rule, AQ_WorkAssignmentWrapper wrapper) {
        if(String.isNotBlank(rule.Task_Subject__c) && rule.Task_Subject__c!= null ){
            wrapper.taskSubject = rule.Task_Subject__c.split(',');

        }else{
            wrapper.taskSubject= new List<String>();
        }
    }
     private static void cleanMarketingSourceValues(AQ_WorkAssignmentRule__c rule, AQ_WorkAssignmentWrapper wrapper) {
        if(String.isNotBlank(rule.Marketing_Source_Stored__c) && rule.Marketing_Source_Stored__c!= null ){
            rule.Marketing_Source_Stored__c = rule.Marketing_Source_Stored__c.removeStart('(');
            rule.Marketing_Source_Stored__c = rule.Marketing_Source_Stored__c.removeEnd(')');
            wrapper.marketingSource = rule.Marketing_Source_Stored__c.split(',');

        }else{
            wrapper.marketingSource= new List<String>();
        }
    }
    private static void cleanOppOriginatorValues(AQ_WorkAssignmentRule__c rule, AQ_WorkAssignmentWrapper wrapper) {
        if(String.isNotBlank(rule.Opp_Originator_Stored__c) && rule.Opp_Originator_Stored__c!= null ){
            rule.Opp_Originator_Stored__c = rule.Opp_Originator_Stored__c.removeStart('(');
            rule.Opp_Originator_Stored__c = rule.Opp_Originator_Stored__c.removeEnd(')');
            wrapper.oppOriginator = rule.Opp_Originator_Stored__c.split(',');

        }else{
            wrapper.oppOriginator= new List<String>();
        }
    }

    private static String updateRoutingDataRecords(List<AQ_WorkAssignmentRule__c> aqWorkAssignmentList) {
        String updateResult = 'error';
        if(!aqWorkAssignmentList.isEmpty()) {
           List<Database.UpsertResult> aqWorkAssignmentUpdateResults = Database.upsert(Security.stripInaccessible(AccessType.Upsertable, aqWorkAssignmentList, true).getRecords(), false);

          LoggingService.logDatabaseResult(aqWorkAssignmentUpdateResults, aqWorkAssignmentList, CLASS_NAME, 'updateRoutingDataRecords', LoggingLevel.ERROR);
            for (Database.UpsertResult result : aqWorkAssignmentUpdateResults) {
                if (result.isSuccess()) {
                    updateResult = 'Success';
                }
            }

        }

        return updateResult;
    }
    private class AQ_WorkAssignmentPreferencesHandlerWrapper{
        private void aqWorkAssign(List<AQ_WorkAssignmentRule__c> usersRoutingData, Map<Id,AQ_WorkAssignmentRule__c> userAQWorkAssignMap)
        {
            for(AQ_WorkAssignmentRule__c aq_workAssgn : usersRoutingData){
                if(String.isNotBlank(aq_workAssgn.User__c)){
                    userAQWorkAssignMap.put(aq_workAssgn.User__c,aq_workAssgn);
                }
            }
        }
    }
    /**
    * @name AQ_WorkAssignmentWrapper
    * @description Wrapper class to hold current Work Assginment Rules for an Agents office.
    */
    public with sharing class AQ_WorkAssignmentWrapper {
        /**
        * @name aqId
        * @description The id corresponding to the rule id.
        */
        @AuraEnabled public String aqId {get;set;}
        /**
        * @name userName
        * @description The user name of the user being assigned to the rule
        */
        @AuraEnabled public String userName {get;set;}
        /**
        * @name alphaStart
        * @description The value of the start alpha from the rule
        */
        @AuraEnabled public String alphaStart {get;set;}
        /**
        * @name alphaEnd
        * @description The value of the end alpha from the rule
        */
        @AuraEnabled public String alphaEnd{get;set;}
        /**
        * @name ownerId
        * @description The value of the owner from the rule
        */
        @AuraEnabled public String ownerId {get;set;}
        /**
        * @name userId
        * @description The value of the user from the rule
        */
        @AuraEnabled public String userId {get;set;}
        /**
        * @name lobValues
        * @description List of LOBs from the rule
        */
        @AuraEnabled public List<String> lobValues{get;set;}
        /**
        * @name taskSubject
        * @description List of task subjects from the rule
        */
        @AuraEnabled public List<String> taskSubject{get;set;}
        /**
        * @name marketingSource
        * @description List of marketing sources from the rule
        */
        @AuraEnabled public List<String> marketingSource{get;set;}
        /**
        * @name oppOriginator
        * @description List of opportunity originators from the rule
        */
        @AuraEnabled public List<String> oppOriginator{get;set;}

         /**
        * @name taskSubject
        * @description List of task subjects from the rule
        */
        @AuraEnabled public Boolean disableLob{get;set;}
         /**
        * @name taskSubject
        * @description List of task subjects from the rule
        */
        @AuraEnabled public Boolean disableTaskSubject{get;set;}
    }

}

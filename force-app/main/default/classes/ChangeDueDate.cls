/**
 * @description Makes API call through AWS to TP2 to change due date of a billing account
 *
 * @author Jacob Ira (VAB2Q2)
 * @version 2.0, 7/27/2023
 * @since 1.0
*/
public with sharing class ChangeDueDate {
    
    private Static Billing_Account__c billingAccount = new Billing_Account__c();
    
    /**@description Makes a callout to AWS passing in
    * @param  policyInfo - policy the user would like to change the due date of
    * @return List<List<String>>
    */
    @InvocableMethod
    public static List<OutputVariables> handleRequest(List<String> policyInfo){
        OutputVariables outputVariables = new OutputVariables();
        String delimiter = '+';
        String accId = policyInfo[0].substringBefore(delimiter);
        String dueDate = policyInfo[0].substringAfter(delimiter);
        String currentUserAlias = getCurrentUserDetail(UserInfo.getUserId()).Alias;
        List<List<String>> retResponse = new List<List<String>>();
        List<String> retString = new List<String>();
        List<Billing_Account__c> secureBa = Security.stripInaccessible(AccessType.READABLE, [Select BillAccountDueDate__c,Id,Name From Billing_Account__c WHERE Id = :accId Limit 1]).getRecords(); //Checks for user permissions to ensure FLS 
        billingAccount = secureBa[0];
        String billDueDate = billDueDate(billingAccount.BillAccountDueDate__c);
        Task t = new Task();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('callout:ECRM_to_TP2/changeDueDate'); 
        request.setMethod('POST'); 
        String jsonBody = '{"accountNumber": "' + billingAccount.Name + '","dueDate": "' + dueDate + '","activityUserId": "' + currentUserAlias + '"}';
        request.setBody(jsonBody); 
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            if(getResponseMessage(response) == 'Success'){
                t.Subject = 'Due Date Changed for Billing Account ' + billingAccount.Name;
                t.Description = 'Due date changed from ' + billDueDate + ' to the ' + dueDate + getDateSuffix(Integer.valueOf(dueDate)) + '.';
                outputVariables.firstMessage = 'You have successfully changed the due date for Billing Account ' + billingAccount.Name;
                outputVariables.boldMessage = ' from the ' + billDueDate + ' to the ' + dueDate + getDateSuffix(Integer.valueOf(dueDate));
                outputVariables.lastMessage = '. The new due date takes effect on all future bills and applies to all policies on the billing account. Any outstanding balance on the account is still due by the previous due date and must be paid to avoid the potential of the policies going into non-pay.';
                outputVariables.taskId = createTask(t);
                outputVariables.taskCreated = taskCreated(outputVariables.taskId);
            }
            else{
                String responseMessage = getResponseMessage(response);
                outputVariables.firstMessage = 'An Error occured because of the following reason: ' + getErrorMessage(responseMessage);
                outputVariables.taskCreated = false;
            }
        }
        else{
            outputVariables.firstMessage = 'Error -> ' +  getErrorMessage(response.getBody());
            outputVariables.taskCreated = false;
        }
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        outputVariablesList.add(outputVariables);
        return outputVariablesList;
    }
    
    //Boolean value for whether or not a task was successfully created
    //
    //@param - taskId - Id of task that was attempted to be created
    private static Boolean taskCreated(Id taskId){
        Boolean taskCreated;
        if(taskId == NULL){
        	taskCreated = false;
        }else{
            taskCreated = true;
        }
        return taskCreated;
    }

    //Gets billing accont due date or returns if no date was found
    //
    //@param - dueDate - value of due date field on billing account
    private static String billDueDate(Date dueDate){
        String retString = '';
        if(dueDate == NULL){
            retString = 'Date Not Found';
        }
        else{
            retString = dueDate.day() + getDateSuffix(Integer.valueOf(dueDate.day()));
        }
        return retString;
    }
    
    //Creates a task and associates it to the global Billing Account
    //
    //@param - newTask - new task with subject and description assigned based on response status
    private static string createTask(Task newTask){
        Task t = new Task();
        t = newTask;
        List<Task> tasksToAdd = new List<Task>();
        List<Billing_Participant__c> secureBp = Security.stripInaccessible(AccessType.READABLE, [SELECT ParticipantAccountId__r.PersonContactId FROM Billing_Participant__c WHERE BillingAccountID__c = :billingAccount.Id Limit 1]).getRecords(); //Checks for user permissions to ensure FLS 
        Billing_Participant__c bp = secureBp[0];
        String userLastName = UserInfo.getLastName().substringAfterLast(',');
        String officeComp = '%' + userLastName + '-Office';
        List<User> oListSecure = Security.stripInaccessible(AccessType.READABLE, [SELECT id FROM User WHERE Name LIKE :officeComp LIMIT 1]).getRecords();
        User oList = oListSecure[0];
        t.OwnerId = oList.id;
        t.WhoId = bp.ParticipantAccountId__r.PersonContactId;
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Log Call').getRecordTypeId();
        t.WhatId = billingAccount.Id;
        t.Status = 'Completed';
        t.CreatedClosed__c = true;
        t.ProductDescription__c = 'SF Billing';
        tasksToAdd.add(t);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, tasksToAdd);
        insert securityDecision.getRecords();
     	List<Task> secureTasks = securityDecision.getRecords();
        return secureTasks[0].Id;
    }
    
    //Parses the Http response and returns the message
    //
    //@param - res - response we are looking to get the message from
    private static String getResponseMessage(HttpResponse res){
        String message = '';
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null){
                if(parser.getText() == 'message'){
                    parser.nextValue();
                    message = parser.getText();
                }
            }
        }
        return message;
    }
    
    public class OutputVariables {
        @InvocableVariable(required=true description='Message returned')
        public String firstMessage;
        
        @InvocableVariable(required=true description='Message returned')
        public String boldMessage;
        
        @InvocableVariable(required=true description='Message returned')
        public String lastMessage;
        
        @InvocableVariable(required=false description='Change Due Date Task ID')
        public String taskId;
        
        @InvocableVariable(required=false description='Variable for if task was succesfully created')
        public boolean taskCreated;
    }
    
    //Looks for the message within the string and returns the corresponding value
    private static String getErrorMessage(String errorString){
        Integer startString = errorString.lastIndexOf('message');
        String message = errorString.substring(startString+10,errorString.length()-2);//two additional charactors for the end of the JSON
        return message;
    }
    
    //Returns the proper suffix for the day that was input
    //
    //@param - dayOfMonth - day of the month that the suffix is needed for
    private static String getDateSuffix(Integer dayOfMonth){
        String suffix;
        if (dayOfMonth > 3 && dayOfMonth < 21){
            suffix = 'th';
        }else{
            switch on (Math.mod(dayOfMonth,10)) {
                when 1{
                    suffix = 'st';
                }
                when 2{
                    suffix = 'nd'; 
                }
                when 3 {
                    suffix = 'rd';
                }
                when else{
                    suffix = 'th';
                }
            }
        }
        return suffix;
    }

    /**
    * @description Query call to find Name and Alias of User
    * @param  userId - Id of current User
    * @return list of users
    **/
    private static User getCurrentUserDetail(String userId){
        try{
            List<User> userList = Security.stripInaccessible(AccessType.READABLE, [SELECT Name, Alias FROM User WHERE Id =: userId LIMIT 1]).getRecords();
        	return userList.get(0);
        }catch(Exception ex){
            ex.setMessage('ERROR - user details not found');
            throw ex;
        }
    }
}
/**
 * @description Class that used to change the payment schedule of a specific billing policy in ECRM by calling the Billing Account Policy Administration 
 * Rest Service. The principal method of this class is changePaymentSchedule() and it desided to called from an Apex Action in flows. Currently the 
 * Change Payment Schedule flow is leveraging this method.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 2.0, 04/24/23
 * @see {@link https://techguide.opr.statefarm.org/index.php/Billing_Account_Policy_Administration_(Rest_Service)} 
 * @since 1.0
*/
public with sharing class ChangePaymentSchedule {
    private static Id billingPolicyId;
    private static string newBillingFrequencyCode;
    private static Billing_Policy__c billingPolicy;
    private static string policyEffectiveDate;
    private static string policyTermCode;
    private static string policyTerm;
    
    /**
     * @description InaccessibleDataException
     */
    public class InaccessibleDataException extends Exception {}
    /**
     * @description TaskCreationValidationException
     */
    public class TaskCreationValidationException extends Exception {}
    /**
     * @description ApiServerException
     */
    public class ApiServerException extends Exception {}
    
    private ChangePaymentSchedule() {}

     /**
     * @description Static invocable method that takes a list of InputVariables static nested classes and calls the Billing Account Policy 
     * Administration Rest Service in order to change the payment schedule of an specific billing policy, where the billingPolicyId and 
     * the new billing frequency (billingFrequency) are the two attributes of the InputVariables static nested classes.
     *   
     * @param request : A list of InputVariables static nested classes with a billingPolicyId and a billingFrequency
     * @return List<OutputVariables> a list of OutputVariables static nested classes with a responseMessage and a taskId
     * @throws InaccessibleDataException if the user calling the method does not have sufficient permissions
     * @throws ApiServerException if there is an error calling the Billing Account Policy Administration (Rest Service)
     * @throws TaskCreationValidationException if the user calling the method cannot create a Task in ECRM
 	 * @see {@link https://techguide.opr.statefarm.org/index.php/Billing_Account_Policy_Administration_(Rest_Service)}
     * @see InputVariables
     * @see OutputVariables
     */ 
	@InvocableMethod(label='POST ChangePaymentSchedule' description='Change the payment schedule for a billing policy')
    public static List<OutputVariables> changeThePaymentSchedule(List<InputVariables> request) {
        //String responseMessage = 'Message was not created. Please contact support for more information.';
        Id taskId;
        billingPolicyId = request.get(0).billPolicyId;
        newBillingFrequencyCode = request.get(0).billingFrequency;
        policyTerm = request.get(0).policyTerm;
        // Get the effective date and policy term of specific billing policy
        try {
            billingPolicy = [SELECT InsurancePolicyId__c, InsurancePolicyId__r.Name, InsurancePolicyId__r.EffectiveDate,
                                    BillingAccountID__c, BillingAccountID__r.AccountNumber__c, BillingAccountID__r.CalculatedCurrentAmountDue__c, 
                                    BillingAccountID__r.Status__c, BillingAccountID__r.SourceSystem__c,
                              		BillingFrequency__c 
                             FROM Billing_Policy__c 
                             WHERE Id = :billingPolicyId WITH SECURITY_ENFORCED LIMIT 1]; 
        } catch (QueryException queryException) {
            throw new InaccessibleDataException(queryException);
        }
        policyEffectiveDate = billingPolicy.InsurancePolicyId__r.EffectiveDate?.format('yyyy-MM-dd');
        policyTermCode = (policyTerm == 'Annual') ? '1' : '2';
        String billingAccountStatus = billingPolicy.BillingAccountID__r.Status__c?.toLowerCase();

        String responseMessage = createResponseMessage(billingAccountStatus);
        if (responseMessage == null) {
            try {
                HttpResponse res = changePaymentScheduleRequest();
                if(res.getStatusCode() == 200 && getResponseMessage(res)== 'SUCCESS'){
            		responseMessage = 'You have successfully updated the payment schedule to ' + billingFreqCodeConversion(newBillingFrequencyCode) + ' for Policy ' + 
                					   billingPolicy.InsurancePolicyId__r.Name + ' on Billing Account ' + billingPolicy.BillingAccountID__r.AccountNumber__c + '.';
                    taskId = createTask();
        		} else {
                    responseMessage = 'Error ' + res.getStatusCode() + ': Internal Server Error';
        		}
            } catch(Exception ex) {
                throw new TaskCreationValidationException(ex);
            }   	
        }
        OutputVariables outputVariables = new OutputVariables();
        outputVariables.responseMessage = responseMessage;
        outputVariables.taskId = taskId;
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        outputVariablesList.add(outputVariables);
        return outputVariablesList;
    }
    
     /**
     * @description Private static helper method that creates a response message given the status of a given billing account.
     * @param billingAccountStatus
     * @return String the formatted response message or null
     */ 
    private static String createResponseMessage(String billingAccountStatus) {
        // Check if policy can be change
        String responseMessageAmountDue = 'Billing Account ' + billingPolicy.BillingAccountID__r.AccountNumber__c + ' has an amount due of $' + billingPolicy.BillingAccountID__r.CalculatedCurrentAmountDue__c + 
                '.\n A policy\'s payment schedule cannot be changed to be billed less often until the current amount due is paid in full.\n';
        String responseMessageStatus = 'Billing Account ' + billingPolicy.BillingAccountID__r.AccountNumber__c + ' has ' + billingAccountStatus + ' status' +
                '.\n A policy\'s payment schedule cannot be changed to be billed less often until the policy status is Active, Billed, or Paid.';
        Boolean hasAmountDue = (billingPolicy.BillingAccountID__r.CalculatedCurrentAmountDue__c > 0);
        Boolean isNotActive = (billingAccountStatus != 'billed' && billingAccountStatus != 'active' && billingAccountStatus != 'paid');
        
        if (hasAmountDue && isNotActive) {
            return responseMessageAmountDue + responseMessageStatus;
        } else if (hasAmountDue) {
            return responseMessageAmountDue;
        } else if (isNotActive) {
            return responseMessageStatus;
        } else {
            return null;
        }
    }
    /**
     * @description InputVariables
     */
    public class InputVariables {
        @InvocableVariable(required=true description='Billing Policy Id whose frequency needs to be changed')
        public Id billPolicyId;
        
        @InvocableVariable(required=true description='New billing frequency for the billing policy')
        public String billingFrequency;
        
        @InvocableVariable(required=false description='Insurance Policy Term of the billing policy')
        public String policyTerm;
        
    }
    /**
     * @description OutputVariables
     */
    public class OutputVariables {
        @InvocableVariable(required=true description='Message returned')
        public String responseMessage;
        
        @InvocableVariable(required=false description='Change Payment Schedule Task ID')
        public Id taskId;
    }
    
     /**
     * @description Private static helper method used to create a task (log a call) that records the Change Payment Schedule transaction.
     *   
     * @return Id of the task created by this method
     */ 
    private static Id createTask() {
        Task task = new Task();
        // Get User Ids for task (OwnerId and AssignedTo__c)
        Id contextUserId = UserInfo.getUserId();	// AssignedTo__c
        String contextUserOfficeName = '%' + UserInfo.getLastName() + '-Office';
        List<User> userListSecure = Security.stripInaccessible(AccessType.READABLE, [SELECT Id FROM User WHERE Name LIKE :contextUserOfficeName LIMIT 1]).getRecords();
        Id officeUserId = userListSecure.isEmpty() ? contextUserId : userListSecure[0].Id;	// OwnerId
        // Get BillingAccount owner (WhoId)
        List<Billing_Participant__c> billPartiListSecure = Security.stripInaccessible(AccessType.READABLE, [SELECT ParticipantAccountId__c, ParticipantAccountId__r.PersonContactId,
                                                                                                            	   Primary_Household__c, SFPolicyRoleId__c,
                                                                                                            	   BillingAccountID__r.SourceSystem__c 
                                                                                                            FROM Billing_Participant__c 
                                                                                                            WHERE BillingAccountID__c  = :billingPolicy.BillingAccountID__c]).getRecords();
        Billing_Participant__c billParticipant;
        for (Billing_Participant__c billParticipantIter : billPartiListSecure) {
            if (billParticipantIter.BillingAccountID__r.SourceSystem__c == 'SFPP' && billParticipantIter.SFPolicyRoleId__c == 'PAH') {
                billParticipant = billParticipantIter;
                break;
            }
        } // {!BillingPolicyTable.firstSelectedRow.InsurancePolicyId__r.PolicyTerm}
        billParticipant = (billParticipant == Null) ? billPartiListSecure[0] : billParticipant;
        task.OwnerId = officeUserId;
        task.AssignedTo__c = contextUserId;
        task.WhoId = billParticipant.ParticipantAccountId__r.PersonContactId;
        task.FinServ__Household__c = billParticipant.Primary_Household__c;
        task.WhatId = billingPolicy.BillingAccountID__c;
        task.PolicyNumber__c = billingPolicy.InsurancePolicyId__r.Name;
        task.Subject = 'Payment Schedule Changed for Billing Account ' + billingPolicy.BillingAccountID__r.AccountNumber__c;
        task.Description = 'Billing Schedule was updated from ' + billingPolicy.BillingFrequency__c?.toLowerCase().capitalize()  + ' to ' + billingFreqCodeConversion(newBillingFrequencyCode);
        task.ProductDescription__c = 'SF Billing';
        task.Status = 'Completed';
        task.CreatedClosed__c = true;
        task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Log Call').getRecordTypeId();
        List<Task> taskListSecure = new List<Task>();
        taskListSecure.add(task);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, taskListSecure);
        insert securityDecision.getRecords();
     	List<Task> secureTasks = securityDecision.getRecords();
        return secureTasks[0].Id;
    }
    
     /**
     * @description Private static method that makes an HTTP call to the Billing Account Policy Administration Rest Service using static attributes
     * of this class as part of the request body. Upon a successfull call, method returns an HTTP response containing the response message.
     *   
     * @return HttpResponse of a call to the Billing Account Policy Administration Rest Service
 	 * @see {@link https://techguide.opr.statefarm.org/index.php/Billing_Account_Policy_Administration_(Rest_Service)}
     */ 
    private static HttpResponse changePaymentScheduleRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ECRM_to_TP2/changePaymentSchedule');
        req.setMethod('POST');
        // Get Alias of current user to assign it to activityUserId
        List<User> userListSecure = Security.stripInaccessible(AccessType.READABLE, [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]).getRecords();
        String requestBodyJson = '{"billFrequencyCode": "' + newBillingFrequencyCode + '", "policyTermCode": "' + policyTermCode + '", "policyEffectiveDate": "' + policyEffectiveDate + '", "activityUserId": "' + userListSecure[0].Alias + '", "displayPolicyNumber": "' + billingPolicy.InsurancePolicyId__r.Name + '"}'; 
        req.setBody(requestBodyJson); 
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        return http.send(req);
    }
    
     /**
     * @description Private static helper method that parses the http response and returns the value of the message.
     *   
     * @param res : the http response
     * @return String the value of the message attribute from the http response body
     */ 
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
    
     /**
     * @description Private static helper method that converts a billing frequency numeric code to its corresponding string value.
     *   
     * @param billFrequencyCode : A billing frequency numeric code
     * @return String the billing frequency string corresponding to the billing frequency numeric code
     */ 
    @TestVisible
    private static String billingFreqCodeConversion(String billFrequencyCode) {
        switch on billFrequencyCode {
            when '1' {
                return 'Monthly';
            }
            when '2' {
                return 'Pay in full';
            }
            when '5' {
                return 'Quarterly';
            }
            when '3', '4' {
                return 'Pay half';
            }
            when else {
                return '<Invalid frequency>';
            }
        }
    }
}
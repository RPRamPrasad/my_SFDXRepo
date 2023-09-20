/**
 * @description Establishes a connection between ACMT and ECRM enironments to simplify Case creation and allow monitoring of Case status.
 * 
 * @author Jacob Ira (VAB2Q2)
 * @version 1.2, 06/21/23
 * @since 1.0
*/
public with sharing class CreateBillingRequestOSCCase {

    static final String DESCRIPTION = 'description';
    static final String SUBJECT = 'subject';
    
    /**
     * @description This method is used as a setup method for the calloutToACMTCase to properly format the data to be worked for on the ACMT side. 
     * 
     * @param caseId the Id of the ECRM Case that is being created in ACMT
     */
    @Future(callout=true)
    public static void createCase(String caseId){
        List<Case> secureCases = Security.stripInaccessible(AccessType.READABLE, 
        [Select CreatedBy.LastName, Account.Name,ACMT_Case_Number__c,Assigned_To__c,CaseNumber,Created_In_Error__c,Date_To__c,Date_From__c,Bill_Due_Date__c, Id,PolicyNumber__c,Type From Case where Id = :caseId]).getRecords(); //Checks for user permissions to ensure FLS 

        Case ecrmCase = secureCases[0];
        String description;
        String caseType = 'Billing';

        //Sets specific description message for ACMT Case depending on ECRM Case type
        if('Account/Policy Breakdown'.equals(ecrmCase.Type)){
            String toDate = ecrmCase.Date_To__c.format();
            String fromDate = ecrmCase.Date_From__c.format();
            description = 'Account/Policy Breakdown needed From Date:  ' + fromDate + ' To Date: ' + toDate + ' for ECRM Case ' + ecrmCase.CaseNumber;
        } else if('Bill Explanation'.equals(ecrmCase.Type)){
            String dueDate = ecrmCase.Bill_Due_Date__c.format();
            description = 'Bill Explanation needed for Bill Due Date ' + dueDate +' for ECRM Case ' + ecrmCase.caseNumber;
        } else if('Hardship'.equals(ecrmCase.Type)) {
            description = 'Hardship - 30 Day Extension Request for ECRM Case ' + ecrmCase.CaseNumber;
        } else if('Catastrophe'.equals(ecrmCase.Type)) {
            description = 'Catastrophe Request for ECRM Case ' + ecrmCase.CaseNumber;
        }
        
        calloutToACMTCase( ecrmCase, description, caseType );
    }

    /**
     * @description This method is used as a setup method for the calloutToACMTCase to properly format the data to be updated on the ACMT side. 
     * 
     * @param caseId the Id of the ECRM Case that is being created in ACMT
     * @param comment the case comment that will be added to ACMT
     */
    @Future(callout=true)
    public static void updateCase(String caseId, String comment){
        calloutToUpdateACMTCase(caseId, comment); 
    }
    
    /**
     * @description Utilizes a Named Credential to access an API and create a Case in ACMT for the passed in ECRM Case.  
     * If case is successfully created in ACMT, the ECRM case is updated with the ACMT case id. OSC Cases created from the 
     * Chat are labeled with "Chat" in the 'External Source' field. The rest of cases are labeled as "ECRM" cases.
     * 
     * @param c the ECRM Case that is being created in ACMT org
     * @param description the description for the Case in ACMT org
     * @param caseType the type of Case created in ACMT org
     * 
     * @return {true} if the case was successfully created; {false} otherwise
     */
    @AuraEnabled(continuation=true)
    public static Boolean calloutToACMTCase(Case c, String description, String caseType){
        try {
            Boolean acmtCaseCreated = false;
            
            //Gathers information of the user that triggered the method to pass into API so it is assigned to the correct contact
            List<User> listOfUsers = Security.stripInaccessible(AccessType.READABLE, [select FirstName,Alias,Id,State,State_Agent_Code__c from User where Id =: c.Assigned_To__c LIMIT 1]).getRecords();
            User assignedUser = listOfUsers[0];
            
            // Create an OSCCase object passing the required parameters/fields. Instantiating the OSCCase class internally creates an "HTTP request", containing 
            // a "request body" with the required parameters
            String appName = c.CreatedBy.LastName == 'SF_CRM_BILLINGCASE' ? 'Chat' : 'ECRM'; //ToDo: also could be voice. In the future, adjust to use new App_Code__c when populated by AWS team

            oscCase.OSCCaseWrapper oscWrapper = new oscCase.OSCCaseWrapper();
            oscWrapper.appName = appName;
            oscWrapper.description = description;
            oscWrapper.topic = c.Type;
            oscWrapper.type = caseType;
            OSCCase oscCase = new OSCCase(oscWrapper);
            oscCase.accountNumber = c.PolicyNumber__c;
            oscCase.subject = c.Type;
            oscCase.agentCode = assignedUser.State_Agent_Code__c;
            oscCase.userAlias = assignedUser.Alias;
            oscCase.customerName = c.Account.Name;
            
            // Submit an "HTTP response". Create the case in the OSC instance using the OSC Case Controller API
            try {
                acmtCaseCreated = oscCase.createOSCCase();
                c.ACMT_Case_Number__c = oscCase.oscCaseNumber;
                // Update the case in ECRM by adding the ACMT case number
                List<Case> acmtCaseList = new List<Case>();
                acmtCaseList.add(c);
                update Security.stripInaccessible(AccessType.UPDATABLE, acmtCaseList).getRecords();
            } catch(Exception ex) {
                    LoggingService.logHandledException(ex, 'CreateBillingRequestOSCCase', 'calloutToACMTCase', System.LoggingLevel.ERROR);
            }
            return acmtCaseCreated;    
        } catch(Exception e) {
            LoggingService.logHandledException(e, 'CreateBillingRequestOSCCase', 'calloutToACMTCase', System.LoggingLevel.ERROR);
            throw new HandledException(e);
        }    
    }
    
    /**
     * @description Method used to update ACMT Case.
     * 
     * @param acmtCaseNumber the ACMT case number
     * @param internalComment the internal comment for the ACMT case
     * 
     * @return {true} if the case was successfully created; {false} otherwise
     */
    public static boolean calloutToUpdateACMTCase(String acmtCaseNumber, String internalComment){
        return OSCCase.updateStatusOfOSCCase(acmtCaseNumber, internalComment, null);
    }

    /**
     * @description Method that utilizes a Named Credential to access an API to fetch the status of the ACMT Case and updates the corresponding ECRM case Status.
     * 
     * @param caseId the ECRM Case in ACMT who's status is being retrieved
     */
    @AuraEnabled
    public static void getCaseStatus(String caseId){
        try{
            List<Case> secureCases = Security.stripInaccessible(AccessType.READABLE,
            [Select ACMT_Case_Number__c,Id,Status From Case where Id = :caseId AND Status != 'closed' AND Status != 'resolved']).getRecords();
            Case c = secureCases[0];
            String status = c.Status;
            if(!String.IsEmpty(c.ACMT_Case_Number__c)){
                status = OSCCase.getStatusOfOSCCase(c.ACMT_Case_Number__c);
                c.Status = status;
                // Update the case in ECRM by adding the ACMT case number
                List<Case> casesToUpdate = new List<Case>();
                casesToUpdate.add(c);
                update Security.stripInaccessible(AccessType.UPDATABLE, casesToUpdate).getRecords();
            }  
        } catch(Exception e) {
            LoggingService.logHandledException(e, 'CreateBillingRequestOSCCase', 'calloutToACMTCase', System.LoggingLevel.ERROR);
            throw new HandledException(e);
        }    
    } 
    
    /**
     * @description CreateECRMCaseWrapper
     * the ECRM case account id
     * the ECRM case app code
     * the ECRM case date from
     * the ECRM case date to
     * the ECRM case billing due date
     * the ECRM case policy number
     * the ECRM case type
     * the ECRM case user record
     */
    public class CreateECRMCaseWrapper{
        /**
         * @description accountId
         */
        @AuraEnabled
        public String accountId {get; set;}
        /**
         * @description appCode
         */
        @AuraEnabled
        public String appCode {get; set;}
        /**
         * @description dateFrom
         */
        @AuraEnabled
        public Date dateFrom{get; set;} 
        /**
         * @description dateTo
         */
        @AuraEnabled
        public Date dateTo{get; set;} 
        /**
         * @description billDueDate
         */
        @AuraEnabled
        public Date billDueDate{get; set;}
        /**
         * @description policyNumber
         */
        @AuraEnabled
        public String policyNumber{get; set;} 
        /**
         * @description type
         */
        @AuraEnabled
        public String type{get; set;} 
        /**
         * @description userRecord
         */
        @AuraEnabled
        public User userRecord{get; set;}
        /**
         * @description userRecord
         */
        @AuraEnabled
        public String userId{get; set;}
     }

    /**
     * @description Takes in the ECRM Wrapper and sets up the values fields required for Case. Then calls insertCase() and it will return a Case
     * number to be sent back to LWC. 
     * 
     * @param createECRMWrap
     * 
     * @return the case number
     */
    @AuraEnabled
    public static String createECRMCase(CreateECRMCaseWrapper createECRMWrap){
        try{
            String getRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing_Request').getRecordTypeId();
            List<Contact> contacts = new List<Contact>();
            contacts = Security.stripInaccessible(AccessType.READABLE, 
            [SELECT id FROM Contact WHERE AccountId = :createECRMWrap.accountId LIMIT 1]).getRecords(); 
            Case newBillingRequestCase = new Case();
            if (!contacts.isEmpty()) {
                newBillingRequestCase.ContactId = contacts.get(0).Id;
            }  
            newBillingRequestCase.AccountId = createECRMWrap.accountId;
            newBillingRequestCase.App_Code__c = createECRMWrap.appCode;
            newBillingRequestCase.PolicyNumber__c = createECRMWrap.policyNumber;
            newBillingRequestCase.Reason = createECRMWrap.type;
            newBillingRequestCase.RecordTypeId = getRecordTypeId;
            newBillingRequestCase.Type = createECRMWrap.type;
            List<Billing_Account__c> listBillingAccounts = Security.stripInaccessible(AccessType.READABLE, [SELECT Id FROM Billing_Account__c WHERE Name =: createECRMWrap.policyNumber LIMIT 1]).getRecords();
            if (!listBillingAccounts.isEmpty()) {
                newBillingRequestCase.Billing_Account__c = listBillingAccounts[0].Id;
            }
            
            //Conditionally sets values of the Case being created depending on the Type being passed
            if ('Account/Policy Breakdown'.equals(createECRMWrap.type)) {
                newBillingRequestCase.Date_From__c = createECRMWrap.dateFrom;
                newBillingRequestCase.Date_To__c = createECRMWrap.dateTo;
            } else if ('Bill Explanation'.equals(createECRMWrap.type)) {
                newBillingRequestCase.Bill_Due_Date__c = createECRMWrap.billDueDate;
            }
            newBillingRequestCase.description = caseDesSub(createECRMWrap.policyNumber, createECRMWrap.type).get('description');
            newBillingRequestCase.subject = caseDesSub(createECRMWrap.policyNumber, createECRMWrap.type).get('subject');

            //Allows external calls to set the owner of the Case record
            if(createECRMWrap.userRecord == NULL){
                newBillingRequestCase.Assigned_To__c = UserInfo.getUserId();
            }else{
                newBillingRequestCase.Assigned_To__c = createECRMWrap.userId;
                newBillingRequestCase.OwnerId = createECRMWrap.userId;
            }
            return insertCase(newBillingRequestCase);
        } catch(Exception e) {
            LoggingService.logHandledException(e, 'CreateBillingRequestOSCCase', 'calloutToACMTCase', System.LoggingLevel.ERROR);
            throw new HandledException(e);
        }
    }

    /**
     * @description Takes in Case to insert case into ECRM and returning Case Number.
     * 
     * @param newRequest the new Billing Request Case
     * 
     * @return result status of inserting a new Case
     */
    public static String insertCase( Case newRequest ){
        String caseId = '';
        String retVal = '';

        List<Case> casesToInsert = new List<Case>();
        casesToInsert.add(newRequest);
        SObjectAccessDecision caseInsert = Security.stripInaccessible(AccessType.CREATABLE, casesToInsert);
        List<Database.SaveResult> srList =  Database.insert(caseInsert.getRecords());
        
        //Sets return value to Case number if successful before calling API prep method
        if(!srList.isEmpty() && srList[0].isSuccess()){
            caseId = srList[0].getId();
            List<Case> retCaseList = Security.stripInaccessible(AccessType.READABLE, [SELECT CaseNumber, Id FROM Case WHERE Id = :caseId LIMIT 1]).getRecords();
            Case retCase = retCaseList.get(0);
            retVal = retCase.CaseNumber;
            if(!String.IsEmpty(caseId)){  
                createCase(caseId);
            }
        }
        //Sets return value to error message to allow user to see what went wrong
        else{
            LoggingService.logDatabaseResult(srList,caseInsert.getRecords(), 'CreateBillingRequestOSCCase', 'insertCase', System.LoggingLevel.ERROR);
            retVal = 'The following error occured while creating Case: ' + srList[0].getErrors();
        }
        return retVal;
    }

    /**
     * @description Takes in parameters of policy number and type to determine the Description and Subject to be assigned to the Case. 
     * 
     * @param policyNumber the ECRM case policy number
     * @param type the ECRM case type
     * 
     * @return a map of description and subject
     */
    public static Map<String,String> caseDesSub( String policyNumber, String type){
            Map <String,String> desSub = new Map <String,String>();

            //Conditionally sets values of the Case being created depending on the Type being passed
            String descripIntro = 'A SF Billing Request Case was submitted to SF Billing Operations on ';
            if ('Account/Policy Breakdown'.equals(type)) {
                desSub.put(DESCRIPTION, descripIntro + DateTime.now().format() + '.  The required research can take up to 5 business days depending on the complexity of the request. SF Billing Operations will provide completed research to the requestor via email.');
                desSub.put(SUBJECT, 'SF Billing Request - Account/Policy Breakdown for Billing Acct ' + policyNumber);
            } else if ('Bill Explanation'.equals(type)) {
                desSub.put(DESCRIPTION, descripIntro + DateTime.now().format() + '.  The required research can take up to 2 business days. SF Billing Operations will provide completed research to the requestor via email.');
                desSub.put(SUBJECT, 'SF Billing Request - Bill Explanation for Billing Acct #' + policyNumber);
            } else if ('Hardship'.equals(type)) {
                desSub.put(DESCRIPTION, descripIntro + DateTime.now().format() + '.  The required research can take 1-2 business days for review and processing. SF Billing Operations will provide confirmation to the requestor via email.');
                desSub.put(SUBJECT,'SF Billing Request - Hardship for Billing Acct ' + policyNumber);
            } else if ('Catastrophe'.equals(type)) {
                desSub.put(DESCRIPTION, descripIntro + DateTime.now().format() + '.  The required research can take 1-2 business days for review and processing. SF Billing Operations will provide confirmation to the requestor via email.');
                desSub.put(SUBJECT, 'SF Billing Request - Catastrophe for Billing Acct ' + policyNumber);
            }
            return desSub;
    }
}
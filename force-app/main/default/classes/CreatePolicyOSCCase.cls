/**
* @description Class that is used to create cases in ECRM and in the OSC Salesforce instance given a specific policy. Based on some input parameters, create a 
* case from an Insuracne Policy in the ECRM Salesforce instance. After the case is created in the ECRM instance, a new case is created in the OSC
* Salesforce instance using the OSC Case Controller API
*
* @author Kiko Ferrer (VAD63S)
* @version 1.1, 12/16/22
* @since 1.0
*/

public with sharing class CreatePolicyOSCCase {
    
    private static final string CASE_RT_ID_POLICY_INQ = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Policy_Inquiry').getRecordTypeId();

    // Objects and fields holding data for the OSC case
    private static final String OSC_APP_NAME = 'ECRM';
    private static final String OSC_CASE_TYPE = 'Billing';
    
    /**
     * @description CreatePolicyCaseECRMWrapper
     * the agent who is creating the case. If null is passed, the userRecord is whomever is running the class
     * the name of the insurance policy (eg: E42 9033-F15-13B)
     * the case type (Premium Change by default)
     * the case reason (Renewal Premium Diff PCU, App Premium Diff PCU, or Quote Premium Diff PCU)
     * the premium change inquiry
     */
    public class CreatePolicyCaseECRMWrapper{
        /**
         * @description userRecord
         */
        @AuraEnabled
        public User userRecord{get; set;}
        /**
         * @description policyName
         */
        @AuraEnabled
        public String policyName{get; set;}
        /**
         * @description caseType
         */
        @AuraEnabled
        public String caseType{get; set;} 
        /**
         * @description caseReason
         */
        @AuraEnabled
        public String caseReason{get; set;}
        /**
         * @description question
         */
        @AuraEnabled
        public String question{get; set;}
    }

    /**
    * @description Creates a case in ECRM instance getting information from a modal (type and reason) and the Insurance Policy 
    * objec, which is where the modal gets launched.
    *
    * @param createPolicyWrap
    *
    * @return the case number (caseNumber) if the case is successfully created in ECRM; null otherwise.
    */
    @AuraEnabled(continuation=true)
    public static String createPolicyCaseECRM(CreatePolicyCaseECRMWrapper createPolicyWrap) {
        try {
        // Objects and fields holding data for the ECRM case
        User ecrmCaseOwner;  
        InsurancePolicy insurancePolicy;
        Contact ecrmCaseContact;  
        Case ecrmCase;           
        ID ecrmCaseId;
        String ecrmCaseNumber;    
                                                  
        // Retrieve the id of the user running the modal if userRecord argument is NULL                                           
        if (createPolicyWrap.userRecord == null) {
            ecrmCaseOwner = [SELECT Id, Name, Alias, State_Agent_Code__c
                             FROM User
                             WHERE Id = :UserInfo.getUserId()WITH SECURITY_ENFORCED
                             LIMIT 1];  
        } else {
            ecrmCaseOwner = createPolicyWrap.userRecord;
        }        

        // Query the ECRM objects related to the case:
        // Query the policy to get the nameInsuredID of the policy (account whose policy is assigned to)
        insurancePolicy = [SELECT Id, Name, PolicyType, PolicyDescription, NameInsuredId, NameInsured.Name, FinServ__Household__c,
                                  Servicing_Agent__c, Servicing_Agent__r.Name
                           FROM InsurancePolicy 
                           WHERE Name = :createPolicyWrap.policyName WITH SECURITY_ENFORCED
                           LIMIT 1];
                                                  
        // Query the contact related to the account/client (nameInsuredId)
        ecrmCaseContact = [SELECT Id, Name, Email
                           FROM Contact 
                           WHERE AccountId = :insurancePolicy.NameInsuredId WITH SECURITY_ENFORCED
                           LIMIT 1];    
                                                  
        // Create a Case Subject (Subject)                                
        String caseSubject = 'Premium Change Inquiry for ' + insurancePolicy.Name;                                   
         
        // Create a Case Description (Description)
		String caseDescription = 'A Premium Change Inquiry Case was submitted to PCU on ' + System.today().format() + 
            '. Most requests are processed in 1-2 business days. PCU will provide completed research to the requestor via email.';
                                                  
        // Create a policy inquiry case ecrmCase.
        ecrmCase = new Case(RecordTypeId=CASE_RT_ID_POLICY_INQ, OwnerId=ecrmCaseOwner.Id, Assigned_To__c=ecrmCaseOwner.Id,
                            AccountId=insurancePolicy.NameInsuredId, FinServ__Household__c=insurancePolicy.FinServ__Household__c, ContactId=ecrmCaseContact.Id, 
                            Insurance_Policy__c=insurancePolicy.Id,
                            Type=createPolicyWrap.caseType, Reason=createPolicyWrap.caseReason, Question__c=createPolicyWrap.question, Subject=caseSubject, Description=caseDescription);

        // Insert the case in salesforce in user mode       
        List<Case> casesToInsert = new List<Case>();
        casesToInsert.add(ecrmCase);
        SObjectAccessDecision decisionInsert = Security.stripInaccessible(AccessType.CREATABLE, casesToInsert);
        Database.SaveResult resultCaseInsert =  Database.insert(decisionInsert.getRecords()[0], false, AccessLevel.SYSTEM_MODE);
                                                       
        // Sets return value to Case number if successful before calling API prep method
        if(resultCaseInsert.isSuccess()) {
            ecrmCaseId = resultCaseInsert.getId();
            ecrmCaseNumber = [SELECT Id, CaseNumber FROM Case WHERE Id = :ecrmCaseId WITH SECURITY_ENFORCED LIMIT 1].CaseNumber;
            createPolicyCaseOSC(ecrmCaseId, ecrmCase.Type, insurancePolicy.Name, insurancePolicy.NameInsured.Name,
                               ecrmCaseOwner.State_Agent_Code__c, ecrmCase.Reason, ecrmCase.Question__c, ecrmCaseOwner.Alias,
                               ecrmCaseContact.Name);
        } 
        
        return ecrmCaseNumber;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Method used as a setup method for the calloutToOSCCase to properly format the description field of the case created in the OSC instance.
    *
    * @param caseId the Id of the ECRM case that is being created in OSC
    * @param topic the case topic 
    * @param polNum the policy number
    * @param nameInsured the owner of the insurance policy
    * @param agentCode the case agent
    * @param reasonTopic the case topic
    * @param question the case question
    * @param agentAlias the agent alias whose case is assinged to 
    * @param contactName the contact assigned to the case
    */
   @Future(callout=true)
   private static void createPolicyCaseOSC(ID caseId, String topic, String polNum, String nameInsured,
                                           String agentCode, String reasonTopic, String question, String agentAlias, 
                                           String contactName) { 
       
        String oscCDescription = 'Policy #: ' + polNum +
       ' - Named Insured: '  + nameInsured + 
       ' - Agent Code: ' + agentCode + 
       ' - Topic: ' + reasonTopic + 
       ' - Question: ' + question +
       ' - Agent Alias: ' + agentAlias +
       ' - Servicing Agent: ' + agentCode +
       ' - Source: ' + OSC_APP_NAME;
        
       CalloutToOSCCaseControllerWrapper calloutWrap = new CalloutToOSCCaseControllerWrapper();
       calloutWrap.ecrmCaseId = caseId;
       calloutWrap.appName = OSC_APP_NAME;
       calloutWrap.description = oscCDescription;
       calloutWrap.topic = topic;
       calloutWrap.type = OSC_CASE_TYPE;
       calloutWrap.agentCode = agentCode;
       calloutWrap.agentAlias = agentAlias;
       calloutWrap.contactName = contactName;
       calloutWrap.nameInsured = nameInsured;
       calloutWrap.polNum = polNum;
       calloutToOSCCaseController(calloutWrap);
   }
    
   /**
    * @description CalloutToOSCCaseControllerWrapper
    * the Id of the ECRM case that is being created in OSC
    * the application creating the case in the OSC instance
    * the description of the case as seen in the OSC instance
    * the case topic
    * the case type
    * the case agent
    * the agent alias whose case is assinged to
    * the contact assigned to the case
    * the owner of the insurance policy
    * the policy number
    */
   private class CalloutToOSCCaseControllerWrapper{
    ID ecrmCaseId;
    String appName;
    String description; 
    String topic;
    String type;
    String agentCode; 
    String agentAlias; 
    String contactName; 
    String nameInsured; 
    String polNum;
   }

     /**
    * @description Method used to create a new case in the OSC instance given by calling the OSC Case Controller API
    * 
    * @see {@link https://sfgitlab.opr.statefarm.org/ACC-Salesforce/acc/-/wikis/home#_postCreateCaseRequest} 
    * @see OSCCase
    * @see OSCCase#createOSCCase()
    * @param callWrap
    */
   public static void calloutToOSCCaseController(CalloutToOSCCaseControllerWrapper callWrap) {                                              
    // Create an OSCCase object passing the required parameters/fields. Instantiating the OSCCase class internally creates an "HTTP request", containing 
    // a "request body" with the required parameters
    OSCCase.OSCCaseWrapper oscWrapper = new OSCCase.OSCCaseWrapper();
    oscWrapper.appName = callWrap.appName;
    oscWrapper.description = callWrap.description;
    oscWrapper.topic = callWrap.topic;
    oscWrapper.type = callWrap.type;
    OSCCase oscCase = new OSCCase(oscWrapper);
                                                     
	// Add optional paramaters to the "request body"
    oscCase.longPolicyNumber = callWrap.polNum;
    oscCase.subject = callWrap.topic;
    oscCase.agentCode = callWrap.agentCode;
    oscCase.userAlias = callWrap.agentAlias;
    oscCase.customerName = callWrap.contactName;
    oscCase.accountName = callWrap.nameInsured;


    // Submit an "HTTP response". Create the case in the OSC instance using the OSC Case Controller API
    oscCase.createOSCCase();
    
    // Fill the OSC case number field (ACMT_Case_Number__c) in the ECRM case record. Update done using the OSC Case Controller API
    
    // Submit an "HTTP response" to update the Case status
    List<Case> caseList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, ACMT_Case_Number__c FROM Case WHERE Id = :callWrap.ecrmCaseId]).getRecords();
    Case ecrmCase = caseList[0];                                             
    ecrmCase.ACMT_Case_Number__c = oscCase.oscCaseNumber;
                                                     
    List<Case> casesToUpdate = new List<Case>();
    casesToUpdate.add(ecrmCase); 
    update Security.stripInaccessible(AccessType.UPDATABLE, casesToUpdate).getRecords(); 
   }
}

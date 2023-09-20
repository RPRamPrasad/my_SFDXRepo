/**
 * @description Handler class that extends the functionality of the CreateBillingRequestOSCCase.createECRMCase() 
 * method, making it an invocable method that can be called from a Salesforce Flow. The main method of this class 
 * createECRMCase() is called by the 'SF Billing Request' Salesforce Flow to create a case in ECRM and OSC given 
 * the parameters entered in the Flow screen window.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 05/30/23
 * @see CreateBillingRequestOSCCase
 * @since 1.0
*/
public class CreateBillingRequestFlowHandler { 
    
    /**
    * @description Invocable method that takes in the parameters from the InputVariables inner class and calls 
    * the CreateBillingRequestOSCCase.createECRMCase() method to create a Case in ECRM then pass the Id of the created 
    * Case into the setup method to be passed to ACMT through the API. Method creates a case in ECRM and OSC given
    * the parameters entered in the Flow screen window.
    * 
    * @param request containing an InputVariables inner class with the method parameters in its class parameters
    * @return a list containing an OutputVariables inner class with the return value/s in its class parameters
    */
   @InvocableMethod(label='Create Case in ECRM and OSC' description='Creates a new case given a list of parameters in the ECRM and OSC instance')
   public static List<OutputVariables> createECRMCase(List<InputVariables> request) {
       CreateBillingRequestOSCCase.CreateECRMCaseWrapper createECRMWrapper = new CreateBillingRequestOSCCase.CreateECRMCaseWrapper();
       createECRMWrapper.accountId = request.get(0).accountId;
       createECRMWrapper.appCode = request.get(0).appCode;
       createECRMWrapper.dateFrom = request.get(0).dateFrom;
       createECRMWrapper.dateTo = request.get(0).dateTo;
       createECRMWrapper.billDueDate = request.get(0).billDueDate;
       createECRMWrapper.policyNumber = request.get(0).policyNumber;
       createECRMWrapper.type = request.get(0).caseType;
       createECRMWrapper.userRecord = request.get(0).userRecord;
       String caseNumber = CreateBillingRequestOSCCase.createECRMCase(createECRMWrapper);
       OutputVariables outputVariables = new OutputVariables();
       outputVariables.ecrmCaseNumber = caseNumber;
       List<OutputVariables> outputVariablesList = new List<OutputVariables>();
       outputVariablesList.add(outputVariables);
       return outputVariablesList;
   }
   
   /**
    * @description Inner class used to provive the parameter values to this class createECRMCase() invocable method.
   */
   public class InputVariables {
       @InvocableVariable(required=true description='The ECRM account id')
       public String accountId;
       @InvocableVariable(required=false description='The ECRM case app code') //ToDo: revisit if should be required
       public String appCode;
       @InvocableVariable(required=false description='The ECRM case date from')
       public Date dateFrom; // Only needed when request type is 'Account/Policy Breakdown'
       @InvocableVariable(required=false description='The ECRM case date to')
       public Date dateTo;	// Only needed when request type is 'Account/Policy Breakdown'
       @InvocableVariable(required=false description='The ECRM case billing due date')
       public Date billDueDate; // Only needed when request type is 'Bill Explanation'
       @InvocableVariable(required=true description='The ECRM case policy number')
       public String policyNumber;
       @InvocableVariable(required=true description='The ECRM case case type')
       public String caseType;
       @InvocableVariable(required=false description='The ECRM case user record')
       public User userRecord;	// The Apex Class determines this information if null user is passed
       
   }
   /**
    * @description Inner class used to output the return value of this class createECRMCase() invocable method.
   */
   public class OutputVariables {
       @InvocableVariable(description='The ECRM Case number')
       public String ecrmCaseNumber;
   }
}
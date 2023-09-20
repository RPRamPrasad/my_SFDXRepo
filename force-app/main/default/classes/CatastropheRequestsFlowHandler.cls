/**
 * @description Handler class that extends the functionality of the CatastropheRequests.billAccsWithOpenCats() 
 * method, making it an invocable method that can be called from a Salesforce Flow. The main method of this class 
 * billAccsWithOpenCats() is called by the 'SF Billing Request' Salesforce Flow.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 05/30/23
 * @see CatastropheRequests
 * @since 1.0
*/
public class CatastropheRequestsFlowHandler {
    
    /**
    * @description Invocable method that takes in the parameters from the InputVariables inner class and calls 
    * the CatastropheRequests.billAccsWithOpenCats() method which finds all the SF billing accounts of a 
    * customer (account) and returns those that are impacted by an open catastrophe. To determine which billing 
    * accounts impacted by an open catastrophe the method looks at the policy type (Auto, Fire, Life, and Health).
    * 
    * @param request containing an InputVariables inner class with the method parameters in its class parameters
    * @return a list containing an OutputVariables inner class with the return value/s in its class parameters
    */
   @InvocableMethod(label='Get Billing Accounts with open Cats' description='Get the Billing Accounts that have open Catastrophes given an Account Id')
   public static List<OutputVariables> billAccsWithOpenCats(List<InputVariables> request) {
           //  public static List<String> billAccsWithOpenCats(Id accountId) 
       List<String> billAccounts = CatastropheRequests.billAccsWithOpenCats(request.get(0).accountId);
       OutputVariables outputVariables = new OutputVariables();
       outputVariables.billingAccounts = billAccounts;
       List<OutputVariables> outputVariablesList = new List<OutputVariables>();
       outputVariablesList.add(outputVariables);
       return outputVariablesList;
   }

   /**
    * @description Inner class used to provive the parameter values to this class billAccsWithOpenCats() invocable method.
   */
   public class InputVariables {
       @InvocableVariable(required=true description='The ECRM account id')
       public Id accountId;
   }
   /**
    * @description Inner class used to output the return value of this class billAccsWithOpenCats() invocable method.
   */
   public class OutputVariables {
       @InvocableVariable(description='The list of billing accounts that have open Catastrophes')
       public List<String> billingAccounts;
   }
}
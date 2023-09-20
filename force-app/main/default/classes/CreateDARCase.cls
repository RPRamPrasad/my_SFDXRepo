/**
* @Name: CreateDARCase
* @Created: 11/05/2019
* @Author: Grumpycats
* @description Creates Data Access Case
*/
public with sharing class CreateDARCase {
    /**
     * @description setUpDARCase
     * @param flowInputs 
     * @return  `List<FlowOutputs>`
     */
    @InvocableMethod
    public static List<FlowOutputs> setUpDARCase(List<FlowInputs> flowInputs){
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        Case newCase = new Case();
        if(Schema.SObjectType.Case.isCreateable() 
           && Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DAR_Case').IsAvailable() 
           && flowInputs.get(0).account != null){
                newCase = createDataAccessCase(flowInputs.get(0).account);
            	result.newCaseId = String.valueOf(newCase.Id);
            	results.add(result);
               } 
        return results;
    }
    

    private static Case createDataAccessCase(Account account){
             Case newCase = new Case();
             newCase.AccountId = account.Id; 
             newCase.ContactId = account.PersonContactId; 
             newCase.OwnerId = UserInfo.getUserId();
             newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DAR_Case').getRecordTypeId();
             newCase.Subject = ('Data Access Request - ' + account.Name); 
             newCase.Description = ('The account for '+ account.Name + ' is requesting access to their data');
        try{
            insert newCase;
        }catch(Exception insertException){
            LoggingService.logHandledException(insertException, 'CreateDARCase', 'createDataAccessCase', System.LoggingLevel.ERROR);
        }
        return newCase;
    }
    
/**
* @Name: FlowInputs
* @Created: 11/05/2019
* @Author: Grumpycats
* @description Inner class to hold flow input variables
*/
    
    public with sharing class FlowInputs{ 

        @InvocableVariable
        public Account account;
        
    }
    
    
/**
* @Name: FlowOutputs
* @Created: 11/05/2019
* @Author: Grumpycats
* @description Inner class to hold flow out variables
*/
    public with sharing class FlowOutputs{       
        @InvocableVariable
        public String newCaseId;
    }


}
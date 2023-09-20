/**
* @Author - Team Data Blazers
* @Name - SNTGenericUTIL
* @description - This class will fetch EIID from custom object and display the transcript on Detail page
* @version 1.0
*/

public with sharing class SNTGenericUTIL{	 
    /**
    * @description Method to retrieve EIID
    * @param recordId
    * @return String
    */
    @AuraEnabled(cacheable = true)
    public static String getInteractionId(Id recordId) {
		string interactionEiid;
        
        List<InteractionSummary__c> interactionSummaryList = new List<InteractionSummary__c>();
        try {
            interactionSummaryList = Security.stripInaccessible(
                    AccessType.READABLE,
                    [
                       	SELECT id,enterprise_interaction_identifier__c 
                        FROM InteractionSummary__c 
                        WHERE id=:recordId
                    ]
                )
                .getRecords();
        
            if(!interactionSummaryList.isEmpty()) {
                InteractionSummary__c interactionSummary = interactionSummaryList.get(0);
                interactionEiid = interactionSummary?.enterprise_interaction_identifier__c;
            }
        }
        catch (Exception err) {
            throw new AuraHandledException('Could not retrieve EIID' + err.getMessage());
        }
    	return interactionEiid; 
    }
}
/**
*  @Author : Golden Spikes Team
*  @Date Created : 03/15/2017
*  @description : This class updates quote fields in Opportunity as blank, if the deleted Quote is Primary. (after delete Trigger on Quote)
                    This class remove primary on quote on quote undelete, if the deleted Quote is Primary. (after undelete Trigger on Quote)
*/
public with sharing class AP_QuoteTrigger {

    private static final String CLASS_NAME = 'AP_QuoteTrigger';
    private static final String UNDELETE_AUTOMATIC_PREVENT_ERROR_MSG = 'You are not allowed to undelete the selected quote.';
    private static final String AUTOMATIC_ATTACH_METHOD = 'Automatic';

    /**
     * @description AfterDelete Trigger - Updates quote fields in Opportunity as blank, if the deleted Quote is Primary.
     * @param afterDeleteQuoteList
     */

    public void syncOpportunityOnQuoteAfterDelete(List<Quote__c> afterDeleteQuoteList) {
        try {
            List<Opportunity> opportunityListToBeUpdated = clearOpportunityValuesForPrimaryQuote(afterDeleteQuoteList);
            if(!opportunityListToBeUpdated.isEmpty()) {
                List<Database.SaveResult> opportunityUpdateResults = Database.update(opportunityListToBeUpdated, false);
                LoggingService.logDatabaseResult(opportunityUpdateResults, afterDeleteQuoteList, CLASS_NAME, 'syncOpportunityOnQuoteAfterDelete', System.LoggingLevel.ERROR);
                processOpportunityUpdateResults(opportunityUpdateResults);
            }
        } catch(Exception quoteAfterDeleteException) {
            LoggingService.logHandledException(quoteAfterDeleteException, CLASS_NAME, 'syncOpportunityOnQuoteAfterDelete', System.LoggingLevel.ERROR);
        }
    }
    /**
     * @description method to process opportunity update results for displaying the trigger error
     * @param opportunityUpdateResults
     */

    private static void processOpportunityUpdateResults(List<Database.SaveResult> opportunityUpdateResults) {
        for(Integer i=0; i < opportunityUpdateResults.size(); i++) {
            if (!opportunityUpdateResults.get(i).isSuccess()) {
                Trigger.old[i].addError(Label.CL_QUOTE_PRIMARY_EXCEPTION_MSG);
            }
        }
    }
     /**
     * @description method to blanking monthly, total premium, Company, Number of Vehicles  during the deletion of primary quote
     * @param quoteList
     * @return opportunityListToBeUpdated
     */

    private static List<Opportunity> clearOpportunityValuesForPrimaryQuote(List<Quote__c> quoteList) {
        List<Opportunity> opportunityListToBeUpdated = new List<Opportunity>();
        for(Quote__c deleteQuote : quoteList) {
               if(deleteQuote.PrimaryQuote__c || AUTOMATIC_ATTACH_METHOD.equals(deleteQuote.Attachmethod__c))  {
                opportunityListToBeUpdated.add(new Opportunity(id = deleteQuote.Opportunity__c, Monthly_Premium__c = null, Amount = null, Number_of_Vehicles__c = null, Company__c = null));
                //Deleted the code to sync on XDate__c and CurrentInsurerName__c
            }
        }
        return opportunityListToBeUpdated;
    }
     /**
     * @description method to AfterUnDelete Trigger - remove primary on quote undelete, if the deleted Quote is Primary.
     * @param afterUnDeleteQuoteList
     */

    public void processQuoteAfterUndelete(List<Quote__c> afterUnDeleteQuoteList) {
        try {
            preventUndeletingDuplicateAutomaticQuote(afterUnDeleteQuoteList);
            handleRemovePrimaryOnQuoteUndelete(afterUnDeleteQuoteList);
        } catch(Exception quoteAfterUnDeleteException) {
            LoggingService.logHandledException(quoteAfterUnDeleteException, CLASS_NAME, 'removePrimaryOnQuoteAfterUnDelete', System.LoggingLevel.ERROR);
        }
    }
    /**
     * @description method to Validating and Preventing undeletion of Fire Automatic quote - if there is an already active Automatic quote.
     * @param afterUnDeleteQuoteList
     */
    private static void preventUndeletingDuplicateAutomaticQuote(List<Quote__c> afterUnDeleteQuoteList) {
        List<String> opportunityIdList = HLPR_PrimaryQuote.filterOpportunity(afterUnDeleteQuoteList);
        if(!opportunityIdList.isEmpty()) {
            Map<Id, List<Quote__c>> existingOpportunityQuoteMap = findDuplicateAutomaticQuote(opportunityIdList);
            for(Quote__c qt : afterUnDeleteQuoteList) {
                if(existingOpportunityQuoteMap.containsKey(qt.Opportunity__c) && existingOpportunityQuoteMap.get(qt.Opportunity__c).size() > 1) { // If it is a first quote under the specific opportunity
                    qt.addError(UNDELETE_AUTOMATIC_PREVENT_ERROR_MSG);
                }
            }
        }
    }
    /**
     * @description method to finding the duplicate Automatic quote from the Quote List for a specific opportunity
     * @param opportunityIdList
     * @return existingOpportunityQuoteMap
     */
    private static  Map<Id, List<Quote__c>> findDuplicateAutomaticQuote(List<String> opportunityIdList) {
        Map<Id, List<Quote__c>> existingOpportunityQuoteMap = new Map<Id, List<Quote__c>>();
        for(Quote__c qt : [Select id, Opportunity__c, AttachMethod__c from Quote__c Where opportunity__c in : opportunityIdList and AttachMethod__c =:'Automatic' WITH SECURITY_ENFORCED]) {
            if(existingOpportunityQuoteMap.containsKey(qt.Opportunity__c)) {
                List<Quote__c> quoteValues = (existingOpportunityQuoteMap.get(qt.Opportunity__c));
                quoteValues.add(qt);
                existingOpportunityQuoteMap.put(qt.Opportunity__c, quoteValues);
            } else {
                existingOpportunityQuoteMap.put(qt.Opportunity__c, new List<Quote__c> {qt});
            }
        }
        return existingOpportunityQuoteMap;
    }
     
    /**
     * @description method to updating the quote for removing primary on quote undelete
     * @param afterUnDeleteQuoteList
     */
    
    private void handleRemovePrimaryOnQuoteUndelete(List<Quote__c> afterUnDeleteQuoteList) {
        List<Quote__c> quoteListToBeUpdated = quoteRemovePrimary(afterUnDeleteQuoteList);
        if(!quoteListToBeUpdated.isEmpty()) {
            List<Database.SaveResult> quoteUpdateResults = Database.update(quoteListToBeUpdated, false);
            LoggingService.logDatabaseResult(quoteUpdateResults, afterUnDeleteQuoteList, CLASS_NAME, 'removePrimaryOnQuoteAfterUnDelete', System.LoggingLevel.ERROR);

            for(Integer i=0; i < quoteUpdateResults.size(); i++) {
                 if (!quoteUpdateResults.get(i).isSuccess()) {
                     Trigger.new[i].addError(Label.CL_QUOTE_PRIMARY_EXCEPTION_MSG);
                 }
            }
        }
    }
    
    /**
     * @description method to forming the quotelist to be updated for remove primary from the quoteUndeleteList
     * @param afterUnDeleteQuoteList
     * @return quoteListToBeUpdated
     */
    
    private static List<Quote__c> quoteRemovePrimary(List<Quote__c> afterUnDeleteQuoteList) {
        List<Quote__c> quoteListToBeUpdated = new List<Quote__c>();
        for(Quote__c unDeleteQuote : afterUnDeleteQuoteList) {
            quoteListToBeUpdated.add(new Quote__c(id = unDeleteQuote.id, PrimaryQuote__c = false, RecordTypeId = HLPR_PrimaryQuote.getPrimaryRecordTypeByLob(unDeleteQuote.RecordTypeId)));
        }
        return quoteListToBeUpdated;
    }  
    /**
     * @description method to after Update trigger - to execute only for Quote Automatic Attach method to sync quote information to opportunity.
     * @param quoteList
     */
    public void syncOpportunityOnAutomaticQuote (List<Quote__c> quoteList) {
        try {
            List<Quote__c> excludedQuoteList = HLPR_PrimaryQuote.filterAutomaticOpportunity(quoteList);
            if(!excludedQuoteList.isEmpty()) {
                handleRemovePrimaryOnQuoteonAutomaticAttach(excludedQuoteList); // Remove Primary On Old Primary Quote if exists in Opp
                HLPR_PrimaryQuote.updateOpportunity(findOpportunityToUpdate(excludedQuoteList)); // Sync quote information to opportunity for Auto Quote Automatic Attach method
            }
        } catch(Exception quoteAfterInsertException) {
            LoggingService.logHandledException(quoteAfterInsertException, CLASS_NAME, 'syncOpportunityOnAutomaticQuote', System.LoggingLevel.ERROR);
        }
    }

    /**
     * @description method to getting Fire primary/Automatic Auto Quote Quote Opportunity values in the list
     * @param excludedQuoteList
     * @return opportunityListToBeUpdated
     */          
    
    private static List<Opportunity> findOpportunityToUpdate(List<Quote__c> excludedQuoteList) {
        List<Opportunity> opportunityListToBeUpdated = new List<Opportunity>();
        for(Quote__c qt : excludedQuoteList) {
            opportunityListToBeUpdated.add(synchOpportunityStage(qt));
        }
        return opportunityListToBeUpdated;
    }
    /**
     * @description method to Updating opportunity values only for Fire Primary/Automatic Auto Quote
     * @param qt
     * @return optyToBeUpdated
     */ 
    private static Opportunity synchOpportunityStage(Quote__c qt) {
        Opportunity optyToBeUpdated = new Opportunity(id = qt.Opportunity__c, Monthly_Premium__c = qt.MonthlyPremium__c, Amount = qt.TotalPremiumAllVehicles__c, Company__c = qt.Company__c);
        if(String.isNotBlank(qt.VehicleInfo__c)) {
            Map<String, Object> vechicleObjMap = (Map<String, Object>) JSON.deserializeUntyped(qt.vehicleInfo__c);
            List<Object> lstVehicleObject = (List<Object>) vechicleObjMap.get('vehicleDetails');
            optyToBeUpdated.Number_of_Vehicles__c = lstVehicleObject.size();
          }

        return optyToBeUpdated;
    }
	/**
     * @description method to updating the quote for removing primary on quote after the Auto Automatic Quote Attach to Opportunity
     * @param excludedQuoteList
     */
    private void handleRemovePrimaryOnQuoteonAutomaticAttach(List<Quote__c> excludedQuoteList) {
        List<Quote__c> quoteListToBeUpdated = quoteRemovePrimaryOnSecondaryQuote(excludedQuoteList);
        if(!quoteListToBeUpdated.isEmpty()) {
            List<Database.SaveResult> quoteUpdateResults = Database.update(quoteListToBeUpdated, false);
            LoggingService.logDatabaseResult(quoteUpdateResults, excludedQuoteList, CLASS_NAME, 'handleRemovePrimaryOnQuoteonAutomaticAttach', System.LoggingLevel.ERROR);

            for(Integer i=0; i < quoteUpdateResults.size(); i++) {
                 if (!quoteUpdateResults.get(i).isSuccess()) {
                     Trigger.new[i].addError(Label.CL_QUOTE_PRIMARY_EXCEPTION_MSG);
                 }
            }
        }
    }
    /**
     * @description method to forming the quotelist to be updated for remove primary after the Auto Automatic Quote Attach to Opportunity
     * @param excludedQuoteList
     * @return quoteListToBeUpdated
     */
    private static List<Quote__c> quoteRemovePrimaryOnSecondaryQuote(List<Quote__c> excludedQuoteList) {
		List<Quote__c> quoteListToBeUpdated = new List<Quote__c>();
		List<String> opportunityIdList = HLPR_PrimaryQuote.automaticOpportunityValues(excludedQuoteList);
		for(Quote__c qt : [Select id, Opportunity__c, PrimaryQuote__c from Quote__c Where Opportunity__c in : opportunityIdList WITH SECURITY_ENFORCED]) {
			if(qt.PrimaryQuote__c == TRUE){
            quoteListToBeUpdated.add(new Quote__c(id = qt.id, PrimaryQuote__c = false));
			}      
		}
        return quoteListToBeUpdated;
    }  
	
}

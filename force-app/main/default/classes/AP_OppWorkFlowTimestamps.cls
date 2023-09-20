/**
* @author Team Quadcore
* @created 08/09/2021
* @description This is a utility class which is to update the timestamps on opportunity
* @version 1.0
*/
	  public with sharing class AP_OppWorkFlowTimestamps {
    private static final List<String> INCLUDE_STAGE_NAMES = new String[] {'Closed Won','Closed'};
    private static final List<String> INCLUDE_STAGE_NAMES_FOR_APP_SUBMITTED = new String[] {'Closed Won','App Submitted'};
    /**
   * @description method to update opportunity timestamps
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return updatedOpportunity
   */
    public static Opportunity updateTimeStamps(Opportunity updatedOpportunity, Opportunity oldOpportunity){ 
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        updatedOpp = updateCloseDate(updatedOpp, oldOpportunity);
		    updatedOpp = updateOppAssignedTimeStamp(updatedOpp, oldOpportunity); 
        updatedOpp = updateAppSubmitted(updatedOpp, oldOpportunity);       
		return updatedOpp;
    }
    
   /**
   * @description Method to update the closeDate when stage is moved to closed or closed won(Opp_WF_UpdateOpportunityCloseDate)
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Opportunity
   */
    private static Opportunity updateCloseDate(Opportunity updatedOpportunity, Opportunity oldOpportunity) {
	    if((updatedOpportunity.StageName != oldOpportunity.StageName) && INCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName)) {
            if(!('Closed'.equalsIgnoreCase(oldOpportunity.StageName) && 'Closed Won'.equalsIgnoreCase(updatedOpportunity.StageName)) &&
               !('Closed Won'.equalsIgnoreCase(oldOpportunity.StageName) && 'Closed'.equalsIgnoreCase(updatedOpportunity.StageName))) {
                 updatedOpportunity.CloseDate = System.today();
              
             }
          
         }
        return updatedOpportunity;
	 }
   private static Opportunity updateAppSubmitted(Opportunity updatedOpportunity, Opportunity oldOpportunity) {
    if((updatedOpportunity.StageName != oldOpportunity.StageName) && INCLUDE_STAGE_NAMES_FOR_APP_SUBMITTED.contains(updatedOpportunity.StageName)
     && oldOpportunity.App_Submitted__c==null) {
                 updatedOpportunity.App_Submitted__c = System.today();           
         }
        return updatedOpportunity;
	 }
    
   /**
   * @description Method to update the AssignedDateTime(OPP_WF_UpdateAssignedTimeStamp)
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Opportunity
   */
    private static Opportunity updateOppAssignedTimeStamp(Opportunity updatedOpportunity,Opportunity oldOpportunity) {
		if(updatedOpportunity.Assigned_To__c !=null && oldOpportunity.OppAssignedDateTime__c==null) {
             updatedOpportunity.OppAssignedDateTime__c=System.now();
         }
        return updatedOpportunity;
	 }
}

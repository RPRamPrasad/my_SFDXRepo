/****************************************************************************************
Name: UTIL_CreateOpportunityNote
=========================================================================================
Decription: 
@description - Utility class for creating note while creating/updating an Opportunity
=========================================================================================

******************************************************************************************/
public without sharing class UTIL_CreateOpportunityNote {

    private static final String SPI_ERROR ='Found SPI data in OpportunityDetail/OpportunityDescription field';
    private static final String OPPORTUNITY_NOTE_CATEGORY = 'System Generated';
    private static final String DEFAULT_OPPORTUNITY_DESC_FOR_NOTE = 'Opportunity Information';

    /**
     * @description - Create Opportunity Note when creating or updating an opportunity
     * @param description - Opportunity Request description field
     * @param details - Opportunity Request details field
     * @param opportunity - Opportunity to be updated 
     */
    public static void createOpportunityNoteBasedOnDescriptionAndDetail(String description, String details, Opportunity opportunity){
        if(String.isNotBlank(details)) {
            opportunity.OpportunityDetail__c = details;
            opportunity.Description = (String.isNotBlank(description)) ? description : DEFAULT_OPPORTUNITY_DESC_FOR_NOTE;
            createAndInsertOpportunityNote(opportunity);
        }
        else if (String.isBlank(details) && String.isNotBlank(description)) {
            opportunity.OpportunityDetail__c = '';
            opportunity.Description = description;
            createAndInsertOpportunityNote(opportunity);
        }
    }
    
   /**
   * @description - Construct the opportunity note and save.
   * @param opp - Opportunity to be created/updated with note
   * @return opportunity note  - New Opportunity Note
   */
    public static Opportunity_Note__c createAndInsertOpportunityNote(Opportunity opp) {
         Opportunity_Note__c note;
         note = constructOpportunityNote(Opp);
         if(String.isNotBlank(note.Comments__c)){
         	checkSPIDataonOpportunityNote(note);
         }
         UTIL_OpportunityDAO.insertOpportunityNote((new List<Opportunity_Note__c>{note}));

        return note;
    }
    
    /**
   * @description - Construct the opportunity note with description and comments.
   * @param opp - Opportunity to be created/updated with note
   * @return opportunity note  - New Opportunity Note
   */
    public static Opportunity_Note__c constructOpportunityNote(Opportunity opp) {        
        Opportunity_Note__c note = new Opportunity_Note__c(Category__c = OPPORTUNITY_NOTE_CATEGORY, Comments__c=createOpportunityNoteComment(opp), 
                                                           Opportunity__c=opp.Id);
       if(String.isNotBlank(opp.Description))
     {
       string description = opp.Description.trim();	
		 if(description.length() <=80)
        {
          note.Name = description;         
        }
         	else
			{
			 description= description.substring(0,80);
			 note.Name = description; 
           	}
       }
			return note;
    }
    
    private static String createOpportunityNoteComment(Opportunity opp) {
        String commentText = '';
        
        if(String.isNotBlank(opp.Description)) {
        	commentText += opp.Description;        
        }
        if(String.isNotBlank(opp.OpportunityDetail__c)) {
       	  commentText += '\n' + opp.OpportunityDetail__c;
        }
      	
        return commentText;
    }
    
       private static void checkSPIDataOnOpportunityNote(Opportunity_Note__c note){
       
        SFDOTCOM_SPISecurityManager spiSecurityManager = new SFDOTCOM_SPISecurityManager();
        String spiErrorMessage=spiSecurityManager.handle(new List<Opportunity_Note__c>{note});        
         if(spiErrorMessage!=null && String.isNotBlank(spiErrorMessage)){
              throw new WS_UpdateOpportunityException(SPI_ERROR +':' +spiErrorMessage);
             }
    }
    
}
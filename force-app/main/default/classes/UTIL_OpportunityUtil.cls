/****************************************************************************************
Name: UTIL_OpportunityUtil
Purpose: Dependent processing class for WS_OpportunityApiRestEndpoint and WS_SFCOMLeadMessageService
VERSION History         AUTHOR                    DATE                   DETAIL
1.0                     Quad Core                 08-14-2020             2020 R12 Release
******************************************************************************************/
/**
 * @description UTIL_OpportunityUtil
 */
public with sharing class UTIL_OpportunityUtil {
    private static final List<String> OLDOPP_STAGE_NAMES = new String[] {'Not Now -  Follow Up','Closed'};
    private static final List<String> INCLUDE_STAGE_NAMES = new String[] {'New', 'Assigned', 'Quoting','App Submitted'};

    private static final String SPI_ERROR ='Found SPI data in OpportunityDetail field';
    /** 
     * @description This method is used to chek the SPI data on OpportunityDetail 
     * @param opportunity - Opportunity
    */
    public static void chekSPIDataonOpportunityDetail(Opportunity opportunity){
        
        SFDOTCOM_SPISecurityManager spiSecurityManager = new SFDOTCOM_SPISecurityManager();
        String spiErrorMessage=spiSecurityManager.handle(new List<Opportunity>{opportunity});        
        if(spiErrorMessage!=null && String.isNotBlank(spiErrorMessage)){
            throw new SFCom_LeadMessageServiceException(SPI_ERROR +':' +spiErrorMessage);
        }
    }

    /**
     * @description postMessages
     * @param opportunityId 
     * @param isNotificationAllowed 
     * @param className 
     */
    public static void postMessages(String opportunityId, Boolean isNotificationAllowed, String className) {         
        try {
            if(isNotificationAllowed){          
                UTIL_OpportunityNotificationManager.postOppNotifications(new List<String>{opportunityId}); 
            }            
        } catch(Exception ex) { 
            LoggingService.logHandledException(ex, className , 'postMessages', System.LoggingLevel.ERROR);
        }
    }

    /**
     * @description validateDateForNNFPAndClosed
     * @param stageName 
     * @param notNowFollowUp 
     * @param closedDate 
     * @return  `Boolean`
     */
    public static Boolean validateDateForNNFPAndClosed(String stageName, DateTime notNowFollowUp, Datetime closedDate ){
        if('Not Now -  Follow Up'.equalsIgnoreCase(stageName) && null != notNowFollowUp
           && (Date.today() != notNowFollowUp.date())
           ){
             return true;
         }
         if('Closed'.equalsIgnoreCase(stageName) && null != closedDate
           && (Date.today() != closedDate.date()) )
            {
                return true;
            }
        return false;
    }

    /**
     * @description updateStageIfReOpen
     * @param opportunity 
     * @param stageName 
     * @return  `Opportunity`
     */
    public static Opportunity updateStageIfReOpen(Opportunity opportunity, String stageName){
        if(OLDOPP_STAGE_NAMES.contains(opportunity.StageName) && INCLUDE_STAGE_NAMES.contains(stageName)
        && UTIL_OpportunityUtil.validateDateForNNFPAndClosed(opportunity.StageName, opportunity.OppNotNowFollowUpDateTime__c, opportunity.OppClosedDateTime__c))
        {
            opportunity.StageName = stageName;
        }
        return opportunity;
    }
}
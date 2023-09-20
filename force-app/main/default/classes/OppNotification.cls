/**
 * @description Builds the Opportunity notification for the agents and their team members 
 * TEST CLASS: OppNotification_TEST.cls
 * @author Team Opptimizers 
 */
public with sharing class OppNotification {

    private static final String POD_WITH_PROTOCOL = 'https://customer';
    private static final String ICP_TP_ENV = 'ICP_TP_ENV'; 
    private static final String URL_GW_CONTEXTROOT = '/urlGateway/ExternalRedirect/Salesforce';
    
    private static final String CALLING_APP = 'chatternotification';
    private static final String OBJECT_TYPE = 'Opportunity';
    private static final String OPP_NEW_STAGE = 'New'; 

    private static final String OPP_LOB_PARAM = '<LOB>';
    private static final String OPP_ORIGINATOR_PARAM = '<OPP ORIGINATOR>';  

    private static final String OPP_ORIGINATOR_SFCOM = 'Statefarm.com';
    private static final String OPP_ORIGINATOR_ILP = 'Internet Lead Provider';

    private static final String UNCLAIMED_OPP_NOTIFICATION_TITLE = 'New or Unclaimed Hot Prospect Opportunity';
    private static final String UPDATED_OPP_NOTIFICATION_TITLE = 'Updated Hot Prospect Opportunity';

    private static final String UNCLAIMED_OPP_NOTIFICATION_MESSAGE = 'New or Unclaimed <OPP ORIGINATOR> <LOB> opportunity is available to be claimed!';
    private static final String UPDATED_OPP_NOTIFICATION_MESSAGE = 'An update has been made to the <OPP ORIGINATOR> <LOB> Opportunity!';        

    private Id recipient;  //either the assigned to user on the opportunity or the collab group id

    /**
     * @description setBaseNotificationProperties
     * @param opp 
     * @return  `Map<String, String>`
     */
    public Map<String, String> setBaseNotificationProperties(Opportunity opp) {
        
        Map<String, String> retVal = new Map<String, String>();
        retVal.put('redirectURL', this.createRedirectURL(opp));
        
        if(!OPP_NEW_STAGE.equals(opp.stageName) && String.isNotBlank(opp.Assigned_To__c)) { // updated (claimed opportunity)
            retVal.put('title', UPDATED_OPP_NOTIFICATION_TITLE);
            retVal.put('chatterMessage', getUpdatedChatterMessage(UPDATED_OPP_NOTIFICATION_MESSAGE, opp));
        }
        else {
            retVal.put('title', UNCLAIMED_OPP_NOTIFICATION_TITLE); // unclaimed opportunity
            retVal.put('chatterMessage', getUpdatedChatterMessage(UNCLAIMED_OPP_NOTIFICATION_MESSAGE, opp));
        }
        return retVal;
    }

    /**
     * @description createSkypeMessage
     * @param opp 
     * @param redirectURL 
     * @return  `String`
     */
    public String createSkypeMessage(Opportunity opp, String redirectURL) {
        
        String retVal = '';

        Account accountOnOpp = getAccountOnOpp(opp);
        retVal += '\n' + opp.LOB__c + '-' + accountOnOpp.Name;

        if(String.isNotEmpty(opp.Opportunity_Originator__c)){
            retVal += '\n' + opp.Opportunity_Originator__c;
        }
        if(String.isNotEmpty(opp.Marketing_Source__c)){
            retVal += '\n' + opp.Marketing_Source__c;  
        } 
        retVal += '\n' + redirectURL;

        return retVal;
    }

    /**
     * @description createRedirectURL
     * @param opp 
     * @return  `String`
     */
    public String createRedirectURL(Opportunity opp){ 
        String redirectURL = '';
        PageReference opportunityPage = new ApexPages.StandardController(opp).view();
        opportunityPage.setRedirect(true);
	
        CS_EnvironmentURLCustomSetting__c baseUrl = CS_EnvironmentURLCustomSetting__c.getInstance(ICP_TP_ENV);
        
        redirectURL = POD_WITH_PROTOCOL + baseUrl.Value__c + 
        URL_GW_CONTEXTROOT + '?callingApplication=' + CALLING_APP +
        '&objectType='+ OBJECT_TYPE + '&opportunityrecordId=' +
        opp.Id + '&action=view';  
        return redirectURL;
    }

    private String getUpdatedChatterMessage(String message, Opportunity opp) {

        String retVal = message.replace(OPP_LOB_PARAM, opp.LOB__c);     

        if (String.isBlank(opp.Opportunity_Originator__c)) { 
            retVal = retVal.replace(OPP_ORIGINATOR_PARAM, '');
        }
        else {    
        	retVal = retVal.replace(OPP_ORIGINATOR_PARAM, opp.Opportunity_Originator__c);  
        } 
        return retVal;
    }

    private Account getAccountOnOpp(Opportunity opp) {

        List<Account> retVal = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Name FROM Account WHERE Id = :opp.AccountId LIMIT 1]).getRecords();  //NULL CHECKING?

        return retVal[0];
    }

    /**
     * @description getRecipient
     * @return  `Id`
     */
    public Id getRecipient(){
        return this.recipient;
    }

    /**
     * @description setRecipient
     * @param recipient 
     */
    public void setRecipient(Id recipient) {
        this.recipient = recipient;
    }
}
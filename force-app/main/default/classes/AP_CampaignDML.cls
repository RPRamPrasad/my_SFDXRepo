/**
* Author : Team Incognito
* Date Created :1/25/2023
* Name : AP_CampaignDML 
* @description Helper class to perform DML on Campaign and CampaignMember object
*/

public with sharing class AP_CampaignDML { 
    
    private static AP_LogHolder logHolder =  new AP_LogHolder();
    
        /**
 * @description upsertCampaign
 * @param newCampaignList
 * @param className
 * @return  List<Campaign>
 */
    public static List<Campaign> upsertCampaign (List<Campaign> newCampaignList,String className) {
        Savepoint commitSavePoint = Database.setSavepoint();
        List<Campaign> campaignSuccessList = new List<Campaign>();
        try {
            List<Database.UpsertResult> upsertCampaignResultList = Database.upsert(newCampaignList, Campaign.External_Campaign_ID__c, false); 
            for (Integer i = 0; i < newCampaignList.size(); i++) {
                if(!upsertCampaignResultList[i].isSuccess()) {
                    String errorMessage = newCampaignList[i].Id + UTIL_Constants.COLON_SYMBOL+upsertCampaignResultList[i].getErrors();
                    logHolder.error(className, errorMessage.substring(0, Math.min(errorMessage.length(), 254))); 
                } else{
                    campaignSuccessList.add(newCampaignList[i]);
                }
            }
            if (logHolder!=null){
                logHolder.writeToLogExceptionObject();
            } 
            return campaignSuccessList;
        } catch(Exception e){
            Database.rollback(commitSavePoint);
            throw e;
        }  
    }
       /**
 * @description insertCampaignMember
 * @param newCampaignMemberList
 * @param className
 * @return  none
 */
    public static void insertCampaignMember (List<CampaignMember> newCampaignMemberList,String className) {
        Savepoint commitSavePoint = Database.setSavepoint();
        try {
            List<Database.UpsertResult> insertCampaignMemberResultList = Database.upsert(newCampaignMemberList, false); 
            for (Integer i = 0; i < newCampaignMemberList.size(); i++) {
                if(!insertCampaignMemberResultList[i].isSuccess()) {
                    String errorMessage = insertCampaignMemberResultList[i].Id + UTIL_Constants.COLON_SYMBOL+insertCampaignMemberResultList[i].getErrors();
                    logHolder.error(className, errorMessage.substring(0, Math.min(errorMessage.length(), 254))); 
                } 
            }
            if (logHolder!=null){
                logHolder.writeToLogExceptionObject();
            }
        } catch(Exception e){
            Database.rollback(commitSavePoint);
            throw e;
        }  
    }

}
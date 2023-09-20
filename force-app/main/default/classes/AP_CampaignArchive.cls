/**
* Author : Team ITIC
* Date Created :09/05/2019
* Description : Helper class for Campaign After Insert/ Delete triggers to copy Campaign record and archive.
* Used by AfterInsert and AfterDelete triggers.
* @description AP_CampaignArchive
*/

public with Sharing class AP_CampaignArchive {
    private static final String CLASS_NAME = 'AP_CampaignArchive';
    private static final String SOBJECTTYPE = 'Campaign';
    private AP_LogHolder logHolder =  new AP_LogHolder();
    List<CampaignArchive__c> campaignArchiveList = new List<CampaignArchive__c>();
    private static Map<Id, String> recordTypeIdNameMap;
/**
 * @description AP_CampaignArchive
 */
    public AP_CampaignArchive(){
        if(recordTypeIdNameMap==null){
            recordTypeIdNameMap = new Map<Id, String>(); 
            for(RecordType recordType: [select id, name from RecordType where SObjectType=:SOBJECTTYPE WITH SECURITY_ENFORCED]){
                recordTypeIdNameMap.put(recordType.Id, recordType.Name);
            }
        }
    }
    /**
     * @description processCampaignArchive
     * @param campaignList 
     * @param isDelete 
     */
    public void processCampaignArchive(List<Campaign> campaignList, Boolean isDelete){
        AP_CampaignArchiveData campaignArchiveData = new AP_CampaignArchiveData();
        CampaignArchive__c campaignArchive = new CampaignArchive__c();
        for(Campaign campaginRecord: campaignList){
            campaignArchive = campaignArchiveData.populateCampaignArchiveData(campaginRecord, recordTypeIdNameMap);
            if(isDelete){
                campaignArchive.CampaignDeletedDate__c = system.now();
                campaignArchive.CampaignDeletedBy__c = UserInfo.getUserId();
            } 
        	campaignArchiveList.add(campaignArchive);  
        }
        upsertCampaignArchive(campaignArchiveList);
    }
	
    private void upsertCampaignArchive(List<CampaignArchive__c> campaignArchiveList)
    {
        Savepoint commitSavePoint = Database.setSavepoint();
        try {
            List<Database.UpsertResult> upsertCampaignArchiveResultList = Database.upsert(campaignArchiveList, CampaignArchive__c.OriginalCampaignSfdcID__c, false); 
            for (Integer i = 0; i < campaignArchiveList.size(); i++) {
                if(!upsertCampaignArchiveResultList[i].isSuccess()) {
                    String errorMessage = campaignArchiveList[i].CampaignID__c + UTIL_Constants.COLON_SYMBOL+upsertCampaignArchiveResultList[i].getErrors();
                    logHolder.error(CLASS_NAME, errorMessage.substring(0, Math.min(errorMessage.length(), 254))); 
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
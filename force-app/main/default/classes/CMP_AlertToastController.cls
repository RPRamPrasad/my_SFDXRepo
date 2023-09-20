    /** 
 	* Author : Team Bisbee
    * Date Created : 01/09/2019
    * @description : This class is used to query the Alerts based on the page you are on.
    * Modified By:  02/07/2019 Team QuadCore Make class reusable across custom notes objects i.e. case notes, opportunity notes, account notes
*/
public with sharing class CMP_AlertToastController {    
    /**
     * @description showAlertToast
     * @param recId
     * @return boolean
     */
    //Method to check if alerts exists on the record if they do then send showAlertToast as true
    @auraEnabled
    public static boolean showAlertToast(String recId) {        
        Boolean alertToast = false;
        Map<String,Object> getAlerts = new Map<String,Object>();  
        getAlerts.put('recId', recId);
        String noteObjName = '';
        String objectname = Id.valueOf(recId).getsobjecttype().getDescribe().getName();
        String objName = objectname+'__c';
        noteObjName = objectname+'_Note__c';
        String queryString = 'SELECT ID,Name,CreatedDate,Comments__c from '+ noteObjName +' where '+ objName +'=:recId AND Alert__c = true ORDER BY CreatedDate DESC LIMIT 1000';
        SObjectAccessDecision recordData = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryString)));
        List<sObject> alertList = recordData.getRecords();
        if(alertList!=null && !alertList.isEmpty()){
            alertToast = true;
        }
        return alertToast;        
    }    
}

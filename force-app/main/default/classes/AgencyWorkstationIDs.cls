/**
* Author : Team LHIPS/GlitterCloud
* Date Created : 19/01/2023
* @description AgencyWorkstationIDs class pass workstationids to WorkstationIdModal
*/
public with sharing class AgencyWorkstationIDs {

    /**
    * @description method to pull AgencyWorkstationIDs
    * @param servicing_agent_associate_id id of User
    * @return list of workstation Id
    */
    @AuraEnabled(cacheable=true)
    public static List<String> getWorkstationIds (String servicing_agent_associate_id) {

        List<String> result = new List<String>();

        //get WIDs from Agency_Workstation__c object based on Servicing Agent Associate ID
        List<Agency_Workstation__c> agencyWorkstation = [SELECT Id, Servicing_Agent_Associate_ID__c, WorkstationID__c FROM Agency_Workstation__c WHERE Servicing_Agent_Associate_ID__c=:servicing_agent_associate_id WITH SECURITY_ENFORCED ];

        for(Agency_Workstation__c agencyWID: agencyWorkstation){
            result.add(agencyWID.WorkstationID__c);
        }
        return result;
    }
}
/**
* Author : Team Incognito
* Date Created :9/5/2023
* Name : Batch_ServiceCampaign 
* @description Helper class to query to process campaign records
*/

public with sharing class AP_ServiceCampaignQuery {

    private static final String PROXY = 'Agent Proxy';

     /**
     * @description getRiskData
     * @param policyNumberSet
     */
    public List<InsurancePolicy> getRiskData (Set<String> policyNumberSet) {
        List<InsurancePolicy> listRiskRecords = new List<InsurancePolicy>();
        listRiskRecords = [SELECT Id,Name,AgreDisplayPartyName__c,PlcyTypeCd__c,PolicyType,PolicyName,
                                                Servicing_Agent__c,Servicing_Agent__r.Associate_Id__c,Servicing_Agent__r.Name,AgreAccessKey__c,
                                                SFDCPolicyNumberSearchKey__c FROM InsurancePolicy where AgreAccessKey__c 
                                                IN :policyNumberSet WITH SECURITY_ENFORCED];
        return listRiskRecords;
    }

    public Map<String,InsurancePolicyAsset> getPolicyAssetRiskInfo(Set<String> policyIds){
        Map<String,InsurancePolicyAsset> policyRiskMap = new Map<String,InsurancePolicyAsset>();
        
        for(InsurancePolicyAsset policyAsset: [SELECT id,AssetName,RiskNumber__c,RiskStatusText__c,InsurancePolicyId 
                                                FROM InsurancePolicyAsset WHERE InsurancePolicyId IN:policyIds WITH SECURITY_ENFORCED]){
           policyRiskMap.put(policyAsset.InsurancePolicyId,policyAsset);
        }
        return policyRiskMap;
    }

    public List<InsurancePolicyParticipant> queryPolicyParticipant(Set<String> policyIds){
        return new List<InsurancePolicyParticipant>([SELECT Id,PrimaryParticipantAccountId,PrimaryParticipantAccount.Name,PrimaryParticipantAccount.ClientIdentifier__c,
                                                                PrimaryParticipantAccount.PersonContactId,InsurancePolicyId, InsurancePolicy.Servicing_Agent__c,
                                                     			InsurancePolicy.Servicing_Agent__r.Associate_ID__c
                                                                FROM InsurancePolicyParticipant WHERE InsurancePolicyId IN:policyIds WITH SECURITY_ENFORCED ]);
    }

    public Map<String,List<InsurancePolicy>> getClientInfo(List<InsurancePolicyParticipant> insurancePolicyParticipantList,List<InsurancePolicy> allPolicyInfo){
        
        Map<String,List<InsurancePolicy>> participantMap = new Map<String,List<InsurancePolicy>>();
        List<InsurancePolicy> policyList;
        String contactId;
        for (InsurancePolicyParticipant participant: insurancePolicyParticipantList){
            contactId = participant.PrimaryParticipantAccount.PersonContactId;
            policyList = new List<InsurancePolicy>();
            for(InsurancePolicy policyRecord: allPolicyInfo){
                if((policyRecord.Id).equals(participant.InsurancePolicyId)){
                    policyList.add(policyRecord);
                }
            }
            if(participantMap.containsKey(contactId)){
                List<InsurancePolicy> policyListFromMap = participantMap.get(contactId);
                policyListFromMap.addAll(policyList);
                participantMap.put(contactId, policyListFromMap);
            } else{
               participantMap.put(contactId,policyList);
            }
        }
       return participantMap;
    }

    public Map<String,String> getProxyUser(Set<String> agentAssociateId){
        Map<String,String> userAssociateIdMap = new Map<String,String>();
        for(User userRecord: [SELECT id,Servicing_Agent_Associate_ID__c from User
                                 where Servicing_Agent_Associate_ID__c IN:agentAssociateId AND UserType__c=:PROXY WITH SECURITY_ENFORCED]){
            userAssociateIdMap.put(userRecord.Servicing_Agent_Associate_ID__c,userRecord.Id);
        }
        return userAssociateIdMap;
        
    }
}
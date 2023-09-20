/**
* Author : Team Incognito
* Date Created :1/25/2023
* Name : Batch_ServiceCampaign 
* @description Helper class to create campaign records from Service Campaign object
*/

public with sharing class AP_ServiceCampaigns {
    private static final String CLASS_NAME = 'AP_ServiceCampaigns';
    private static final String EXTERNAL_ID = 'SC';
    private static final String POLICYDATA = '{"policyData":[';
    private static final String OPEN = '{';
    private static final String CLOSE = '}';
    private static final String COMMA = ',';
    
    private static final String JSON_END = ']}';
    private static final String POLICYLOB = '"lob":"';
    private static final String RISKID = COMMA+'"riskId":';	
    private static final String POLICYNUMBERDISPLAY = COMMA+'"policyNumberDisplay":';
    private static final String POLICYNUMBER = COMMA+'"policyNumber":';
    private static final String DESCRIPTION = COMMA+'"description":';
    private static final String TEXT_PREFIX = 'TextOnly: ';   
    
    private AP_CampaignBuilder campaignBuilder = new AP_CampaignBuilder();
    private AP_CampaignMemberBuilder campaignMemberBuilder = new AP_CampaignMemberBuilder();
    private AP_CampaignBuilder campaignFromReportBuilder;
    private Map<String,String> agreAccessKeyAddnlInfoMap = new Map<String,String>();
    private Map<String,String> policyRiskIdMap = new Map<String,String>();
    private AP_ServiceCampaignQuery serviceCampaignQuery = new AP_ServiceCampaignQuery();
        
    /**
 * @description processServiceCampaign
 * @param serviceCampaignList
 * @param campaignName
 * @param startDate
 * @return  none
 */
    public void processServiceCampaign(List<Service_Campaign__c> serviceCampaignList, String campaignName, Date startDate) {
        Set<String> policyNumberSet = new Set<String>();
        Set<String> agentAssociateIdSet = new Set<String>();
        Set<String> insurancePolicyId = new Set<String>();
        Map<String,InsurancePolicy> insurancePolicyMap = new Map<String,InsurancePolicy>();
        
            for(Service_Campaign__c serviceCampaign: serviceCampaignList){
                //populate agreAccessKeyAddnlInfoMap;Key:AgreAccessKey;value:AddnlInfo
                policyNumberSet.add(serviceCampaign.PolicyNumber__c);
                agreAccessKeyAddnlInfoMap.put(serviceCampaign.PolicyNumber__c, serviceCampaign.AdditionalInformation__c);
            } // if(agreAccessKeyAddnlInfoMap(policyRiskIdMap.get(policy.id)))
            List<InsurancePolicy> allPolicyInfos = serviceCampaignQuery.getRiskData(policyNumberSet);
            for(InsurancePolicy policy: allPolicyInfos){
                insurancePolicyId.add(policy.id);
                insurancePolicyMap.put(policy.id, policy);
                agentAssociateIdSet.add(policy.Servicing_Agent__r.Associate_Id__c);
                policyRiskIdMap.put(policy.id, policy.AgreAccessKey__c);//populate policyRiskIdMap;key:Policy.Id,value:AgreAccessKey__c
            }
            Map<String,InsurancePolicyAsset> policyRiskMap = serviceCampaignQuery.getPolicyAssetRiskInfo(insurancePolicyId);//key:PolicyId; Value:PolicyAsset
            List<InsurancePolicyParticipant> insurancePolicyParticipantList = serviceCampaignQuery.queryPolicyParticipant(insurancePolicyId);
            Map<String,String> userIdMap = serviceCampaignQuery.getProxyUser(agentAssociateIdSet);//key:AgentAssocId; value:UserId
            Map<String,List<InsurancePolicy>> clientMap = serviceCampaignQuery.getClientInfo(insurancePolicyParticipantList,allPolicyInfos);//key:ContactId; value:PolicyList
            
            Map<String, String> associateExternalIdMap = buildAssociateExternalId(agentAssociateIdSet,userIdMap, serviceCampaignList[0].State__c);//key:UserId; value:externalId
            Map<Id,Set<Id>> userIdToContactIdsMap = buildUserContacts(agentAssociateIdSet, insurancePolicyParticipantList, userIdMap);//key:UserId;value:Set of ContactIds
            Map<String,String>  contactPolicyDataMap = buildPolicyData(clientMap,policyRiskMap);//key:ConactId;value:Policydata
        
            campaignFromReportBuilder = new AP_CampaignBuilder();
            AP_CampaignBuilder.AP_CampaignBuilderRequest request = new AP_CampaignBuilder.AP_CampaignBuilderRequest();
            request.userContactsMapIn = userIdToContactIdsMap;
            request.associateExternalIdMapIn = associateExternalIdMap;
        	request.campaignNameIn = campaignName;
            request.startDateIn = startDate;
            
            List<Campaign> campaignList = createCampaign (request);
            Map<Id,Set<Id>> campaignContactsMap = queryExistingCampaignMember(contactPolicyDataMap.keySet());
            Map<Id,Set<Id>> userIdToContactIds = populateDuplicateCampaignMember(campaignContactsMap, campaignList,userIdToContactIdsMap);
            createCampaignMember (userIdToContactIds,contactPolicyDataMap, campaignList);
            //createCampaignMember (userIdToContactIdsMap,contactPolicyDataMap, campaignList);
        	updateServiceCampaign(serviceCampaignList);
    }

    private Map<String,String> buildAssociateExternalId(Set<String> agentAssociateId, Map<String,String> userAssociateIdMap,String stateValue){
        Map<String,String> userExternalIdMap = new Map<String,String>();
        String stateCode = '';
        for(String assocId: agentAssociateId){
            if(String.isNotBlank(stateValue)){
                stateCode = stateValue;
            }
            userExternalIdMap.put(userAssociateIdMap.get(assocId),assocId + stateCode + generateExternalId());
        }
        return userExternalIdMap;
    }

    private Map<Id,Set<Id>> buildUserContacts(Set<String> agentAssociateIdSet, List<InsurancePolicyParticipant> participantList, Map<String,String> userAssociateIdMap){
        Set<Id> participantSet;
        Map<Id,Set<Id>> userParticipantMap = new Map<Id,Set<Id>>();
        for (String agentAssociateId: agentAssociateIdSet){
            participantSet = new Set<Id>();
            for(InsurancePolicyParticipant participantRecord: participantList){
                if(agentAssociateId.equals(participantRecord.InsurancePolicy.Servicing_Agent__r.Associate_ID__c)){
                    participantSet.add(participantRecord.PrimaryParticipantAccount.PersonContactId);
                }
            }
            userParticipantMap.put(userAssociateIdMap.get(agentAssociateId),participantSet);
        }
        return userParticipantMap;
    }

    private Map<String,String> buildPolicyData(Map<String,List<InsurancePolicy>> clientMap,Map<String,InsurancePolicyAsset> policyRiskMap){
        Map<String,String> contactPolicyDataMap =new Map<String,String>();
        for (String contactId: clientMap.keySet()){
            String policyDataAll = '';
            for(InsurancePolicy policy: clientMap.get(contactId)){
                if(String.isNotBlank(agreAccessKeyAddnlInfoMap.get(policyRiskIdMap.get(policy.id)))){
                    contactPolicyDataMap.put(contactId, TEXT_PREFIX + agreAccessKeyAddnlInfoMap.get(policyRiskIdMap.get(policy.id)));
                } else{
                        String policyRecord;
                        if(String.isNotBlank(policyDataAll)){ 
                            policyRecord+= COMMA;
                        }
                        policyRecord = OPEN + POLICYLOB + policy.PolicyType +'"'+ RISKID +'"'+ policyRiskMap.get(policy.id).RiskNumber__c +'"'+ 
                                            POLICYNUMBERDISPLAY + '"'+ policy.Name + '"'+ POLICYNUMBER +'"'+ policy.AgreAccessKey__c +
                                            '"'+ DESCRIPTION + '"' + policyRiskMap.get(policy.id).AssetName + '"'+CLOSE;
                        policyDataAll+= policyRecord;                                   
                    
                contactPolicyDataMap.put(contactId,POLICYDATA+policyDataAll+JSON_END);
            }
            }
        } 
        return contactPolicyDataMap;
    }

    private List<Campaign> createCampaign(AP_CampaignBuilder.AP_CampaignBuilderRequest request){
        List<Campaign> campaignList =  campaignBuilder.buildCampaignsForServiceCampaign(request);
        return AP_CampaignDML.upsertCampaign (campaignList, CLASS_NAME);
    }

    private void createCampaignMember(Map<Id,Set<Id>> usersToAccountIdsMap, Map<String,String> contactPolicyDataMap, List<Campaign> campaignList) {
        List<CampaignMember> campaignMemberList = campaignMemberBuilder.buildCampaignMembersFromServiceCampaign(usersToAccountIdsMap, contactPolicyDataMap, campaignList);
        AP_CampaignDML.insertCampaignMember(campaignMemberList, CLASS_NAME);
    }
    
    private void updateServiceCampaign(List<Service_Campaign__c> serviceCampaignList){
        List<Service_Campaign__c> recordsProcessedList = new List<Service_Campaign__c>();
        for (Service_Campaign__c serviceCampaignRecord: serviceCampaignList){
            serviceCampaignRecord.ToBeProcessed__c = false;
            recordsProcessedList.add(serviceCampaignRecord);
        }
        if(Schema.sObjectType.Service_Campaign__c.isUpdateable()){
            update recordsProcessedList;
        }
    }

    private String generateExternalId(){
        return String.valueOf(system.today().month()) + String.valueOf(system.today().day()+ formatYear());
        
    }
    private String formatYear(){
        String str = String.valueOf(system.today().year()); 
        return str.substring(str.length()-2);
    }

    private Map<Id,Set<Id>> queryExistingCampaignMember(Set<String> contactIdSet){
        Map<Id,Set<Id>> campaignContactsMap = new Map<Id,Set<Id>>();
        for (CampaignMember member: [Select Id, CampaignId, ContactId, Campaign.OwnerId from CampaignMember where ContactId IN:contactIdSet WITH SECURITY_ENFORCED]){
            if(campaignContactsMap.containsKey(member.CampaignId)){
                campaignContactsMap.get(member.CampaignId).add(member.ContactId);
            }else{
                Set<Id> contactsSet = new Set<Id>();
                contactsSet.add(member.ContactId);
                campaignContactsMap.put(member.CampaignId, contactsSet);
            }
        } 
        return campaignContactsMap;
    }

    private Map<Id,Set<Id>> populateDuplicateCampaignMember(Map<Id,Set<Id>> campaignContactsMap, List<Campaign> campaignSuccessList,Map<Id,Set<Id>> userIdToContactIdsMap){
        for(Campaign campaignRecord: campaignSuccessList){
            if(campaignContactsMap.containsKey(campaignRecord.Id)){
                userIdToContactIdsMap.get(campaignRecord.OwnerId).removeAll(campaignContactsMap.get(campaignRecord.Id));
            }
        }
        return userIdToContactIdsMap;
    }
}
/**
* @author : Team Loco Motivated / Targaryen
* @name : HLPR_RemoveFromBookAggregatorRequest
* @description This is JSON object for Remove From Book helper aggregator request 
* @Date : 07/05/2018
**/

public with sharing class HLPR_RemoveFromBookAggregatorRequest {
    
    /**
     * @description Get Remove From Book Request
     * @param finalListForRemoveFromBook
     * @param requesterAssociateId
     * @return String
     */
    public static String getRemoveFromBookRequest(List<AgentRole__c> finalListForRemoveFromBook, string requesterAssociateId) {
 
        AP_RemoveFromBookAggregatorRequest req = new AP_RemoveFromBookAggregatorRequest();
        req.data=new List<AP_RemoveFromBookAggregatorRequest.RemoveFromBookData>();
            for(AgentRole__c ar:finalListForRemoveFromBook){
                AP_RemoveFromBookAggregatorRequest.RemoveFromBookData data = new AP_RemoveFromBookAggregatorRequest.RemoveFromBookData();
                data.clientIdentifier=ar.customer__r.clientidentifier__c;
                data.associateId=ar.Agent__r.Associate_ID__c;
                data.errors=Null;
                req.addDataList(data);
            }

        req.meta=getMetaInformation(requesterAssociateId);    
        return JSON.serialize(req);
    }  
    
        //Audit and Tracability Data Formation
    /**
     * @description Get Meta Information
     * @param associateId
     * @return AP_RemoveFromBookAggregatorRequest.RemoveFromBookMeta
     */
    public static AP_RemoveFromBookAggregatorRequest.RemoveFromBookMeta getMetaInformation(string associateId){
        AP_RemoveFromBookAggregatorRequest.RemoveFromBookMeta meta = new AP_RemoveFromBookAggregatorRequest.RemoveFromBookMeta();
        AP_RemoveFromBookAggregatorRequest.RemoveFromBookMetaAuditInfo auditInfo = new AP_RemoveFromBookAggregatorRequest.RemoveFromBookMetaAuditInfo();
        AP_RemoveFromBookAggregatorRequest.RemoveFromBookMetaAuditFields auditFields = new AP_RemoveFromBookAggregatorRequest.RemoveFromBookMetaAuditFields();
        AP_RemoveFromBookAggregatorRequest.RemoveFromBookMetaTraceabilityInfo traceabilityInfo = new AP_RemoveFromBookAggregatorRequest.RemoveFromBookMetaTraceabilityInfo();
        
        traceabilityInfo.affiliate='';
        traceabilityInfo.orginatingSourceId='';
        traceabilityInfo.orginatingSourceType='';
        traceabilityInfo.orginatingSourceTimestamp='';
        meta.traceabilityInfo=traceabilityInfo;
        
        
        auditFields.auditFieldValue='';
        auditFields.auditFieldType='';
        auditInfo.auditFields=auditFields;
        
        auditInfo.callingApplication=HLPR_CustAggt.CALLING_APP;
        auditInfo.callingArea=HLPR_CustAggt.CALLING_AREA;
        auditInfo.requesterReferenceId=associateId;
        auditInfo.requesterReferenceType='';
        meta.auditInfo=auditInfo;
        
        return meta;
    }
}
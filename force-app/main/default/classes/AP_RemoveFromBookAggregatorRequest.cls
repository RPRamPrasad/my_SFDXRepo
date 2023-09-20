/**
* @author : Team Loco Motivated / Targaryen
* @name : AP_RemoveFromBookAggregatorRequest
* This is JSON object for Remove From Book aggregator POST/PUT request 
* @description AP Remove From Book Aggregator Request
* @Date : 07/05/2018
**/

public with sharing class AP_RemoveFromBookAggregatorRequest {
    public List<RemoveFromBookData> data;
    public RemoveFromBookMeta meta;
    
    /**
     * @description Add Data List
     * @param removeFromBookdataItems
     */
    public void addDataList(RemoveFromBookData removeFromBookdataItems){
        data.add(removeFromBookdataItems);
    }
    
    /**
     * @description Remove From Book Data Errors
     */
    public with sharing class RemoveFromBookDataErrors {
        
    }

    /**
     * @description Remove From Book Data
     */
    public with sharing class RemoveFromBookData {
        public String clientIdentifier;
        public String associateId;
        public List<RemoveFromBookDataErrors> errors;
        
    }
    
    /**
     * @description Remove From Book Meta
     */
    public with sharing class RemoveFromBookMeta {
        public RemoveFromBookMetaAuditInfo auditInfo;
        public RemoveFromBookMetaTraceabilityInfo traceabilityInfo;
    }

    /**
     * @description Remove From Book Meta Audit Info
     */
    public with sharing class RemoveFromBookMetaAuditInfo {
        public String callingApplication;
        public String callingArea;  
        public String requesterReferenceId;
        public String requesterReferenceType;
        public RemoveFromBookMetaAuditFields auditFields;
    }

    /**
     * @description Remove From Book Meta Audit Fields
     */
    public with sharing class RemoveFromBookMetaAuditFields {
        public String auditFieldValue;  
        public String auditFieldType;   
    }
    
    /**
     * @description Remove From Book Meta Traceability Info
     */
    public with sharing class RemoveFromBookMetaTraceabilityInfo {
        public String affiliate;
        public String orginatingSourceId;  
        public String orginatingSourceType;
        public String orginatingSourceTimestamp;
    }      
}
/**
* @author Team Loco Motivated
* @name HLPR_C2CRelationshipAggregator
* This is JSON object for customer aggregator response 
* @description HLPR C2C Relationship Aggregator
* @Date : 11/29/2017
**/

public with sharing class HLPR_C2CRelationshipAggregator {
    private static final String CUSTOMER_TO_CUSTOMER = 'CustomerToCustomerRelationships';
    private static final String AFFILIATE = 'State Farm Mutual Automobile Insurance Company';
    private static final String AUDIT_FIELD_VALUE = 'ent delivery doc ID';
    private static final String AUDIT_FIELD_TYPE = 'ent delivery doc ID';

    /**
     * @description Get C2C Relationship Request
     * @param relWrap
     * @return String
     */
    public static String getC2CRelationshipRequest(C2CRelationshipReqWrapper relWrap) {
        
        String primaryclientId = relWrap.primaryclientId;
        String relatedClientId = relWrap.relatedClientId;
        String relationshipNature = relWrap.relationshipNature;
        string associateId = relWrap.associateId;

        AP_C2CRelationshipAggregatorRequest req = new AP_C2CRelationshipAggregatorRequest();
        req.data=new List<AP_C2CRelationshipAggregatorRequest.C2CRelationshipData>();
        AP_C2CRelationshipAggregatorRequest.C2CRelationshipData data = new AP_C2CRelationshipAggregatorRequest.C2CRelationshipData();
        AP_C2CRelationshipAggregatorRequest.C2CRelationshipAttributes attributes = new AP_C2CRelationshipAggregatorRequest.C2CRelationshipAttributes();
        
        data.type = CUSTOMER_TO_CUSTOMER;
        attributes.clientId = primaryclientId;
        attributes.relatedClientId = relatedClientId;
        attributes.relationshipNature = relationshipNature;
        data.attributes = attributes;
        req.addDataList(data);
        
        req.meta=getMetaInformation(associateId);    
        return JSON.serialize(req);
    }    
    
    //Audit and Tracability Data Formation
    /**
     * @description Get Meta Information
     * @param associateId
     * @return AP_C2CRelationshipAggregatorRequest.C2CRelationshipMeta
     */
    public static AP_C2CRelationshipAggregatorRequest.C2CRelationshipMeta getMetaInformation(string associateId){
        AP_C2CRelationshipAggregatorRequest.C2CRelationshipMeta meta = new AP_C2CRelationshipAggregatorRequest.C2CRelationshipMeta();
        AP_C2CRelationshipAggregatorRequest.C2CRelationshipAuditInfo auditInfo = new AP_C2CRelationshipAggregatorRequest.C2CRelationshipAuditInfo();
        AP_C2CRelationshipAggregatorRequest.C2CRelationshipAuditFields auditFields = new AP_C2CRelationshipAggregatorRequest.C2CRelationshipAuditFields();
        AP_C2CRelationshipAggregatorRequest.C2CRelationshipTraceabilityInfo traceabilityInfo = new AP_C2CRelationshipAggregatorRequest.C2CRelationshipTraceabilityInfo();
        
        traceabilityInfo.affiliate=AFFILIATE;
        traceabilityInfo.orginatingSourceId=associateId;// CurrentUser AssociateId
        traceabilityInfo.orginatingSourceType=HLPR_CustAggt.ASSOC_ID;
        traceabilityInfo.orginatingSourceTimestamp=String.valueOf(system.now());
        meta.traceabilityInfo=traceabilityInfo;
        
        
        auditFields.auditFieldValue=AUDIT_FIELD_VALUE;
        auditFields.auditFieldType=AUDIT_FIELD_TYPE;
        auditInfo.auditFields=auditFields;
        
        auditInfo.callingApplication=HLPR_CustAggt.CALLING_APP;
        auditInfo.callingArea=HLPR_CustAggt.CALLING_AREA;
        auditInfo.requesterReferenceId=associateId;
        auditInfo.requesterReferenceType=HLPR_CustAggt.ASSOC_ID;
        meta.auditInfo=auditInfo;
        
        return meta;
        
    }

    /**
     * @description C2C Relationship Reqest Wrapper
     */
    public class C2CRelationshipReqWrapper{
        public String primaryclientId;
        public String relatedClientId;
        public String relationshipNature;
        public string associateId;
    }
}
/****************************************************************************************
Name: AP_AddrStdAggtReq
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description This is JSON object for customer aggregator - Address standardization request

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Stark   		          11/23/2021             R20 Major Release
******************************************************************************************/
public with sharing class AP_AddrStdAggtReq {
    public Cls_address address;
    public Cls_meta meta;
    /**
     * @description inner class - address
     */
    public with sharing class Cls_address {
        public String street1; 
        public String street2;
        public String city;
        public String country;
        public String postalCode; 
        public String state;
    }
    /**
     * @description inner class - meta
     */
    public with sharing class Cls_meta {
        public Cls_auditInfo auditInfo;
    }
    /**
     * @description inner class - audit info
     */
    public with sharing class Cls_auditInfo {
        public String callingApplication;  
        public String callingArea;
        public String requesterReferenceId; 
        public String requesterReferenceType;
        public Cls_auditFields auditFields;
    }
    /**
     * @description inner class - audit fields
     */
    public with sharing class Cls_auditFields {
        public String auditFieldValue; 
        public String auditFieldType;
    }
    /**
     * @description description deserializing json into class
     * @method parse
     * @param json
     * @return AP_AddrStdAggtReq
     */
    public static AP_AddrStdAggtReq parse(String json){
        return (AP_AddrStdAggtReq) System.JSON.deserialize(json, AP_AddrStdAggtReq.class);
    }
}
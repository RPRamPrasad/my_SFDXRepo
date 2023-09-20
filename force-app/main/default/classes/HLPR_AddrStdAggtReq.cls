/****************************************************************************************
Name: HLPR_AddStdAggtReq
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description This is a helper class to create JSON request string for address standardization 

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Stark   		          11/29/2021             R20 Major Release
*****************************************************************************************/
public with sharing class HLPR_AddrStdAggtReq {
    public static final String ASSOC_ID = 'Enterprise ID - Associate';
    public static final String CALLING_APP = 'SALESFORCE.COM';
    public static final String CALLING_AREA = 'CROM CAAM';
    
    /**
     * @name getIndCreateCustReq
     * @description This method is used create individual customer post request
     * @param addressJSON
     * @param loggedInUser
     * @return String
     */
    public static String getCustAddrStdReq(String addressJSON, User loggedInUser) {
        CustAggtAddrStdReqWrapper reqWrap = (CustAggtAddrStdReqWrapper) JSON.deserializeStrict(addressJSON,CustAggtAddrStdReqWrapper.class);
        AP_AddrStdAggtReq req = new AP_AddrStdAggtReq();
        AP_AddrStdAggtReq.cls_address address = new AP_AddrStdAggtReq.cls_address();
        
        address.street1 = reqWrap.address1;
        address.street2 = reqWrap.address2;
        address.city = reqWrap.city;
        address.state = reqWrap.state;
        address.postalCode = reqWrap.zip;
        req.address = address;
        
        AP_AddrStdAggtReq.cls_meta meta = new AP_AddrStdAggtReq.cls_meta();
        AP_AddrStdAggtReq.cls_auditInfo auditInfo = new AP_AddrStdAggtReq.cls_auditInfo();
        
        auditInfo.callingApplication = CALLING_APP; // Once other areas (ie HAART) update their flow to use the wrapper, remove this hard-coding
        auditInfo.callingArea = CALLING_AREA;
        auditInfo.requesterReferenceType = ASSOC_ID;
        auditInfo.requesterReferenceId = String.valueOf(loggedInUser.Associate_ID__c);
        meta.auditInfo = auditInfo;
       	req.meta = meta;
        return JSON.serialize(req);
    }
    
    /**
    * @description This inner class is used to make request Address Wrapper JSON
    * @name : CustAggtAddrStdReqWrapper
    */
    public with sharing class CustAggtAddrStdReqWrapper {
        String address1;
        String address2;
        String city;
        String state;
        String zip;
    }
}
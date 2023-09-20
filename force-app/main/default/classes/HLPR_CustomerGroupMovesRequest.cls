/**
* @author Team Loco Motivated
* @name HLPR_CustomerGroupMovesRequest
* This is JSON object for Customer Group Member Moves Request
* @description HLPR Customer Group Moves Request
* @Date : 03/01/2018
**/

public with sharing class HLPR_CustomerGroupMovesRequest {
	
    /**
     * @description Get Customer Group Moves Request
     * @param req
     * @return String
     */
    public static String getCustomerGroupMovesRequest(AP_CustomerGroupMemberRequest req) {
             
        req.meta=getMetaInformation();   
        return JSON.serialize(req);
    }
    
    //Audit and Tracability Data Formation
    /**
     * @description Get Meta Information
     * @return AP_CustomerGroupMemberRequest.CustomerGroupMemberMeta
     */
    public static AP_CustomerGroupMemberRequest.CustomerGroupMemberMeta getMetaInformation(){
        User currentUser = [Select Associate_ID__c, Profile.Name from User Where Id = :UserInfo.getUserId()];
        string associateId=currentUser.Associate_ID__c;
        
        AP_CustomerGroupMemberRequest.CustomerGroupMemberMeta meta = new AP_CustomerGroupMemberRequest.CustomerGroupMemberMeta();
        meta.requester = new AP_CustomerGroupMemberRequest.CustomerGroupRequester();
        
        
        meta.callingApplication=HLPR_CustAggt.CALLING_APP;
        meta.callingArea=HLPR_CustAggt.CALLING_AREA;
        meta.requester.requesterReferenceId=associateId;
        meta.requester.requesterReferenceType=HLPR_CustAggt.ASSOC_ID;
        
        return meta;        
    }
}
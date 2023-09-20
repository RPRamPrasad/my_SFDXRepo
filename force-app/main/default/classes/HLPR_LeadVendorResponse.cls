/****************************************************************************************
Name: LeadVendorResponse
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: Class written to declare webservice response variables
Team: ImpactForce
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Kalimatha Mandadi         09/06/2016             Initial Development
******************************************************************************************/
/**
 * @description HLPR_LeadVendorResponse
 */
global with sharing class HLPR_LeadVendorResponse{
    webservice Integer response_code;
    webservice  String  response_msg;
 }
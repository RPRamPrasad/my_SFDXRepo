/****************************************************************************************
Name: GoodNeighborConnectUTILHelper
Copyright © State Farm
=========================================================================================
@description : Helper method that is AuraEnabled. Allows for use of 
			   UTIL_GoodNeighborConnect.meetNow method. Also Helps fix the
			  'No direct DML from Lightning controllers' scan issue.
Team: ITIC
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ITIC               		  8/17/2021             	 Initial Development

******************************************************************************************/ 
public with sharing class GoodNeighborConnectUTILHelper {
    private static final String CLASS_NAME = 'GoodNeighborConnectUTILHelper';
    private static final String METHOD_NAME = 'createVirtualMeetingRecord';

	/**
    * @description createVirtualMeetingRecord
    * @method - Creates a virtual meeting record and adds virtual meeting particpants
    * @param gncParams - Array of string values coming from goodNeighborConnect LWC
    * @param accountId - Account ID of the participant to be added
    */   
    @AuraEnabled
    public static void createVirtualMeetingRecord(List<String> gncParams, string accountId){
        UTIL_GoodNeighborConnect.VirtualMeetingAttributes vmattributes = new UTIL_GoodNeighborConnect.VirtualMeetingAttributes();
        
        Datetime startDate = (DateTime)JSON.deserialize('"' + gncParams[2] + '"', DateTime.class);
        Datetime endDate = (DateTime)JSON.deserialize('"' + gncParams[3] + '"', DateTime.class);
        
        vmattributes.virtualMeetingId = null;
        vmattributes.meetingHost = gncParams[0];
        vmattributes.meetingPurpose = gncParams[1];
        vmattributes.startDateTime = startDate;
        vmattributes.endDateTime = endDate;
        
        try{
            UTIL_GoodNeighborConnect.meetNow(vmattributes, accountId);
        }catch (Exception gncCreationHelperException) {
            LoggingService.logHandledException(gncCreationHelperException, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
        }
    }
}
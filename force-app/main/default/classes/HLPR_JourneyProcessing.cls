/****************************************************************************************
Name: HLPR_JourneyProcessing
Copyright © State Farm
@description This class will be invoked by Journey object Triggers 
Team: ClubCar
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  07/22/2021              Initial Development
******************************************************************************************/ 
public with sharing class HLPR_JourneyProcessing {

    private static Boolean isBeforeInsertTriggerFirstRun = true;
    private static final Integer JNYVENDORCODE = 0;
    private static final String CLASS_NAME = 'AP_JourneyProcessing';
    private static final String METHOD_NAME = 'populateJourneyNonUIFields';
    private static final String TEXT_XDATE = 'Xdate';
    private static Map<String, String> categoryMethTargetGroupMap = new Map<String, String>{'Corporate assigned' => '01', 'Prospect customers' => '00',
                                                                     'Lead campaigns' => '01', 'Customer prospect campaigns' => '00', 'Cases' => '02'};
    /**
    * @method - populateJourneyNonUIFields
    * @description - This method will be invoked by Journey Before Insert Trigger
    *                will populate Journey fields that are not populated through UI
    * @param jnyList - List of Journeyc records passed by Before Insert Trigger operation
    */    
    public static void populateJourneyNonUIFields (List<Journey__c> jnyList) {
        if(isBeforeInsertTriggerFirstRun){
            isBeforeInsertTriggerFirstRun = false;
            try {
                String loggedInUsrAlias = getLoggedInUserAlias();
                //populate non ui fields in pre insert trigger    
                for (Journey__c jny : jnyList) {
                    if(String.isBlank(jny.UserAlias__c)) {
                        jny.UserAlias__c = loggedInUsrAlias;
                        jny.InsertTimestamp__c = System.Now();
                        jny.VendorCode__c = JNYVENDORCODE ;
                        jny.TargetGroupCode__c = getTargetGroupCode(jny);
                        jny.TimingTypeCode__c =  getTimingTypeCode(jny);
                    } 
                    if(jny.AppliestoAllStates__c) {
                        jny.applicableStates__c = null;
                        }             
                    }
            }
            catch (Exception jnyBeforeInsertException) {
                LoggingService.logHandledException(jnyBeforeInsertException, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);  
            }
        }
    }

    // private method to query User Alias based on CRUD validation
    private static String getLoggedInUserAlias() {
        return [SELECT Alias from User where id =: userinfo.getUserId()WITH SECURITY_ENFORCED LIMIT 1].Alias;  
    }
    /**
     * @description getTargetGroupCode
     * @param jny
     * @return string
     */
    //Retrive Journey TargetGroupCode__c based on Journey CategoryName
    public static string getTargetGroupCode (Journey__c jny) {
        String targetGroupCode = null;
        if (categoryMethTargetGroupMap.containsKey(jny.CategoryName__c)) {
            targetGroupCode = categoryMethTargetGroupMap.get(jny.CategoryName__c);
        }
        return targetGroupCode;
    }
    
    //Retrive Journey TimingTypeCode__c based on Journey Type Xdate or Standard
    private static Integer getTimingTypeCode (Journey__c jny) {
        Integer timingTypeCode = null;
        if (jny.Type__c.containsIgnoreCase(TEXT_XDATE)) {
            timingTypeCode = 2;                        
        }
        else {
            timingTypeCode = 1;
        }
        return timingTypeCode;
    }
}
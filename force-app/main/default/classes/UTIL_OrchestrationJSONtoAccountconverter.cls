/**
* @Name UTIL_OrchestrationJSONtoAccountconverter
* @Author Team Dream Builders, Team Loco-Motivated
* @description UTIL_OrchestrationJSONtoAccountconverter class is used to convert JSON Account blocks to Account Objects
*/
public with sharing class UTIL_OrchestrationJSONtoAccountconverter {
    
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();    
    private static final String ACCOUNT='Account';
    private static final String UNITED_STATES = 'UNITED STATES';
    private static final String OVERSEAS_MILITARY = 'Overseas Military';
    private static List<CM_StageOrchestration_Mapping__mdt> mappingForJSONToAccountMapping = [SELECT Mapping_Type__c,Source_Field__c,Target_Field__c
                                                                                              FROM CM_StageOrchestration_Mapping__mdt
                                                                                              WHERE Mapping_Type__c=:UTIL_StageOrchestrationConstants.JSON_TO_ACCOUNT_MAPPING];
    
    private static List<CM_StageOrchestration_Mapping__mdt> mappingForJSONToPreferenceAccountMapping = [SELECT Mapping_Type__c,Source_Field__c,Target_Field__c
                                                                                                        FROM CM_StageOrchestration_Mapping__mdt
                                                                                                        WHERE Mapping_Type__c=:UTIL_StageOrchestrationConstants.JSON_TO_PREFERENCES_ACCOUNT_MAPPING];
    
    /**
    * This method takes AP_StageOrchestrationJSONParser Object, loops through orchestrationDataNames, and converts them into a List of Account objects
    * 
    * @name jsontoAccountConverter
    * @description JSON To Account Converter
    * @param parseJSON
    * @return List<Account>
    */ 
    public static List<Account> jsontoAccountConverter(AP_StageOrchestrationJSONParser parseJSON){ 
        List<Account> accounts = new List<Account>();
        for (AP_StageOrchestrationJSONParser.OrchestrationDataName orchestrationDataName : parseJSON.orchestrationInfo.orchestrationDataName) {
            if(ACCOUNT.equalsIgnoreCase(orchestrationDataName.orchestrationNameDetail.dataName)){
                Account acct = new Account();
                acct = insertJsonToAccountFields(acct,orchestrationDataName);
                acct = insertJsonPrefToAccountFields(acct,orchestrationDataName);
                acct.ClientIdentifier__c  = orchestrationDataName.orchestrationNameDetail.dataExternalKeyValue;
                acct.ClientIdentifier__pc  = orchestrationDataName.orchestrationNameDetail.dataExternalKeyValue;
                acct.ExternalSourceSyncTime__c = orchestrationDataName.orchestrationNameDetail.externalSourceSyncTime;
                accounts.add(acct);
            }
        }
        return accounts;
    }
    
    /**
    * This method takes Account Object and JSON OrchestrationDataName and inserts the OrchestrationDataName values into the Account
    * 
    * @name insertJsonToAccountFields
    * @description Insert JSON To Account Fields
    * @param acct
    * @param orchDataName
    * @return Account
    */
    private static Account insertJsonToAccountFields(Account acct,AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName){
        AP_StageOrchestrationJSONParser.OrchestrationDataValues dataValues = orchDataName.orchestrationNameDetail.orchestrationDataValues;
        String jsonString=JSON.serialize(dataValues);
        Map<String,Object> jsonrecordsMap=(Map<String, Object>) JSON.deserializeUntyped(jsonString);
        jsonRecordsMap = UTIL_OrchestrationDataTransformation.transformJsonData(jsonrecordsMap);
        for(CM_StageOrchestration_Mapping__mdt mappingLoopForList : mappingForJSONToAccountMapping){
            //To Filter out other fields which are defined for agent role
            if(jsonrecordsMap.containsKey(mappingLoopForList.Source_Field__c) && 
            		(!UTIL_StageOrchestrationConstants.ADDL_BUSINESS_DATA_FIELDS.contains(mappingLoopForList.Source_Field__c.toLowerCase()) || 
            			toggleContext.isNotActive(UTIL_Toggles.ADDLBUSINESSDATAFIELDS))){
                String targetAccountField = mappingLoopForList.Target_Field__c;
                object valueFromJSON = jsonrecordsMap.get(mappingLoopForList.Source_Field__c);
                acct.put(targetAccountField, valueFromJSON);
                }
            }
        return acct;
    }

    /**
    * This method takes Account Object and JSON OrchestrationDataName and inserts the OrchestrationDataName preference values into the Account
    * 
    * @name insertJsonPrefToAccountFields
    * @description Insert JSON Pref To Account Fields
    * @param acct
    * @param orchDataName
    * @return Account
    */     
    private static Account insertJsonPrefToAccountFields(Account acct,AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName){
        AP_StageOrchestrationJSONParser.OrchestrationDataValues dataValues = orchDataName.orchestrationNameDetail.orchestrationDataValues;
        if (dataValues.preferences!=NULL&&!dataValues.preferences.isEmpty()) {
            for (CM_StageOrchestration_Mapping__mdt preferenceMappingInstance : mappingForJSONToPreferenceAccountMapping){
                Object prefValue=setPreferencesAppropriately(dataValues,preferenceMappingInstance);
                acct.put(preferenceMappingInstance.Target_Field__c,prefValue);
            }
        }else{
            acct=setPreferencetoNull(acct);
        }
        return acct;
    }

    /**
    * This method takes JSON Orchestration DataValues and Preference instance from Custom Metadata and set the correct Preference Value from JSON for particular Metadata instance
    * 
    * @name setPreferencesAppropriately
    * @description Set Preferences Appropriately
    * @param dataValues
    * @param preferenceMappingInstance
    * @return Object
    */   
    private static Object setPreferencesAppropriately(AP_StageOrchestrationJSONParser.OrchestrationDataValues dataValues,
                                                       CM_StageOrchestration_Mapping__mdt preferenceMappingInstance){
                Object prefValue=null;

                for(AP_StageOrchestrationJSONParser.Preferences prefDataValue : dataValues.preferences){
                    String valueForPrefConversion = String.valueOf(prefDataValue.preferenceValue);

                    if (preferenceMappingInstance.Source_Field__c.equalsIgnoreCase(prefDataValue.preferenceType) && 
                    		(!UTIL_StageOrchestrationConstants.ADDL_BUSINESS_DATA_FIELDS.contains(preferenceMappingInstance.Source_Field__c.toLowerCase()) || 
            				toggleContext.isNotActive(UTIL_Toggles.ADDLBUSINESSDATAFIELDS))){
                       prefValue=UTIL_OrchestrationDataTransformation.transformPreferences(prefDataValue.preferenceType, valueForPrefConversion);
                       break;
                    }else{
                        prefValue=UTIL_OrchestrationDataTransformation.transformPreferences(preferenceMappingInstance.Source_Field__c, null);
                    }
                    
                }
                                                         
       return prefValue;
    }

    /**
    * This method takes Account Object and set the null Preference Value to Account
    * 
    * @name setPreferencetoNull
    * @description Set Preference To Null
    * @param acct
    * @return Account
    */     
    private static Account setPreferencetoNull(Account acct){
        for (CM_StageOrchestration_Mapping__mdt mappingLoopForPrefList : mappingForJSONToPreferenceAccountMapping){
               acct.put(mappingLoopForPrefList.Target_Field__c, UTIL_OrchestrationDataTransformation.transformPreferences(mappingLoopForPrefList.Source_Field__c, null));
            }
        return acct;
    }
}
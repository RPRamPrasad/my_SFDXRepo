/**
@author Team TARGARYEN
@owner Team TARGARYEN
@name UTIL_EnterpriseCustomerSearch
@CreateDate 07/21/2022
@modifiedDate
@description This class is used by LWC Enterprise Customer Search components to leverage the AccountContactRelation object operations
@version 1.0
*/

public with sharing class UTIL_EnterpriseCustomerSearch {

    @TestVisible
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    private static final String CLASS_NAME = 'UTIL_EnterpriseCustomerSearch';



    /**
    * @description This method is used to retrieve record types
    * @name : fetchCustomerRecordTypes
    * @return List<RecordType>
    */
    @AuraEnabled(cacheable=true)
    public static List<RecordType> fetchCustomerRecordTypes() { 
        return UTIL_AccountCreateEditHelper.getAccountRecordTypes(); 
    } 

    /**
    * @description This method is used to retrieve State/Province data
    * @name : getStateProvinceData
    * @param searchKey : inout search key
    * @return List<String> : output state or province data
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getStateProvinceData(String searchKey) {
        List<String> stateOptions = new List <String>();
        List<CM_US_Canada_State__mdt> states = UTIL_AccountCreateEditHelper.getStateProvinceData(searchKey);
        for(CM_US_Canada_State__mdt state : states) { stateOptions.add(state.DeveloperName + ',' + state.MasterLabel); }
        return stateOptions;
    }

    /**
    * @description This method is used to retrieve Military city data
    * @name : getMilitaryCityData
    * @return List<String>
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getMilitaryCityData() {
        List<String> cityOptions = new List <String>();
        List<CM_US_Canada_State__mdt> cities = UTIL_AccountCreateEditHelper.getMilitaryCityData(UTIL_CreateCustomerConstants.OVERSEAS_MILITARY);
        for(CM_US_Canada_State__mdt city : cities) { cityOptions.add(city.DeveloperName + ',' + city.MasterLabel); }
        return cityOptions;
    }

    /**
     * @description Validate And Save
     * @param accountJSON
     * @param reqJSON
     * @param isNewCustomer
     * @return Object
     */
    @AuraEnabled(continuation=true)
    public static Object validateAndSave(String accountJSON, String reqJSON, Boolean isNewCustomer) {
        return UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
    }


}
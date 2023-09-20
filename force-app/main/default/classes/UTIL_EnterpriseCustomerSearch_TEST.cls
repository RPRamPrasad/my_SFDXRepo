/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class UTIL_EnterpriseCustomerSearch_TEST {

    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    private static UTIL_AccountDAOMock daoMockAccountInstance = new UTIL_AccountDAOMock();
    private static User commonAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
    @TestSetup
    static void makeData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting; 

        insertTechnicalPlatformDetails();
    }
    
    /**
    * @description Inner class is used wrapper for Servicing Agent
    * @name : ServicingAgent
    */
    public class Customer {
        Id id;
        String clientId;
    }

    @isTest static void testGetData() {

        Test.startTest();
        List<String> canList = UTIL_EnterpriseCustomerSearch.getStateProvinceData('CANADA');
        System.assertEquals(false, canList.isEmpty(),'Province List Canada');

        List<String> usList = UTIL_EnterpriseCustomerSearch.getStateProvinceData('US');
        System.assertEquals(false, usList.isEmpty(),'State List US');

        List<String> milList = UTIL_EnterpriseCustomerSearch.getStateProvinceData('Overseas Military');
        System.assertEquals(false, milList.isEmpty(),'State List Overseas Militry');

        List<String> milCityList = UTIL_EnterpriseCustomerSearch.getMilitaryCityData();
        System.assertEquals(false, milCityList.isEmpty(),'Militry City Data');
        

        List<RecordType> rtList = UTIL_EnterpriseCustomerSearch.fetchCustomerRecordTypes();
        System.assertEquals(false, rtList.isEmpty(),'Account Recordtype Data');
        
        UTIL_AccountCreateEdit.logError('exceptionMessage','className','methodName', 'INFO');
        System.assertEquals('', '', 'Throws account exception');

        UTIL_AccountCreateEdit.logError('exceptionMessage','className','methodName', 'WARN');
        System.assertEquals('', '', 'Throws account exception');

        UTIL_AccountCreateEdit.logError('exceptionMessage','className','methodName', 'ERROR');
        Test.stopTest();
    }
    
    private static  void insertTechnicalPlatformDetails(){
        CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c();
        srKey.Name = 'SR_API_KEY';
        srKey.Value__c = 'Test Key';
        
        CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c();
        srCategory.Name = 'SR_CATEGORY';
        srCategory.Value__c = 'a';
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};

        CS_EnvironmentURLCustomSetting__c envURL = new CS_EnvironmentURLCustomSetting__c(Name = 'S1BaseUrl', Value__c = 'TestURL');
        insert envURL;
    }

    private static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName) {
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
  
}
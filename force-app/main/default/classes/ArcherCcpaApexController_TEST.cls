@isTest(seeAllData = false)
public class ArcherCcpaApexController_TEST {
    /**
     * @description testSetUpData
     */
	@testsetup
	public static void testSetUpData(){
		UTIL_CaseTestData.setUpUsersForCase();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            createAccountAndContact();
            Id accountId = UTIL_CaseTestData.getAccount().Id;
            UTIL_CaseTestData.createAgentRoleList(accountId);
        }
    	      
   }
    /**
     * @description createAccountAndContact
     */
   public static void createAccountAndContact(){
        Id accountId;
        accountId = UTIL_CaseTestData.createAccountId();
        UTIL_CaseTestData.contactId();
    } 
    
    /**
     * @description createCustomSetting
     * @return  `CS_EnvironmentURLCustomSetting__c`
     */
    public static CS_EnvironmentURLCustomSetting__c createCustomSetting(){
        CS_EnvironmentURLCustomSetting__c ccpaFormUrl = new CS_EnvironmentURLCustomSetting__c(Name='CCPA_Request_Form_URL',Value__c='https://sfarcherautoweb.unitopr.unitint.test.statefarm.org/DataAccessRequest/');
        insert ccpaFormUrl;
        return ccpaFormUrl;
    } 
    
   @isTest	
   private static void testGetUrl(){
        Test.startTest();
   		createCustomSetting();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(UTIL_CaseTestData.getAgentUser());
        System.runAs(UTIL_CaseTestData.getAgentUser()) {
            CS_EnvironmentURLCustomSetting__c ccpaFormUrl = CS_EnvironmentURLCustomSetting__c.getInstance('CCPA_Request_Form_URL');            
            String ccpaUrl = ArcherCcpaApexController.getCcpaFormUrl();
            System.assertEquals(ccpaFormUrl.Value__c , ccpaUrl, 'Expected value is '+ccpaFormUrl.Value__c+', but actual value is '+ccpaUrl);
            Test.stopTest();
        }
        
    }
    
}
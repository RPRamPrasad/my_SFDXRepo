/**
* @Author Team Loco Motivated
* @description UTIL_ProductsServicedByMeDAO_Test
* @CreateDate 04/18/2018
* @Description This test class provides test coverage for UTIL_ProductsServicedByMeDAO class.
* @Version : 1.0
*/
@isTest(SeeAllData = false)
public class UTIL_ProductsServicedByMeDAO_Test {
    
    private static User systemUser;
    private static User testAPIUser;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT12';
    private static Account accrecord;
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
	private static String recordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
    
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    /**
     * @description setup
     */
    public static void setup() {
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        systemUser=UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        insert systemUser;
        insert testAPIUser;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
		UTIL_OverrideSystemUser_TEST.doOverride();
    }
    /**
     * @description testSetupData
     */
    @testsetup
    public static void testSetupData() {        
        User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID); 
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
    }
    
    @isTest
    static void testProductsServicedByMeDelete(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);
        accrecord = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER,RecordTypeId = recordTypeId,Edit_In_VFP__c = true);
        List<ProductsServicedByMe__c> productsServicedBeMeList = new List<ProductsServicedByMe__c>();
        setup();        
        system.runAs(testAPIUser){
            Test.startTest();
            insert accrecord;
            productsServicedBeMeList.add(new ProductsServicedByMe__c(Agent__c=salesRoleHierarchy1.Agent.Id,
                                                                     ProductLine__c='Auto',ProductType__c='ATV',CarrierName__c='Assigned Risk/JUA',
                                                                     Customer__c = accrecord.Id));
            
            system.runAs(systemUser){
                insert new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accrecord.Id);
            }
            system.runAs(salesRoleHierarchy1.Agent){
                insert productsServicedBeMeList;
            }
            UTIL_ProductsServicedByMeDAO.deleteProductsServicedByMe(productsServicedBeMeList);           
            Test.stopTest();   
        }
        
        List<ProductsServicedByMe__c> testProductsServicedByMe=[SELECT Id FROM ProductsServicedByMe__c where id IN : productsServicedBeMeList];
        system.assert(testProductsServicedByMe.isEmpty(),'Expected '+testProductsServicedByMe+' to be Empty');
    }

}
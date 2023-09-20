/**
* @name CombineVerifyControllerTest  
* @owner Atlas
* @date 10/11/2018  
* @description Combine Customers Page Onload controller to get customer group members
*/

@isTest(seeAllData = false)
public class CombineVerifyControllerTest {
    
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');    
    private static User systemAdminUser;
    private static account accRecord1 = new Account(FirstName='FNameForMerge1',LastName='LNameForMerge1',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP71L8XB', PersonBirthdate=Date.valueOf('2013-05-05'));
    private static account accRecord2 = new Account(FirstName='FNameForMerge2',LastName='LNameForMerge2',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP81L8XB', PersonBirthdate=Date.valueOf('2009-05-05'));
    private static account accRecord3 = new Account(FirstName='FNameForMerge3',LastName='LNameForMerge3',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP41L8XB');
    private static account accRecord4 = new Account(FirstName='FNameForMerge4',LastName='LNameForMerge4',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP01L8XB');        
    private static account accRecord5 = new Account(FirstName='FNameForMerge5',LastName='LNameForMerge5',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP11L8XB');        
    private static account accRecord6 = new Account(FirstName='FNameForMerge6',LastName='LNameForMerge6',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP21L8XB');        
    
    // Create the accounts and the relationships
    private static void createAccountsAndRelationships() {
        List<Account> accList= new List<Account>{accRecord1,accRecord2,accRecord3,accRecord4,accRecord5,accRecord6};

        insert accList;
        Relationship__c relationship1;
        Relationship__c relationship2;
        relationship1 = new Relationship__c(AccountOne__c=accRecord3.id,AccountTwo__c=accRecord1.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord3.ClientIdentifier__c + '~' + accRecord1.ClientIdentifier__c);
        relationship2 = new Relationship__c(AccountOne__c=accRecord4.id,AccountTwo__c=accRecord2.id,RelationshipType__c='Child',RelationshipIdentifier__c=accRecord4.ClientIdentifier__c + '~' + accRecord2.ClientIdentifier__c);

        List<Relationship__c> relList = new List<Relationship__c>{relationship1,relationship2};
        insert relList;
    }

    /**
     * @description This method will create test data
     */
    @TestSetup
    public static void setup() {
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        System.runAs(systemAdminUser){
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            createAccountsAndRelationships();
        }
    }
    //getAcocunt and Relations
    private static void getAccandRel(){
        List<Account> acclst = [Select Id,ClientIdentifier__c from Account 
        where FirstName in ('FNameForMerge1','FNameForMerge2') order by FirstName];
        accRecord1 = acclst.get(0);
        accRecord2 = acclst.get(1);
    }
    //get admin user
    private static void getadminUser(){
        systemAdminUser = [Select Id from User where username=:SYSADMIN_USER_ID];
    }

    @isTest
    private static void testGetRelationshipDetails() {
        Test.startTest();
        getAccandRel();
        getadminUser();
        System.runAs(systemAdminUser){
        	String [] clientIDs = new List<String>{accRecord1.ClientIdentifier__c,accRecord2.ClientIdentifier__c};
            List<List<String>> relations = CombineVerifyController.getRelationshipDetails(clientIDs);
            system.assertEquals(2, relations.size(), 'Size of List<List<String>> should be 2');
       }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetLoggedInUserAlias() {
        getadminUser();
        Test.startTest();
        System.runAs(systemAdminUser){
           String alias = CombineVerifyController.getLoggedInUserAlias();
           System.assertEquals('admin', alias, 'Expected alias should be equals to the actual alias');
       }
        Test.stopTest();
    }
}
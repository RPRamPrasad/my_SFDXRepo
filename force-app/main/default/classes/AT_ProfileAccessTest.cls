/**
* Author : Team Kraken
* Date Created : 9/5/2018
* @description : test for class that retrieves OData for AT_StateFarmProducts lightning component
* Version : 1.0
*/
@isTest(SeeAllData=false)
public class AT_ProfileAccessTest {       
    @isTest
    private static void testHasCreateNewPSBMAccessTrue() {
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
            Billing_Summary__c=False,           //access is controlled by tab filtering
            Claim_Summary__c=False,             //access is controlled by tab filtering
            ABS_Activities_Summary__c=False,    //access is controlled by tab filtering
            ProductsServicedByMe__c=False, 
            ProductsWithOthers__c=False, 
            Life_Asc_Policy_View__c=False, 
            Life_Policy_View__c=False, 
            AutoLoadProductsOnGroupingPage__c = False, 
            AutoLoadProductsOnAccountPage__c = False, 
            Phoenix_Policy_View__c=False, 
            Claims_Detail__c=False, 
            Create_New_SFPP__c=False, 
            Policy_Transactions__c=False, 
            StateFarm_Products__c=False, 
            Create_New_PSBM__c=True, 
            Create_New_PWOC__c=False,
            View_CreateTask__c=False);
        
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasCreateNewPSBMAccess();
        }
        Test.stopTest();
        
        System.assertEquals(true, returnValue, 'Access should be true');
    }
    
    @isTest
    private static void testHasCreateNewPSBMAccessFalse() {
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
            Billing_Summary__c=True,           //access is controlled by tab filtering
            Claim_Summary__c=True,             //access is controlled by tab filtering
            ABS_Activities_Summary__c=True,    //access is controlled by tab filtering
            ProductsServicedByMe__c=True, 
            ProductsWithOthers__c=True, 
            Life_Asc_Policy_View__c=True, 
            Life_Policy_View__c=True, 
            AutoLoadProductsOnGroupingPage__c = true, 
            AutoLoadProductsOnAccountPage__c = true, 
            Phoenix_Policy_View__c=True, 
            Claims_Detail__c=True, 
            Create_New_SFPP__c=True, 
            Policy_Transactions__c=True, 
            StateFarm_Products__c=True, 
            Create_New_PSBM__c=False, 
            Create_New_PWOC__c=True,
            View_CreateTask__c=True);
        
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasCreateNewPSBMAccess();
        }
        Test.stopTest();
        
        System.assertEquals(false, returnValue, 'Access should be false');
    }
    @isTest
    private static void testHasCreateNewPWOCAccessTrue() {
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
            Billing_Summary__c=False,           //access is controlled by tab filtering
            Claim_Summary__c=False,             //access is controlled by tab filtering
            ABS_Activities_Summary__c=False,    //access is controlled by tab filtering
            ProductsServicedByMe__c=False, 
            ProductsWithOthers__c=False, 
            Life_Asc_Policy_View__c=False, 
            Life_Policy_View__c=False, 
            AutoLoadProductsOnGroupingPage__c = False, 
            AutoLoadProductsOnAccountPage__c = False, 
            Phoenix_Policy_View__c=False, 
            Claims_Detail__c=False, 
            Create_New_SFPP__c=False, 
            Policy_Transactions__c=False, 
            StateFarm_Products__c=False, 
            Create_New_PSBM__c=False, 
            Create_New_PWOC__c=True,
            View_CreateTask__c=False);
        
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasCreateNewPWOCAccess();
        }
        Test.stopTest();
        
        System.assertEquals(true, returnValue, 'Access should be true');
    }
    
    @isTest
    private static void testHasCreateNewPWOCAccessFalse() {
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
            Billing_Summary__c=True,           //access is controlled by tab filtering
            Claim_Summary__c=True,             //access is controlled by tab filtering
            ABS_Activities_Summary__c=True,    //access is controlled by tab filtering
            ProductsServicedByMe__c=True, 
            ProductsWithOthers__c=True, 
            Life_Asc_Policy_View__c=True, 
            Life_Policy_View__c=True, 
            AutoLoadProductsOnGroupingPage__c = true, 
            AutoLoadProductsOnAccountPage__c = true, 
            Phoenix_Policy_View__c=True, 
            Claims_Detail__c=True, 
            Create_New_SFPP__c=True, 
            Policy_Transactions__c=True, 
            StateFarm_Products__c=True, 
            Create_New_PSBM__c=True, 
            Create_New_PWOC__c=False,
            View_CreateTask__c=True);
        
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasCreateNewPWOCAccess();
        }
        Test.stopTest();
        
        System.assertEquals(false, returnValue, 'Access should be false');
    }
    
    @isTest
    private static void testHasClaimsDetailTrue() {
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
            Billing_Summary__c=True,           //access is controlled by tab filtering
            Claim_Summary__c=True,             //access is controlled by tab filtering
            ABS_Activities_Summary__c=True,    //access is controlled by tab filtering
            ProductsServicedByMe__c=True, 
            ProductsWithOthers__c=True, 
            Life_Asc_Policy_View__c=True, 
            Life_Policy_View__c=true, 
            AutoLoadProductsOnGroupingPage__c = true, 
            AutoLoadProductsOnAccountPage__c = true, 
            Phoenix_Policy_View__c=True, 
            Claims_Detail__c=True, 
            Create_New_SFPP__c=True, 
            Policy_Transactions__c=True, 
            StateFarm_Products__c=True, 
            Create_New_PSBM__c=True, 
            Create_New_PWOC__c=True,
            View_CreateTask__c=True,
            View_Auto_Detail__c=True,
            View_Fire_Detail__c=True,
            View_Health_Detail__c=True,
            View_MutualFunds_Detail__c=False
        );
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasClaimsDetailView();
        }
        Test.stopTest();
        
        System.assertEquals(true, returnValue, 'Access should be true');
    }
    
    @isTest
    private static void testHasClaimsDetailFalse() {
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
            Billing_Summary__c=True,           //access is controlled by tab filtering
            Claim_Summary__c=True,             //access is controlled by tab filtering
            ABS_Activities_Summary__c=True,    //access is controlled by tab filtering
            ProductsServicedByMe__c=True, 
            ProductsWithOthers__c=True, 
            Life_Asc_Policy_View__c=True, 
            Life_Policy_View__c=true, 
            AutoLoadProductsOnGroupingPage__c = true, 
            AutoLoadProductsOnAccountPage__c = true, 
            Phoenix_Policy_View__c=True, 
            Claims_Detail__c=False, 
            Create_New_SFPP__c=True, 
            Policy_Transactions__c=True, 
            StateFarm_Products__c=True, 
            Create_New_PSBM__c=True, 
            Create_New_PWOC__c=True,
            View_CreateTask__c=True,
            View_Auto_Detail__c=True,
            View_Fire_Detail__c=True,
            View_Health_Detail__c=True,
            View_MutualFunds_Detail__c=False
        );
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasClaimsDetailView();
        }
        Test.stopTest();
        
        System.assertEquals(false, returnValue, 'Access should be false');
    }

    @isTest
    private static void testPolicySyncAccessTrue(){
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView = new CS_CustomerSummaryView__c(
            Policy_Sync_Access__c = true
        );
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasPolicySyncAccess();
        }
        Test.stopTest();
        
        System.assertEquals(true, returnValue, 'Access should be true');
    }
    
    @isTest
    private static void testPolicySyncAccessFalse(){
        Boolean returnValue;
        User technicalSupport = TestDataFactory_User_Wrapper.generateTechSupportUser('TEST', '12345678915');
        AT_ProfileAccess.mockCustomerSummaryView = new CS_CustomerSummaryView__c(
            Policy_Sync_Access__c = false
        );
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(technicalSupport);
        System.runAs(technicalSupport){
        returnValue = AT_ProfileAccess.hasPolicySyncAccess();
        }
        Test.stopTest();
        
        System.assertEquals(false, returnValue, 'Access should be false');
    }
}
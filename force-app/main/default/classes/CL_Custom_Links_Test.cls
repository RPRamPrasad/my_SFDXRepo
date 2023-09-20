/**
* @author : Team Kraken
* @date Created : 11/8/2018
* @description : test for class that builds specific Custom Links for URLGateway in Lightning
* Version : 1.0
*/

@isTest(SeeAllData=false)
public class CL_Custom_Links_Test {
    
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
    
    @isTest
    private static void testbuildCIALinkPilotAgent200() {
        String gatewayValue;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            CL_Custom_Links.loggedInProfile = Label.CL_Agent_Profile;
            gatewayValue = CL_Custom_Links.buildCIALinkPilot('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=75&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCIALinkPilotATM201() {
        String gatewayValue;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agentTeamMember);

        System.runAs(salesRoleHierarchy1.agentTeamMember){
        	CL_Custom_Links.loggedInProfile = Label.CL_ATM_Profile;
        	gatewayValue = CL_Custom_Links.buildCIALinkPilot('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=75&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCIALinkPilotCCC300() {
        User cccUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678913');
        String gatewayValue;
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);

        System.runAs(cccUser){
        	CL_Custom_Links.loggedInProfile = Label.CL_CCCLicensedProfile;
        	gatewayValue = CL_Custom_Links.buildCIALinkPilot('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=75&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCIALinkPilotCCC301() {
        User cccUser = TestDataFactory_User_Wrapper.generateCCCUnLicensedUser('TEST', '12345678913');
        String gatewayValue;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);

        System.runAs(cccUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCUnLicensedProfile;
            gatewayValue = CL_Custom_Links.buildCIALinkPilot('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=75&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCIALinkPilotOS401() {
        User opSearchUser = TestDataFactory_User_Wrapper.generateActiveOperationsSearchUser('TEST', '12345678913');
        String gatewayValue;
        Test.startTest();
         TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(opSearchUser);

        System.runAs(opSearchUser){
            CL_Custom_Links.loggedInProfile = Label.CL_Operations_Search_Profile;
            gatewayValue = CL_Custom_Links.buildCIALinkPilot('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=75&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testBuildCIALinkPilotInMobile(){        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCIALinkPilot('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }

    @isTest
    private static void testBuildProfilePrintLinkWithAgent() {
       
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.Agent){
        String gatewayValue = CL_Custom_Links.buildProfilePrintLink('9099');
        
        String gateway = '/c/ExternalLinkApp.app?linkId=55&accountId=9099&ECEuser=true';    
        System.assertEquals(gateway, gatewayValue,'matched');
        
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testBuildProfilePrintLinkWithATM() {
       
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agentTeamMember);

        System.runAs(salesRoleHierarchy1.agentTeamMember){
        String gatewayValue = CL_Custom_Links.buildProfilePrintLink('9099');
        
        String gateway = '/c/ExternalLinkApp.app?linkId=55&accountId=9099&ECEuser=true';    
        System.assertEquals(gateway, gatewayValue,'matched');
        
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testBuildProfilePrintLinkInMobile(){
        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildProfilePrintLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testBuildCurrMarkOppsLink() {
        String gatewayValue;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
        	gatewayValue = CL_Custom_Links.buildCurrMarkOppsLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=80&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
   @isTest
    private static void testBuildCurrMarkOppsLinkInMobile(){
        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCurrMarkOppsLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testbuildCallTrackerLinkCCC300() {
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCLicensedProfile;
            gatewayValue = CL_Custom_Links.buildCallTrackerLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=227&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCallTrackerLinkCCC301() {
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCUnlicensedProfile;
            gatewayValue = CL_Custom_Links.buildCallTrackerLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=227&accountId=9099';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCallTrackerLinkInMobile(){
        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCallTrackerLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testbuildCIMAuthLinkCCC300() {
        
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCLicensedProfile;
            gatewayValue = CL_Custom_Links.buildCIMAuthLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=216&accountId=9099&userid=admin';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    
    @isTest
    private static void testbuildCIMAuthLinkCCC301() {
        
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCUnlicensedProfile;
            gatewayValue = CL_Custom_Links.buildCIMAuthLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=216&accountId=9099&userid=admin';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }

    @isTest
    private static void testBuildCIMAuthLinkAccountIPSWPermSet() {
        String gatewayValue;
        Test.startTest();
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(systemAdminUser.Id, 'Account_IPS_W');
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            gatewayValue = CL_Custom_Links.buildCIMAuthLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=216&accountId=9099&userid=admin';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildCIMAuthLinkInMobile(){
        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCIMAuthLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testbuildCIMAuthLinkNotAllowedProfile() {
        
        Test.startTest();
        CL_Custom_Links.loggedInProfile = Label.CL_TechSupport_Profile;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCIMAuthLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testbuildCallTrackerLinkNotAllowedProfile() {
        
        Test.startTest();
        CL_Custom_Links.loggedInProfile = Label.CL_TechSupport_Profile;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCallTrackerLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testbuildOCATLinkCCC301() {
        
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCUnlicensedProfile;
            gatewayValue = CL_Custom_Links.buildOCATLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=222&accountId=9099&userid=admin';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }

    @isTest
    private static void testbuildOCATLinkCCC300() {
        
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCLicensedProfile;
            gatewayValue = CL_Custom_Links.buildOCATLink('9099');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=222&accountId=9099&userid=admin';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void testbuildOCATLinkInMobile(){
        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildOCATLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    @isTest
    private static void testbuildOCATLinkNotAllowedProfile() {
        
        Test.startTest();
        CL_Custom_Links.loggedInProfile = Label.CL_TechSupport_Profile;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildOCATLink('9099');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
                Test.stopTest();
            }
        }
    }
    
    
    @isTest
    private static void buildCallTrackerLinkForCCCSalesOnAccountCreate() {
        String gatewayValue;
        Test.startTest();
        CL_Custom_Links.currentUser = systemAdminUser;
        System.runAs(systemAdminUser){
            CL_Custom_Links.loggedInProfile = Label.CL_CCCLicensedProfile;
            gatewayValue = CL_Custom_Links.buildCallTrackerLinkForCCCSalesOnAccountCreate('9099','');
        }
        Test.stopTest();
        String gateway = '/c/ExternalLinkApp.app?linkId=227&accountId=9099&callKey=';    
        System.assertEquals(gateway, gatewayValue,'matched');
    }
    
    @isTest
    private static void buildCallTrackerLinkForCCCSalesOnAccountCreateOnError() {
        
        Test.startTest();
        CL_Custom_Links.loggedInProfile = Label.CL_CCCLicensedProfile;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(salesRoleHierarchy1.agent){
            try {
                CL_Custom_Links.buildCallTrackerLinkForCCCSalesOnAccountCreate('','');
                System.assertNotEquals('should not get here', 'should not get here','matched');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    private static void buildCallTrackerLinkForCCCSalesOnAccountCreateOnMobile(){
        
        Test.startTest();
        CL_Custom_Links.isSalesforce1Theme = true;
        try {
            CL_Custom_Links.buildCallTrackerLinkForCCCSalesOnAccountCreate('9099','');
            System.assertNotEquals('should not get here', 'should not get here','matched');
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(),'matched');
        }
        Test.stopTest();
    }
    
}
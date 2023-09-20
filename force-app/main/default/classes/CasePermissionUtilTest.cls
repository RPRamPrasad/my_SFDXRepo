@isTest
(seeAllData=false)
private class CasePermissionUtilTest {

    
    
    @isTest
    private static void testisAllowedToChangeOwner(){
        Test.startTest();
        Case c = new Case(OwnerId = UserInfo.getUserId());
        CasePermissionUtil util = new CasePermissionUtil();
        System.assert(util.isAllowedToChangeOwner(c), 'isAllowedToChangeOwner');
        Test.stopTest();
    }
    
    @isTest
    private static void testisAllowedToChangeOwnerFalse(){
        Test.startTest();
        Case c = new Case(OwnerId = UnitTestDataUtility.MOCK_USER_ID);
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = false;
        System.assert(!caseUtil.isAllowedToChangeOwner(c), 'isAllowedToChangeOwner');
        Test.stopTest();
    }
    
    @isTest
    private static void testisPrevalidatedUser(){
        Test.startTest();
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = true;
        System.assert(caseUtil.isPrevalidatedUser(), 'isPrevalidatedUser');
        Test.stopTest();
    }
    
    @isTest
    private static void testisPrevalidatedUserFalse(){
        Test.startTest();
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = false;
        System.assert(!caseUtil.isPrevalidatedUser(), 'isPrevalidatedUser');
        Test.stopTest();
    }
    
    @isTest
    private static void testisCaseEscalationUser(){
        Test.startTest();
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = true;
        System.assert(caseUtil.isCaseEscalationUser(), 'isCaseEscalationUser');
        Test.stopTest();
    }
    
    @isTest
    private static void testisCaseEscalationUserFalse(){
        Test.startTest();
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = false;
        System.assert(!caseUtil.isCaseEscalationUser(), 'isCaseEscalationUser');
        Test.stopTest();
    }
    
    @isTest
    private static void testisTechSupportUser(){
        Test.startTest();
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = true;
        System.assert(caseUtil.isTechSupportUser(), 'isTechSupportUser');
        Test.stopTest();
    }
    
    @isTest
    private static void testisTechSupportUserFalse(){
        Test.startTest();
        CasePermissionUtil caseUtil = new CasePermissionUtil();
        caseUtil.util.setCustomPermission = true;
        caseUtil.util.mockBoolean = false;
        System.assert(!caseUtil.isTechSupportUser(), 'isTechSupportUser');
        Test.stopTest();
    }
 
        
}
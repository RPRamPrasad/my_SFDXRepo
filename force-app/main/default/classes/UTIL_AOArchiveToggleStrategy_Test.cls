@isTest(SeeAllData = false)
public with sharing class UTIL_AOArchiveToggleStrategy_Test {
    @isTest
    static void testIsActiveNoToggleDefined() {
        UTIL_AOArchiveToggleStrategy toggleStrategy = new UTIL_AOArchiveToggleStrategy();
        System.assertEquals(toggleStrategy.isActive(null,null), false, 'Expected isActive to return false');
    }

    @isTest
    static void testIsActiveToggleActive() {
        CM_Toggle__mdt toggle = new CM_Toggle__mdt();
        toggle.Enabled__c = true;
        UTIL_AOArchiveToggleStrategy toggleStrategy = new UTIL_AOArchiveToggleStrategy();
        System.assertEquals(toggleStrategy.isActive(toggle, null), true, 'Expected isActive to return true');
    }

    @isTest
    static void testIsActiveToggleInactive() {
        CM_Toggle__mdt toggle = new CM_Toggle__mdt();
        toggle.Enabled__c = false;
        UTIL_AOArchiveToggleStrategy toggleStrategy = new UTIL_AOArchiveToggleStrategy();
        System.assertEquals(toggleStrategy.isActive(toggle, null), false, 'Expected isActive to return false');
    }
}

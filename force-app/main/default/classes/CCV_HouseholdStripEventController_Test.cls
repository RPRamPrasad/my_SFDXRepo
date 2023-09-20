/**
 * @description This class is used to capture usage events on Household Strip
 * Click on lightning pages - TEST
 * @Date: 05/04/2023
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_HouseholdStripEventController_Test {
     @isTest
     private static void testAllClickEvents() {
         System.assert(CCV_HouseholdStripEventController.logClickAddMembers(),true);
         System.assert(CCV_HouseholdStripEventController.logClickRemoveMembers(),true);
         System.assert(CCV_HouseholdStripEventController.logClickMoveMembers(),true);
         System.assert(CCV_HouseholdStripEventController.logClickChangeMailingAddress(),true);
         System.assert(CCV_HouseholdStripEventController.logClickUpdateMembersRole(),true);
         System.assert(CCV_HouseholdStripEventController.logClickManageRelationships(),true);
         System.assert(CCV_HouseholdStripEventController.logClickAccount(),true);
         System.assert(CCV_HouseholdStripEventController.logClickHouseholdCall(),true);
         System.assert(CCV_HouseholdStripEventController.logClickHouseholdText(),true);
         System.assert(CCV_HouseholdStripEventController.logClickHouseholdEmail(),true);
         System.assert(CCV_HouseholdStripEventController.logClickShowAll(),true);
         System.assert(CCV_HouseholdStripEventController.logClickShowLess(),true);
         System.assert(CCV_HouseholdStripEventController.logLoadHouseholdMembers(),true);
         System.assert(CCV_HouseholdStripEventController.logClickHouseholdMembers(),true);
         System.assert(CCV_HouseholdStripEventController.logClickHouseholdRelationships(),true);
     }
}
/****************************************************************************************
Name: UTIL_LtngODataAccess_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test class for UTIL_LtngODataAccess

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             kdvb		         	  1/22/2019              2019 R1 Release

******************************************************************************************/

/**
 * @description UTIL Ltng OData Access Test
 */
@isTest(seeAllData=false)
public with sharing class UTIL_LtngODataAccess_TEST {
	
	//test method to fetch Web Enablement Status.
    @isTest
    private static void testPerformQueryOnWebEnablementODATA() {
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
     	insert agentUser;
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
        	List<WebEnablement__x> webStatus = UTIL_LtngODataAccess.retrieveWebEnablementStatus('TESTCLNTID1');
        	System.assertEquals(0, webStatus.size(), 'Size of \'webStatus\' is not equals to 0');
        }
        Test.stopTest();
    }
    
}
/** 
* @description task trigger test OOP Enterprise User
* @Owner: Grumpycats
*/
@isTest
(seeAllData=false)
private class CaseTriggerTestOOP {

    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            User oopUser = TestUserSetupUtility.getEnterpriseUser();
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(oopUser);
            CaseTestDataUtility.addUserToDataAccessRequestPermissionSet(oopUser);
            CaseTestDataUtility.addUserToOOPPublicGroup(TestUserSetupUtility.getEnterpriseUser());
        }
    }
    //On create the DAR Case will always have DAR CASE QUEUE as its owner
    //OOP Users can then change the owner to themselves
    //Then they can edit
    //When closed the Case will go back to having DAR Case QUEUE as its owner
	@isTest
    private static void testDataAccessRequestInsertAndUpdate(){
        Account accountRecord = CaseTestDataUtility.getAccount();
        User oopUser = TestUserSetupUtility.getEnterpriseUser();
        Test.startTest();
        
        Case darCase = new Case();
        // Create and Insert DAR Case
        System.runAs(oopUser){
            darCase = CaseTestDataUtility.buildDataAccessRequest(accountRecord);
            insert darCase; 
        }
        Case retrievedCase = CaseTestDataUtility.retrieveCaseAfterInsert(darCase);
        System.assert(retrievedCase.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST, 'The record type was not set to DAR');
        System.assert(retrievedCase.Status == CaseHandlerConstants.CASE_STATUS_RECEIVED, 'The status is not set to Received');
        
        // Change DAR Case Owner and update
        System.runAs(oopUser){
            retrievedCase.OwnerId = oopUser.Id;
            update retrievedCase; 
        }
        Case changedOwnerCase = CaseTestDataUtility.retrieveCaseAfterInsert(retrievedCase);
        System.assert(changedOwnerCase.OwnerId == oopUser.Id, 'OOP User is not the DAR Case Owner');
        
        // Update DAR Case Status to closed
        System.runAs(oopUser){
            changedOwnerCase.Status = CaseHandlerConstants.CASE_STATUS_CLOSED;
            update changedOwnerCase; 
        }
        Case updatedCase = CaseTestDataUtility.retrieveCaseAfterInsert(changedOwnerCase);
        System.assert(updatedCase.Status == CaseHandlerConstants.CASE_STATUS_CLOSED, 'DAR Case Status did not update to Closed');
        System.assert(updatedCase.OwnerId == CaseHandlerConstants.QUEUE_DAR_CASE_QUEUE_ID, 'OwnerId did not changed to DAR Case Queue');
        Test.stopTest();
    }
}
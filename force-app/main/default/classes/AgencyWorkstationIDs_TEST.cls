/**
* Author : Team LHIPS/GlitterCloud
* Date Created : 19/01/2023
* @description : Test class for AgencyWorkstationIDs
*/
@isTest
private class AgencyWorkstationIDs_TEST {

    @isTest
    public static void retrieveWorkStationIDs(){
       User devsysadmin = TestDataFactory_User_Wrapper.generateDeveloperSystemAdministratorUser('TEST','12345678914');
        String saaid = 'D0Y1024X004';
        System.runAs(DevSysAdmin){
        List<String>  agencyWIDs = AgencyWorkstationIDs.getWorkstationIds(saaid);

        if(!agencyWIDs.isEmpty()) {
            System.assertEquals(2,agencyWIDs.size(),'Size not equal to 2');
        }

    }
       
    }
}
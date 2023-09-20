/**
* @Name: FlowAccessManager_Test
* @Created: 11/05/2019
* @Author: Grumpycats
* @description Test for FlowAccessManager
*/

@isTest
(seeAllData=false)
public class FlowAccessManager_Test {
    /**
     * @description userSetup
     */
    @testsetup
    public static void userSetup() {  
        UTIL_CaseTestData.setUpUsersForCase();
    }
    
    @isTest
    public static void testFlowAccessManagerWithAccess(){
       List<FlowAccessManager.FlowInputs> flowinputslist = new List<FlowAccessManager.FlowInputs>();
       List<FlowAccessManager.FlowOutputs> results = new List<FlowAccessManager.FlowOutputs>(); 
       Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            flowinputslist = createFlowInputs();
       		results = FlowAccessManager.determineUserAccess(flowinputslist);
        }
       Test.stopTest();
       System.assert(!results.isEmpty(), 'Results are empty');
    }
    
    @isTest
    public static void testFlowAccessManagerWithoutAccess(){
       List<FlowAccessManager.FlowInputs> flowinputslist = new List<FlowAccessManager.FlowInputs>();
       List<FlowAccessManager.FlowOutputs> results = new List<FlowAccessManager.FlowOutputs>(); 
       Test.startTest();
       TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(UTIL_CaseTestData.getCCCUnLicensedUser());
        System.runAs(UTIL_CaseTestData.getCCCUnLicensedUser()){
            flowinputslist = createFlowInputsWithOutAccess();
       		results = FlowAccessManager.determineUserAccess(flowinputslist);
        }
       Test.stopTest();
       System.assert(!results.isEmpty(), 'Results are empty'); 
    }
    
    /**
     * @description createObjectNameListWithAccess
     * @return  `List<String>`
     */
    public static List<String> createObjectNameListWithAccess(){
        List<String> objectNameList = new List<String>();
        objectNameList.add('Case');
        return objectNameList;
    }
    /**
     * @description createObjectNameListWithoutAccess
     * @return  `List<String>`
     */
    public static List<String> createObjectNameListWithoutAccess(){
        List<String> objectNameList = new List<String>();
        objectNameList.add('Custom_Template__c');
        return objectNameList;
    }
    
    /**
     * @description createFlowInputs
     * @return  `List<FlowAccessManager.FlowInputs>`
     */
     public static List<FlowAccessManager.FlowInputs> createFlowInputs(){
       FlowAccessManager.FlowInputs flowinputs = new FlowAccessManager.FlowInputs(); 
       List<FlowAccessManager.FlowInputs> flowinputslist = new List<FlowAccessManager.FlowInputs>();
       flowinputs.objectNameList = createObjectNameListWithAccess();
       flowinputs.checkRecordTypeAccess = true;  
       flowinputslist.add(flowinputs);
       return flowinputslist;
    }
    /**
     * @description createFlowInputsWithOutAccess
     * @return  `List<FlowAccessManager.FlowInputs>`
     */  
    public static List<FlowAccessManager.FlowInputs> createFlowInputsWithOutAccess(){
       FlowAccessManager.FlowInputs flowinputs = new FlowAccessManager.FlowInputs(); 
       List<FlowAccessManager.FlowInputs> flowinputslist = new List<FlowAccessManager.FlowInputs>();
       flowinputs.objectNameList = createObjectNameListWithoutAccess();
       flowinputslist.add(flowinputs);
       return flowinputslist;
    }
   
}
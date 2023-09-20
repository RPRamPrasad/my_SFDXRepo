/**
 * @description OfficeProxyLookupFlowHelper_Test
 */
@isTest (seeAllData=false)
public class OfficeProxyLookupFlowHelper_Test {
    /**
     * @description userSetup
     */
    @testsetup
    public static void userSetup() {  
        UTIL_CaseTestData.setUpUsersForCase();
    }
    
    
    @isTest
    public static void testOfficeProxyLookup(){
       List<OfficeProxyLookupFlowHelper.FlowInputs> flowinputslist = new List<OfficeProxyLookupFlowHelper.FlowInputs>();
       List<OfficeProxyLookupFlowHelper.FlowOutputs> results = new List<OfficeProxyLookupFlowHelper.FlowOutputs>(); 
       Test.startTest();
       TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(UTIL_CaseTestData.getAgentUser());
       System.runAs(UTIL_CaseTestData.getAgentUser()){
            flowinputslist = createFlowInputs();
       		results = OfficeProxyLookupFlowHelper.officeProxyLookup(flowinputslist);
        }
       Test.stopTest();  
       System.assert(!results.isEmpty(), 'Results are empty');
    }
    
    
    /**
     * @description createFlowInputs
     * @return  `List<OfficeProxyLookupFlowHelper.FlowInputs>`
     */
    public static List<OfficeProxyLookupFlowHelper.FlowInputs> createFlowInputs(){
       OfficeProxyLookupFlowHelper.FlowInputs flowinputs = new OfficeProxyLookupFlowHelper.FlowInputs(); 
       List<OfficeProxyLookupFlowHelper.FlowInputs> flowinputslist = new List<OfficeProxyLookupFlowHelper.FlowInputs>();
       User agentUser = UTIL_CaseTestData.getAgentUser();
       flowinputs.currentUserId = String.valueOf(agentUser.Id);
       flowinputslist.add(flowinputs);
       
       return flowinputslist;
    }

    
    
    
}
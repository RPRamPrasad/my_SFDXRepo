/**
* @Name: CreateDARCase_Test
* @Created: 11/05/2019
* @Author: Grumpycats
* @description : Test for Create Data Access Request Case
*/
@isTest
(seeAllData=false)
public class CreateDARCase_Test {
    /**
     * @description userSetup
     */
    @testsetup
    public static void userSetup() {  
        UTIL_CaseTestData.setUpUsersForCase();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            createAccountAndContact();
            Id accountId = UTIL_CaseTestData.getAccount().Id;
            UTIL_CaseTestData.createAgentRoleList(accountId);
        }
    }
    
    /**
     * @description createAccountAndContact
     */
    public static void createAccountAndContact(){
        Id accountId;
        accountId = UTIL_CaseTestData.createAccountId();
        UTIL_CaseTestData.contactId();
    }

    @isTest
    public static void testCreateDARCase(){
       List<CreateDARCase.FlowInputs> flowinputslist = new List<CreateDARCase.FlowInputs>();
       Test.startTest();
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            flowinputslist = createFlowInputs();
       		CreateDARCase.setUpDARCase(flowinputslist);
        }
       Test.stopTest();  
       Case darCase = [SELECT Id, RecordTypeId, AccountId, Subject FROM Case WHERE AccountId =: flowinputslist.get(0).account.Id  LIMIT 1];
       System.assert(darCase != null, 'A Case was not created');
       System.assertEquals(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DAR_Case').getRecordTypeId(), darCase.RecordTypeId, 'Case is not a DAR case');       
    }
    
    /**
     * @description createFlowInputs
     * @return  `List<CreateDARCase.FlowInputs>`
     */
    public static List<CreateDARCase.FlowInputs> createFlowInputs(){
       CreateDARCase.FlowInputs flowinputs = new CreateDARCase.FlowInputs(); 
       List<CreateDARCase.FlowInputs> flowinputslist = new List<CreateDARCase.FlowInputs>();
       flowinputs.account = UTIL_CaseTestData.getAccount();
       flowinputslist.add(flowinputs);
       return flowinputslist;
    }
    
    
}
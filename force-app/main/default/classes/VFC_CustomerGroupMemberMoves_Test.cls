/****************************************************************************************
Name: VFC_CustomerGroupMemberMoves_Test
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test suite for VFC_CustomerGroupMemberMovesCtrl class

Team: Loco Motivated
=========================================================================================
History
-------
VERSION         AUTHOR                  DATE              DETAIL
1.0             LocoMotivated           01/22/2018        Initial test(s) for Add or Move
                                                          customer group members controller
******************************************************************************************/
/**
 * @description VFC_CustomerGroupMemberMoves_Test
 */
@isTest(seeAllData=false)
public with sharing class VFC_CustomerGroupMemberMoves_Test {

    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin19');
    private static account accRecord1=new Account(FirstName='FNameForAdd1',LastName='LNameForAdd1',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='INDSP81L8XB',PersonBirthdate=Date.valueOf('2013-05-05'));
    private static account accRecord2=new Account(FirstName='FNameForAdd2',LastName='LNameForAdd2',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='INDSP91L8XB');
    private static account accRecord3=new Account(FirstName='FNameForAdd3',LastName='LNameForAdd3',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='INDSP92L8XB');
    private static List<Account> accList=new List<Account>{accRecord1,accRecord2,accRecord3};

    private static CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c(Name = 'SR_API_KEY',Value__c = 'TestKeyAPIValue');
    private static CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c(Name = 'SR_CATEGORY',Value__c = 'b');
    private static User systemAdminUser;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static CustomerGroup__c customerGroup;
    private static List<CustomerGroupMember__c> groupMemberList=new List<CustomerGroupMember__c>();
    private static User agentuser;

    private static VFC_CustomerGroupMemberMoves_Test_Wrapper vfcWrap = new VFC_CustomerGroupMemberMoves_Test_Wrapper();
    private static VFC_CustomerGroupMemberMoves_Test_Wrapper2 vfcWrap2= new VFC_CustomerGroupMemberMoves_Test_Wrapper2();

  /**
    * Setup method for VFC_CustomerGroupMemberMoves_Test test methods
    * @name setup
    * @return void
    */
    /**
     * @description makeData
     */
    @TestSetup
    public static void makeData(){

        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('M');
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        System.runAs(systemAdminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        }
    }
    /**
     * @description setup
     */
    public static void setup() {
        systemAdminUser = [Select id, Name From User Where username = :SYSADMIN_USER_ID];
        agentuser = [Select Id, Name, Associate_ID__c, UserExternalId__c From User Where UserExternalId__c = '1111111111M_1111111111M' LIMIT 1];
        System.runAs(systemAdminUser){
            insert accList;
            List<AgentRole__c> agentRoleList=new List<AgentRole__c>();
            agentRoleList.add(new AgentRole__c(Agent__c=agentuser.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id));
            agentRoleList.add(new AgentRole__c(Agent__c=agentuser.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id));
            agentRoleList.add(new AgentRole__c(Agent__c=agentuser.Id, RelationshipNature__c='Prospect',Customer__c=accRecord3.Id));
            insert agentRoleList;
            customerGroup=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='123IDENTIFY');
            insert customerGroup;
            groupMemberList.add(new CustomerGroupMember__c(Customer__c=accRecord1.id,GroupMemberId__c=customerGroup.SFgroupIdentifier__c+accRecord1.ClientIdentifier__c,group__C=customerGroup.id));
            groupMemberList.add(new CustomerGroupMember__c(Customer__c=accRecord2.id,GroupMemberId__c=customerGroup.SFgroupIdentifier__c+accRecord2.ClientIdentifier__c,group__C=customerGroup.id));
            insert groupMemberList;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentuser);
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberInitSetup
     */
     @isTest
    static void cutomerGroupMemberInitSetup(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.newGoupMemberNamesSet.size(), 'Size of \'newGoupMemberNamesSet\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            Test.stopTest();
            system.assert(ctr.isResetANDSaveButtonDisabled, 'Save/Reset Buttons are not disabaled on load');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page with an invalid GroupId parameter
    * Then a error will be through for invalid input parameters
    * @name cutomerGroupMemberInitSetupWithInvalidGroupParameter
    * @return Void
    */
    /**
     * @description cutomerGroupMemberInitSetupWithInvalidGroupParameter
     */
     @isTest
    static void cutomerGroupMemberInitSetupWithInvalidGroupParameter(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', accRecord1.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            new VFC_CustomerGroupMemberMovesCtrl();
            system.assert(ApexPages.hasMessages(), 'Method \'ApexPages.hasMessages\' returns false');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('InvalidParameterValueException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
            system.assert(actualException.Exception_Message__c.contains(accRecord1.Id+' '+accRecord1.Id), 'Exception message does not contain the given record id');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page with an invalid Account parameter
    * Then a error will be through for invalid input parameters
    * @name cutomerGroupMemberInitSetupWithInvalidAccountParameter
    * @return Void
    */
    /**
     * @description cutomerGroupMemberInitSetupWithInvalidAccountParameter
     */
     @isTest
    static void cutomerGroupMemberInitSetupWithInvalidAccountParameter(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', customerGroup.Id);
            new VFC_CustomerGroupMemberMovesCtrl();
            system.assert(ApexPages.hasMessages(), 'Method \'ApexPages.hasMessages\' returns false');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('InvalidParameterValueException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
            system.assert(actualException.Exception_Message__c.contains(customerGroup.Id+' '+customerGroup.Id), 'Exception message does not contain the given record id');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on Add/Move GroupMember page will be rendered with current group member(s) information and searches with empty groupmember
    * Then a error with be logged and displayed
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveWithEmptyGroupMemberSearch
     */
     @isTest
    static void cutomerGroupMemberMoveWithEmptyGroupMemberSearch(){
        setup();
        CustomerGroup__c customerGroup1;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.newGoupMemberNamesSet.size(), 'Size of \'newGoupMemberNamesSet\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Add Members';
            ctr.relatedCustomerId=accRecord3.ID;
            ctr.retriveSelectedAccountInfo();
            system.assert(ApexPages.hasMessages(), 'Method \'ApexPages.hasMessages\' returns false');
            system.assert(ctr.getErrorsPresent(), 'Method \'getErrorsPresent\' returns false');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('DataNotFoundException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
            system.assertEquals('Group Information not found for: '+accRecord3.ID+' , '+agentuser.Associate_ID__c, actualException.Exception_Message__c, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on Add/Move GroupMember page and selecting exisitng group members in related customer
    * Then a error will be thorwn after selecting the related customer
    * @name cutomerGroupMemberWithSameGroupSearchError
    * @return Void
    */
    /**
     * @description cutomerGroupMemberWithSameGroupSearchError
     */
     @isTest
    static void cutomerGroupMemberWithSameGroupSearchError(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.newGoupMemberNamesSet.size(), 'Size of \'newGoupMemberNamesSet\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Add Members';
            ctr.relatedCustomerId=accRecord1.ID;
            ctr.retriveSelectedAccountInfo();
            system.assert(ApexPages.hasMessages(), 'Method \'ApexPages.hasMessages\' returns false');
            boolean isErrorPresent = ctr.getErrorsPresent();
            system.assert(isErrorPresent, '\'isErrorPresent\' is false');
            Test.stopTest();
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on clear action
    * Then the current group member(s) information with be reset
    * @name cutomerGroupMemberWithRelatedGroupMemberAndClearAction
    * @return Void
    */
    /**
     * @description cutomerGroupMemberWithRelatedGroupMemberAndClearAction
     */
     @isTest
    static void cutomerGroupMemberWithRelatedGroupMemberAndClearAction(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.newGoupMemberNamesSet.size(), 'Size of \'newGoupMemberNamesSet\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            vfcWrap.assertFNameLName1(ctr);
            ctr.radioButtonValue='Add Members';
            ctr.renderingSelectedContent();
            system.assertEquals(0,ctr.selectedCustomerGroupMemSize, '\'selectedCustomerGroupMemSize\' not equals to 0');
            system.assert(ctr.isResetANDSaveButtonDisabled, '\'isResetANDSaveButtonDisabled\' is false');
            system.assert(!ctr.isMoveMemberAction, '\'isMoveMemberAction\' is true');
            system.assertEquals('', ctr.relatedCustomerName,'Related Customer Name is not empty');
            system.assertEquals('Move Member(s) between two groups',ctr.outputTitle,'Output title is not matched');
            system.assert(ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
            ctr.relatedCustomerId=accRecord3.Id;
            ctr.retriveSelectedAccountInfo();
            system.assertEquals(1,ctr.newGoupMemberNamesSet.size(), 'Size of \'newGoupMemberNamesSet\' is not equals to 1');
            vfcWrap.assertFNameLName3(ctr);
            ctr.emptyingGroupMemberListOnClearAction();
            system.assertEquals('', ctr.relatedCustomerName,'Related Customer Name is not empty');
            system.assertEquals(0,ctr.newGoupMemberNamesSet.size(), 'Size of \'newGoupMemberNamesSet\' is not equals to 0');
            system.assertEquals(2, ctr.existingGoupMemberNamesSet.size(), 'Current Group Member List is not as expected');
            vfcWrap.assertFNameLName1(ctr);
            Test.stopTest();
        }
    }
    /**
     * @description createAccountData
     * @return  `List<account>`
     */
    public static List<account> createAccountData(){
        List<account> accountList = new List<account>();
        List<AgentRole__C> listOfAgentRoles = new List<AgentRole__C>();
        vfcWrap.createAccountList(accountList);
        insert accountList;
        vfcWrap.createAgentRole(accountList, listOfAgentRoles);
        insert listOfAgentRoles;

        return accountList;
    }
    /**
     *
     * @param listOfAccounts
     * @description createTestData
     * @return  `List<CustomerGroup__c>`
     */
    public static List<CustomerGroup__c> createTestData(List<Account> listOfAccounts){
        
        List<CustomerGroupMember__c> listofGM = new List<CustomerGroupMember__c>();
        List<CustomerGroup__c> listOfCustomerGroups = new List<CustomerGroup__c>();
        listOfCustomerGroups.add(new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY'));
        listOfCustomerGroups.add(new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='333IDENTIFY'));
        listOfCustomerGroups.add(new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='444IDENTIFY'));
        insert listOfCustomerGroups;
        vfcWrap.createListOfGM(listOfAccounts, listofGM, listOfCustomerGroups);
        insert listofGM;
        return listOfCustomerGroups;
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on Add Member and perform the changes and clicks save
    * Then the updated information will be saved to salesforce with new information
    * @name cutomerGroupMemberMoveToExistingGroupEndToEnd
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupEndToEnd
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupEndToEnd(){
        setup();
        List<CustomerGroup__c> listOfCustomerGroups;
        List<Account> listOfAccounts;
        System.runAs(systemAdminUser){
           	listOfAccounts= createAccountData();
            listOfCustomerGroups = createTestData(listOfAccounts);
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', listOfCustomerGroups.get(0).Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', listOfAccounts.get(0).Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            vfcWrap.assertFNameLName0(ctr);
            ctr.radioButtonValue='Add Members';
            ctr.renderingSelectedContent();
            existingGrpEndToEndAssertion1(ctr);
            ctr.relatedCustomerId=listOfAccounts.get(30).Id;
            ctr.retriveSelectedAccountInfo();
            for(CustomerGroupMember__c custGM :ctr.relatedGMSetToDisplay){
                system.assertEquals('FNameForMove30 LNameForMove30', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
                break;
            }
            //boolean isCustomerGroupMemberPresent =false;
            system.assertEquals(30,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 30');

            boolean isCustomerGroupMemberPresent;
            existingGrpEndToEndAssertion2(ctr, listOfAccounts, isCustomerGroupMemberPresent);
            existingGrpEndToEndAssertion3(ctr, listOfAccounts, isCustomerGroupMemberPresent);
            existingGrpEndToEndAssertion4(ctr, listOfAccounts, isCustomerGroupMemberPresent);

            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":{"agent":"ZP9NS1YS000","groupings":[{"customer":"MOVECUST61","groupId":"222IDENTIFY"},{"customer":"MOVECUST1","groupId":"333IDENTIFY"}]},"errors":null}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            system.assert(ctr.isSuccess, '\'isSuccess\' is false');
            Test.stopTest();
            CustomerGroupMember__c actualListofGroupMembers =[select id,Group__C from CustomerGroupMember__c where Customer__c=:listOfAccounts.get(61).Id];
            system.assertEquals(listOfCustomerGroups.get(0).Id, actualListofGroupMembers.Group__C, 'The given two parameters are not equal');
        }
    }  

    private static void existingGrpEndToEndAssertion1(VFC_CustomerGroupMemberMovesCtrl ctr){
        
        system.assertEquals(0,ctr.selectedCustomerGroupMemSize, 'Size of \'selectedCustomerGroupMemSize\' is not equals to 0');
        system.assert(ctr.isResetANDSaveButtonDisabled, '\'isResetANDSaveButtonDisabled\' is false');
        system.assert(!ctr.isMoveMemberAction, '\'isMoveMemberAction\' is true');
        system.assertEquals('', ctr.relatedCustomerName,'Related Customer Name is not empty');
        system.assertEquals('Move Member(s) between two groups',ctr.outputTitle,'Output title is not matched');
        system.assert(ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
    }
    
    private static void existingGrpEndToEndAssertion2(VFC_CustomerGroupMemberMovesCtrl ctr, 
                                                      List<Account> listOfAccounts, Boolean isCustomerGroupMemberPresent){
                                                          
        ValidationWrapper valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 60;
        valWrap.p2 = 29;
        isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);

        system.assert(!isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is true');

        ctr.emptyingGroupMemberListOnClearAction();
        system.assertEquals('', ctr.relatedCustomerName,'Related Customer Name is not empty');
        system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
        system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');

        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 29;
        valWrap.p2 = null;
        isCustomerGroupMemberPresent = vfcWrap2.validateInitGroupMemberSetToDisplay(valWrap);

        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');
        ctr.relatedCustomerId=listOfAccounts.get(60).Id;
        ctr.retriveSelectedAccountInfo();
        vfcWrap.assertFNameLName60(ctr);
        system.assertEquals(40,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 40');

        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 59;
        valWrap.p2 = 29;
        isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);

        system.assert(!isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is true');
        ctr.selectedCurrentGMs=new List<Id>{listOfAccounts.get(1).Id,listOfAccounts.get(2).Id,listOfAccounts.get(3).Id,listOfAccounts.get(4).Id,listOfAccounts.get(5).Id};
        ctr.addingToNewGMList();
        system.assertEquals(25, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(45, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
    }

    private static void existingGrpEndToEndAssertion3(VFC_CustomerGroupMemberMovesCtrl ctr, 
                                                      List<Account> listOfAccounts, Boolean isCustomerGroupMemberPresent){

        ValidationWrapper valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 1;
        valWrap.p2 = 2;
        isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');

        ctr.selectedSecondaryGMs=new List<Id>{listOfAccounts.get(61).Id,listOfAccounts.get(62).Id,listOfAccounts.get(63).Id,listOfAccounts.get(64).Id,listOfAccounts.get(65).Id};
        ctr.removeFromNewGMList();
        system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(40, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');

        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 61;
        valWrap.p2 = 62;
        isCustomerGroupMemberPresent = vfcWrap2.validateInitGroupMemberSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');

        ctr.selectedCurrentGMs=new List<Id>{listOfAccounts.get(61).Id};
        ctr.addingToNewGMList();
        system.assertEquals(29, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(41, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');

        valWrap = new ValidationWrapper();
		valWrap.ctr = ctr;
		valWrap.listOfAccounts = listOfAccounts;
		valWrap.p1 = 61;
		valWrap.p2 = null;
		isCustomerGroupMemberPresent = vfcWrap2.validateInitGroupMemberSetToDisplay(valWrap);
		system.assert(!isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is true');
		isCustomerGroupMemberPresent = vfcWrap.evaulateIsCustomerGroupMemberPresent(ctr.relatedGMSetToDisplay, listOfAccounts, isCustomerGroupMemberPresent);
		system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');
                                                          
		ctr.selectedSecondaryGMs=new List<Id>{listOfAccounts.get(1).Id};
		ctr.removeFromNewGMList();
		system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
		system.assertEquals(40, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
		isCustomerGroupMemberPresent=false;
        isCustomerGroupMemberPresent = vfcWrap.iterateRelatedGMSetToDisplay(listOfAccounts, isCustomerGroupMemberPresent, ctr);                                                          
		system.assert(!isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is true');                                                          
        isCustomerGroupMemberPresent = vfcWrap.iterateInitGroupMemberSetToDisplay(listOfAccounts, isCustomerGroupMemberPresent, ctr);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');
    }

    private static void existingGrpEndToEndAssertion4(VFC_CustomerGroupMemberMovesCtrl ctr, 
                                                      List<Account> listOfAccounts, Boolean isCustomerGroupMemberPresent){

        ctr.resettingCustomerGroupMemberSection();
        system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(40, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
        for(CustomerGroupMember__c custGM :ctr.initGroupMemberSetToDisplay){
            system.assertEquals('FNameForMove0 LNameForMove0', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
            break;
        }

        ctr.selectedCurrentGMs=new List<Id>{listOfAccounts.get(1).Id,listOfAccounts.get(2).Id,listOfAccounts.get(3).Id,listOfAccounts.get(4).Id,listOfAccounts.get(5).Id};
        ctr.addingToNewGMList();
        system.assertEquals(25, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(45, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');

        ValidationWrapper valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 1;
        valWrap.p2 = 2;
        isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');

        ctr.selectedSecondaryGMs=new List<Id>{listOfAccounts.get(61).Id,listOfAccounts.get(62).Id,listOfAccounts.get(63).Id,listOfAccounts.get(64).Id,listOfAccounts.get(65).Id};
        ctr.removeFromNewGMList();
        system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(40, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');

        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 61;
        valWrap.p2 = 62;
        isCustomerGroupMemberPresent = vfcWrap2.validateInitGroupMemberSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');
    }
    
    class ValidationWrapper{
        VFC_CustomerGroupMemberMovesCtrl ctr;
        List<Account> listOfAccounts;
        Integer p1;
        Integer p2;
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on Move Member and perform the changes and clicks save
    * Then the updated information will be saved to salesforce with new group
    * @name cutomerGroupMemberMoveToNewGroupEndToEnd
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToNewGroupEndToEnd
     */
     @isTest
    static void cutomerGroupMemberMoveToNewGroupEndToEnd(){
        setup();
        List<CustomerGroup__c> listOfCustomerGroups;
        List<Account> listOfAccounts;
        System.runAs(systemAdminUser){
           	listOfAccounts= createAccountData();
            listOfCustomerGroups = createTestData(listOfAccounts);
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', listOfCustomerGroups.get(0).Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', listOfAccounts.get(0).Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            for(CustomerGroupMember__c custGM :ctr.initGroupMemberSetToDisplay){
                system.assertEquals('FNameForMove0 LNameForMove0', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
                break;
            }
            ctr.radioButtonValue='Move Members';
            ctr.renderingSelectedContent();
            assertionCallOfNewGrpEndToEnd(ctr);
            ctr.selectedCurrentGMs=new List<Id>{listOfAccounts.get(1).Id,listOfAccounts.get(2).Id,listOfAccounts.get(3).Id,listOfAccounts.get(4).Id,listOfAccounts.get(5).Id};
            ctr.addingToNewGMList();
            system.assertEquals(5, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            system.assertEquals(25, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');

            assertionNewGrpEndToEnd(ctr, listOfAccounts);

            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":{"agent":"ZP9NS1YS000","groupings":[{"customer":"MOVECUST1","groupId":"555IDENTIFY"}]},"errors":null}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            system.assert(ctr.isSuccess, '\'isSuccess\' is false');
            Test.stopTest();
            CustomerGroupMember__c actualGroupMember =[select id,Group__r.SFGroupIdentifier__c,Customer__c from CustomerGroupMember__c where Customer__c=:listOfAccounts.get(1).Id];
            system.assertEquals('555IDENTIFY', actualGroupMember.Group__r.SFGroupIdentifier__c, 'The given two parameters are not equal');
        }
    }

    private static void assertionCallOfNewGrpEndToEnd(VFC_CustomerGroupMemberMovesCtrl ctr){
        system.assertEquals('New Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
        system.assert(!ctr.isAddMemberAction, '\'isAddMemberAction\' is true');
        system.assert(ctr.isMoveMemberAction, '\'isMoveMemberAction\' is false');
        system.assert(!ctr.isSearchEnabled, '\'isSearchEnabled\' is true');
        system.assert(ctr.isResetANDSaveButtonDisabled, '\'isResetANDSaveButtonDisabled\' is false');
        system.assertEquals('Move Member(s) to a New Group',ctr.outputTitle,'Section Title is not set properly');
    }

    private static void assertionNewGrpEndToEnd(VFC_CustomerGroupMemberMovesCtrl ctr, List<Account> listOfAccounts){
        ValidationWrapper valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 1;
        valWrap.p2 = 2;
        boolean isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');

        ctr.selectedSecondaryGMs=new List<Id>{listOfAccounts.get(1).Id};
        ctr.removeFromNewGMList();
        system.assertEquals(26, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(4, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
        
        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 1;
        valWrap.p2 = null;
        isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);
        system.assert(!isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is true');            
        
        ctr.resettingCustomerGroupMemberSection();
        system.assertEquals(30, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(0, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
        for(CustomerGroupMember__c custGM :ctr.initGroupMemberSetToDisplay){
            system.assertEquals('FNameForMove0 LNameForMove0', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
            break;
        }

        ctr.selectedCurrentGMs=new List<Id>{listOfAccounts.get(1).Id,listOfAccounts.get(2).Id,listOfAccounts.get(3).Id,listOfAccounts.get(4).Id,listOfAccounts.get(5).Id};
        ctr.addingToNewGMList();
        system.assertEquals(25, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(5, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
        
        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 1;
        valWrap.p2 = 2;
        isCustomerGroupMemberPresent = vfcWrap.validateRelatedGMSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');

        ctr.selectedSecondaryGMs=new List<Id>{listOfAccounts.get(1).Id};
        ctr.removeFromNewGMList();
        system.assertEquals(26, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
        system.assertEquals(4, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
        
        valWrap = new ValidationWrapper();
        valWrap.ctr = ctr;
        valWrap.listOfAccounts = listOfAccounts;
        valWrap.p1 = 1;
        valWrap.p2 = null;
        isCustomerGroupMemberPresent = vfcWrap2.validateInitGroupMemberSetToDisplay(valWrap);
        system.assert(isCustomerGroupMemberPresent, '\'isCustomerGroupMemberPresent\' is false');
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on Add Member to exiting Group radio button and searched for a related customer
    * Then adding new group member into current group members
    * @name cutomerGroupMemberMoveToExistingGroupSearchAndRemoveFunction
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupSearchAddandRemoveFunction
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupSearchAddandRemoveFunction(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Add Members';
            ctr.searchKeyWord='LNameForAdd3';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(1, ctr.accountList.size(), 'Account List is not as expected');
            ctr.relatedCustomerId=accRecord3.Id;
            ctr.retriveSelectedAccountInfo();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.getNewGMOptionsListToDisplay();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            system.assertEquals('FNameForAdd3 LNameForAdd3\''+'s Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(2, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.selectedSecondaryGMs=new List<Id>();
            ctr.selectedSecondaryGMs.add(accRecord3.Id);
            ctr.selectedSecondaryGMs.add(accRecord2.Id);
            ctr.removeFromNewGMList();
            system.assertEquals(3, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            Test.stopTest();
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on Add Member to exiting Group radio button and searched for a related customer
    * Then adding new group member into current group members
    * @name cutomerGroupMemberMoveToExistingGroupSearchAndRemoveFunction
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupAccountSearch
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupAccountSearch(){
        setup();
        account accRecord4=UTIL_CreateCustomerTestData.createOrganizationCustomer('FNameForOrg1');
    	accRecord4.ClientIdentifier__c='ORGSP91L8XB';
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            insert accRecord4;
            insert new AgentRole__c(Agent__c=agentuser.Id, RelationshipNature__c='Prospect',Customer__c=accRecord4.Id);
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Add Members';
            ctr.searchKeyWord='LNameForAdd3';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(1, ctr.accountList.size(), 'Account List is not as expected');
            ctr.searchKeyWord='LN FN';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(3, ctr.accountList.size(), 'Account List is not as expected');
            ctr.searchKeyWord='LN,FN';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(3, ctr.accountList.size(), 'Account List is not as expected');
            ctr.searchKeyWord='L,N';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(0, ctr.accountList.size(), 'Account List is not as expected');
            ctr.searchKeyWord='L,F,';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(3, ctr.accountList.size(), 'Account List is not as expected');
            ctr.searchKeyWord='FNameForOrg1';
            ctr.fetchAccountOnKeySearch();
            system.assertEquals(1, ctr.accountList.size(), 'Account List is not as expected');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupRadioButtonSelectedAndReset
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupRadioButtonSelectedAndReset(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            ctr.radioButtonValue='Add Members';
            ctr.renderingSelectedContent();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.relatedCustomerId=accRecord3.Id;
            ctr.retriveSelectedAccountInfo();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.getNewGMOptionsListToDisplay();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            system.assertEquals('FNameForAdd3 LNameForAdd3\''+'s Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(2, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            ctr.selectedSecondaryGMs=new List<Id>();
            ctr.selectedSecondaryGMs.add(accRecord3.Id);
            ctr.removeFromNewGMList();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.selectedCurrentGMs.add(accRecord1.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(2, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            ctr.resettingCustomerGroupMemberSection();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            Test.stopTest();
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupSuccessSave
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupSuccessSave(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            ctr.radioButtonValue='Add Members';
            ctr.renderingSelectedContent();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.relatedCustomerId=accRecord3.Id;
            ctr.retriveSelectedAccountInfo();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.getNewGMOptionsListToDisplay();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            system.assertEquals('FNameForAdd3 LNameForAdd3\''+'s Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(2, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            ctr.selectedSecondaryGMs=new List<Id>();
            ctr.selectedSecondaryGMs.add(accRecord3.Id);
            ctr.removeFromNewGMList();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.selectedCurrentGMs.add(accRecord1.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(2, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            CustomerGroupMember__c actualListofGM =[select id,Group__C from CustomerGroupMember__c where Customer__c=:accRecord3.Id];
            system.assertEquals(customerGroup1.Id, actualListofGM.Group__C, 'The given two parameters are not equal');
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":{"agent":"ZP9NS1YS000","groupings":[{"customer":"INDSP92L8XB","groupId":"123IDENTIFY"}]},"errors":null}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            system.assert(ctr.isSuccess, '\'isSuccess\' is false');
            Test.stopTest();
            CustomerGroupMember__c actualListofGroupMembers =[select id,Group__C from CustomerGroupMember__c where Customer__c=:accRecord3.Id];
            system.assertEquals(customerGroup.Id, actualListofGroupMembers.Group__C, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupErrorOnSave
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupErrorOnSave(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            ctr.radioButtonValue='Add Members';
            ctr.renderingSelectedContent();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":null,"errors":["Stored Procedure 503 Error - Unknown error"]}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            system.assert(ApexPages.hasMessages(), 'Method \'ApexPages.hasMessages\' returns false');
            system.assert(!ctr.isSuccess, '\'isSuccess\' is true');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('CustomerAggregatorException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('processCustomerGroupingResponse', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
            system.assert(actualException.Exception_Message__c.contains('Stored Procedure 503 Error - Unknown error'), '\'Exception_Message__c\' does not contains the String literal \'Stored Procedure 503 Error - Unknown error\'');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToExistingGroupWithRunTimeErrorOnSave
     */
     @isTest
    static void cutomerGroupMemberMoveToExistingGroupWithRunTimeErrorOnSave(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            ctr.radioButtonValue='Add Members';
            ctr.renderingSelectedContent();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":null,"errors":["Stored Procedure 503 Error - Unknown error"]}';
            response.setBody(responseString);
            Test.setContinuationResponse('', response);
            Test.invokeContinuationMethod(ctr, cont);
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            system.assert(!ctr.isSuccess, '\'isSuccess\' is true');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('System.NullPointerException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('processCustomerGroupingResponse', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToNewGroupRadioButtonSelectedAndReset
     */
     @isTest
    static void cutomerGroupMemberMoveToNewGroupRadioButtonSelectedAndReset(){
        setup();
        CustomerGroup__c customerGroup1;
        CustomerGroupMember__c customerGroupMember;
        System.runAs(systemAdminUser){
            customerGroup1=new CustomerGroup__c(Agent__c=agentuser.Id,SFgroupIdentifier__c='222IDENTIFY');
            insert customerGroup1;
            customerGroupMember =new CustomerGroupMember__c(Customer__c=accRecord3.id,GroupMemberId__c=customerGroup1.SFgroupIdentifier__c+accRecord3.ClientIdentifier__c,group__C=customerGroup1.id);
            insert customerGroupMember;
        }
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Move Members';
            ctr.renderingSelectedContent();
            system.assertEquals('New Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            system.assert(!ctr.isAddMemberAction, '\'isAddMemberAction\' is true');
            system.assert(ctr.isMoveMemberAction, '\'isMoveMemberAction\' is false');
            system.assert(!ctr.isSearchEnabled, '\'isSearchEnabled\' is true');
            system.assert(ctr.isResetANDSaveButtonDisabled, '\'isResetANDSaveButtonDisabled\' is false');
            system.assertEquals('Move Member(s) to a New Group',ctr.outputTitle,'Section Title is not set properly');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.selectedSecondaryGMs=new List<Id>();
            ctr.selectedSecondaryGMs.add(accRecord2.Id);
            ctr.removeFromNewGMList();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0, ctr.relatedGMSetToDisplay.size(), 'Related Group Member List is not as expected');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord1.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            ctr.resettingCustomerGroupMemberSection();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            Test.stopTest();
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page and saves
    * Then a changed customer which are moved to new group sould be saved successfully
    * @name cutomerGroupMemberMoveToNewGroupSuccessSave
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToNewGroupSuccessSave
     */
     @isTest
    static void cutomerGroupMemberMoveToNewGroupSuccessSave(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Move Members';
            ctr.renderingSelectedContent();
            system.assertEquals('New Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            system.assertEquals('Move Member(s) to a New Group',ctr.outputTitle,'Section Title is not set properly');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            CustomerGroupMember__c actualListofGM =[select id,Group__r.SFGroupIdentifier__c,Customer__c from CustomerGroupMember__c where Customer__c=:accRecord2.Id];
            system.assertEquals(customerGroup.SFGroupIdentifier__c, actualListofGM.Group__r.SFGroupIdentifier__c, 'The given two parameters are not equal');
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":{"agent":"ZP9NS1YS000","groupings":[{"customer":"INDSP91L8XB","groupId":"555IDENTIFY"}]},"errors":null}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            system.assert(ctr.isSuccess, '\'isSuccess\' is false');
            Test.stopTest();
            CustomerGroupMember__c actualGroupMember =[select id,Group__r.SFGroupIdentifier__c,Customer__c from CustomerGroupMember__c where Customer__c=:accRecord2.Id];
            system.assertEquals('555IDENTIFY', actualGroupMember.Group__r.SFGroupIdentifier__c, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page and clicks save with invalid clients
    * Then a error will be thrown from the service and being logged and error is shown on UI
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToNewGroupErrorOnSave
     */
     @isTest
    static void cutomerGroupMemberMoveToNewGroupErrorOnSave(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Move Members';
            ctr.renderingSelectedContent();
            system.assertEquals('New Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            system.assertEquals('Move Member(s) to a New Group',ctr.outputTitle,'Section Title is not set properly');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            CustomerGroupMember__c actualListofGM =[select id,Group__C from CustomerGroupMember__c where Customer__c=:accRecord2.Id];
            system.assertEquals(customerGroup.Id, actualListofGM.Group__C, 'The given two parameters are not equal');
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":null,"errors":["Stored Procedure 503 Error - Unknown error"]}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            system.assert(ApexPages.hasMessages(), 'Method \'ApexPages.hasMessages\' returns false');
            system.assert(!ctr.isSuccess, '\'isSuccess\' is true');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('CustomerAggregatorException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('processCustomerGroupingResponse', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
            system.assert(actualException.Exception_Message__c.contains('Stored Procedure 503 Error - Unknown error'), '\'Exception_Message__c\' does not contains the String literal \'Stored Procedure 503 Error - Unknown error\'');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page and changes the customer to new group and saves
    * Then a exception will be logges and shown it on the UI
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveToNewGroupWithRunTimeErrorOnSave
     */
     @isTest
    static void cutomerGroupMemberMoveToNewGroupWithRunTimeErrorOnSave(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            system.assertEquals(0,ctr.relatedGMSetToDisplay.size(), 'Size of \'relatedGMSetToDisplay\' is not equals to 0');
            ctr.getExistingGMOptionsListToDisplay();
            system.assertEquals(2, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            ctr.radioButtonValue='Move Members';
            ctr.renderingSelectedContent();
            system.assertEquals('New Group Member(s)',ctr.outputLabelName,'Output label didnt matched as expected');
            system.assertEquals('Move Member(s) to a New Group',ctr.outputTitle,'Section Title is not set properly');
            ctr.selectedCurrentGMs=new List<Id>();
            ctr.selectedCurrentGMs.add(accRecord2.Id);
            ctr.addingToNewGMList();
            system.assertEquals(1, ctr.relatedGMSetToDisplay.size(), 'New Group Member list is not empty');
            system.assertEquals(1, ctr.initGroupMemberSetToDisplay.size(), 'Current Group Member List is not as expected');
            CustomerGroupMember__c actualListofGM =[select id,Group__C from CustomerGroupMember__c where Customer__c=:accRecord2.Id];
            system.assertEquals(customerGroup.Id, actualListofGM.Group__C, 'The given two parameters are not equal');
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":null,"errors":["Stored Procedure 503 Error - Unknown error"]}';
            response.setBody(responseString);
            Test.setContinuationResponse('', response);
            Test.invokeContinuationMethod(ctr, cont);
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            system.assert(!ctr.isSuccess, '\'isSuccess\' is true');
            Test.stopTest();
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_CustomerGroupMemberMovesCtrl', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('System.NullPointerException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('processCustomerGroupingResponse', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveBackButtonAction
     */
     @isTest
    static void cutomerGroupMemberMoveBackButtonAction(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            PageReference pageRef =ctr.goBackToGroupDetialsPage();
            system.assert(pageRef!=null, '\'pageRef\' is null');
            Test.stopTest();
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on move member button on Group Details page
    * Then a Add/Move GroupMember page will be rendered with current group member(s) information
    * @name cutomerGroupMemberInitSetup
    * @return Void
    */
    /**
     * @description cutomerGroupMemberMoveRedirectOnSaveAction
     */
     @isTest
    static void cutomerGroupMemberMoveRedirectOnSaveAction(){
        setup();
        System.runAs(agentuser){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_CustomerGroupMemberMoves);
            ApexPages.currentPage().getParameters().put('groupId', customerGroup.Id);
            ApexPages.currentPage().getParameters().put('accIdInContext', accRecord1.Id);
            VFC_CustomerGroupMemberMovesCtrl ctr = new VFC_CustomerGroupMemberMovesCtrl();
            PageReference pageRef =ctr.redirectToGroupDetialsPage();
            system.assert(pageRef!=null, '\'pageRef\' is null');
            Test.stopTest();
        }
    }

    private class VFC_CustomerGroupMemberMoves_Test_Wrapper{

        private void assertFNameLName1(VFC_CustomerGroupMemberMovesCtrl ctr){
        
            for(String str :ctr.existingGoupMemberNamesSet){
                system.assertEquals('FNameForAdd1 LNameForAdd1 | DOB: 5/5/2013', str, 'Current Group Member Name is not as expected');
                break;
            }
        }
        
        private void assertFNameLName3(VFC_CustomerGroupMemberMovesCtrl ctr){
        
            for(String str :ctr.newGoupMemberNamesSet){
                system.assertEquals('FNameForAdd3 LNameForAdd3', str, 'New Group Member Name is not as expected');
                break;
            }
        }

        private void createAccountList(List<account> accountList){
            for(Integer i=0; i<100; i++){
                accountList.add(new Account(FirstName='FNameForMove'+i,LastName='LNameForMove'+i,BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='MOVECUST'+i));
            }
        }
        
        private void createAgentRole(List<account> accountList, List<AgentRole__C> listOfAgentRoles){
            for(Account acc: accountList){
                listOfAgentRoles.add(new AgentRole__c(Agent__c=agentuser.Id, RelationshipNature__c='Prospect',Customer__c=acc.Id));
            }
        }

        private void createListOfGM(List<Account> listOfAccounts, List<CustomerGroupMember__c> listofGM, List<CustomerGroup__c> listOfCustomerGroups){
            integer i=0;
            
            for(Account acc: listOfAccounts){
                if(i<=29){
                    listofGM.add(new CustomerGroupMember__c(Customer__c=acc.id,GroupMemberId__c=listOfCustomerGroups.get(0).SFgroupIdentifier__c+'~'+acc.ClientIdentifier__c,
                                                            group__C=listOfCustomerGroups.get(0).id));
                }else if(i>29 &&i<=59){
                    listofGM.add(new CustomerGroupMember__c(Customer__c=acc.id,GroupMemberId__c=listOfCustomerGroups.get(1).SFgroupIdentifier__c+'~'+acc.ClientIdentifier__c,
                                                            group__C=listOfCustomerGroups.get(1).id));
                }else{
                    listofGM.add(new CustomerGroupMember__c(Customer__c=acc.id,GroupMemberId__c=listOfCustomerGroups.get(2).SFgroupIdentifier__c+'~'+acc.ClientIdentifier__c,
                                                            group__C=listOfCustomerGroups.get(2).id));
                }
                i++;
            }
        }

        private void assertFNameLName0(VFC_CustomerGroupMemberMovesCtrl ctr){
	
            for(CustomerGroupMember__c custGM :ctr.initGroupMemberSetToDisplay){
                system.assertEquals('FNameForMove0 LNameForMove0', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
                break;
            }
        }
        
        private void assertFNameLName30(VFC_CustomerGroupMemberMovesCtrl ctr){
        
            for(CustomerGroupMember__c custGM :ctr.initGroupMemberSetToDisplay){
                system.assertEquals('FNameForMove30 LNameForMove30', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
                break;
            }
        }

        private void assertFNameLName60(VFC_CustomerGroupMemberMovesCtrl ctr){
	
            for(CustomerGroupMember__c custGM :ctr.relatedGMSetToDisplay){
                system.assertEquals('FNameForMove60 LNameForMove60', custGM.Customer__r.Name, 'Current Group Member Name is not as expected');
                break;
            }
        }

        private Boolean iterateRelatedGMSetToDisplay(List<Account> listOfAccounts, Boolean isCustomerGroupMemberPresent, VFC_CustomerGroupMemberMovesCtrl ctr){
	
            for(CustomerGroupMember__c custGM:ctr.relatedGMSetToDisplay){
                if(custGM.Customer__c.equals(listOfAccounts.get(1).Id)){
                    isCustomerGroupMemberPresent=true;
                }
            }
            
            return isCustomerGroupMemberPresent;
        }
        
        private Boolean iterateInitGroupMemberSetToDisplay(List<Account> listOfAccounts, Boolean isCustomerGroupMemberPresent, VFC_CustomerGroupMemberMovesCtrl ctr){
        
            for(CustomerGroupMember__c custGM:ctr.initGroupMemberSetToDisplay){
                if(custGM.Customer__c.equals(listOfAccounts.get(1).Id)){
                    isCustomerGroupMemberPresent=true;
                }
            }
            
            return isCustomerGroupMemberPresent;
        }

        private Boolean evaulateIsCustomerGroupMemberPresent(Set<CustomerGroupMember__c> relatedGMSetToDisplay, List<Account> listOfAccounts, Boolean isCustomerGroupMemberPresent){
            for(CustomerGroupMember__c custGM:relatedGMSetToDisplay){
                if(custGM.Customer__c.equals(listOfAccounts.get(61).Id)){
                    isCustomerGroupMemberPresent=true;
                }
            }
            return isCustomerGroupMemberPresent;
        }

        private Boolean validateRelatedGMSetToDisplay(ValidationWrapper valWrap){
            boolean isCustomerGroupMemberPresent =false;
            
            VFC_CustomerGroupMemberMovesCtrl ctr = valWrap.ctr;
            List<Account> listOfAccounts = valWrap.listOfAccounts;
            Integer p1 = valWrap.p1;
            Integer p2 = valWrap.p2;
            
            if(p2 != null){
                for(CustomerGroupMember__c custGM:ctr.relatedGMSetToDisplay){
                    if(custGM.Customer__c.equals(listOfAccounts.get(p1).Id) || custGM.Customer__c.equals(listOfAccounts.get(p2).Id)){
                        isCustomerGroupMemberPresent=true;
                    }
                }
            }else if(p2 == null){
                for(CustomerGroupMember__c custGM:ctr.relatedGMSetToDisplay){
                    if(custGM.Customer__c.equals(listOfAccounts.get(p1).Id)){
                        isCustomerGroupMemberPresent=true;
                    }
                }
            }
            
            return isCustomerGroupMemberPresent;
        }        
    }

    private class VFC_CustomerGroupMemberMoves_Test_Wrapper2{

        private Boolean validateInitGroupMemberSetToDisplay(ValidationWrapper valWrap){
            boolean isCustomerGroupMemberPresent =false;            
            VFC_CustomerGroupMemberMovesCtrl ctr = valWrap.ctr;
            List<Account> listOfAccounts = valWrap.listOfAccounts;
            Integer p1 = valWrap.p1;
            Integer p2 = valWrap.p2;            
            if(p2 == null){
                for(CustomerGroupMember__c custGM:ctr.initGroupMemberSetToDisplay){
                    if(custGM.Customer__c.equals(listOfAccounts.get(p1).Id)){
                        isCustomerGroupMemberPresent=true;
                    }
                }
            }else if(p2 != null){
                for(CustomerGroupMember__c custGM:ctr.initGroupMemberSetToDisplay){
                    if(custGM.Customer__c.equals(listOfAccounts.get(p1).Id) || custGM.Customer__c.equals(listOfAccounts.get(p2).Id)){
                        isCustomerGroupMemberPresent=true;
                    }
                }
            }            
            return isCustomerGroupMemberPresent;
        }
    }
}
/**
* @name VFC_C2CRelationshipController_TEST
* @author Team LocoMotivated
* @date 11/01/2017
* @description Customer Relationship create update Controller Test
*/
@isTest(seeAllData = false)
public class VFC_C2CRelationshipController_TEST {

    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static account accRecord1=new Account(FirstName='FNameForC2C',LastName='LNameForC2C', RecordTypeId='012o0000000qlF7AAI',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP81L8XB');
    private static account accRecord2=new Account(FirstName='FNameForC2C1',LastName='LNameForC2C1',RecordTypeId='012o0000000qlF7AAI',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L8XB');

    private static CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c(Name = 'SR_API_KEY',Value__c = 'TestKeyAPIValue');
    private static CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c(Name = 'SR_CATEGORY',Value__c = 'a');
    private static User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
    private static List<CM_C2C_Relationship_AV_Mapping__mdt> customMDTypeList = new List<CM_C2C_Relationship_AV_Mapping__mdt>();
      

    /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a C2C New Relationship
    * Then a page will be rendered with current account information
    * @name testC2CRelationshipControllerVariables
    * @description Test C2C Relationship Controller Variables
    */    
    @isTest
    static void testC2CRelationshipControllerVariables() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);           
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            Test.stopTest();
            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
            system.assertEquals(1, ctr.accountList.size(), 'Size of \'accountList\' is not equals to 1');
        }
    }
   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box
    * Able to select relationship nature from dropdown and Save the C2C relationship
    * @name testCreateC2CRelationshipWithSuccessSave
    * @description Test Create C2C Relationship With Success Save
    */ 
    @isTest
    static void testCreateC2CRelationshipWithSuccessSave() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
            System.runAs(salesRoleHierarchy1.Agent){
                insert accRecord1;
                insert accRecord2;
            }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            ctr.relatedCustomerClientId='C2CSP81L8XB';
            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":[{"attributes":{"relationshipNature":"Spouse","clientId":"C2CSP91L8XB","relatedClientId":"C2CSP81L8XB"}},{"attributes":{"relationshipNature":"Spouse","clientId":"C2CSP81L8XB","relatedClientId":"C2CSP91L8XB"}}],"errors":[]}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(!isErrorPresent, '\'isErrorPresent\' is true');

            Test.stopTest();
            List<Id> accountIds=new List<Id>();
            accountIds.add(accRecord1.id);
            accountIds.add(accRecord2.id);
            List<relationship__c> savedRel = [select id, accountTwo__c,accountOne__c, relationshipType__c from relationship__c where accountTwo__c IN :accountIds and accountOne__c IN :accountIds];
            System.assertEquals(2, savedRel.size(), 'Size of \'savedRel\' is not equals to 2');

            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(true, ctr.isSuccess, '\'isSuccess\' is false');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box
    * Able to select relationship nature from dropdown and while try to Save - Invalid response will come from MPD hence Save will failed
    * User able to see Error Message on UI
    * @name testCreateC2CRelationshipWithInvalidResponse
    * @description Test Create C2C Relationship With Invalid Response
    */    
    @isTest 
    static void testCreateC2CRelationshipWithInvalidResponse() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
            System.runAs(salesRoleHierarchy1.Agent){
                insert accRecord1;
                insert accRecord2;
            }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            ctr.relatedCustomerClientId=accRecord2.ClientIdentifier__c;

            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data": null,"errors": [   {"status": "500","code": "nodata_foundfault_02","title": "sf.crom.customer.customermanagementbulk.NoDataFoundFault"}]} ';

            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);            
            Test.stopTest(); 
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            try{
                relationship__c savedRel;
                savedRel = [select id from relationship__c where  relationshipType__c= :'Spouse'];
                System.assert(false, 'Assertion failed');
            }catch(exception ex){
                System.assert(true, 'Assertion passed');
                System.assert(ex.getMessage()!=null, 'Method \'getMessage\' is returns null');
            }
            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' false');
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_C2CRelationshipController', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('CustomerAggregatorException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('processC2CRelationshipAggregatorResponse', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box
    * Able to select relationship nature from dropdown and while try to Save - RunTime Exception will happen hence Save will failed
    * User able to see Error Message on UI
    * @name testCreateC2CRelationshipWithRunTimeException
    * @description testCreateC2CRelationshipWithRunTimeException
    */
    @isTest
    static void testCreateC2CRelationshipWithRunTimeException() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
            System.runAs(salesRoleHierarchy1.Agent){
                insert accRecord1;
                insert accRecord2;
            }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            ctr.relatedCustomerClientId=accRecord2.ClientIdentifier__c;

            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data": null,"errors": [   {"status": "500","code": "nodata_foundfault_02","title": "sf.crom.customer.customermanagementbulk.NoDataFoundFault"}]} ';

            response.setBody(responseString);
            Test.setContinuationResponse('', response);
            Test.invokeContinuationMethod(ctr, cont);
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            Test.stopTest();

            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
            ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
            system.assertEquals('VFC_C2CRelationshipController', actualException.Class__c, 'The given two parameters are not equal');
            system.assertEquals('System.NullPointerException', actualException.Exception_Type__c, 'The given two parameters are not equal');
            system.assertEquals('processC2CRelationshipAggregatorResponse', actualException.Method__c, 'The given two parameters are not equal');
            system.assertEquals('ERROR', actualException.Severity__c, 'The given two parameters are not equal');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * will be rendered with current account information and User didn't Select any related Customer in Search Box and click on save
    * Then a error will be thrown showing to select a related customer before save
    * @name testCreateC2CRelationshipWithoutSelectingRelatedCustomerError
    * @description Test Create C2C Relationship Without Selecting Related Customer Error
    */    
    @isTest 
    static void testCreateC2CRelationshipWithoutSelectingRelatedCustomerError() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
            System.runAs(salesRoleHierarchy1.Agent){
                insert accRecord1;
                insert accRecord2;
            }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            
            ctr.invokeContinuation();
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');

            Test.stopTest();
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box
    * Able to select relationship nature from dropdown and while try to Save - Invalid StatusCode will come as response hence Save will failed
    * User able to see Error Message on UI
    * @name testCreateC2CRelationshipWithInvalidStatusCodeResponse
    * @description Test Create C2C Relationship With Invalid Status Code Response
    */  
    @isTest
    static void testCreateC2CRelationshipWithInvalidStatusCodeResponse() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};

            System.runAs(salesRoleHierarchy1.Agent){
                insert accRecord1;
                insert accRecord2;
            }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            ctr.relatedCustomerClientId=accRecord2.ClientIdentifier__c;

            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            response.setStatusCode(2000);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);            
            Test.stopTest(); 
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box With LastName and FirstName
    * Able to select relationship nature from dropdown
    * @name testCreateC2CRelationshipSearchWithLNAndFN
    * @description Test Create C2C Relationship Search With LN And FN
    */    
    @isTest
    static void testCreateC2CRelationshipSearchWithLNAndFN() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LNameForC2C1 FNameForC2C1';
            ctr.fetchAccountOnKeySearch();
            Test.stopTest();
            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and
    * User try to Save the C2C relationship without entering any value in Related Customer and RelationshipNature
    * User able to see Error Message on UI and Save will be Failed
    * @name testCreateC2CRelationshipValidationError
    * @description Test Create C2C Relationship Validation Error
    */    
    @isTest
     static void testCreateC2CRelationshipValidationError() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
         UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){

            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));

            Test.startTest();
                ctr.init();
                ctr.getRelationshipPickList();
            	ctr.clearSelectedAccount();
            	ctr.relatedCustomerName='';
            	ctr.relationshipNature='';
                ctr.fieldValidations();
                Boolean isErrorPresent = ctr.getErrorsPresent();
                System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            Test.stopTest();
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals('', ctr.relatedCustomerName, '\'relatedCustomerName\' is not an empty String');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box With LastName COMMA FirstName
    * Able to select relationship nature from dropdown
    * @name testCreateC2CRelationshipSearchWithLNCommaFN
    * @description Test Create C2C Relationship Search With LN Comma FN
    */   
    @isTest
    static void testCreateC2CRelationshipSearchWithLNCommaFN() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account accRecord3=new Account(FirstName='TestFN1',LastName='TestLN1',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2C2391L8XV');
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord3;
        }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord3.Id);
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord3.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord3.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='T,T';
            ctr.fetchAccountOnKeySearch();
            Test.stopTest();
            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isSearchEnabled, '\'isSearchEnabled\' is false');
            system.assertEquals(1, ctr.accountList.size(), 'Size of \'accountList\' is not equals to 1');
            System.assertEquals(accRecord3.ClientIdentifier__c, ctr.accountList.get(0).ClientIdentifier__c, 'The given two parameters are not equal');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on new relationship button to Create a New C2C Relationship
    * Then a page will be rendered with current account information and User can able to Select related Customer from Search Box With Invalid Account Name
    * Able to select relationship nature from dropdown
    * @name testCreateC2CRelationshipSearchWithIvalidAccountSearch
    * @description Test Create C2C Relationship Search With Ivalid Account Search
    */    
    @isTest
    static void testCreateC2CRelationshipSearchWithIvalidAccountSearch() {
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        System.runAs(systemAdminUser){
            AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
            insert ar1;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            ctr.searchKeyWord='LastName FirstName Test';
            ctr.fetchAccountOnKeySearch();
            ctr.disableSearch();
            Test.stopTest();
            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(false, ctr.isSearchEnabled, '\'isSearchEnabled\' is true');
            system.assertEquals(0, ctr.accountList.size(), 'Size of \'accountList\' is not equals to 0');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on edit button to update an existing C2C Relationship
    * Then a page will be rendered with current account information , related Account and relationship nature
    * Able to select relationship nature from dropdown 
    * @name testC2CRelationshipInitForUpdateScenario
    * @description Test C2C Relationship Init For Update Scenario
    */    
    @isTest
    static void testC2CRelationshipInitForUpdateScenario(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }

        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Child',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }

        System.runAs(systemAdminUser){
            delete ar2;
        }
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('id', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();
            Test.stopTest();
            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on edit button to update an existing C2C Relationship which having ORGANIZATIONAL Account involved
    * Then a page will be rendered with current account information , related Account and relationship nature
    * Unable to select relationship nature from dropdown as its disabled mode
    * Able to see an error message on UI
    * @name testUpdateC2CRelationshipWithORGAccount
    * @description Test Update C2C Relationship With ORG Account
    */
    @isTest
    static void testUpdateC2CRelationshipWithORGAccount(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account accRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');

        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecordOrg;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecordOrg.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecordOrg.id,RelationshipType__c='Other Business Relationship',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecordOrg.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }
        System.runAs(systemAdminUser){
            delete ar2;
        }

        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('id', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            Test.stopTest();
            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(false, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is true');
            system.assertEquals(true, ctr.isOrganizationRestrictIndicator, '\'isOrganizationRestrictIndicator\' is false');

        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on edit button to update an existing C2C Relationship
    * Then a page will be rendered with current account information , related Account and relationship nature
    * Able to select relationship nature from dropdown to change into different one
    * Able to click on Save button to Save the C2C relationship
    * @name testUpdateC2CRelationshipSuccessSave
    * @description Test Update C2C Relationship Success Save
    */    
    @isTest
    static void testUpdateC2CRelationshipSuccessSave(){

        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Child',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }

        System.runAs(systemAdminUser){
            delete ar2;
        }
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
	            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
	            ApexPages.currentPage().getParameters().put('id', rel.Id);
	            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
	            ctr.init();
	            ctr.getRelationshipPickList();
	            ctr.searchKeyWord='LNameForC2C1';
	            ctr.fetchAccountOnKeySearch();

	            Continuation cont = (Continuation) ctr.invokeContinuation();
	            Map<String, HttpRequest> requests = cont.getRequests();
	            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
	            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
	            HttpResponse response = new HttpResponse();

	            String responseString = '{"data":[{"attributes":{"relationshipNature":"Spouse","clientId":"C2CSP81L8XB","relatedClientId":"C2CSP91L8XB"}},{"attributes":{"relationshipNature":"Spouse","clientId":"C2CSP91L8XB","relatedClientId":"C2CSP81L8XB"}}],"errors":[]}';
	            response.setBody(responseString);
	            Test.setContinuationResponse(ctr.requestLabel, response);
	            Test.invokeContinuationMethod(ctr, cont);
	            Boolean isErrorPresent = ctr.getErrorsPresent();
	            System.assert(!isErrorPresent, '\'isErrorPresent\' is true');
            Test.stopTest();


            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(true, ctr.isSuccess, '\'isSuccess\' is false');
            system.assertEquals(false, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is true');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
        }
        System.runAs(systemAdminUser){
        List<Id> accountIds=new List<Id>{accRecord1.id,accRecord2.id};
        List<relationship__c> savedRel = [select id, accountTwo__c,accountOne__c, relationshipType__c from relationship__c where accountTwo__c IN :accountIds and accountOne__c IN :accountIds];
        System.assertEquals(2, savedRel.size(), 'Size of \'savedRel\' is not equals to 2');
        System.assertEquals('Spouse',savedRel.get(0).relationshipType__c, 'The given two parameters are not equal');
        System.assertEquals('Spouse',savedRel.get(1).relationshipType__c, 'The given two parameters are not equal');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on delete button to delete an existing C2C Relationship
    * Then a page will be rendered with current account information , related Account and relationship nature
    * Unable to select relationship nature from dropdown
    * @name testC2CRelationshipDeleteInit
    * @description Test C2C Relationship Delete Init
    */    
    @isTest
    static void testC2CRelationshipDeleteInit(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Parent',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }

        System.runAs(systemAdminUser){
            delete ar2;
        }
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('delId', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            Test.stopTest();
            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(true, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is false');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
        }
    }

       /**
    * @method
    * Given a Agent User
    * When user clicks on delete button to delete an existing C2C Relationship
    * Then a page will be rendered with current account information , related Account and relationship nature
    * Unable to select relationship nature from dropdown
    * @name testDeleteC2CRelationshipSuccess
    * @description Test Delete C2C Relationship Success
    */    
    @isTest
    static void testDeleteC2CRelationshipSuccess(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Parent',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }

        System.runAs(systemAdminUser){
            delete ar2;
        }
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('delId', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();

            Continuation cont = (Continuation) ctr.invokeContinuation();
            Map<String, HttpRequest> requests = cont.getRequests();
            System.assert(requests.size()==1, 'Size of \'requests\' is not equals to 1');
            System.assert(requests.get(ctr.requestLabel)!=null, '\'requestLabel\' is null');
            HttpResponse response = new HttpResponse();

            String responseString = '{"data":[],"errors":[]}';
            response.setBody(responseString);
            Test.setContinuationResponse(ctr.requestLabel, response);
            Test.invokeContinuationMethod(ctr, cont);
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(!isErrorPresent, '\'isErrorPresent\' is true');
            Test.stopTest();

            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(true, ctr.isSuccess, '\'isSuccess\' is false');
            system.assertEquals(true, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is false');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
        }
        System.runAs(systemAdminUser){
            List<Id> accountIds=new List<Id>{accRecord1.id,accRecord2.id};
            List<relationship__c> savedRel = [select id, accountTwo__c,accountOne__c, relationshipType__c from relationship__c where accountTwo__c IN :accountIds and accountOne__c IN :accountIds];
            System.assertEquals(0, savedRel.size(), 'Size of \'savedRel\' is not equals to 0');
        }
    }
   /**
    * @method
    * Given a Agent User
    * When user clicks on delete button to delete an existing C2C Relationship which having ORGANIZATIONAL account involved
    * Then a page will be rendered with current account information , related Account and relationship nature
    * Able to see an error message
    * @name testDeleteC2CRelationshipWithORGAccount
    * @description Test Delete C2C Relationship With ORG Account
    */    
    @isTest
    static void testDeleteC2CRelationshipWithORGAccount(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account accRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecordOrg;
        }

        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecordOrg.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecordOrg.id,RelationshipType__c='Employee',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecordOrg.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }
        System.runAs(systemAdminUser){
            delete ar2;
        }

        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('delId', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');
            Test.stopTest();
            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(true, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is false');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');
            system.assertEquals(true, ctr.isOrganizationRestrictIndicator, '\'isOrganizationRestrictIndicator\' is false');
        }
    }

   /**
    * @method
    * Given a Agent User
    * When user clicks on delete button to delete an existing C2C Relationship
    * Then a page will be rendered with current account information , related Account and relationship nature
    * User can change her decision and can delete operation at that time to click Cancel button
    * @name testCancelDeleteC2CRelationshipOperation
    * @description Test Cancel Delete C2C Relationship Operation
    */    
    @isTest 
    static void testCancelDeleteC2CRelationshipOperation(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Parent',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(salesRoleHierarchy1.Agent){
            insert rel;
        }
        System.runAs(systemAdminUser){
            delete ar2;
        }
        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('delId', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.init();
            ctr.getRelationshipPickList();

            system.assertEquals(false, ctr.isNewRelationship, '\'isNewRelationship\' is true');
            system.assertEquals(false, ctr.isSuccess, '\'isSuccess\' is true');
            system.assertEquals(true, ctr.isDeleteIndicator, '\'isDeleteIndicator\' is false');
            system.assertEquals(false, ctr.isS1Request, '\'isS1Request\' is true');

            PageReference accountPage = ctr.delCancel();
            Test.stopTest();
            System.assert(accountPage.getUrl().contains(accRecord1.id), 'URL does not contain the given record id');
        }
    }

       /**
    * @method
    * Given a Agent User
    * When user clicks on New button on C2C Relationship Related List for ORGANIZATIONAL Account
    * Then a page will be rendered with a message
    * Able to see an error message on UI
    * @name testCreateC2CRelationshipWithORGANIZATIONAccount
    * @description Test Create C2C Relationship With ORGANIZATION Account
    */
    /**
     * @description testCreateC2CRelationshipWithORGANIZATIONAccount
     */
     @isTest
    static void testCreateC2CRelationshipWithORGANIZATIONAccount(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account accRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecordOrg;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecordOrg.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }

        relationship__c rel=new Relationship__c(accounttwo__c=accRecordOrg.id,accountone__c=accRecord1.id,RelationshipType__c='Employee',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecordOrg.ClientIdentifier__c);


        System.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            Test.setCurrentPageReference(Page.VFP_C2CRelationship);
            ApexPages.currentPage().getParameters().put('id', rel.Id);
            VFC_C2CRelationshipController ctr = new VFC_C2CRelationshipController(new Apexpages.Standardcontroller(rel));
            ctr.isLightningRequest=false;
            ctr.init();
            Test.stopTest();
            Boolean isErrorPresent = ctr.getErrorsPresent();
            System.assert(isErrorPresent, '\'isErrorPresent\' is false');

            system.assertEquals(true, ctr.isNewRelationship, '\'isNewRelationship\' is false');
            system.assertEquals(true, ctr.isCreateOrganizationRelationshipInClassic, '\'isCreateOrganizationRelationshipInClassic\' is false');
            for (ApexPages.Message msg:ApexPages.getMessages()){
                system.assertEquals('Create New Customer to Customer Relationship for Organization currently is not available!', msg.getSummary(), 'The given two parameters are not equal');
            }
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on New button on C2C Relationship Related List for ORGANIZATIONAL Account in Lightning
    * Then a page will be rendered with AccountName and able to Select relatedAccount as Organizational
    * On selecting related account the Relationship Nature field will give options to select and proceed
    * @name testCreateC2CRelationshipInLightningOrgToOrg
    * @description Test Create C2C Relationship In Lightning Org To Org
    */
    /**
     * @description testCreateC2CRelationshipInLightningOrgToOrg
     */
     @isTest
    static void testCreateC2CRelationshipInLightningOrgToOrg(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account primaryAccRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');
        Account relatedAccRecordOrg=new Account(LastName='IBM',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='IL',ClientIdentifier__c='C2CSP90L0RG');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert primaryAccRecordOrg;
            insert relatedAccRecordOrg;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=primaryAccRecordOrg.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=relatedAccRecordOrg.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        
        //relationship__c rel=new Relationship__c(accounttwo__c=primaryAccRecordOrg.id,accountone__c=relatedAccRecordOrg.id,RelationshipType__c='Executor\'s Trust',RelationshipIdentifier__c=primaryAccRecordOrg.ClientIdentifier__c+'~'+relatedAccRecordOrg.ClientIdentifier__c);
        
        System.runAs(salesRoleHierarchy1.Agent){
            Id recordId=primaryAccRecordOrg.Id;
            VFC_C2CRelationshipController.AccountAndAgentAssocIdWrapper primaryAccount;
            List<String> optionValueList;
            Account relatedOrgAcnt=[Select Id,LastName, RecordTypeId, recordType.Name,ClientIdentifier__c from Account where id=:relatedAccRecordOrg.Id];
            Test.startTest();
            primaryAccount=VFC_C2CRelationshipController.getPrimaryAccount(recordId);
            optionValueList=VFC_C2CRelationshipController.getOptions(primaryAccount.accountRecord.RecordType.Name, relatedOrgAcnt.RecordType.Name);
            Test.stopTest();
            system.assertEquals(primaryAccount.accountRecord.LastName, primaryAccRecordOrg.LastName, 'The given two parameters are not equal');
           // system.assertEquals(15, optionValueList.size());
        }
    }

    @isTest
    static void testCreateC2CRelationshipInLightningOrgToOrgAccessibilityFix(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account primaryAccRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');
        Account relatedAccRecordOrg=new Account(LastName='IBM',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='IL',ClientIdentifier__c='C2CSP90L0RG');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert primaryAccRecordOrg;
            insert relatedAccRecordOrg;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=primaryAccRecordOrg.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=relatedAccRecordOrg.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        
        //relationship__c rel=new Relationship__c(accounttwo__c=primaryAccRecordOrg.id,accountone__c=relatedAccRecordOrg.id,RelationshipType__c='Executor\'s Trust',RelationshipIdentifier__c=primaryAccRecordOrg.ClientIdentifier__c+'~'+relatedAccRecordOrg.ClientIdentifier__c);
        
        System.runAs(salesRoleHierarchy1.Agent){
            Id recordId=primaryAccRecordOrg.Id;
            VFC_C2CRelationshipController.AccountAndIsHouseholdWrapper isHouseholdAndAccountDetails;
            List<String> optionValueList;
            Account relatedOrgAcnt=[Select Id,LastName, RecordTypeId, recordType.Name,ClientIdentifier__c from Account where id=:relatedAccRecordOrg.Id];
            Test.startTest();
            isHouseholdAndAccountDetails=VFC_C2CRelationshipController.checkForHousehold(recordId);
            optionValueList=VFC_C2CRelationshipController.getOptions(isHouseholdAndAccountDetails.selectedAccount.RecordType.Name, relatedOrgAcnt.RecordType.Name);
            Test.stopTest();
            system.assertEquals(false,isHouseholdAndAccountDetails.isHousehold, '\'isHousehold\' should be false');
            system.assertEquals(isHouseholdAndAccountDetails.selectedAccount.LastName, primaryAccRecordOrg.LastName, 'Given two last names must be equal');
            system.assertEquals(15, optionValueList.size(), 'Size of \'List<String>\' should be equals to 15');
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on New button on C2C Relationship Related List for ORGANIZATIONAL Account in Lightning
    * Then a page will be rendered with AccountName and able to Select relatedAccount as INDIVIDUAL
    * On selecting related account the Relationship Nature field will give options to select and proceed
    * @name testCreateC2CRelationshipInLightningOrgToIndiv
    * @description Test Create C2C Relationship In Lightning Org To Indiv
    */
    /**
     * @description testCreateC2CRelationshipInLightningOrgToIndiv
     */
    @isTest
    static void testCreateC2CRelationshipInLightningOrgToIndiv(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account primaryAccRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert primaryAccRecordOrg;
            insert accRecord1;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=primaryAccRecordOrg.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        
        //relationship__c rel=new Relationship__c(accounttwo__c=primaryAccRecordOrg.id,accountone__c=accRecord1.id,RelationshipType__c='Owner\'s Trust',RelationshipIdentifier__c=primaryAccRecordOrg.ClientIdentifier__c+'~'+accRecord1.ClientIdentifier__c);
        
        System.runAs(salesRoleHierarchy1.Agent){
            Id recordId=primaryAccRecordOrg.Id;
            VFC_C2CRelationshipController.AccountAndAgentAssocIdWrapper primaryAccount;
            List<String> optionValueList;
            Account relatedIndividualAcnt=[Select Id,LastName, RecordTypeId, recordType.Name,ClientIdentifier__c from Account where id=:accRecord1.Id];
            Test.startTest();
            primaryAccount=VFC_C2CRelationshipController.getPrimaryAccount(recordId);
            optionValueList=VFC_C2CRelationshipController.getOptions(primaryAccount.accountRecord.RecordType.Name, relatedIndividualAcnt.RecordType.Name);
            Test.stopTest();
            system.assertEquals(primaryAccount.accountRecord.LastName, primaryAccRecordOrg.LastName, 'The given two parameters are not equal');
            //system.assertEquals(16, optionValueList.size());
        }
    }
  /**
    * @method
    * Given a Agent User
    * When user clicks on New button on C2C Relationship Related List for INDIVIDUAL Account in Lightning
    * Then a page will be rendered with AccountName and able to Select relatedAccount as ORGANIZATIONAL
    * On selecting related account the Relationship Nature field will give options to select and proceed
    * @name testCreateC2CRelationshipInLightningIndivToOrg
    * @description Test Create C2C Relationship In Lightning Indiv To Org
    */
    /**
     * @description testCreateC2CRelationshipInLightningIndivToOrg
     */
    @isTest
    static void testCreateC2CRelationshipInLightningIndivToOrg(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account relatedAccRecordOrg=new Account(LastName='SF INSURANCE',RecordTypeId='012o0000000qlFCAAY',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='C2CSP91L0RG');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert relatedAccRecordOrg;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=relatedAccRecordOrg.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        
        //relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=relatedAccRecordOrg.id,RelationshipType__c='Business Owner',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+relatedAccRecordOrg.ClientIdentifier__c);
        
        System.runAs(salesRoleHierarchy1.Agent){
            Id recordId=accRecord1.Id;
           	VFC_C2CRelationshipController.AccountAndAgentAssocIdWrapper primaryAccount;
            List<String> optionValueList;
            Account relatedIndividualAcnt=[Select Id,LastName, RecordTypeId, recordType.Name,ClientIdentifier__c from Account where id=:relatedAccRecordOrg.Id];
            Test.startTest();
            primaryAccount=VFC_C2CRelationshipController.getPrimaryAccount(recordId);
            optionValueList=VFC_C2CRelationshipController.getOptions(primaryAccount.accountRecord.RecordType.Name, relatedIndividualAcnt.RecordType.Name);
            Test.stopTest();
            system.assertEquals(primaryAccount.accountRecord.LastName, accRecord1.LastName, 'The given two parameters are not equal');
           // system.assertEquals(16, optionValueList.size());
        }
    }

  /**
    * @method
    * Given a Agent User
    * When user clicks on New button on C2C Relationship Related List for INDIVIDUAL Account in Lightning
    * Then a page will be rendered with AccountName and able to Select relatedAccount as INDIVIDUAL
    * On selecting related account the Relationship Nature field will give options to select and proceed
    * @name testCreateC2CRelationshipInLightningIndivToIndiv
    * @description Test Create C2C Relationship In Lightning Indiv To Indiv
    */
    @isTest
    static void testCreateC2CRelationshipInLightningIndivToIndiv(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
            insert accRecord2;
        }
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);

        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
        }
        
        //relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        
        //System.debug('User Record in Test'+salesRoleHierarchy1.Agent);
        System.runAs(salesRoleHierarchy1.Agent){
            Id recordId=accRecord1.Id;
            VFC_C2CRelationshipController.AccountAndAgentAssocIdWrapper primaryAccount;
            List<String> optionValueList;
            Account relatedIndividualAcnt=[Select Id,LastName, RecordTypeId, recordType.Name,ClientIdentifier__c from Account where id=:accRecord2.Id];
            Test.startTest();
            primaryAccount=VFC_C2CRelationshipController.getPrimaryAccount(recordId);
            optionValueList=VFC_C2CRelationshipController.getOptions(primaryAccount.accountRecord.RecordType.Name, relatedIndividualAcnt.RecordType.Name);
            Test.stopTest();
            system.assertEquals(primaryAccount.accountRecord.LastName, accRecord1.LastName, 'The given two parameters are not equal');
            system.assertEquals(26, optionValueList.size(), 'Size of \'optionValueList\' is not equals to 26');
        }
    }

    /**
    * @method
    * Given a Agent User
    * When user clicks on edit button on C2C Relationship Related List for INDIVIDUAL Account in Lightning
    * On click, error message should be thrown that you are not allowed for out of book customers 
    * @name testgetC2CRelationshipRecordForLightning
    * @description Test Get C2C Relationship Record For Lightning
    */
    @isTest
    static void testgetC2CRelationshipRecordForLightning(){
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});    
     
        System.runAs(salesRoleHierarchy1.Agent){
            insert accRecord1;
        }
        System.runAs(salesRoleHierarchy2.Agent){
            insert accRecord2;
        }

        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord1.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy2.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRecord2.Id);
        relationship__c rel=new Relationship__c(accounttwo__c=accRecord1.id,accountone__c=accRecord2.id,RelationshipType__c='Spouse',RelationshipIdentifier__c=accRecord1.ClientIdentifier__c+'~'+accRecord2.ClientIdentifier__c);
        System.runAs(systemAdminUser){
            insert ar1;
            insert ar2;
            insert rel;
        }

        System.runAs(salesRoleHierarchy1.Agent){

            VFC_C2CRelationshipController.RelationshipAndUserIdWrapper userAndRelationship;
            Test.startTest();
            try{
                userAndRelationship=VFC_C2CRelationshipController.getC2CRelationshipRecordForLightning(rel.Id);
                System.assert(false, 'Assertion returns true');
            }catch(AuraHandledException e){
                  System.assert(true, 'Assertion returns false');
               }
            Test.stopTest();
        }
    }
}

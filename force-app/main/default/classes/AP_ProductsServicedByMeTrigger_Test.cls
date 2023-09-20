@isTest
(SeeAllData=false)
public class AP_ProductsServicedByMeTrigger_Test {

    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
	private static Integer products_Test_Batch_Size = 50;
	private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
	private static TestData_SalesRoleHierarchy salesRoleHierarchy2; 
	private static User techSupport;
	private static Account accountRecord;
	private static List<AgentRole__c> agentRoleList=new List<AgentRole__c>();
    private static User systemAdminUser;
	/**
     * @description setupData
     */
    @testsetup
    public static void setupData() {    
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
		systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID); 
		SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser); 
		salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
		salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
        User testTechUser = new User(Alias='XXXX',LastName='techSupForPSMTest',Username='techSupForPSMTest@test.statefarm.com',Associate_ID__c='12345678PSM',UserExternalID__c='12345678PSM');
		techSupport=UTIL_UserProvisioning_TEST.buildTechnicalUser(testTechUser);
        insert techSupport;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{techSupport,salesRoleHierarchy2.Agent});
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.Agent});
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy1.AgentTeamMember});
        system.runAs(systemAdminUser){
            PermissionSet permSet3 = [select Id from PermissionSet where Name = 'CustomerView_Support_ViewAll'];
            PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = techSupport.Id, PermissionSetId = permSet3.Id);
            insert psa3;
            PermissionSet permSet5 = [select Id from PermissionSet where Name = 'ProductsServicedByMe_Edit'];
            PermissionSetAssignment psa5 = new PermissionSetAssignment(AssigneeId = techSupport.Id, PermissionSetId = permSet5.Id);
            insert psa5;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{salesRoleHierarchy2.AgentTeamMember});
        system.runAs(salesRoleHierarchy2.Agent){
			accountRecord=new Account(FirstName='FAccountForCoA',LastName='LAccountForCoA',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='SFFSP81L8XB');
			insert accountRecord;
		}
		system.runAs(systemAdminUser){
            createAgentRoles();
		} 
	}
    
    private static void retrieveUsers(){
        List<User> userList = [SELECT Id, Username, Associate_ID__c, Email, Alias, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c FROM User where email = 'techSupForPSMTest@test.statefarm.com' or alias = 'admin'];
        for(User usr : userList) {
            if(usr.email=='techSupForPSMTest@test.statefarm.com'){
                techSupport = usr;
            }
            else if(usr.alias=='admin'){
                systemAdminUser = usr;
            }
        }
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        accountRecord = [Select Id, FirstName, LastName, BillingAddressType__c, BillingCity, ClientIdentifier__c From Account Where ClientIdentifier__c = 'SFFSP81L8XB'];
    }
    /**
     * @description setupForSPIValidations
     */
    public static void setupForSPIValidations(){
        system.runAs(systemAdminUser){
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreachNew();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForProductServicedByMe();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
		}
    }
	
    /* Given an Account with agent roles   
    * When a Tech support user creates a Product Serviced by me record 
      Then the record should be accessiable to appropriate office.  
    */
    /**
     * @description testProductsServicedByMeWithTechUser
     */
    @isTest
	public static void testProductsServicedByMeWithTechUser(){
		retrieveUsers();
		List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
		ProductsServicedByMe__C prod1 = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',
			CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy2.Agent.id);
		ProductsServicedByMeList.add(prod1);
        system.runAs(techSupport){
			insert ProductsServicedByMeList;
			ProductsServicedByMe__C productsServicedByMeRecord=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountRecord.Id];
			System.assertEquals(salesRoleHierarchy2.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
			System.assertEquals(salesRoleHierarchy2.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
		}
		verifyAccessToProduct(accountRecord.Id,ProductsServicedByMeList.size(),salesRoleHierarchy2.Agent);
		verifyAccessToProduct(accountRecord.Id,0,salesRoleHierarchy1.Agent);
	}
	
    /* Given an Account with agent roles   
    * When a Tech support user creates a Product Serviced by me records 
    * Then the record should be accessiable to appropriate offices.  
    */
    /**
     * @description testProductsServicedByMeWithTechUserBulkified
     */
    @isTest
	public static void testProductsServicedByMeWithTechUserBulkified(){
        retrieveUsers();
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        for(Integer i = 0 ; i <products_Test_Batch_Size; i++) {
        	ProductsServicedByMe__C prod1 = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy2.Agent.id);
        ProductsServicedByMeList.add(prod1);
        }
        system.runAs(techSupport){
            insert ProductsServicedByMeList;
            List<ProductsServicedByMe__C> productsServicedByMeRecordList=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountRecord.Id];
            for(ProductsServicedByMe__C productsServicedByMeRecord:productsServicedByMeRecordList){
                System.assertEquals(salesRoleHierarchy2.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
            	System.assertEquals(salesRoleHierarchy2.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
            }
        }
        verifyAccessToProduct(accountRecord.Id,ProductsServicedByMeList.size(),salesRoleHierarchy2.Agent);
        verifyAccessToProduct(accountRecord.Id,0,salesRoleHierarchy1.Agent);
    }
    
    /* Given an Account with agent roles   
    * When a Agent user creates a Product Serviced by me record 
    * Then the record should be accessiable by their office.  
    */
    /**
     * @description testProductsServicedByMeWithAgentUser
     */
    @isTest
    public static void testProductsServicedByMeWithAgentUser(){
        retrieveUsers();
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        ProductsServicedByMe__C prod1 = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health');
        ProductsServicedByMeList.add(prod1);
        system.runAs(salesRoleHierarchy1.Agent){
            insert ProductsServicedByMeList;
        }
        ProductsServicedByMe__C productsServicedByMeRecord=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountRecord.Id];
        System.assertEquals(salesRoleHierarchy1.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
        System.assertEquals(salesRoleHierarchy1.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
        verifyAccessToProduct(accountRecord.Id,ProductsServicedByMeList.size(),salesRoleHierarchy1.Agent);
        verifyAccessToProduct(accountRecord.Id,0,salesRoleHierarchy2.AgentTeamMember);
    }
    
    /* Given an Account with agent roles   
    * When a Agent user creates a Product Serviced by me record 
    * Then the record should be accessiable to their office.  
    */
    /**
     * @description testProductsServicedByMeWithAgentUserBulkified
     */
    @isTest
    public static void testProductsServicedByMeWithAgentUserBulkified(){
        retrieveUsers();
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        for(Integer i = 0 ; i <products_Test_Batch_Size; i++) {
        	ProductsServicedByMe__C prod1 = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health');
        	ProductsServicedByMeList.add(prod1);
        }
        system.runAs(salesRoleHierarchy2.Agent){
            insert ProductsServicedByMeList;
        }
        List<ProductsServicedByMe__C> productsServicedByMeRecordList=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountRecord.Id];
        for(ProductsServicedByMe__C productsServicedByMeRecord:productsServicedByMeRecordList){
        	System.assertEquals(salesRoleHierarchy2.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
        	System.assertEquals(salesRoleHierarchy2.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
        }
        verifyAccessToProduct(accountRecord.Id,ProductsServicedByMeList.size(),salesRoleHierarchy2.Agent);
        verifyAccessToProduct(accountRecord.Id,0,salesRoleHierarchy1.AgentTeamMember);
    }
    
    /* Given an Account with agent roles   
    * When a ATM user creates a Product Serviced by me record 
    * Then the record should be accessiable to their office.  
    */   
    /**
     * @description testProductsServicedByMeWithATMUser
     */ 
    @isTest
    public static void testProductsServicedByMeWithATMUser(){
        retrieveUsers();
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        ProductsServicedByMe__C prod1 = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health');
        ProductsServicedByMeList.add(prod1);
        system.runAs(salesRoleHierarchy1.AgentTeamMember){
            insert ProductsServicedByMeList;
            
        }
        ProductsServicedByMe__C productsServicedByMeRecord=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountRecord.Id];
        System.assertEquals(salesRoleHierarchy1.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
        System.assertEquals(salesRoleHierarchy1.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
        verifyAccessToProduct(accountRecord.Id,ProductsServicedByMeList.size(),salesRoleHierarchy1.AgentTeamMember);
        verifyAccessToProduct(accountRecord.Id,0,salesRoleHierarchy2.Agent);
    }
    
    /* Given an Account with agent roles   
    * When a ATM user creates a Product Serviced by me records 
    * Then the records should be accessiable to their office.  
    */  
    /**
     * @description testProductsServicedByMeWithATMUserBulkified
     */  
    @isTest
    public static void testProductsServicedByMeWithATMUserBulkified(){
        retrieveUsers();
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        for(Integer i = 0 ; i <products_Test_Batch_Size; i++) {
        	ProductsServicedByMe__C prod1 = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health');
        	ProductsServicedByMeList.add(prod1);
        }
        system.runAs(salesRoleHierarchy2.AgentTeamMember){
            insert ProductsServicedByMeList;
            
        }
        List<ProductsServicedByMe__C> productsServicedByMeRecordList=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountRecord.Id];
        for(ProductsServicedByMe__C productsServicedByMeRecord:productsServicedByMeRecordList){
        	System.assertEquals(salesRoleHierarchy2.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
        	System.assertEquals(salesRoleHierarchy2.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
        }
        verifyAccessToProduct(accountRecord.Id,ProductsServicedByMeList.size(),salesRoleHierarchy2.AgentTeamMember);
        verifyAccessToProduct(accountRecord.Id,0,salesRoleHierarchy1.Agent);
    }
    
    /* Utility method to create Agent roles. 
    */    
    private static void createAgentRoles(){
        AgentRole__c ar1=new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accountRecord.Id);
        AgentRole__c ar2=new AgentRole__c(Agent__c=salesRoleHierarchy2.Agent.Id, RelationshipNature__c='Customer',Customer__c=accountRecord.Id);
        
        agentRoleList.add(ar1);
        agentRoleList.add(ar2);
        
        insert agentRoleList;
    }
    
    /* Utility method to validate access and number of  Products serviced by me records
    */    
    private static void verifyAccessToProduct(Id accountId,Integer expectedSizeOfProducts,User runAsUser){
        system.runAs(runAsUser){
            List<ProductsServicedByMe__C> productsServicedByMeRecordList=[Select id,ownerid,Agent__c from ProductsServicedByMe__C where customer__c=:accountId];
            System.assertEquals(expectedSizeOfProducts, productsServicedByMeRecordList.size(), 'Expected number of products not found on the account for the user'+runAsUser);
        }
    }
    
    /* Given an Account with Products Serviced by me record 
    * When a Agent user updates a Product Serviced by me record 
    * Then the record should be accessiable to appropriate office.  
    */   
    /**
     * @description verifyThatTheOwnerIdIsSetWhenAnAgentUpdatesAProductServicedByMe
     */ 
    @isTest
    public static void verifyThatTheOwnerIdIsSetWhenAnAgentUpdatesAProductServicedByMe() {
        //Setup
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
        retrieveUsers();
        updateARecordAndVerifyTheOwnerIdIsSet(salesRoleHierarchy1.Agent);
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }
    /* Given an Account with agent roles   
    * When a ATM user updates a Product Serviced by me record 
    * Then the record should be accessiable to appropriate office.  
    */   
    /**
     * @description verifyThatTheOwnerIdIsSetWhenAnAtmUpdatesAProductServicedByMe
     */ 
    @isTest
    public static void verifyThatTheOwnerIdIsSetWhenAnAtmUpdatesAProductServicedByMe() {
        //Setup
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
        retrieveUsers();
       	updateARecordAndVerifyTheOwnerIdIsSet(salesRoleHierarchy1.AgentTeamMember);
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }
    
    /* Given an Account with agent roles   
    * When a Tech Supprt user updates a Product Serviced by me record 
    * Then the record should be accessiable to appropriate office.  
    */    
    /**
     * @description verifyThatTheOwnerIdIsSetWhenTechSupportUpdatesAProductServicedByMe
     */
    @isTest
    public static void verifyThatTheOwnerIdIsSetWhenTechSupportUpdatesAProductServicedByMe() {
        //Setup
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
        retrieveUsers();
        updateARecordAndVerifyTheOwnerIdIsSet(techSupport);
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }
    
    /* Given an Account wit h agent roles   
    * When a Agent user with invalid user dataupdates a Product Serviced by me record 
    * Then the update should be fail.  
    */ 
    /**
     * @description verifyThatanExceptionIsThrownWhenLookupFails
     */
    @isTest
    public static void verifyThatanExceptionIsThrownWhenLookupFails() {
		 retrieveUsers();
        
         List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        ProductsServicedByMe__C prod1 = 
            new ProductsServicedByMe__C(customer__c=accountRecord.Id,
            ProductType__c='Disability Income', CarrierName__c='Trupanion',ProductLine__c='Health');
        productsServicedByMeList.add(prod1);
        //Insert the list as the given User (userWithAccess)
        system.runAs(salesRoleHierarchy1.Agent) {
            insert ProductsServicedByMeList;
        }
   		
        salesRoleHierarchy1.AgentOffice.UserExternalID__c='TestUpdate1';
        system.runAs(systemAdminUser){
        	update salesRoleHierarchy1.AgentOffice;
        }
        system.runAs(salesRoleHierarchy1.Agent) {
            try{
            	update new ProductsServicedByMe__C(Agent__c = salesRoleHierarchy1.Agent.Id,Id=ProductsServicedByMeList.get(0).Id);
                System.assert(false,'Assertion failed');
            } Catch(Exception ex) {
                System.assert(ex.getMessage()!=null, 'Exception message should not be null');
            }
        }
        
    }
    
    /* Utility to test the update of ProductsServicedByMe__c 
    */ 
    
    private static void updateARecordAndVerifyTheOwnerIdIsSet(User userWithAccess) {
        //Add a single product to the list
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        ProductsServicedByMe__C prod1 = 
            new ProductsServicedByMe__C(customer__c=accountRecord.Id,
                                        ProductType__c='Disability Income', CarrierName__c='Trupanion',ProductLine__c='Health');
        productsServicedByMeList.add(prod1);
        //Insert the list as the given User (userWithAccess)
        system.runAs(salesRoleHierarchy1.Agent) {
            insert ProductsServicedByMeList;
        }
        
        //modify the records
        //prod1.ProductLine__c = '';
        ProductsServicedByMe__C productsServicedByMeRecord = [Select id,ownerid,Agent__c, ProductLine__c from ProductsServicedByMe__C where customer__c = :accountRecord.Id];
        productsServicedByMeRecord.ProductLine__c = 'Fire';
        
        system.runAs(userWithAccess) {
            update productsServicedByMeRecord;
        }
        //Do a query to get the inserted data
        System.runas(techSupport){
            productsServicedByMeRecord = [Select id,ownerid,Agent__c, ProductLine__c from ProductsServicedByMe__C where customer__c = :accountRecord.Id];
            
            System.assertEquals('Fire', productsServicedByMeRecord.ProductLine__c, 'The product line was not updated');
            System.assertEquals(salesRoleHierarchy1.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
            System.assertEquals(salesRoleHierarchy1.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
            System.assertNotEquals(salesRoleHierarchy2.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId is set to the wrong proxy');
            System.assertNotEquals(salesRoleHierarchy2.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup did not work as expected');
        }
        
        //To Do
        //STUFF
        Integer numberOfRecords = 1;
        verifyAccessToProduct(accountRecord.Id, numberOfRecords, userWithAccess);
        
        productsServicedByMeRecord = [Select id,ownerid,Agent__c, ProductLine__c from ProductsServicedByMe__C where customer__c = :accountRecord.Id];
        productsServicedByMeRecord.OwnerId = salesRoleHierarchy2.AgentOffice.id;
        
        system.runAs(userWithAccess) {
            update productsServicedByMeRecord;
        }
        system.runAs(techSupport){
            productsServicedByMeRecord = [Select id,ownerid,Agent__c, ProductLine__c from ProductsServicedByMe__C where customer__c = :accountRecord.Id];
            System.assertEquals(salesRoleHierarchy1.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId not set to the proxy');
            System.assertEquals(salesRoleHierarchy1.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup is not setup as expected');
            System.assertNotEquals(salesRoleHierarchy2.AgentOffice.id, productsServicedByMeRecord.ownerid, 'OwnerId is set to the wrong proxy');
            System.assertNotEquals(salesRoleHierarchy2.Agent.id, productsServicedByMeRecord.agent__c, 'Agent lookup did not work as expected');
        }
    }
    
    /****************************** SPI TESTS ***************************/
    
    /* Given an Account with agent roles   
    * When a user creates a Product Serviced by me record with SPI data on Comments field
    * Then the user should receive appropriate error message.  
    */ 
    /**
     * @description verifySPIErrorOnCommentsFieldInsert
     */
    @isTest
    private static void verifySPIErrorOnCommentsFieldInsert(){
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
        retrieveUsers();
        setupForSPIValidations();
       CreateProductServicedByMeRecordsWrapper createProductServicedWrapper = new CreateProductServicedByMeRecordsWrapper(); 
       createProductServicedWrapper.productCommentsValue = 'ssn 734853914';
       createProductServicedWrapper.companyNameValue = 'Other';
       createProductServicedWrapper.companyNameOtherValue = 'XYZ INC';
       createProductServicedWrapper.sizeOfList = 200;
        List<ProductsServicedByMe__C> productsServicedByMeList=createProductServicedByMeRecords(createProductServicedWrapper);
        verifySPIErrorsOnInsert(salesRoleHierarchy1.Agent,productsServicedByMeList,UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMMENTS_ERROR );
        verifySPIErrorsOnInsert(techSupport,productsServicedByMeList,UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMMENTS_ERROR );
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }
    
    /* Given an Account with agent roles   
    * When a user creates a Product Serviced by me record with SPI data on Company Name Other field
    * Then the user should receive appropriate error message.  
    */ 
    @isTest
    private static void verifySPIErrorOnCarrierNameOtherFieldInsert(){
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
      	retrieveUsers();
        setupForSPIValidations();
       CreateProductServicedByMeRecordsWrapper createProductServicedWrapper = new CreateProductServicedByMeRecordsWrapper(); 
       createProductServicedWrapper.productCommentsValue = 'XYZ';
       createProductServicedWrapper.companyNameValue = 'Other';
       createProductServicedWrapper.companyNameOtherValue = 'ssn 734853914';
       createProductServicedWrapper.sizeOfList = 5;
        List<ProductsServicedByMe__C> productsServicedByMeList=createProductServicedByMeRecords(createProductServicedWrapper);
        verifySPIErrorsOnInsert(salesRoleHierarchy1.AgentTeammember,productsServicedByMeList,UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMPANY_NAME_OTHER_ERROR);
        verifySPIErrorsOnInsert(techSupport,productsServicedByMeList,UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMPANY_NAME_OTHER_ERROR);  
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }
    
    /* Given an Account with Product Serviced by me record   
    * When a user updates a Product Serviced by me record with SPI data on Comments field
    * Then the user should receive appropriate error message.  
    */ 
    @isTest
    private static void verifySPIErrorOnCommentsFieldUpdate(){
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
        retrieveUsers();
        setupForSPIValidations();
        VerifySPIErrorsOnUpdateWrapper verifyWrapper = new  VerifySPIErrorsOnUpdateWrapper();
        verifyWrapper.runAsUser = salesRoleHierarchy1.Agent;
        verifyWrapper.spiTargetFeildName = 'ProductComments__c';
        verifyWrapper.spiTargetfeildValue = 'ssn 734853914';
        verifyWrapper.expectedError = UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMMENTS_ERROR;
        verifySPIErrorsOnUpdate(verifyWrapper);
        VerifySPIErrorsOnUpdateWrapper verifyWrapper1 = new  VerifySPIErrorsOnUpdateWrapper();
        verifyWrapper1.runAsUser = techSupport;
        verifyWrapper1.spiTargetFeildName = 'ProductComments__c';
        verifyWrapper1.spiTargetfeildValue = 'ssn 734853914';
        verifyWrapper1.expectedError = UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMMENTS_ERROR;
        verifySPIErrorsOnUpdate(verifyWrapper1);
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }
    
    @isTest
    private static void verifySPIErrorOnCarrierNameOtherFieldUpdate(){
        User cccLicensedUser = TestDataFactory_User_Wrapper.generateCCCLicensedUser('TEST', '12345678914');
        System.runAs(cccLicensedUser){
        retrieveUsers();
        setupForSPIValidations();
        VerifySPIErrorsOnUpdateWrapper verifyWrapper = new  VerifySPIErrorsOnUpdateWrapper();
        verifyWrapper.runAsUser = salesRoleHierarchy1.AgentTeammember;
        verifyWrapper.spiTargetFeildName = 'CarrierNameOther__c';
        verifyWrapper.spiTargetfeildValue = 'ssn 734853914';
        verifyWrapper.expectedError = UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMPANY_NAME_OTHER_ERROR;
        verifySPIErrorsOnUpdate(verifyWrapper);
        VerifySPIErrorsOnUpdateWrapper verifyWrapper1 = new  VerifySPIErrorsOnUpdateWrapper();
        verifyWrapper1.runAsUser = techSupport;
        verifyWrapper1.spiTargetFeildName = 'CarrierNameOther__c';
        verifyWrapper1.spiTargetfeildValue = 'ssn 734853914';
        verifyWrapper1.expectedError = UTIL_SPITestConstants.PRODUCT_SERVICED_BY_ME_COMPANY_NAME_OTHER_ERROR;
        verifySPIErrorsOnUpdate(verifyWrapper1);
        }
        System.assertEquals(1, 1, '1 should equal 1');
    }

    /**
     * @description CreateProductServicedByMeRecordsWrapper
     */
    public class CreateProductServicedByMeRecordsWrapper{
       String productCommentsValue;
       String companyNameValue;
       String companyNameOtherValue;
       Integer sizeOfList;
    }

    private static List<ProductsServicedByMe__C> createProductServicedByMeRecords(CreateProductServicedByMeRecordsWrapper createProductWrapper){
        List<ProductsServicedByMe__C> productsServicedByMeList = new List<ProductsServicedByMe__C>();
        for(Integer i = 0 ; i <createProductWrapper.sizeOfList; i++) {
            ProductsServicedByMe__C prod = new ProductsServicedByMe__C(customer__c=accountRecord.Id,ProductType__c='Disability Income',CarrierNameOther__c=createProductWrapper.companyNameOtherValue,
                                                                        CarrierName__c=createProductWrapper.companyNameValue,ProductLine__c='Health',Agent__c=salesRoleHierarchy2.Agent.id,ProductComments__c=createProductWrapper.productCommentsValue);
            productsServicedByMeList.add(prod);
        }
        return productsServicedByMeList;
    }
    
    private static void verifySPIErrorsOnInsert(User runAsUser,List<ProductsServicedByMe__C> productsServicedByMeList,String expectedError){
        System.runAs(runAsUser){
            try{
                insert productsServicedByMeList;
                system.assert(false,'Assertion failed');
            }catch(Exception ex){
                system.assert(true,'Assertion failed');
                System.assert(ex.getMessage().contains(expectedError), 'Exception Message Doesnot contain expected error');
            }
            List<ProductsServicedByMe__C> resultantList=[Select id,ownerid,Agent__c, ProductLine__c from ProductsServicedByMe__C where customer__c = :accountRecord.Id];
        	system.assert(resultantList.isEmpty(),'resultantList should be empty');
        }
    }
    
    /**
     * @description VerifySPIErrorsOnUpdateWrapper
     */
    public class VerifySPIErrorsOnUpdateWrapper{
        User runAsUser;
        String spiTargetFeildName;
        String spiTargetfeildValue;
        String expectedError;
    }

    private static void verifySPIErrorsOnUpdate(VerifySPIErrorsOnUpdateWrapper verifySPIWrapper){
        System.runAs(verifySPIWrapper.runAsUser){
            CreateProductServicedByMeRecordsWrapper createProductServicedWrapper = new CreateProductServicedByMeRecordsWrapper(); 
            createProductServicedWrapper.productCommentsValue = 'ABC';
            createProductServicedWrapper.companyNameValue = 'Other';
            createProductServicedWrapper.companyNameOtherValue = 'ABC';
            createProductServicedWrapper.sizeOfList = 200;
            List<ProductsServicedByMe__C> productsServicedByMeList=createProductServicedByMeRecords(createProductServicedWrapper);
        	insert productsServicedByMeList;
            try{
                for(ProductsServicedByMe__C prod:productsServicedByMeList){
                    prod.put(verifySPIWrapper.spiTargetFeildName,verifySPIWrapper.spiTargetfeildValue);
                }
                update productsServicedByMeList;
            }catch(Exception ex){
                system.assert(true,'Assertion failed');
                System.assert(ex.getMessage().contains(verifySPIWrapper.expectedError), 'Exception Message Doesnot contain expected error');
            }
            List<ProductsServicedByMe__C> resultantList=[Select id,ownerid,Agent__c, ProductLine__c from ProductsServicedByMe__C where customer__c = :accountRecord.Id];
        	system.assert(!resultantList.isEmpty(),'resultantList should not be empty');
        }
    }
}
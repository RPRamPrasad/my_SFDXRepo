/*
Author-QuadC Team
Description-Test Class for HLPR_OppButtonController
*/
@isTest
Public class HLPR_OppButtonController_Test {
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User cccLUser;
    private static User cccULUser;
    private static User generalReadOnly;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static final String PSN_EFFECTIVEDATE_ERROR_MSG='Please validate the choices below.';
    private static final String PRODUCT_INVALID_ERROR_MSG='The Line of Business, Effective Date and Product combination is not valid. Please validate the choices below.';
    private static final String SUCCESS = 'success';
    private static final String FAILURE = 'failure';
    private static Account testAccount;
    //To get the Recordtype of opportunity
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();

    /**
    Set up test data
    * @description setUpTriggerAndUserData
    */
    @TestSetup
    private static void setUpTriggerAndUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);
        insert sysAdminUserIdSetting;
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        insert oppByPassTrigger;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');

        System.runAs(sysAdminuser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            agentStandardUserRole= new UserRole(name='AgentRole');
            insert agentStandardUserRole;
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            
            atmUser = new User(alias = 'Alias', email='remCmpMemAgent1@statefarm.com.bad',
                    Associate_ID__c='124test', UserExternalID__c= '124test', Servicing_Agent_Associate_ID__c ='123test',
                    emailencodingkey='UTF-8', lastname='CmpMemProx', languagelocalekey='en_US',
                    localesidkey='en_US', timezonesidkey='Europe/London', username= 'TestAtmUserForOppTst11@statefarm.com',userRoleId=agentTeamMemberUserRole.id);
                    atmUser.ProfileId = UTIL_ProfileId_TEST.getATMProfileId();
                    Database.insert(atmUser);
            cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            Database.insert(cccLUser);
            User testCCCUnLicenUser1 = new User(Alias='CCUL',LastName='CCUL',Username='CCUL@statefarm.com',Associate_ID__c='12123',UserExternalID__c='12123');
            cccULUser = UTIL_UserProvisioning_TEST.buildCCCUnlicensedUser(testCCCUnLicenUser1);
            Database.insert(cccULUser);
            User testGenReadOnlyUser = new User(Alias='GRPU',LastName='GeneralReadOnly',Username='TestGeneralReadOnlyUserTst123@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123testgrpu');
            generalReadOnly = UTIL_UserProvisioning_TEST.buildGeneralReadOnlyUser(testGenReadOnlyUser);
            Database.insert(generalReadOnly);
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(generalReadOnly.Id, 'Opportunity_Standard_R');
            OpportunityProduct__c oppProd1 = insertOpportunityProductData('Auto','Private Passenger');
            oppProd1.Product_System_Name__c='PSN';
            insert oppProd1;
            OpportunityProduct__c oppProd2 = insertOpportunityProductData('Life','Life Annuity');
            insert oppProd2;
        }
        Account testAccount;
        System.runAs(agentUser) {
            Account act = buildAccountRecord('1213121');
            insert act;
        }
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            insert opty;
        }
    }
    
    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String param_clientIdentifier) {
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = param_clientIdentifier);
        return act;
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        return agentRole;
    }

    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String param_accountId, String param_StageName, String param_recordTypeId) {
        Opportunity opty = new Opportunity (Name = 'Tst ILP Claimed Opty', AccountId = param_accountId,
                            CloseDate = Date.today(), LOB__c = 'Auto',
                            StageName = param_StageName, RecordTypeId = param_recordTypeId, Product__c = 'Private Passenger');
       return opty;
    }
    @isTest
    private static void testButtonsAsAgent(){
        agentUser = [select id from user where alias = 'Alia' limit 1];
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            AppDefinition definition = [SELECT Id, DeveloperName, Label, Description, UtilityBar, HeaderColor, DurableId
                                       FROM AppDefinition WHERE DeveloperName ='ECRM_3_0' LIMIT 1];

            UserAppInfo userAppInfo = new UserAppInfo();
            userAppInfo.UserId=agentUser.Id;
            userAppInfo.AppDefinitionId=definition.DurableId;
            userAppInfo.FormFactor='Large';
            insert userAppInfo;
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
               opty.State_Code__c='KY / 12-1233';

            insert opty;
            Opportunity opp = [select id,State_Code__c,Assigned_To__c from opportunity where id=:opty.id];
            Boolean inLtngExp = HLPR_OppButtonController.inLightningExp();
            system.assertNotEquals(inLtngExp, null,'Lightning Exp should be true');
            Boolean isValidProfile = HLPR_OppButtonController.isValidProfile();
            system.assert(isValidProfile, true);
            Boolean isOppCreatable = HLPR_OppButtonController.isOppCreatable();
            system.assert(isOppCreatable, true);
            Boolean isOppCreatableAndValidProfile = HLPR_OppButtonController.isOppCreatableAndValidProfile();
            system.assert(isOppCreatableAndValidProfile, true);
            Boolean isAllowedProfileForNewAppQuoteAndProdMger = HLPR_OppButtonController.isAllowedprofileForNewAppQuoteAndProductionManager();
            system.assert(isAllowedProfileForNewAppQuoteAndProdMger, true);

            String url = HLPR_OppButtonController.newAppQuoteUrl(opp.id,getProductJson());
            system.assert(String.isNotBlank(url),'Url Cannot be blank');
            url = HLPR_OppButtonController.prodMgrURL(opp.id);
            system.assert(String.isNotBlank(url),'Url cannot be blank');

            System.assert(!HLPR_OppButtonController.isOppNewAndAssigned(String.valueOf(opp.id)),'Opportunity Assigned to cannot be blank');

        }
    }

    @isTest
    private static void testButtonsAsCCCL(){
        cccLUser = [select id from user where alias =  'CCCL' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
         AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(cccLUser.Id, 'Opportunity_PartialAccess');
        System.runAs(ccCLUser) {
              Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.State_Code__c='KY / 12-1233';

            insert opty;
            Opportunity opp = [select id from opportunity where id=:opty.Id];
            String url = HLPR_OppButtonController.newAppQuoteUrl(opp.id,getProductJson());
            system.assert(String.isNotBlank(url),'String should not be blank');
            url = HLPR_OppButtonController.prodMgrURL(opp.id);
            system.assert(String.isNotBlank(url),'String should not be blank');
           
            String buttonValidity = HLPR_OppButtonController.oppButtonVisibility(opp.id);
            System.assertEquals(buttonValidity, 'ValidEdit','Expected value is '+buttonValidity+', but actual value is ValidEdit');
        }        
    }

    @isTest
    private static void testProductionManagerButtonAsCCCUL(){
        cccULUser = [select id from user where alias =  'CCUL' limit 1];
         agentUser = [select id from user where alias = 'Alia' limit 1];
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(cccULUser) {
             Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
           	opty.Opportunity_Originator__c='Statefarm.com';
            insert opty;
            Opportunity opp = [select id, isQuoteCanvasable__c from opportunity where id=:opty.id];
            String url = HLPR_OppButtonController.prodMgrURL(opp.id);
            system.assert(String.isNotBlank(url),'String should not be blank');
            String buttonValidity = HLPR_OppButtonController.oppButtonVisibility(opp.id);
            System.assertEquals(buttonValidity, 'ValidRead','Expected value is '+buttonValidity+', but actual value is ValidRead');
        }        
    }

    @isTest
    private static void testButtonVisibilityAsGeneralReadOnly() {
        generalReadOnly = [select id from user where alias =  'GRPU' limit 1];
        System.runAs(generalReadOnly) {
            Opportunity opp = [select id, Opportunity_Originator__c from opportunity limit 1];
            String buttonValidity = HLPR_OppButtonController.oppButtonVisibility(opp.id);
            System.assertEquals(buttonValidity, 'ValidRead','Expected value is '+buttonValidity+', but actual value is ValidRead');
        }
    }

    @isTest
    private static void testIsOppQuoteCanvasable() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'ECRM_ARIA_Participant_PermSetPID');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
           	opty.Opportunity_Originator__c='Statefarm.com';
            insert opty;
            Opportunity opp = [select id, isQuoteCanvasable__c from opportunity where id=:opty.id];
            String oppCanvasable = HLPR_OppButtonController.isOppQuoteCanvasable(opp.id);
            System.assertEquals('true;ECRM 3.0;', oppCanvasable, 'isQuoteCanvasable field not correct');
        }
    }

    @isTest
    private static void testIsOppQuoteCanvasableCCCLUser() {
        cccLUser = [select id from user where alias =  'CCCL' limit 1];
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(cccLUser.Id, 'Opportunity_PartialAccess');
        System.runAs(cccLUser) {
            Opportunity opp = [select id, isQuoteCanvasable__c from opportunity limit 1];
            String oppCanvasable = HLPR_OppButtonController.isOppQuoteCanvasable(opp.id);
            System.assertEquals('false;ECRM 3.0;', oppCanvasable, 'isQuoteCanvasable field not correct for CCCLUser test');
        }
    }

    private static String getProductJson(){
      String oppProductJson= '{"attributes":{"type":"OpportunityProduct__c"},'
            			+'"lob_Name__c":"Auto","Category_Name__c":"Product Selection","Product_Description__c":"Private Passenger","Product_Form_Num__c":"AP8103","Product_Id__c":"P1","Product_Line__c":"A","Product_System_Name__c":"PP_PRSNL_PREF","Product_End_Date__c":"2028-04-15","Product_Postal_State__c":"IL","Product_Start_Date__c":"2020-04-15","Product_Type__c":"Private Passenger","Status__c":"true","Name":"test"'
        +   '}';
        return oppProductJson;
    }
    @isTest
    private static void testgetResponselistInvalidPSN() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        System.runAs(agentUser) {
            Opportunity opp = [select id, isQuoteCanvasable__c from opportunity limit 1];
            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opp.Id);

            System.assertEquals(PSN_EFFECTIVEDATE_ERROR_MSG, responseMap.get('errorInfo'),'Error Information showing to agent is wrong');
            System.assertEquals(FAILURE, responseMap.get('status'),'This might result invalid invocation which might break application');
        }
    }

    @isTest
    private static void testgetResponselistInvalidEffectiveDateRange() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];

        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.Requested_Effective_Date__c=System.Today()-365;
            insert opty;
            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);

            System.assertEquals(PRODUCT_INVALID_ERROR_MSG, responseMap.get('errorInfo'),'The lob, effective date, product combination is not valid. Please choose an effective date where the Product is valid or create a new Opportunity');
            System.assertEquals(FAILURE, responseMap.get('status'),'This might result invalid invocation which might break application');
        }
    }

    @isTest
    private static void testgetResponselistNulldEffectiveDate() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            insert opty;
            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);

            System.assertEquals(PRODUCT_INVALID_ERROR_MSG, responseMap.get('errorInfo'),'Error Message is incorrect');
            System.assertEquals(FAILURE, responseMap.get('status'),'This might result invalid invocation which might break application');
        }
    }

    @isTest
    private static void testgetResponselistInvalidProduct() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.Requested_Effective_Date__c=System.Today()-5;
            insert opty;
            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);

            System.assertEquals(PRODUCT_INVALID_ERROR_MSG, responseMap.get('errorInfo'),'Please verify the existing information is correct, Actual: The lob, effective date, product combination is not valid. Please choose an effective date where the Product is valid or create a new Opportunity');
            System.assertEquals(FAILURE, responseMap.get('status'),'This might result invalid invocation which might break application');
        }
    }

    @isTest
    private static void testgetResponselistValidProduct() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.product__c='Private Passenger';
            opty.lob__c='Auto';
            opty.Requested_Effective_Date__c=System.Today();
            opty.State_code__c='IL / 13-1234';
            insert opty;

            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);
            Opportunity opp = [select id,Product__c,lob__c,StageName,status__c,IsQuoteCanvasable__c,State_code__c,AccountId,OwnerServicingAgentAssociateID__c,Requested_Effective_Date__c from opportunity where id=:opty.id];
            System.assertEquals(SUCCESS, responseMap.get('errorInfo'),'Please verify the existing information is correct');
            System.assertEquals(SUCCESS, responseMap.get('status'),'Valid information this is coming as wrong');
            System.assertEquals(opp.StageName, responseMap.get('stageName'),'Stage Name information is incorrect');
            System.assertEquals(opp.OwnerServicingAgentAssociateID__c, responseMap.get('ownerId'),'Servicing Agent information is incorrect');
            System.assertEquals(opp.Status__c, responseMap.get('oppStatus'),'Status information is incorrect');
            System.assertEquals('Yes',responseMap.get('isProductSellable'),'Product is not sellable');
            System.assertEquals(opp.State_code__c,responseMap.get('userState'),'State code is not valid');
            System.assertNotEquals(null,responseMap.get('ProductObjectInfo'),'Product Object Information is not null');
            System.assertEquals('false', responseMap.get('isProductEditable'),'Product data is not editable as PSN is not empty');
            System.assertEquals(String.valueOf(opp.Requested_Effective_Date__c),responseMap.get('effectiveDate'),'Effectdate is not matching with Opp effective date');
            System.assertEquals(opp.product__c,responseMap.get('product'),'Product data is not matching with opportunity product information');
            System.assertEquals(opp.AccountId,responseMap.get('accountId'),'Account Id information is not matching');
            System.assertEquals(opp.lob__c,responseMap.get('lob'),'Lob  information is not matching');
            System.assertEquals(String.valueOf(opp.IsQuoteCanvasable__c),responseMap.get('isQuoteCanvasable'),'Quote canvasable  information is not matching');
        }
    }

	@isTest
    private static void testgetResponselistValidProductNoPSN() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            //opty.Product_system_name__c='PSN';
            opty.product__c='Private Passenger';
            opty.lob__c='Auto';
            opty.Requested_Effective_Date__c=System.Today()-5;
            opty.State_code__c='IL / 13-1234';
            insert opty;

            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);
            Opportunity opp = [select id,Product__c,lob__c,StageName,status__c,IsQuoteCanvasable__c,State_code__c,AccountId,OwnerServicingAgentAssociateID__c,Requested_Effective_Date__c from opportunity where id=:opty.id];
            System.assertEquals(PSN_EFFECTIVEDATE_ERROR_MSG, responseMap.get('errorInfo'),'');
            System.assertEquals(FAILURE, responseMap.get('status'),'Valid information this is coming as wrong');
            System.assertEquals(opp.StageName, responseMap.get('stageName'),'Stage Name information is incorrect');
            System.assertEquals(opp.OwnerServicingAgentAssociateID__c, responseMap.get('ownerId'),'Stage Name information is incorrect');
            System.assertEquals(opp.Status__c, responseMap.get('oppStatus'),'Status information is incorrect');
            System.assertEquals('Yes',responseMap.get('isProductSellable'),'Product is not sellable');
            System.assertEquals(opp.State_code__c,responseMap.get('userState'),'State code is not valid');
            System.assertNotEquals(null,responseMap.get('ProductObjectInfo'),'Product Object Information is not null');
            System.assertEquals('true', responseMap.get('isProductEditable'),'Product data is not editable as PSN is not empty');
            System.assertEquals(String.valueOf(opp.Requested_Effective_Date__c),responseMap.get('effectiveDate'),'Effectdate is not matching with Opp effective date');
            System.assertEquals(opp.product__c,responseMap.get('product'),'Product data is not matching with opportunity product information');
            System.assertEquals(opp.AccountId,responseMap.get('accountId'),'Account Id information is not matching');
            System.assertEquals(opp.lob__c,responseMap.get('lob'),'Lob  information is not matching');
            System.assertEquals(String.valueOf(opp.IsQuoteCanvasable__c),responseMap.get('isQuoteCanvasable'),'Quote canvasable  information is not matching');
        }
    }
    @isTest
    private static void testgetResponselistEffectiveDateInvalidP() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.product__c='Private Passenger';
            opty.lob__c='Auto';
            opty.Requested_Effective_Date__c=System.Today()-150;
            opty.State_code__c='IL / 13-1234';
            insert opty;

            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);
            Opportunity opp = [select id,Product__c,lob__c,StageName,status__c,IsQuoteCanvasable__c,State_code__c,AccountId,OwnerServicingAgentAssociateID__c,Requested_Effective_Date__c from opportunity where id=:opty.id];
            System.assertEquals(PSN_EFFECTIVEDATE_ERROR_MSG, responseMap.get('errorInfo'),'');
            System.assertEquals(FAILURE, responseMap.get('status'),'Valid information this is coming as wrong');
            System.assertEquals(opp.StageName, responseMap.get('stageName'),'Stage Name information is incorrect');
            System.assertEquals(opp.OwnerServicingAgentAssociateID__c, responseMap.get('ownerId'),'Stage Name information is incorrect');
            System.assertEquals(opp.Status__c, responseMap.get('oppStatus'),'Status information is incorrect');
            System.assertEquals('Yes',responseMap.get('isProductSellable'),'Product is not sellable');
            System.assertEquals(opp.State_code__c,responseMap.get('userState'),'State code is not valid');
            System.assertNotEquals(null,responseMap.get('ProductObjectInfo'),'Product Object Information is not null');
            System.assertEquals('false', responseMap.get('isProductEditable'),'Product data is not editable as PSN is not empty');
            System.assertEquals(String.valueOf(opp.Requested_Effective_Date__c),responseMap.get('effectiveDate'),'Effectdate is not matching with Opp effective date');
            System.assertEquals(opp.product__c,responseMap.get('product'),'Product data is not matching with opportunity product information');
            System.assertEquals(opp.AccountId,responseMap.get('accountId'),'Account Id information is not matching');
            System.assertEquals(opp.lob__c,responseMap.get('lob'),'Lob  information is not matching');
            System.assertEquals(String.valueOf(opp.IsQuoteCanvasable__c),responseMap.get('isQuoteCanvasable'),'Quote canvasable  information is not matching');
        }
    }
    private static OpportunityProduct__c insertOpportunityProductData(String lob, String product){
        OpportunityProduct__c oppProduct = new OpportunityProduct__c();
        oppProduct.name='TestProduct';
        oppProduct.lob_Name__c=lob;
        oppProduct.Category_Name__c='Product Selection';
        oppProduct.Product_Description__c=product;
        oppProduct.Product_Form_NUM__c='PFM1';
        oppProduct.Product_Id__c='PID';
        oppProduct.Product_End_Date__c=System.today()+10;
        oppProduct.Product_Start_Date__c=System.today()-10;
        oppProduct.Product_Postal_State__c='IL';
        oppProduct.Product_Type__c=product;
        oppProduct.status__c=true;
        oppProduct.Lob_cd__c='27';
        return oppProduct;
    }
    @isTest
    private static void testgetResponselistForLobLife() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.product__c='Life Annuity';
            opty.lob__c='Life';
            opty.Requested_Effective_Date__c=System.Today()-5;
            opty.State_code__c='IL / 13-1234';
            insert opty;

            Map<String,String> responseMap = HLPR_OppButtonController.getResponseMap(opty.Id);
            Opportunity opp = [select id,Product__c,lob__c,StageName,status__c,IsQuoteCanvasable__c,State_code__c,AccountId,OwnerServicingAgentAssociateID__c,Requested_Effective_Date__c from opportunity where id=:opty.id];
            System.assertEquals(SUCCESS, responseMap.get('errorInfo'),'Please verify the existing information is correct.');
            System.assertEquals(SUCCESS, responseMap.get('status'),'Valid information this is coming as wrong');
            //System.assertEquals(opp.StageName, responseMap.get('stageName'),'Stage Name information is incorrect');
            System.assertEquals(opp.OwnerServicingAgentAssociateID__c, responseMap.get('ownerId'),'Stage Name information is incorrect');
            System.assertEquals(opp.Status__c, responseMap.get('oppStatus'),'Status information is incorrect');
            System.assertEquals(opp.State_code__c,responseMap.get('userState'),'State code is not valid');
            System.assertNotEquals(null,responseMap.get('ProductObjectInfo'),'Product Object Information is not null');
            System.assertEquals('false', responseMap.get('isProductEditable'),'Product data is not editable as PSN is not empty');
            //System.assertEquals(String.valueOf(System.today()),responseMap.get('effectiveDate'),'Effectdate is not matching with Opp effective date');
            System.assertEquals(opp.product__c,responseMap.get('product'),'Product data is not matching with opportunity product information');
            System.assertEquals(opp.AccountId,responseMap.get('accountId'),'Account Id information is not matching');
            System.assertEquals(opp.lob__c,responseMap.get('lob'),'Lob  information is not matching');
            System.assertEquals(String.valueOf(opp.IsQuoteCanvasable__c),responseMap.get('isQuoteCanvasable'),'Quote canvasable  information is not matching');
        }
    }
    @isTest
    private static void testAppName() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
         System.runAs(agentUser) {
              AppDefinition definition = [SELECT Id, DeveloperName, Label, Description, UtilityBar, HeaderColor, DurableId
                                       FROM AppDefinition WHERE DeveloperName ='ECRM_3_0' LIMIT 1];
            UserAppInfo userAppInfo = new UserAppInfo();
            userAppInfo.UserId=agentUser.Id;
            userAppInfo.AppDefinitionId=definition.DurableId;
            userAppInfo.FormFactor='Large';
            insert userAppInfo;

           String appName = HLPR_OppButtonNavController.getApplicationName();
           System.assertEquals(appName,'ECRM 3.0','Product data is not matching with opportunity product information');
        }
    }

    @isTest
    private static void testUpdateOpportunity() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.product__c='Life Annuity';
            opty.lob__c='Life';
            opty.Requested_Effective_Date__c=System.Today()-5;
            opty.State_code__c='IL';
            insert opty;

            String statusUpdate = HLPR_OppButtonController.updateOpportunity(opty.Id);
            Opportunity opp = [select id,Product__c,lob__c,StageName,status__c,IsQuoteCanvasable__c,State_code__c,AccountId,OwnerServicingAgentAssociateID__c,Requested_Effective_Date__c from opportunity where id=:opty.id];
            System.assertEquals('Success', statusUpdate,'Opportunity Updation is not successful');
            System.assertEquals(opp.StageName, 'Quoting','Stage Name information is incorrect');
            System.assertEquals(opp.status__c, 'Quote In Progress','Status information is incorrect');
        }
    }

    @isTest
    private static void testNewAppQuoteFunctionalityIfCanvasable() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'ECRM_ARIA_Participant_PermSetPID');
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
           	opty.Opportunity_Originator__c='Statefarm.com';
            insert opty;
            Opportunity opp = [select id, isQuoteCanvasable__c from opportunity where id=:opty.id];
            String url = HLPR_OppButtonController.newAppQuoteUrl(opp.id,getProductJson());
            System.assertEquals('QuoteIsCanvasable', url, 'isQuoteCanvasable field not correct');
        }
    }
    @isTest
    private static void testEffectiveDateValidationRange() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
       // AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'ECRM_ARIA_Participant_PermSetPID');
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
          OpportunityProduct__c oppProd1 = insertOpportunityProductData('Auto','Private Passenger');
            oppProd1.Product_System_Name__c='PSN';
            Date futureDay=System.today() + 15;
            oppProd1.ErrorFutureDays__c = futureDay.day();
            Date pastDay=System.today() -10;
             oppProd1.ErrorPastDays__c = pastDay.day();
            oppProd1.Product_Postal_State__c='KY';
        	oppProd1.Product_Start_Date__c =System.today()-250;
        	oppProd1.Product_End_Date__c =System.today()+350;
            insert oppProd1;
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'Claimed', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
          // 	opty.Opportunity_Originator__c='Statefarm.com';
            opty.Requested_Effective_Date__c = System.today() -100;
            opty.Product_System_Name__c='PSN';
            opty.State_Code__c='KY / 12-1236';
            insert opty;

            Map<String,String> responseMap =  HLPR_OppButtonController.getResponseMap(opty.Id);


            System.assertEquals(FAILURE, responseMap.get('status'),'Valid information this is coming as wrong');
            System.assertEquals(PRODUCT_INVALID_ERROR_MSG, responseMap.get('errorInfo'),'Please verify the existing information is correct.');
        }
    }
    @isTest
    private static void testOppButtonVisibilityAsAgentForIlp(){
        agentUser = [select id from user where alias = 'Alia' limit 1];
        System.runAs(agentUser) {
            Opportunity opp = [select id from opportunity limit 1];
            String viewPage = HLPR_OppButtonController.oppButtonVisibility(opp.id);
            System.assertEquals(viewPage, 'ilp','View page is not valid');
        }
    }

   	@isTest
    private static void testOppBtnVsblityAsAgentForIlpAndRFCGrant(){
        agentUser = [select id from user where alias = 'Alia' limit 1];
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
             Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Opportunity_Originator__c='Internet Lead Provider';
            insert opty;
            Opportunity updatedOpp = new Opportunity();
            updatedOpp.id = opty.id;
                updatedOpp.Credit_Status__c='RFC Granted';
            update updatedOpp;
            String viewPage = HLPR_OppButtonController.oppButtonVisibility(opty.id);
            System.assertEquals(viewPage, 'rfcGranted','View page is not valid');
        }
    }

    @isTest
    private static void testOppBtnVsblityAsAgentForRFCDisplay(){
        agentUser = [select id from user where alias = 'Alia' limit 1];
         testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
             Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Opportunity_Originator__c='Internet Lead Provider';
            insert opty;
            Opportunity updatedOpp = new Opportunity();
            updatedOpp.id = opty.id;
                updatedOpp.Credit_Status__c='';
            update updatedOpp;
            String viewPage = HLPR_OppButtonController.oppButtonVisibility(opty.id);
            System.assertEquals(viewPage, 'isRFCToBeDisplay','View Page is not valid');
        }
    }
    @isTest
    private static void testUpdateOpportunityIfStageQuot() {
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(testAccount.id, 'New', opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId);
            opty.Product_system_name__c='PSN';
            opty.product__c='Life Annuity';
            opty.lob__c='Life';
            opty.Requested_Effective_Date__c=System.Today()-5;
            opty.State_code__c='IL';
            opty.StageName='Quoting';
            opty.status__c='Quote In Progress';
            insert opty;

            String statusUpdate = HLPR_OppButtonController.updateOpportunity(opty.Id);
            System.assertEquals('StageInQuoting', statusUpdate,'Opportunity Updation is not successful');
        }
    }
}

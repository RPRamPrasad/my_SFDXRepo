/**
* Author : Golden Spikes Team
* Date Created : 09/10/2018
* @description : Test class for the CMP_AttachQuoteController apex class.
*/

@isTest(seeAllData=false)
private class CMP_AttachQuoteController_Test {
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static final String AUTO_QUOTE_RECORD_TYPE_NAME = 'Auto Quote';
    private static final String PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME = 'Primary Auto Quote';
    private static final String SECONDS_FORMAT= 'ssSSS';
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

    private static User agentUser;
    private static User agentUser1;
    private static User proxyUser1;
    private static User proxyUser;
    private static User systemUser;
    private static User techSupportUser;
    //global mock admin user
    private static User adminUser = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFtch1Quote1ForOpty1Admn1'+ '@sfa111.test.com', adminProfileId, '', '', '');
    private static String driverJSON = '{'+
    '   "driverDetails": ['+
    '       {'+
    '           "lastName": "kkkkkk",'+
    '           "dlState": "gg",'+
    '           "gender": "M",'+
    '           "firstName": "rrrrrrr",'+
    '           "suffix": "mmm"'+
    '       },'+
    '       {'+
    '           "lastName": "kkkkkk",'+
    '           "dlState": "gg",'+
    '           "gender": "F",'+
    '           "firstName": "rrrrrrr",'+
    '           "suffix": "mmm"'+
    '       }'+
    '   ]'+
    '  }';

    private static String vehicleJSON = '{'+
    '   "vehicleDetails": ['+
    '       {'+
    '           "model": "ttttt",'+
    '           "coverageDetails": {'+
    '               "coverage": ['+
    '                   {'+
    '                       "premium": "0.00",'+
    '                       "coveragelimit": "$50,000/$100,000/$50,000",'+
    '                       "code": "kkkkkkk"'+
    '                   },'+
    '                   {'+
    '                       "premium": "50.00",'+
    '                       "coveragelimit": "$50,000/$100,000/$50,000",'+
    '                       "code": "ZZZZZ"'+
    '                   }'+
    '               ]'+
    '           },'+
    '           "discountDetails": {'+
    '               "discount": ['+
    '                   {"code": "kkkk"},'+
    '                   {"code": "gggggg"}'+
    '               ]'+
    '           },'+
    '           "expDate": "07/17/2017",'+
    '           "year": "2014",'+
    '           "effectiveDate": "07/17/2017",'+
    '           "premiumNumberMonths": "6",'+
    '           "make": "ssssss",'+
    '           "totalPremium": "1804.58",'+
    '           "currentInsurance": "kkkkkkk"'+
    '       }'+
    '   ]'+
    ' }';
    
    @TestSetup
    static void makeData(){
      System.runAs(adminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            byPassTrigger();
            String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
            String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
            String techSupport107ProfileId = getProfileId('1.07 Technical Support');
            String noAccessProfileId = getProfileId('1.02 No Access');
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            agentUser = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFth1Quote1ForOpty1Agnt1'+ '@sfa111.test.com', agentProfileId , 'ttccww11zzc', 'ttccww11zzc', 'ttccww11zzc');
            agentUser.userRoleId = agentUserRole.id;
            agentUser.subUserType__c = 'Agent';
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            agentUser1 = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFth5Quote1ForOpty5Agnt5'+ '@sfa555.test.com', agentProfileId , 'ttccww55zzc', 'ttccww55zzc', 'ttccww55zzc');
            agentUser1.userRoleId = agentUserRole.id;
            agentUser1.subUserType__c = 'Agent';
            insert agentUser1;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser1);
            proxyUser = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFth1Quote1ForOpty1Prox1'+ '@sfa111.test.com', proxyProfileId, '', 'ttccww11zzc', 'ttccww11zzcP');
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            proxyUser1 = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFth5Quoe5ForOpty5Prox5'+ '@sfa555.test.com', proxyProfileId, '', '', 'ttccww55zzcP');           
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;
			
            systemUser = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFth1Quote1ForOpty1Syst1'+ '@sfa111.test.com', noAccessProfileId, '', '', 'ttccww55zzcY');
            insert systemUser;

            techSupportUser = buildUser(UserInfo.getOrganizationId() + System.now().format(SECONDS_FORMAT) + 'trigFth4Qute4ForOpty4Buss4'+ '@sfa444.test.com', techSupport107ProfileId, '', '', 'ttccww55zzcZ');
            insert techSupportUser;
          	TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(techSupportUser);
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
    }

    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
    }

    //method to build user with the given parameter value
    private static User buildUser(String param_UserName, String param_profileId, String param_associateId, String param_servicingAgentAssociateId, String param_externalId) {
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
    }

    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        return new UserRole(name = roleName, parentRoleId = parentrole);
    }

    //method to build userrole with the given parameter value
    private static UserRole buildRole(String roleName) {
        return new UserRole(name = roleName);
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        return new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
    }

    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String param_clientIdentifier) {
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt',
            RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier);
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
    }

    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String param_accountId, String param_LOB, String param_ownerId) {
        return new Opportunity (Name = 'Tst Opty', AccountId = param_accountId, Monthly_Premium__c = 600.00, 
                            CloseDate = Date.today() + 1, LOB__c = param_LOB, Product__c = 'Commercial', ownerId = param_ownerId,
                            StageName = 'New', RecordTypeId = optyRecordTypeId, Amount = 1200.00, X_Date__c = Date.newInstance(2015, 03, 16)                            
                          );
    }

     //method to create Quotes Summary External object data
     private static Quotes__x buildExternalObjQuoteRecord(String param_clientId, String param_associateId, String param_firstName, String param_lastName, String param_orgName,
         String param_addressLine1, String param_addressLine2, String param_applicantCity, String param_applicantPostalCode, String param_applicantStateCode, String param_applicantSuffix,
         String param_currentInsurer, Date param_quoteEffectiveDate, Decimal param_quoteMonthlyPremiumAmount, String param_quotePayLoadIdentifier, 
         Decimal param_totalPremiumAmount, Date param_vehicleExpirationDate
     ) {
        return new Quotes__x (
            LineOfBusiness__c = 'Auto',
            ClientId__c = param_clientId,
            AssociateId__c = param_associateId,
            ApplicantFirstName__c = param_firstName,
            ApplicantLastName__c = param_lastName,
            ApplicantOrganizationName__c = param_orgName,
            ApplicantAddressLine1__c = param_addressLine1,
            ApplicantAddressLine2__c = param_addressLine2,
            ApplicantCity__c = param_applicantCity,
            ApplicantPostalCode__c = param_applicantPostalCode,
            ApplicantStateCode__c = param_applicantStateCode,
            ApplicantSuffix__c = param_applicantSuffix,
            CurrentInsurer__c = param_currentInsurer,
            QuoteEffectiveDate__c = param_quoteEffectiveDate,
            QuoteMonthlyPremiumAmount__c = param_quoteMonthlyPremiumAmount,
            QuotePayloadIdentifier__c = param_quotePayLoadIdentifier,
            QuoteTotalPremiumAmount__c = param_totalPremiumAmount,
            VehicleExpirationDate__c = param_vehicleExpirationDate
        );
     }

    //method to create Quotes Detail External object data
    private static QuoteDetails__x buildExternalObjQuoteDetailRecord(String param_quotePayLoadIdentifier, String param_driverInfo, String param_vehicleInfo) {
        return new QuoteDetails__x (
            QuotePayloadIdentifier__c = param_quotePayLoadIdentifier,
            DriverInfo__c = param_driverInfo,
            VehicleInfo__c = param_vehicleInfo
        );
    }

    //method to fetch all users
    private static void fetchAllUsers(){
        List<User> usrList = [SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, SubUserType__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c FROM User where UserExternalID__c in('ttccww11zzc','ttccww11zzcP','ttccww55zzc','ttccww55zzcP','ttccww55zzcZ','ttccww55zzcY')];
        for (User usrobj : usrList){
            if (usrobj.UserExternalID__c == 'ttccww11zzc') {
                agentUser = usrobj;
            }
            else if (usrobj.UserExternalID__c == 'ttccww55zzc') {
                agentUser1 = usrobj;
            }
            else if (usrobj.UserExternalID__c == 'ttccww11zzcP') {
                proxyUser = usrobj;
            }
            else if (usrobj.UserExternalID__c == 'ttccww55zzcP') {
                proxyUser1 = usrobj;
            }
            else if (usrobj.UserExternalID__c == 'ttccww55zzcZ') {
                techSupportUser = usrobj;
            }
            else {
                systemUser = usrobj;
            }
        }
     }
    //test method to fetch quote records as an Agent for Manual Opportunity record
    @isTest
    private static void testAttachQuoteSelectionAsAgent() {
        
        fetchAllUsers();
        System.runAs(agentUser) {

            Account act = buildAccountRecord('9802011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            insert opty;
            
            Opportunity optyInfo = [select id, name, account.name from Opportunity where id = :opty.id];

            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();

            for(Integer i=1; i <= 5; i++) {
                quoteSummaryExtList.add(
                    buildExternalObjQuoteRecord('9802011', 'rrccww11zzc', 'rrrrrr'+i, 'wwwwww'+i, 'zzzzz',
                     '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '12345678'+i,200.00, Date.newInstance(2015, 03, 15)
                    )
                );
            }

            Test.startTest();

            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            System.assertEquals(null, queryQtResponse, 'quoteResponse should be null');
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);
            System.assertEquals(optyInfo.name, queryQtResponse.opportunityName, 'quoteResponse Opportunity name should be '+optyInfo.name);
            System.assertEquals(optyInfo.Account.Name, queryQtResponse.accountName, 'quoteResponse accountName should be '+optyInfo.Account.Name);
            System.assert(!queryQtResponse.quoteRecordsToDisplay.isEmpty(), 'quoteResponse quoteRecordsToDisplay should not be empty');
            System.assert(queryQtResponse.isSuccessOnFetchQuote, 'quoteResponse isSuccessOnFetchQuote should be true');
            System.assert(String.isBlank(queryQtResponse.pageMessage), 'quoteResponse pageMessage should abe blank');

            Test.stopTest();
        }
    }

    //test method to fetch quote records as an Agent for Manual Opportunity record, with no Quote Summary records
    @isTest
    private static void testAttachQuoteSelectionAsAgentForNoQuoteSummary() {
        
        fetchAllUsers();
        System.runAs(agentUser) {

            Account act = buildAccountRecord('9802022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            insert opty;

            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();

            Test.startTest();

            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            System.assertEquals(null, queryQtResponse, 'quoteResponse should be null');
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);

            System.assert(queryQtResponse.quoteRecordsToDisplay.isEmpty(), 'quoteResponse quoteRecordsToDisplay should be empty');
            System.assert(!queryQtResponse.isSuccessOnFetchQuote, 'quoteResponse isSuccessOnFetchQuote should be false');
            System.assertEquals(Label.CL_QUOTE_FETCH_NOT_AVAILABLE, queryQtResponse.pageMessage, 'quoteResponse pageMessage should be '+Label.CL_QUOTE_FETCH_NOT_AVAILABLE);

            Test.stopTest();
        }
    }

    //test method to fetch quote records as an Agent for Manual Opportunity record, for other Line Of Business - 'Fire'
    @isTest
    private static void testAttachQuoteSelectionAsAgentForOtherLOB() {

        fetchAllUsers();
        System.runAs(agentUser) {

            Account act = buildAccountRecord('9802033');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Fire', proxyUser.id);
            insert opty;

            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();

            for(Integer i=1; i <= 5; i++) {
                quoteSummaryExtList.add(
                    buildExternalObjQuoteRecord('9802011', 'rrccww11zzc', 'rrrrrr'+i, 'wwwwww'+i, 'zzzzz',
                     '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '12345678'+i,200.00, Date.newInstance(2015, 03, 15)
                    )
                );
            }

            Test.startTest();

            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            System.assertEquals(null, queryQtResponse, 'quoteResponse should be null');
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);

            System.assert(queryQtResponse.quoteRecordsToDisplay.isEmpty(), 'quoteResponse quoteRecordsToDisplay should be empty');
            System.assert(!queryQtResponse.isSuccessOnFetchQuote, 'quoteResponse isSuccessOnFetchQuote should be false');
            System.assertEquals(Label.CL_QUOTE_ATTACH_NOT_AVAILABLE, queryQtResponse.pageMessage, 'quoteResponse pageMessage should be '+Label.CL_QUOTE_ATTACH_NOT_AVAILABLE);

            Test.stopTest();
        }
    }

    //test method to fetch quote records as an Agent for Manual Opportunity record, for missing parameters on the request
    @isTest
    private static void testAttachQuoteSelectionAsAgentForMissingParam() {
        fetchAllUsers();
        Opportunity opty;
        System.runAs(agentUser1) {

            Account act = buildAccountRecord('9802055');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            opty = buildOpportunityRecord(act.id, 'Fire', proxyUser1.id);
            insert opty;

            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();

            for(Integer i=1; i <= 5; i++) {
                quoteSummaryExtList.add(
                    buildExternalObjQuoteRecord('9802011', 'rrccww11zzc', 'rrrrrr'+i, 'wwwwww'+i, 'zzzzz',
                     '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '12345678'+i,200.00, Date.newInstance(2015, 03, 15)
                    )
                );
            }

            Test.startTest();

            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            System.assertEquals(null, queryQtResponse, 'quoteResponse should be null');
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);

            System.assert(queryQtResponse.quoteRecordsToDisplay.isEmpty(), 'quoteResponse quoteRecordsToDisplay should be empty');
            System.assert(!queryQtResponse.isSuccessOnFetchQuote, 'quoteResponse isSuccessOnFetchQuote should be false');
            System.assertEquals(Label.CL_QUOTE_MISSING_PARAM, queryQtResponse.pageMessage, 'quoteResponse pageMessage should be '+Label.CL_QUOTE_MISSING_PARAM);

            Test.stopTest();
        }
    }

    //test method to save quote records as an Agent for Manual Opportunity record
    @isTest
    private static void testSaveQuoteAsAgentForDefaultOpportunity() {
        fetchAllUsers();
        System.runAs(agentUser) {

            Account act = buildAccountRecord('9872011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            insert opty;
            
            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();
            Map<String, String> quotePayLoadIdentifierMap = new Map<String, String>();
            Map<String, Quote__c> quoteInfoIndexMap = new Map<String, Quote__c>();

            for(Integer i=1; i <= 3; i++) {
                quoteSummaryExtList.add(
                    buildExternalObjQuoteRecord('9872011', 'rrccww77zzc', 'rrrrrr1', 'wwwwww1', 'zzzzz',
                     '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '100'+i,200.00, Date.newInstance(2015, 03, 15)
                    )
                );
            }
            Integer p=0;
            for(Quotes__x quoteExternalList: quoteSummaryExtList){
                quotePayLoadIdentifierMap.put(String.valueOf(p), quoteExternalList.QuotePayloadIdentifier__c);
                p++;
            }

            List<QuoteDetails__x> quoteDetailExtList = new List<QuoteDetails__x>();
            for(Integer i=1; i<= 3; i++){
                quoteDetailExtList.add(buildExternalObjQuoteDetailRecord('100'+i, driverjson, vehiclejson));
            }

            Test.startTest();
            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            CMP_AttachQuoteController.MOCKED_QUOTE_DETAIL_LIST.addAll(quoteDetailExtList);            
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);
            Integer q=0;
            for(Quote__c qt: queryQtResponse.quoteRecordsToDisplay) {
                quoteInfoIndexMap.put(String.valueOf(q), qt);
                q++;
            }

            CMP_AttachQuoteController.QuoteSaveResponse quoteSaveResponse;
            String selectedQuoteRecords = Json.serialize(quoteInfoIndexMap);
            String quotePayLoads = Json.serialize(quotePayLoadIdentifierMap);
            quoteSaveResponse = CMP_AttachQuoteController.processSaveQuote(selectedQuoteRecords, quotePayLoads, opty.id);
            System.assert(quoteSaveResponse.isSuccessOnSaveQuote, 'quoteSaveResponse isSuccessOnSaveQuote should be true');
            System.assert(String.isBlank(quoteSaveResponse.pageMessage), 'quoteSaveResponse pageMessage should be blank');
            Opportunity opp = [Select id,stagename,status__c from opportunity where id=:opty.id];
            System.assertEquals('Quoting',opp.StageName,'Stage Name not updated in Opportunity');
            System.assertEquals('Quote Provided',opp.status__c,'Status value not updated in Opportunity');
            Test.stopTest();

            for(Quote__c savedQuote : [select id, FirstName__c, LastName__c, OrganizationName__c, MonthlyPremium__c, Suffix__c, Street1__c, Street2__c, City__c,
                                                PostalCode__c, State__c, CurrentInsurerName__c, EffectiveDate__c, XDate__c, DriverInfo__c, VehicleInfo__c,
                                                TotalPremiumAllVehicles__c, PrimaryQuote__c, Opportunity__c  from Quote__c where Opportunity__c =:opty.id]) {
                  System.assertEquals('rrrrrr1 wwwwww1', savedQuote.FirstName__c + ' ' + savedQuote.LastName__c, 'savedQuote name should be rrrrrr1 wwwwww1');
                  System.assertEquals('zzzzz', savedQuote.OrganizationName__c, 'savedQuote organization name should be zzzzz');
                  System.assertEquals(100.00, savedQuote.MonthlyPremium__c, 'savedQuote monthly premium should be 100.00');
                  System.assertEquals('RR', savedQuote.Suffix__c, 'savedQuote suffix should be RR');
                  System.assertEquals('1234 rrrrrrr', savedQuote.Street1__c, 'savedQuote street 1 should be 1234 rrrrrrr');
                  System.assertEquals('5678 wwww', savedQuote.Street2__c, 'savedQuote street 2 should be 5678 wwww');
                  System.assertEquals('cccccc', savedQuote.City__c, 'savedQuote city should be cccccc');
                  System.assertEquals('123456', savedQuote.PostalCode__c, 'savedQuote postal code should be 123456');
                  System.assertEquals('XZ', savedQuote.State__c, 'savedQuote state should be XZ');
                  System.assertEquals(Date.newInstance(2015, 03, 20), savedQuote.EffectiveDate__c, 'savedQuote effective date should be 03/20/2015');
                  System.assertEquals(driverJSON, savedQuote.DriverInfo__c, 'savedQuote driver info should be '+driverJSON);
                  System.assertEquals(vehicleJSON, savedQuote.VehicleInfo__c, 'savedQuote vehicle info should be '+vehicleJSON);
                  System.assertEquals(200.00, savedQuote.TotalPremiumAllVehicles__c, 'savedQuote total premium should be 200.00');
                  System.assertEquals(false, savedQuote.PrimaryQuote__c, 'savedQuote primary quote should be false');
                //   System.assertEquals(opty.id, savedQuote.Opportunity__c, 'savedQuote Opportunity Id should be '+opty.id);
            }
        }
    }

    //test method to save single quote record and to make it primary as an Agent, for Manual Opportunity record
    @isTest
    private static void testSaveSingleQuoteAsAgent() {
        fetchAllUsers();
        System.runAs(agentUser) {
            Account act = buildAccountRecord('9882011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            insert opty;
            
            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();
            Map<String, String> quotePayLoadIdentifierMap = new Map<String, String>();
            Map<String, Quote__c> quoteInfoIndexMap = new Map<String, Quote__c>();

            quoteSummaryExtList.add(
                buildExternalObjQuoteRecord('9872011', 'rrccww77zzc', 'rrrrrr1', 'wwwwww1', 'zzzzz',
                 '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '1001',200.00, Date.newInstance(2015, 03, 15)
                )
            );
            quotePayLoadIdentifierMap.put('0', quoteSummaryExtList[0].QuotePayloadIdentifier__c);

            List<QuoteDetails__x> quoteDetailExtList = new List<QuoteDetails__x>();
            quoteDetailExtList.add(buildExternalObjQuoteDetailRecord('1001', driverjson, vehiclejson));

            Test.startTest();
            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            CMP_AttachQuoteController.MOCKED_QUOTE_DETAIL_LIST.addAll(quoteDetailExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);
            quoteInfoIndexMap.put('0', queryQtResponse.quoteRecordsToDisplay[0]);

            CMP_AttachQuoteController.QuoteSaveResponse quoteSaveResponse;
            String selectedQuoteRecords = Json.serialize(quoteInfoIndexMap);
            String quotePayLoads = Json.serialize(quotePayLoadIdentifierMap);
            quoteSaveResponse = CMP_AttachQuoteController.processSaveQuote(selectedQuoteRecords, quotePayLoads, opty.id);
            System.assert(quoteSaveResponse.isSuccessOnSaveQuote, 'quoteSaveResponse isSuccessOnSaveQuote should be true');
            System.assert(String.isBlank(quoteSaveResponse.pageMessage), 'quoteSaveResponse pageMessage should be blank');
            Test.stopTest();

            Quote__c savedQuote = [select id, FirstName__c, LastName__c, OrganizationName__c, MonthlyPremium__c, Suffix__c, Street1__c, Street2__c, City__c,
                                                PostalCode__c, State__c, CurrentInsurerName__c, EffectiveDate__c, XDate__c, DriverInfo__c, VehicleInfo__c,
                                                TotalPremiumAllVehicles__c, PrimaryQuote__c, Opportunity__c  from Quote__c where Opportunity__c =:opty.id limit 1];
            System.assertEquals('rrrrrr1', savedQuote.FirstName__c, 'savedQuote first name should be rrrrrr1');
            System.assertEquals('wwwwww1', savedQuote.LastName__c, 'savedQuote last name should be wwwwww1');
            System.assertEquals('zzzzz', savedQuote.OrganizationName__c, 'savedQuote organization name should be zzzzz');
            System.assertEquals(100.00, savedQuote.MonthlyPremium__c, 'savedQuote monthly premium should be 100.00');
            System.assertEquals('RR', savedQuote.Suffix__c, 'savedQuote suffix should be RR');
            System.assertEquals('1234 rrrrrrr', savedQuote.Street1__c, 'savedQuote street 1 should be 1234 rrrrrrr');
            System.assertEquals('5678 wwww', savedQuote.Street2__c, 'savedQuote street 2 should be 5678 wwww');
            System.assertEquals('cccccc', savedQuote.City__c, 'savedQuote city should be cccccc');
            System.assertEquals('123456', savedQuote.PostalCode__c, 'savedQuote postalCode should be 123456');
            System.assertEquals('XZ', savedQuote.State__c, 'savedQuote state should be XZ');
            System.assertEquals(Date.newInstance(2015, 03, 20), savedQuote.EffectiveDate__c, 'savedQuote effective date should be 03/20/2015');
            System.assertEquals(driverJSON, savedQuote.DriverInfo__c, 'savedQuote driver info should be '+driverJSON);
            System.assertEquals(vehicleJSON, savedQuote.VehicleInfo__c, 'savedQuote vehicle info should be '+vehicleJSON);
            System.assertEquals(200.00, savedQuote.TotalPremiumAllVehicles__c, 'savedQuote total premium all vehicles should be 200.00');
            System.assertEquals(true, savedQuote.PrimaryQuote__c, 'savedQuote primaryQuote should be true');
            System.assertEquals(opty.id, savedQuote.Opportunity__c, 'savedQuote opportunity Id should be '+opty.id);

            Opportunity selectedOptyAfter = [Select id, Monthly_Premium__c, Amount,Number_of_Vehicles__c, X_Date__c, CurrentInsurerName__c from opportunity where id =:opty.id];
            System.assertEquals(100.00, selectedOptyAfter.Monthly_Premium__c, 'selectedOptyAfter monthly premium should be 100.00');
            System.assertEquals(200.00, selectedOptyAfter.Amount, 'selectedOptyAfter amount should be 200.00');
            System.assertEquals(1, selectedOptyAfter.Number_of_Vehicles__c, 'selectedOptyAfter Number of vehicles should be 1');
        }
    }

    //test method to save quote record exception as an Agent for Manual Opportunity record
    @isTest
    private static void testSaveQuoteSummaryExceptionAsAgent() {
        fetchAllUsers();
        System.runAs(agentUser) {
            Account act = buildAccountRecord('9889011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            insert opty;
            
            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();
            Map<String, String> quotePayLoadIdentifierMap = new Map<String, String>();
            Map<String, Quote__c> quoteInfoIndexMap = new Map<String, Quote__c>();

            quoteSummaryExtList.add(
                buildExternalObjQuoteRecord('9872011', 'rrccww77zzc', 'rrrrrr1', 'wwwwww1', 'zzzzz',
                 '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '1001',200.00, Date.newInstance(2015, 03, 15)
                )
            );
            quotePayLoadIdentifierMap.put('0', quoteSummaryExtList[0].QuotePayloadIdentifier__c);
            List<QuoteDetails__x> quoteDetailExtList = new List<QuoteDetails__x>();
            quoteDetailExtList.add(buildExternalObjQuoteDetailRecord('1001', driverjson, vehiclejson));

            Test.startTest();
            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            CMP_AttachQuoteController.MOCKED_QUOTE_DETAIL_LIST.addAll(quoteDetailExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);
            quoteInfoIndexMap.put('0', queryQtResponse.quoteRecordsToDisplay[0]);

            CMP_AttachQuoteController.QuoteSaveResponse quoteSaveResponse;
            String selectedQuoteRecords = Json.serialize(quoteInfoIndexMap);
            String quotePayLoads = Json.serialize(quotePayLoadIdentifierMap);
            delete opty;
            quoteSaveResponse = CMP_AttachQuoteController.processSaveQuote(selectedQuoteRecords, quotePayLoads, opty.id);
            System.assert(!quoteSaveResponse.isSuccessOnSaveQuote, 'quoteSaveResponse isSuccessOnSaveQuote should not be true');
            System.assertEquals(Label.CL_QUOTE_SAVE_EXCEPTION_MSG, quoteSaveResponse.pageMessage, 'quoteSaveResponse pageMessage should be '+Label.CL_QUOTE_SAVE_EXCEPTION_MSG);
            Test.stopTest();
        }
    }

    //test method to save quote record exception as an Agent for Manual Opportunity record
    @isTest
    private static void testSaveQuoteExceptionAsAgent() {
        fetchAllUsers();
        Map<String, String> quotePayLoadIdentifierMap;
        Map<String, Quote__c> quoteInfoIndexMap;
        System.runAs(agentUser) {
            Account act = buildAccountRecord('9889011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            insert opty;
            
            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();
            
            

            quoteSummaryExtList.add(
                buildExternalObjQuoteRecord('9872011', 'rrccww77zzc', 'rrrrrr1', 'wwwwww1', 'zzzzz',
                 '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '1001',200.00, Date.newInstance(2015, 03, 15)
                )
            );
            
            List<QuoteDetails__x> quoteDetailExtList = new List<QuoteDetails__x>();
            quoteDetailExtList.add(buildExternalObjQuoteDetailRecord('1001', driverjson, vehiclejson));

            Test.startTest();
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            CMP_AttachQuoteController.MOCKED_QUOTE_DETAIL_LIST.addAll(quoteDetailExtList);

            CMP_AttachQuoteController.QuoteSaveResponse quoteSaveResponse;
            String selectedQuoteRecords = Json.serialize(quoteInfoIndexMap);
            String quotePayLoads = Json.serialize(quotePayLoadIdentifierMap);
            quoteSaveResponse = CMP_AttachQuoteController.processSaveQuote(selectedQuoteRecords, quotePayLoads, opty.id);
            System.assert(!quoteSaveResponse.isSuccessOnSaveQuote, 'quoteSaveResponse isSuccessOnSaveQuote should not be true');
            System.assertEquals(Label.CL_QUOTE_SAVE_EXCEPTION_MSG, quoteSaveResponse.pageMessage, 'quoteSaveResponse pageMessage should be '+Label.CL_QUOTE_SAVE_EXCEPTION_MSG);
            Test.stopTest();
        }
    }
    
    //test method to save quote record exception as an Agent for Manual Opportunity record
    //when opportunity is assigned to another user
    @isTest
    private static void testOppNewAndAssignedToAnotherUser() {
        fetchAllUsers();
        insert adminUser;
        System.runAs(agentUser) {
            Account act = buildAccountRecord('9802011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', proxyUser.id);
            opty.Assigned_To__c = adminUser.id;
            insert opty;
            
            List<Quotes__x> quoteSummaryExtList = new List<Quotes__x>();

            for(Integer i=1; i <= 5; i++) {
                quoteSummaryExtList.add(
                    buildExternalObjQuoteRecord('9802011', 'rrccww11zzc', 'rrrrrr'+i, 'wwwwww'+i, 'zzzzz',
                     '1234 rrrrrrr', '5678 wwww', 'cccccc', '123456', 'XZ', 'RR','PPPPPP', Date.newInstance(2015, 03, 20), 100.00, '12345678'+i,200.00, Date.newInstance(2015, 03, 15)
                    )
                );
            }

            Test.startTest();

            CMP_AttachQuoteController.QuoteQueryResponse queryQtResponse;
            System.assertEquals(null, queryQtResponse, 'quote Response should be null');
            CMP_AttachQuoteController.MOCKED_QUOTE_SUMMARY_LIST.addAll(quoteSummaryExtList);
            queryQtResponse = CMP_AttachQuoteController.processQuoteSummary(opty.id);
            System.assert(!queryQtResponse.isSuccessOnFetchQuote, 'quote Response isSuccessOnFetchQuote should not be true');
            System.assertEquals(Label.CL_OPP_ASSIGNED_TO_ERROR, queryQtResponse.pageMessage, 'quote Response pageMessage should be '+Label.CL_OPP_ASSIGNED_TO_ERROR);

            Test.stopTest();
        }
    }
    
}
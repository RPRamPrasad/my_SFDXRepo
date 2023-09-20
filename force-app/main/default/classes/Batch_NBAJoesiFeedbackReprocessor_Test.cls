/**
  * @name Batch_NBAJoesiFeedbackReprocessor_Test
  * @author Team Skynet
  * @createdDate 06/03/2022
  * @description Apex unit testing for Batch_NBAJoesiFeedbackReprocessor Batch class
  */
  @isTest(seeAllData = false)
  public class Batch_NBAJoesiFeedbackReprocessor_Test {

      @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
      @TestVisible private static final String ACTION_ID = 'MUPLGU0025';

      /**
      * @name AzureMockHttpResponseGenerator
      * @author Team Skynet
      * @description Fake response for Azure AD call.
      */
      public class AzureMockHttpResponseGenerator implements HttpCalloutMock {
          /**
          * @name: respond
          * @description HttpResponse
          * @param request
          * @return HTTPResponse
          */
          public HTTPResponse respond(HTTPRequest request) {
              // Create a fake response
              HttpResponse response = new HttpResponse();
              response.setHeader('Content-Type', 'application/json');
              response.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAi"}');
              response.setStatusCode(200);
              return response;
          }
      }

      /**
      * @name JoesiMockHttpResponseGenerator
      * @author Team Skynet
      * @description Fake response for JOESI Feedback call.
      */
      public class JoesiMockHttpResponseGenerator implements HttpCalloutMock {
          /**
          * @name: respond
          * @description HttpResponse
          * @param request
          * @return HTTPResponse
          */
          public HTTPResponse respond(HTTPRequest request) {
              // Create a fake response
              HttpResponse response = new HttpResponse();
              response.setHeader('Content-Type', 'application/json');
              response.setBody('{"Status":"OK","Message":"Response captured sucessfully"}');
              response.setStatusCode(200);
              return response;
          }
      }

      /**
      * @name JoesiMockHttpResponseGeneratorFail
      * @author Team Skynet
      * @description Fake error response for JOESI Feedback call.
      */
      public class JoesiMockHttpResponseGeneratorFail implements HttpCalloutMock {
          /**
          * @name: respond
          * @description HttpResponse
          * @param request
          * @return HTTPResponse
          */
          public HTTPResponse respond(HTTPRequest request) {
              // Create a fake response
              HttpResponse response = new HttpResponse();
              response.setHeader('Content-Type', 'application/json');
              response.setBody('{"Internal Server Error"}');
              response.setStatusCode(502);
              return response;
          }
      }

      @testSetup
      private static void testSetup(){
          TestUserSetupUtility.setupAgentOffice();
          TestUserSetupUtility.setupSystemAdminUser();
          TestUserSetupUtility.setupApiOnlyUser();
          System.runAs(TestUserSetupUtility.getSysAdminUser()){
              Account accountRecord = createAccount();
              setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
              createRecommendation();
              User nbaProcessId = TestUserSetupUtility.getApiOnlyUser();
              PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_NextBestAction_PermSetPID'];
              insert new PermissionSetAssignment(AssigneeId = nbaProcessId.id, PermissionSetId = ps.Id);
          }
      }

      @TestVisible private static Account createAccount(){
          Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                              BillingAddressType__c='US',BillingCity='Phoenix',
                                              ClientIdentifier__c=ACCOUNT_CLIENT_ID);
          UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
          insert accountRecord;
          return accountRecord;
      }

      @TestVisible private static Account getAccount(){
          return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
      }

      @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
          AgentRole__c agentRole = new AgentRole__c();
          agentRole.Agent__c = userRecord.Id;
          agentRole.Customer__c = accountRecord.Id;
          agentRole.RelationshipNature__c = 'Customer';
          insert agentRole;
      }

      @TestVisible private static void createRecommendation(){
          Recommendation rec = new Recommendation(ActionReference='Enterprise_CRM',
                                                  Action_ID__c = ACTION_ID,
                                                  Name = 'Test Action', Description = 'Test Description',
                                                  AcceptanceLabel = 'Accept', RejectionLabel = 'Reject');
          insert rec;
      }

      @isTest
      public static void reprocessRecommendationsSuccessfulTest() {
          Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
          // Set mock callout class
          Test.setMock(HttpCalloutMock.class, new JoesiMockHttpResponseGenerator());
          System.runAs(TestUserSetupUtility.getSysAdminUser()){
              CS_NBA_Config__c batchFeedbackAPIMaxRetryCounter = new CS_NBA_Config__c();
              batchFeedbackAPIMaxRetryCounter.Name = 'BatchFeedbackAPIMaxRetryCounter';
              batchFeedbackAPIMaxRetryCounter.Value__c = 1;
              insert batchFeedbackAPIMaxRetryCounter;
          }

          User proxyUser = TestUserSetupUtility.getProxyUser();
          User sysAdmin = TestUserSetupUtility.getSysAdminUser();
          User nbaProcessId = TestUserSetupUtility.getApiOnlyUser();
          Account accountRecord = getAccount();

          SFCustomRecommendation__c recommendation =
                          new NBA_RecommendationBuilder()
                          .setAccountId(accountRecord.Id)
                          .setAgentOfficeUserId(proxyUser.Id)
                          .setServicingAgentAssociateId('ASSOCIATEID')
                          .setContextType('COA')
                          .setEnterpriseInteractionId('eiid123')
                          .setPropensity('0.80')
                          .setExternalInteractionID('-3721810088443331923')
                          .setPriority('0.9955418985179654')
                          .setChannel('Agent')
                          .setRank('1')
                          .setDirection('Inbound')
                          .setTreatment('Agent ECRM Rec')
                          .setPlacement('ECRM NBA Module')
                          .setExternalClientId('123456')
                          .setDecisionTime('20210318T173517.577 GMT')
                          .setActionID(ACTION_ID)
                          .setActionGroup('Auto')
                          .setActionIssue('Multi Lining')
                          .setActionCategory('TBD')
                          .setActionLabel('Guidance on PLUP')
                          .setActionName('GuidanceOnPLUP')
                          .setActionVariant('TBD Variant')
                          .setActionIdText('/ML/PLUP/GOnPLUP')
                          .build();

          List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
          recommendation.FeedbackAPICalloutSuccess__c = 'Failed';
          recommendation.Status__c = 'Accepted';
          recommendations.add(recommendation);

          System.runAs(sysAdmin){
              NBA_RecommendationService.saveRecommendations(recommendations);
          }
          List<SFCustomRecommendation__c> recs = [SELECT Id, EIID__c, Account__r.ClientIdentifier__c, External_Interaction_ID__c, Rank__c, Direction__c, Channel__c, Status__c,
                                                  Treatment__c, Action_ID__c, Recommendation__r.Group__c, Recommendation__r.Issue__c, Recommendation__r.Name,
                                                  FeedbackAPICalloutSuccess__c, FeedbackAPIRetryCounter__c
                                                  FROM SFCustomRecommendation__c];

          System.assertEquals(true, !recs.isEmpty(), 'Recommendation list is empty, save failed');

          Batch_NBAJoesiFeedbackReprocessor schedule = new Batch_NBAJoesiFeedbackReprocessor();

          System.runAs(nbaProcessId){
            Test.startTest();
            schedule.execute(null, recs);
            Test.stopTest();
          }

          List<SFCustomRecommendation__c> recsAfter = [Select Id, Status__c, FeedbackAPICalloutSuccess__c, FeedbackAPIRetryCounter__c, Name from SFCustomRecommendation__c];
          System.assertEquals('Successful', recsAfter[0].FeedbackAPICalloutSuccess__c, 'FeedbackAPICalloutSuccess not as expected');
          System.assertEquals(1.0, recsAfter[0].FeedbackAPIRetryCounter__c, 'FeedbackAPIRetry counter not as expected');
      }

      @isTest
      public static void reprocessRecommendationsFailedTest() {
          Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
          // Set mock callout class
          Test.setMock(HttpCalloutMock.class, new JoesiMockHttpResponseGeneratorFail());
          System.runAs(TestUserSetupUtility.getSysAdminUser()){
              CS_NBA_Config__c batchFeedbackAPIMaxRetryCounter = new CS_NBA_Config__c();
              batchFeedbackAPIMaxRetryCounter.Name = 'BatchFeedbackAPIMaxRetryCounter';
              batchFeedbackAPIMaxRetryCounter.Value__c = 1;
              insert batchFeedbackAPIMaxRetryCounter;
          }

          User proxyUser = TestUserSetupUtility.getProxyUser();
          User sysAdmin = TestUserSetupUtility.getSysAdminUser();
          User nbaProcessId = TestUserSetupUtility.getApiOnlyUser();
          Account accountRecord = getAccount();

          SFCustomRecommendation__c recommendation =
                          new NBA_RecommendationBuilder()
                          .setAccountId(accountRecord.Id)
                          .setAgentOfficeUserId(proxyUser.Id)
                          .setServicingAgentAssociateId('ASSOCIATEID')
                          .setContextType('COA')
                          .setEnterpriseInteractionId('eiid123')
                          .setPropensity('0.80')
                          .setExternalInteractionID('-3721810088443331923')
                          .setPriority('0.9955418985179654')
                          .setChannel('Agent')
                          .setRank('1')
                          .setDirection('Inbound')
                          .setTreatment('Agent ECRM Rec')
                          .setPlacement('ECRM NBA Module')
                          .setExternalClientId('123456')
                          .setDecisionTime('20210318T173517.577 GMT')
                          .setActionID(ACTION_ID)
                          .setActionGroup('Auto')
                          .setActionIssue('Multi Lining')
                          .setActionCategory('TBD')
                          .setActionLabel('Guidance on PLUP')
                          .setActionName('GuidanceOnPLUP')
                          .setActionVariant('TBD Variant')
                          .setActionIdText('/ML/PLUP/GOnPLUP')
                          .build();

          List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
          recommendation.FeedbackAPICalloutSuccess__c = 'Failed';
          recommendation.Status__c = 'Accepted';
          recommendations.add(recommendation);

          System.runAs(sysAdmin){
              NBA_RecommendationService.saveRecommendations(recommendations);
          }
          List<SFCustomRecommendation__c> recs = [SELECT Id, EIID__c, Account__r.ClientIdentifier__c, External_Interaction_ID__c, Rank__c, Direction__c, Channel__c, Status__c,
                                                  Treatment__c, Action_ID__c, Recommendation__r.Group__c, Recommendation__r.Issue__c, Recommendation__r.Name,
                                                  FeedbackAPICalloutSuccess__c, FeedbackAPIRetryCounter__c
                                                  FROM SFCustomRecommendation__c];

          System.assertEquals(true, !recs.isEmpty(), 'Recommendation list is empty, save failed');

          Batch_NBAJoesiFeedbackReprocessor schedule = new Batch_NBAJoesiFeedbackReprocessor();

          System.runAs(nbaProcessId){
            Test.startTest();
            schedule.execute(null, recs);
            Test.stopTest();
          }

          List<SFCustomRecommendation__c> recsAfter = [Select Id, Status__c, FeedbackAPICalloutSuccess__c, FeedbackAPIRetryCounter__c, Name from SFCustomRecommendation__c];
          System.assertEquals('Failed', recsAfter[0].FeedbackAPICalloutSuccess__c, 'FeedbackAPICalloutSuccess not as expected');
          System.assertEquals(1.0, recsAfter[0].FeedbackAPIRetryCounter__c, 'FeedbackAPIRetry counter not as expected');

          List<ExceptionLog__c> exceptionLogs = [select id, method__c, Exception_Message__c from ExceptionLog__c where method__c = 'reprocessSFCustomRecommendations'];
          System.assertEquals(1, exceptionLogs.size(), 'Size of exceptions is not greater than 0');
      }

      @isTest
      public static void scheduleBatchTest(){

          User nbaProcessId = TestUserSetupUtility.getApiOnlyUser();
          System.runAs(TestUserSetupUtility.getSysAdminUser()){
              CS_NBA_Config__c batchFeedbackAPIMaxRetryCounter = new CS_NBA_Config__c();
              batchFeedbackAPIMaxRetryCounter.Name = 'BatchFeedbackAPIMaxRetryCounter';
              batchFeedbackAPIMaxRetryCounter.Value__c = 1;
              insert batchFeedbackAPIMaxRetryCounter;
          }

          Date todaysDate = System.today();
          Batch_NBAJoesiFeedbackReprocessor sched = new Batch_NBAJoesiFeedbackReprocessor();
          Integer nextYear = todaysDate.Year() +1;
          String cronExpr = '0 0 0 15 3 ? ' + nextYear;
          System.runAs(nbaProcessId){
            Test.startTest();
            String jobId = System.schedule('Batch_NBAJoesiFeedbackReprocessor', cronExpr, sched);
            sched.execute(null);
            Test.stopTest();
            System.assert(jobId != null, 'Batch Process Id returned null.');
          }

      }

  }

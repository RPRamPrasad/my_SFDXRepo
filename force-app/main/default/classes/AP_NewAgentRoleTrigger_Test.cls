/** @description This is a test class for AgentRole Trigger apex class.This class will execute methods for insert and update records in the AgentRole Object.
  * This class is used to test FSC Insurance Policy records for creating shares
  * @author Team Stark
  * @owner Team Stark
  * @createdDate 02/15/2021 
  */
  @isTest
  (seeAllData = false)
  public class AP_NewAgentRoleTrigger_Test {
    private static final Integer AGENTROLE_TEST_BATCH_SIZE = 5;
    private static User agentUser; 
    private static User atmUser;
    private static User  techSupport;
    private static User  cccLicensedUser;
    private static final String CUSTOMER = 'Customer';
    private static final String EXCUSTOMER = 'Ex-Customer';
    private static final String PROSPECT = 'Prospect';
    private static final String FSC_AGENTROLE_UPDATE_CHECK = 'FSC_AgentRole_Update_Check';
    public static User commonTechUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('techSupportUser'),Alias='TECH',Associate_ID__c='4321TEST321',UserExternalID__c='4321TEST321');

    /**
    * @description Setup method used for building test data
    * @name setUp
    */
    @testsetup
    public static void testSetupData() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        objectBasedByPassTrigger.Override_AgentRoleAfterDelete__c = false;
        objectBasedByPassTrigger.Override_AgentRoleAfterUpdate__c = false;
        insert objectBasedByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;   
    }

    /**
      * @description insert or delete insurance policy 
      * @name testAgentRoleInsertDeleteForInsurancePolicy
      */ 
      @isTest
      public static void testAgentRoleInsertDeleteForInsurancePolicy(){

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;
            techSupport= AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(commonTechUser);
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
            TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
            Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
            System.runAs(systemAdmin){
                insert techSupport;
                insert accountForAgentRole;
            } 
            AgentRole__c agentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy1.Agent.Id,CUSTOMER);
             System.runAs(systemAdmin){
                insert agentRoleCreation;
            }
            InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=accountForAgentRole.id);
            System.runAs(systemAdmin){
                insert policy;
            }
            InsurancePolicyParticipant participant = 
                new InsurancePolicyParticipant(PrimaryParticipantAccountId = accountForAgentRole.id, InsurancePolicyId = policy.Id, Role='Named Insured');
                insert participant;
            AgentRole__c newAgentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy2.Agent.Id,PROSPECT);
            Test.startTest();
            System.runAs(systemAdmin){
                insert newAgentRoleCreation;
            }
            Integer insurancePolicyShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
            System.assertEquals(1,insurancePolicyShare,'new insurance policy share should be 1');
            System.runAs(systemAdmin){
                delete newAgentRoleCreation;
            } 
            Test.stopTest();
            Integer insurancePolicyShareAfterDelete = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
            System.assertEquals(0, insurancePolicyShareAfterDelete,'delete insurance policy share size 0');
        }
    
        /**
        * @description Given three accounts with two cases each "WHEN three new agentroles are inserted, THEN three agent's offices specific to the agentroles should have access to their respective account and Cases"   
        * @name testAgentRoleInsertForInsurancePolicyBulk
        */ 
        @isTest
        public static void testAgentRoleInsertForInsurancePolicyBulk(){

            UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;
            techSupport= AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(commonTechUser);
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
            TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('B');
            TestData_SalesRoleHierarchy salesRoleHierarchy3 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('C');
            TestData_SalesRoleHierarchy salesRoleHierarchy4 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('D');
            TestData_SalesRoleHierarchy salesRoleHierarchy5 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('E');
            Account accountForAgentRole1 = new Account(FirstName='FirstName1',LastName='LastName1',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
            Account accountForAgentRole2 = new Account(FirstName='FirstName2',LastName='LastName2',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYX');
            Account accountForAgentRole3 = new Account(FirstName='FirstName3',LastName='LastName3',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYA');
            Account accountForAgentRole4 = new Account(FirstName='FirstName4',LastName='LastName4',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYB');
            List<Account> accountsLists = new List<Account>{accountForAgentRole1, accountForAgentRole2, accountForAgentRole3, accountForAgentRole4};
            System.runAs(systemAdmin){
                insert techSupport;
                insert accountsLists;
            }
            InsurancePolicy policy1 = new InsurancePolicy(Name='Policy1', NameInsuredId=accountForAgentRole1.Id);
            InsurancePolicy policy2 = new InsurancePolicy(Name='Policy2', NameInsuredId=accountForAgentRole1.Id);
            InsurancePolicy policy3 = new InsurancePolicy(Name='Policy3', NameInsuredId=accountForAgentRole2.Id);
            List<InsurancePolicy> policyList = new List<InsurancePolicy>{policy1, policy2, policy3};
            System.runAs(systemAdmin){
                insert policyList;
            }
            AgentRole__c agentRoleCreation1=getAgentRoleData(accountForAgentRole1.Id,salesRoleHierarchy1.Agent.Id,CUSTOMER);
            AgentRole__c agentRoleCreation2=getAgentRoleData(accountForAgentRole2.Id,salesRoleHierarchy2.Agent.Id,CUSTOMER);
            AgentRole__c agentRoleCreation3=getAgentRoleData(accountForAgentRole3.Id,salesRoleHierarchy1.Agent.Id,CUSTOMER);
            List<AgentRole__c> agentRolesList = new List<AgentRole__c>{agentRoleCreation1,agentRoleCreation2,agentRoleCreation3};
            System.runAs(systemAdmin){
                insert agentRolesList;
            }
            AgentRole__c newAgentRoleCreation1=getAgentRoleData(accountForAgentRole1.Id,salesRoleHierarchy3.Agent.Id,PROSPECT);
            AgentRole__c newAgentRoleCreation2=getAgentRoleData(accountForAgentRole1.Id,salesRoleHierarchy4.Agent.Id,PROSPECT);
            AgentRole__c newAgentRoleCreation3=getAgentRoleData(accountForAgentRole2.Id,salesRoleHierarchy5.Agent.Id,PROSPECT);
            List<AgentRole__c> newAgentRolesList = new List<AgentRole__c>{newAgentRoleCreation1, newAgentRoleCreation2, newAgentRoleCreation3};
            Test.startTest();
            System.runAs(systemAdmin){
                insert newAgentRolesList;
            }
            Integer insurancePolicyShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy1.Id];
            System.assertEquals(4, insurancePolicyShare,'existing insurance policy shares 4');
            System.runAs(systemAdmin){
                delete newAgentRolesList;
            }
            System.runAs(systemAdmin){
                delete agentRoleCreation3;
            }
            Integer insurancePolicyShareAfterDelete = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy1.Id];
            System.assertEquals(2, insurancePolicyShareAfterDelete,'deleted insurance policy shares 2');
            Test.stopTest();
        }
  
        /**
        * @description insert or delete insurance policy 
        * @name testAgentRoleUpdateForInsurancePolicy
        */ 
        @isTest
        public static void testAgentRoleUpdateForInsurancePolicy(){

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);

          UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
          User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
              insert systemAdmin;
              techSupport= AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(commonTechUser);
              TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
              TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
              Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
              System.runAs(systemAdmin){
                  insert techSupport;
                  insert accountForAgentRole;
                  TestDataFactory_CustomPermission.activateCustomPerm(techSupport.id,FSC_AGENTROLE_UPDATE_CHECK);
                  insert assignPermSet(techSupport);
              } 
              AgentRole__c agentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy1.Agent.Id,CUSTOMER);
              AgentRole__c newAgentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy2.Agent.Id,PROSPECT);
              System.runAs(systemAdmin){
                  insert agentRoleCreation;
                  insert newAgentRoleCreation;
              } 
              InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=accountForAgentRole.id);
              System.runAs(systemAdmin){
                  insert policy;
              }
              InsurancePolicyParticipant participant = 
                  new InsurancePolicyParticipant(PrimaryParticipantAccountId = accountForAgentRole.id, InsurancePolicyId = policy.Id, Role='Named Insured');
                  insert participant;
                  
              newAgentRoleCreation.RelationshipNature__c=CUSTOMER;
              Test.startTest();
                System.assertEquals(false, FeatureManagement.checkPermission(FSC_AGENTROLE_UPDATE_CHECK),'Failed to check custom permission');
                System.runAs(techSupport){
                    System.assertEquals(true, FeatureManagement.checkPermission(FSC_AGENTROLE_UPDATE_CHECK),'Failed to check custom permission');
                    update newAgentRoleCreation;
              }
              Integer insurancePolicyShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
              System.assertEquals(1,insurancePolicyShare,'new insurance policy share 1');
              System.runAs(techSupport){
                  delete newAgentRoleCreation;
              } 
              Test.stopTest();
              Integer insurancePolicyShareAfterDelete = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
              System.assertEquals(0, insurancePolicyShareAfterDelete,'delete insurance policy share size 0');
        }

    /**
    * @description insert or delete insurance policy and related claim
    * @name testAgentRoleInsertDeleteForInsurancePolicyAndClaim
    */ 
    @isTest
    public static void testAgentRoleInsertDeleteForInsurancePolicyAndClaim(){

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;
        techSupport= AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(commonTechUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
        TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
        Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin){
            insert techSupport;
            insert accountForAgentRole;
        } 
        AgentRole__c agentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy1.Agent.Id,CUSTOMER);
        System.runAs(systemAdmin){
            insert agentRoleCreation;
        }
        InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=accountForAgentRole.id);
        System.runAs(systemAdmin){
            insert policy;
        }
        InsurancePolicyParticipant participant = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = accountForAgentRole.id, InsurancePolicyId = policy.Id, Role='Named Insured');
            insert participant;
        Claim claim = new Claim(Name='Claim', AccountId=accountForAgentRole.id,PolicyNumberId=policy.id);
        System.runAs(systemAdmin){
            insert claim;
        }
        AgentRole__c newAgentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy2.Agent.Id,PROSPECT);
        Test.startTest();
        System.runAs(systemAdmin){
            insert newAgentRoleCreation;
        }
        Integer insurancePolicyShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(1, insurancePolicyShare,'new insurance policy share should be 1');
        Integer claimShare = [SELECT COUNT() FROM ClaimShare WHERE ParentId = :claim.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(1, claimShare,'new claim share should be 1');
        System.runAs(systemAdmin){
            delete newAgentRoleCreation;
        } 
        Test.stopTest();
        Integer insurancePolicyShareAfterDelete = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(0, insurancePolicyShareAfterDelete,'delete insurance policy share size 0');
        Integer claimShareAfterDelete = [SELECT COUNT() FROM ClaimShare WHERE ParentId = :claim.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(0, claimShareAfterDelete,'delete claim share size 0');
    }


    /**
    * @description insert or delete insurance policy  and claim
    * @name testAgentRoleUpdateForInsurancePolicyAndClaims
    */
    @isTest
    public static void testAgentRoleUpdateForInsurancePolicyAndClaim(){

        UTIL_InsurancePolicyShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.POLICY_SHARES, true);
        UTIL_ClaimShare.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_SHARES, true);

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdmin;
        techSupport= AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(commonTechUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
        TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
        Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
        System.runAs(systemAdmin){
            insert techSupport;
            insert accountForAgentRole;
            TestDataFactory_CustomPermission.activateCustomPerm(techSupport.id,FSC_AGENTROLE_UPDATE_CHECK);
            insert assignPermSet(techSupport);
        } 
        AgentRole__c agentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy1.Agent.Id,CUSTOMER);
        AgentRole__c newAgentRoleCreation=getAgentRoleData(accountForAgentRole.Id,salesRoleHierarchy2.Agent.Id,PROSPECT);
        System.runAs(systemAdmin){
            insert agentRoleCreation;
            insert newAgentRoleCreation;
        } 
        InsurancePolicy policy = new InsurancePolicy(Name='Policy', NameInsuredId=accountForAgentRole.id);
        System.runAs(systemAdmin){
            insert policy;
        }
        InsurancePolicyParticipant participant = 
            new InsurancePolicyParticipant(PrimaryParticipantAccountId = accountForAgentRole.id, InsurancePolicyId = policy.Id, Role='Named Insured');
            insert participant;
        Claim claim = new Claim(Name='Claim', AccountId=accountForAgentRole.id,PolicyNumberId=policy.id);
        System.runAs(systemAdmin){
            insert claim;
        }
                    
        newAgentRoleCreation.RelationshipNature__c=CUSTOMER;
        Test.startTest();
        System.assertEquals(false, FeatureManagement.checkPermission(FSC_AGENTROLE_UPDATE_CHECK),'Failed to check custom permission');
            System.runAs(techSupport){
                System.assertEquals(true, FeatureManagement.checkPermission(FSC_AGENTROLE_UPDATE_CHECK),'Failed to check custom permission');
                update newAgentRoleCreation;
            }
        Integer insurancePolicyShare = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(1, insurancePolicyShare,'new insurance policy share 1');
        Integer claimShare = [SELECT COUNT() FROM ClaimShare WHERE ParentId = :claim.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(1, claimShare,'new claim share should be 1');
        System.runAs(techSupport){
            delete newAgentRoleCreation;
        } 
        Test.stopTest();
        Integer insurancePolicyShareAfterDelete = [SELECT COUNT() FROM InsurancePolicyShare WHERE ParentId = :policy.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(0, insurancePolicyShareAfterDelete,'delete insurance policy share size 0');
        Integer claimShareAfterDelete = [SELECT COUNT() FROM ClaimShare WHERE ParentId = :claim.Id AND UserOrGroupId = :salesRoleHierarchy2.AgentOffice.Id];
        System.assertEquals(0, claimShareAfterDelete,'delete claim share size 0');
    }
    
    /**
      * @description building agent roles record information
      * @name getAgentRoleData
      * @param accountId
      * @param agentId
      * @param nature
      * @return single AgentRole__c
      */         
        private static AgentRole__c getAgentRoleData(id accountId,id agentId,string nature) { return new AgentRole__c(Agent__c=agentId, RelationshipNature__c=nature,Customer__c=accountId); }

    private static List<PermissionSetAssignment> assignPermSet(User techSupportUser){
        PermissionSet permSet1 = [select Id from PermissionSet where Name = 'CoreComponents_AllUsers'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet1.Id);
        PermissionSet permSet2 = [select Id from PermissionSet where Name = 'CoreComponents_User_R'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet2.Id);
        PermissionSet permSet3 = [select Id from PermissionSet where Name = 'CustomerView_Support_ModifyAll'];
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = techSupportUser.Id, PermissionSetId = permSet3.Id);
        List<PermissionSetAssignment> psalist = new List<PermissionSetAssignment> {
            psa1, psa2, psa3
        };
        return psalist;
    }
  }
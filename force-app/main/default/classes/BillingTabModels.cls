/**
* name : BillingTabModels
* @description : Models for agent and insurance data for billing tab
* @author : Team Kraken
* Date Created : 2/12/21
*/
public with sharing abstract class BillingTabModels {
    /**
     * @name - InsurancePolicyData
     * @description - Holds policy and billing information.
     */
    public with sharing class InsurancePolicyData {
        @AuraEnabled
        public String insurancePolicyUrl;
        @AuraEnabled
        public String insurancePolicyNumber;
        @AuraEnabled
        public String insurancePolicyDescription;
        @AuraEnabled
        public Map<Id, String> billingFrequency;
        @AuraEnabled
        public Map<Id, Boolean> policyActive;
        @AuraEnabled
        public Map<Id, String> policyStatus;
        @AuraEnabled
        public Map<Id, Date> cancellationDate;
        @AuraEnabled
        public String agreementAccessKey;
        @AuraEnabled
        public String productLineCode;
        @AuraEnabled
        public String stateAgentCode;
        @AuraEnabled
        public String agentName;
        @AuraEnabled
        public AgentData agentData;
        @AuraEnabled
        public String insuranceInsuredNamed;

        /**
         * @name - InsurancePolicyData constructor
         * @description - constructor that accepts an InsurancePolicy object
         * @param insurancePolicy
         */
        public InsurancePolicyData(InsurancePolicy insurancePolicy) {
            this.insurancePolicyUrl = '/' + insurancePolicy.Id;
            this.insurancePolicyNumber = insurancePolicy.Name;
            this.insurancePolicyDescription = insurancePolicy.PolicyDescription;
            this.agreementAccessKey = insurancePolicy.AgreAccessKey__c;
            this.productLineCode = insurancePolicy.ProdLineCd__c;
            this.stateAgentCode = insurancePolicy.Servicing_Agent__r.State_Agent_Code__c;
            this.agentName = insurancePolicy.Servicing_Agent__r.Name;
            this.agentData = BillingTabAgentDataBuilder.buildAgentData(this.stateAgentCode, this.agentName);
            this.billingFrequency = new Map<Id, String>();
            this.policyActive = new Map<Id, Boolean>();
            this.policyStatus = new Map<Id, String>();
            this.cancellationDate = new Map<Id, Date>();
            this.insuranceInsuredNamed = insurancePolicy.AgreDisplayPartyName__c;
        }

        /**
         * @name - InsurancePolicyData constructor
         * @description - constructor that accepts an InsurancePolicyParticipant object
         * @param participant
         */
        public InsurancePolicyData(InsurancePolicyParticipant participant) {
            this.insurancePolicyUrl = '/' + participant.InsurancePolicyId;
            this.insurancePolicyNumber = participant.InsurancePolicy.Name;
            this.insurancePolicyDescription = participant.InsurancePolicy.PolicyDescription;
            this.agreementAccessKey = participant.InsurancePolicy.AgreAccessKey__c;
            this.productLineCode = participant.InsurancePolicy.ProdLineCd__c;
            this.stateAgentCode = participant.InsurancePolicy.Servicing_Agent__r.State_Agent_Code__c;
            this.agentName = participant.InsurancePolicy.Servicing_Agent__r.Name;
            this.agentData = BillingTabAgentDataBuilder.buildAgentData(this.stateAgentCode, this.agentName);
            this.billingFrequency = new Map<Id, String>();
            this.policyActive = new Map<Id, Boolean>();
            this.policyStatus = new Map<Id, String>();
            this.cancellationDate = new Map<Id, Date>();
            this.insuranceInsuredNamed = participant.InsurancePolicy.AgreDisplayPartyName__c;
        }
    }

    /**
     * @name - AgentData
     * @description - Holds agent information.
     */
    public with sharing class AgentData {
        @AuraEnabled
        public String stateAgentCode;
        @AuraEnabled
        public String servicingAgentName;
        @AuraEnabled
        public String servicingAgentUrl;
        public Boolean isSFOAgent;
        public String stateCode;
        public String agentCode;

        /**
         * @name - AgentData constructor
         * @description - constructor that accepts a state agent code
         * @param stateAgentCode
         */
        public AgentData(String stateAgentCode) {
            this.stateAgentCode = stateAgentCode;
        }
    }

    /**
     * @name - BillingParticipantData
     * @description - Holds billing participant information.
     */
    public with sharing class BillingParticipantData {
        @AuraEnabled
        public String participantName;
        @AuraEnabled
        public String participantUrl;
        @AuraEnabled
        public String participantRole;
        @AuraEnabled
        public String participantClientIdentifier;

        /**
         * @name - BillingParticipantData constructor
         * @description - constructor that accepts a billing participant
         * @param participant
         */
        public BillingParticipantData(Billing_Participant__c participant) {
            this.participantName = participant.ParticipantAccountId__r.Name;
            this.participantUrl = '/' + participant.ParticipantAccountId__r.Id;
            this.participantRole = participant.SFPolicyRoleId__c;
        }
    }

    /**
     * @description BillingPolicyDAO
     */
    public with sharing class BillingPolicyDAO {
        public Map<Id, Billing_Policy__c> missingInsurancePolicyIdsToBillingPolicy;
        public List<Billing_Policy__c> billingPoliciesInAccountList;
        public BillingAccountData billingAccount;
        public List<InsurancePolicy> queriedPolicies;
    }

    /**
     * @description InsurancePolicyToBillingPolicyDAO
     */
    public with sharing class InsurancePolicyToBillingPolicyDAO {
        public Map<Id, Map<Id, InsurancePolicyData>> billingAccountIdToInsurancePolicyData;
        public Billing_Policy__c billingPolicy;
        public Billing_Account__c billingAccount;
        public Map<Id, Map<Id, Billing_Policy__c>> missingInsurancePolicies;
    }
}

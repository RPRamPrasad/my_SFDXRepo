/**
 * @description Apex controller for JOT component
 * @owner ASTRO
 **/
public with sharing class JustOneThingController {
    private static final String CLASS_NAME = 'JustOneThingController';
    private static final String WHO = 'WhoId';
    private static final String OWNER = 'OwnerId';
    private static final String ASSIGNED_TO = 'AssignedTo__c';
    private static final String NAME = 'Name';

    /**
     * @description - Obtains the parent record data based on the record id that is passed in
     * @param recordId - Id of the record that will be used to obtain needed record data
     * @return Map<String, Object> - returns a map that contains the parent record data
     */
    @AuraEnabled
    public static Map<String, Object> getParentRecordData(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> response = new Map<String, Object>();

        try {
            SObjectType objectType = recordId.getSobjectType();

            if (objectType == Account.getSObjectType()) {
                data = getParentRecordDataForAccount(recordId);
            } else if (objectType == Billing_Account__c.getSObjectType()) {
                data = getParentRecordDataForBilling(recordId);
            } else if (objectType == Case.getSObjectType()) {
                data = getParentRecordDataForCase(recordId);
            } else if (objectType == Opportunity.getSObjectType()) {
                data = getParentRecordDataForOpportunity(recordId);
            } else if (objectType == InsurancePolicy.getSObjectType()) {
                data = getParentRecordDataForInsurancePolicy(recordId);
            } else if (objectType == Claim.getSObjectType()) {
                data = getParentRecordDataForClaim(recordId);
            }

            response.put('data', data);
            response.put('agencyUser', FeatureManagement.checkPermission('Agency_User'));
            response.put('cccUser', FeatureManagement.checkPermission('CCC_User'));
        } catch (Exception e) {
            String errorMessage = 'Failed to retrieve parent record data';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);

            LoggingService.logHandledException(e, CLASS_NAME, 'getParentRecordData', LoggingLevel.ERROR);
            throw error;
        }

        return response;
    }

    private static Map<String, Object> getParentRecordDataForAccount(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        Account firstAccount = getAccountData(recordId).get(0);

        data.put(WHO, firstAccount.PersonContactId);
        data.put(OWNER, JustOneThingUtilities.handleOfficeAssignedUserAccess());
        data.put(ASSIGNED_TO, JustOneThingUtilities.handleAssignedToUserAccess());
        data.put(NAME, firstAccount.Name);

        return data;
    }

    private static Map<String, Object> getParentRecordDataForBilling(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        Billing_Account__c billingAccount = getBillingAccountData(recordId).get(0);
        Billing_Participant__c billingParticipant = getBillingParticipantData(recordId).get(0);

        data.put(WHO, billingParticipant.ParticipantAccountId__r.PersonContactId);
        data.put(OWNER, JustOneThingUtilities.handleOfficeAssignedUserAccess());
        data.put(ASSIGNED_TO, JustOneThingUtilities.handleAssignedToUserAccess());
        data.put(NAME, billingParticipant.ParticipantAccountId__r.Name);
        data.put('BillingAccountNumber', billingAccount.Name);
        data.put('BillingAccountSourceSystem', billingAccount.SourceSystem__c);

        return data;
    }

    private static Map<String, Object> getParentRecordDataForCase(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        Case firstCase = getCaseData(recordId).get(0);

        data.put(WHO, firstCase.Account.PersonContactId);
        data.put(OWNER, JustOneThingUtilities.handleOfficeAssignedUserAccess());
        data.put(ASSIGNED_TO, JustOneThingUtilities.handleAssignedToUserAccess());
        data.put('CaseNumber', firstCase.CaseNumber);
        data.put('CaseOwnerId', firstCase.OwnerId);
        data.put(NAME, firstCase.Account.Name);

        return data;
    }

    private static Map<String, Object> getParentRecordDataForInsurancePolicy(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        InsurancePolicy policy = getInsurancePolicyData(recordId).get(0);

        // add policy onto data map
        data.put(WHO, policy.NameInsured.PersonContactId);
        data.put(OWNER, JustOneThingUtilities.handleOfficeAssignedUserAccess());
        data.put(ASSIGNED_TO, JustOneThingUtilities.handleAssignedToUserAccess());

        data.put('PolicyDescription', policy.PolicyDescription);
        data.put('PolicyOwnerId', policy.OwnerId);
        data.put('PolicyPartyName', policy.AgreDisplayPartyName__c);

        return data;
    }

    private static Map<String, Object> getParentRecordDataForClaim(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        Claim claim = getClaimData(recordId).get(0);

        // add claim onto data map
        data.put(WHO, claim.Account.PersonContactId);
        data.put(OWNER, JustOneThingUtilities.handleOfficeAssignedUserAccess());
        data.put(ASSIGNED_TO, JustOneThingUtilities.handleAssignedToUserAccess());

        data.put('ClaimName', claim.Name);
        data.put('ClaimDescription', claim.ClaimDescription__c);
        data.put('ClaimOwnerId', claim.OwnerId);
        return data;
    }

    private static Map<String, Object> getParentRecordDataForOpportunity(Id recordId) {
        Map<String, Object> data = new Map<String, Object>();
        Opportunity opp = getOpportunityData(recordId).get(0);

        data.put(WHO, opp.Account.PersonContactId);
        data.put(OWNER, JustOneThingUtilities.handleOfficeAssignedUserAccess());
        data.put(ASSIGNED_TO, JustOneThingUtilities.handleAssignedToUserAccess());
        data.put('LOB', opp.LOB__c);
        data.put(NAME, opp.Account.Name);
        data.put('OppOwnerId', opp.OwnerId);
        data.put('OppAssignedTo', opp.Assigned_To__c);

        return data;
    }

    private static List<Account> getAccountData(Id recordId) {
        List<Account> accounts = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Name, OwnerId, PersonContactId FROM Account WHERE Id =: recordId LIMIT 1]
        ).getRecords();

        return accounts;
    }

    private static List<Billing_Account__c> getBillingAccountData(Id recordId) {
        List<Billing_Account__c> billingAccounts = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Name, SourceSystem__c FROM Billing_Account__c WHERE Id =: recordId LIMIT 1]
        ).getRecords();

        return billingAccounts;
    }

    private static List<Billing_Participant__c> getBillingParticipantData(Id recordId) {
        List<Billing_Participant__c> billingParticipants = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, ParticipantAccountId__r.PersonContactId, ParticipantAccountId__r.Name FROM Billing_Participant__c WHERE BillingAccountID__c =: recordId LIMIT 1]
        ).getRecords();

        return billingParticipants;
    }

    private static List<Case> getCaseData(Id recordId) {
        List<Case> cases = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Assigned_To__c, Account.PersonContactId, Account.Name, CaseNumber, OwnerId FROM Case WHERE Id =: recordId LIMIT 1]
        ).getRecords();

        return cases;
    }

    private static List<InsurancePolicy> getInsurancePolicyData(Id recordId) {
        // Query for parent record data
        List<InsurancePolicy> insurancePolicies = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, AgreDisplayPartyName__c, PolicyDescription, NameInsured.PersonContactId, OwnerId FROM InsurancePolicy WHERE Id =: recordId LIMIT 1]
        ).getRecords();

        return insurancePolicies;
    }

    private static List<Claim> getClaimData(Id recordId) {
        // Query for parent record data
        List<Claim> claims = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Name, ClaimDescription__c, Account.PersonContactId, OwnerId FROM Claim WHERE Id =: recordId LIMIT 1]
        ).getRecords();

        return claims;
    }

    private static List<Opportunity> getOpportunityData(Id recordId) {
        List<Opportunity> opps = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Assigned_To__c, LOB__c, OwnerId, Account.Name, Account.PersonContactId FROM Opportunity WHERE Id =: recordId LIMIT 1]
        ).getRecords();

        return opps;
    }

    /**
     * @description - Obtains the user's timezone to format a start and end date/time
     * that is 1-2 hours ahead to display as default values.
     * @return Map<String, DateTime> - returns a map that contains the start and end date/time
     */
    @TestVisible
    @AuraEnabled
    public static Map<String, DateTime> getStartEndDateTimes() {
        Map<String, DateTime> dateTimes = new Map<String, DateTime>();
        try {
            DateTime dateTimeNow = DateTime.now();
            String userTimeZone = UserInfo.getTimeZone().getID();
            String formattedStartDate = dateTimeNow.addHours(1).format('yyyy-MM-dd HH:00:00', userTimeZone);
            String formattedEndDate = dateTimeNow.addHours(2).format('yyyy-MM-dd HH:00:00', userTimeZone);

            dateTimes.put('startDateTime', DateTime.valueOf(formattedStartDate));
            dateTimes.put('endDateTime', DateTime.valueOf(formattedEndDate));
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getStartEndDateTimes', LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to retrieve start and end date times');
        }
        return dateTimes;
    }
}
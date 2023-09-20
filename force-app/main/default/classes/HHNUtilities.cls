/**
 *  @description Helper Apex class to help with operations needed when retrieving data for HHN.
 */
public with sharing class HHNUtilities {

    private static final String CLASS_NAME = 'HHNUtilities';

    private static final String ALL_ROWS = 'ALL ROWS ';
    private static final String NOT_DELETED = ' AND isDeleted = false';

    private static final Set<SObjectType> EXCLUDED_OBJECTS = new Set<SObjectType> {
        Billing_Account__c.getSObjectType(),
        Case.getSObjectType(),
        Claim.getSObjectType(),
        Opportunity.getSObjectType(),
        InsurancePolicy.getSObjectType()
    };

    /**
     * @description - Queries for the account id based on email
     * @param email
     * @return account id of persons email
     */      
    @AuraEnabled
    public static Id getAccountIdFromEmail(String email) {
        try {
        	String queryToExecute = 'SELECT Id FROM Account WHERE personEmail =: email';
        	List<Account> accts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        	Account acct = accts.get(0);
        	return Id.valueOf(acct.id);
        }catch (Exception e){
            String errorMessage = 'Failed to retrieve id based on email';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);
            LoggingService.logHandledException(e, CLASS_NAME, 'getAccountIdFromEmail', LoggingLevel.ERROR);
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description - Queries for accounts based on a list of emails
     * @param emails
     * @return accounts containing the emails
     */      
    @AuraEnabled
    public static List<Account> getAccountsFromEmails(List<String> emails) {
        try {
            String queryToExecute = 'SELECT Id, Name, PersonContactId, PersonEmail FROM Account WHERE PersonEmail IN :emails';
            return Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        } catch (Exception e){
            String errorMessage = 'Failed to retrieve account information based on emails';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);
            LoggingService.logHandledException(e, CLASS_NAME, 'getAccountsFromEmail', LoggingLevel.ERROR);
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description - Queries for the account id and household id of the record
     * @param recordId
     * @param objectApiName
     * @return List<String> - returns the account id and household id of the record
     */
    @AuraEnabled
    public static List<String> getAccountAndHouseholdId(String recordId, String objectApiName) {
        try {
            switch on objectApiName {
                when 'Account' {
                    return getIdsForAccount(recordId);
                }
                when 'Billing_Account__c' {
                    return getIdsForBillingAccount(recordId);
                }
                when 'Case' {
                    return getIdsForCase(recordId);
                }
                when 'Claim' {
                    return getIdsForClaim(recordId);
                }
                when 'InsurancePolicy' {
                    return getIdsForInsurancePolicy(recordId);
                }
                when 'Opportunity' {
                    return getIdsForOpportunity(recordId);
                }
                when else {
                    return new List<String>{null, null};
                }
            }
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getAccountAndHouseholdId', LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to get account and household ID, getAccountAndHouseholdId');
        }
    }

    private static List<String> getIdsForAccount(String recordId) {
        String queryToExecute = 'SELECT Primary_Household__pc, RecordType.Name FROM Account WHERE Id =: recordId';
        List<Account> accounts = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        Account acc = accounts.get(0);
        String primaryHouseholdId = null;
        if (acc.RecordType.Name != null && acc.RecordType.Name.equals('Household')) {
            primaryHouseholdId = recordId;
        } else if (String.isNotBlank(acc.Primary_Household__pc)) {
            primaryHouseholdId = acc.Primary_Household__pc;
        }
        return new List<String>{recordId, primaryHouseholdId};
    }

    private static List<String> getIdsForBillingAccount(String recordId) {
        String queryToExecute = 'SELECT ParticipantAccountId__c, Primary_Household__c FROM Billing_Participant__c WHERE BillingAccountID__c =: recordId';
        List<Billing_Participant__c> billingParticipants = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        Billing_Participant__c billingParticipant = billingParticipants.get(0);
        return new List<String>{billingParticipant.ParticipantAccountId__c, billingParticipant.Primary_Household__c};
    }

    private static List<String> getIdsForCase(String recordId) {
        String queryToExecute = 'SELECT AccountId, FinServ__Household__c FROM Case WHERE Id =: recordId';
        List<Case> cases = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        Case c = cases.get(0);
        return new List<String>{c.AccountId, c.FinServ__Household__c};
    }

    private static List<String> getIdsForClaim(String recordId) {
        String queryToExecute = 'SELECT AccountId, FinServ__Household__c FROM Claim WHERE Id =: recordId';
        List<Claim> claims = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        Claim claim = claims.get(0);
        return new List<String>{claim.AccountId, claim.FinServ__Household__c};
    }

    private static List<String> getIdsForInsurancePolicy(String recordId) {
        String queryToExecute = 'SELECT NameInsuredId, FinServ__Household__c FROM InsurancePolicy WHERE Id =: recordId';
        List<InsurancePolicy> insurancePolicies = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        InsurancePolicy insurancePolicy = insurancePolicies.get(0);
        return new List<String>{insurancePolicy.NameInsuredId, insurancePolicy.FinServ__Household__c};
    }

    private static List<String> getIdsForOpportunity(String recordId) {
        String queryToExecute = 'SELECT AccountId, FinServ__Household__c FROM Opportunity WHERE Id =: recordId';
        List<Opportunity> opps = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        Opportunity opp = opps.get(0);
        return new List<String>{opp.AccountId, opp.FinServ__Household__c};
    }

    /**
     *  @description Get events based on the household ID.
     *  @param householdId
     *  @param includeArchive
     *  @return List<Event> - Events related to the household.
     */
    public static List<Event> getEventsForHouseholdAccounts(String householdId, boolean includeArchive) {
        String queryToExecute = HHNConstants.EVENT_FIELDS
                                + ',('  + HHNConstants.EVENT_RELATION_FIELDS + HHNConstants.EVENT_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.EVENT_FROM_OBJECT + HHNConstants.EVENT_HOUSEHOLD_WHERE ;
        if(includeArchive == true) {
            queryToExecute =  queryToExecute + NOT_DELETED + HHNConstants.ORDER_BY_ACCOUNT_ID + ALL_ROWS;
        }
        else{
            queryToExecute = HHNConstants.EVENT_FIELDS
                                + ',('  + HHNConstants.EVENT_RELATION_FIELDS + HHNConstants.EVENT_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.EVENT_FROM_OBJECT + HHNConstants.EVENT_HOUSEHOLD_WHERE + HHNConstants.ORDER_BY_ACCOUNT_ID;
        }

        return Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
    }

    /**
     *  @description Get tasks based on the household ID.
     *  @param householdId
     *  @param includeArchive
     *  @return List<Task> - Tasks related to the household.
     */
    public static List<Task> getTasksForHouseholdAccounts(String householdId, boolean includeArchive) {
        String queryToExecute = HHNConstants.TASK_FIELDS
                                + ',('  + HHNConstants.TASK_RELATION_FIELDS + HHNConstants.TASK_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.TASK_FROM_OBJECT + HHNConstants.TASK_HOUSEHOLD_WHERE;
        if(includeArchive == true) {
             queryToExecute =  queryToExecute + NOT_DELETED + HHNConstants.ORDER_BY_ACCOUNT_ID + ALL_ROWS;
        }
        else{
             queryToExecute = HHNConstants.TASK_FIELDS
                                + ',('  + HHNConstants.TASK_RELATION_FIELDS + HHNConstants.TASK_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.TASK_FROM_OBJECT + HHNConstants.TASK_HOUSEHOLD_WHERE + HHNConstants.ORDER_BY_ACCOUNT_ID;
        }

        return Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
    }

    /**
     *  @description Get events based on the account ID.
     *  @param parentRecordId
     *  @param includeArchive
     *  @return List<Event> - Events related to the account.
     */
    public static List<Event> getEventsForAccount(String parentRecordId, boolean includeArchive) {
        String queryToExecute = HHNConstants.EVENT_FIELDS
                                + ',('  + HHNConstants.EVENT_RELATION_FIELDS + HHNConstants.EVENT_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.EVENT_FROM_OBJECT + HHNConstants.EVENT_ACCOUNT_WHERE;
        if(includeArchive == true) {
            queryToExecute =  queryToExecute + NOT_DELETED + HHNConstants.ORDER_BY_ACCOUNT_ID + ALL_ROWS;
        }
        else{
            queryToExecute = HHNConstants.EVENT_FIELDS
            + ',('  + HHNConstants.EVENT_RELATION_FIELDS + HHNConstants.EVENT_RELATION_FROM_OBJECT + ') '
            + HHNConstants.EVENT_FROM_OBJECT + HHNConstants.EVENT_ACCOUNT_WHERE + HHNConstants.ORDER_BY_ACCOUNT_ID;
        }

        return Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
    }

    /**
     *  @description Get tasks based on the account ID.
     *  @param parentRecordId
     *  @param includeArchive
     *  @return List<Task> - Tasks related to the account.
     */
    public static List<Task> getTasksForAccount(String parentRecordId, boolean includeArchive) {
        String queryToExecute = HHNConstants.TASK_FIELDS
                                + ',('  + HHNConstants.TASK_RELATION_FIELDS + HHNConstants.TASK_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.TASK_FROM_OBJECT + HHNConstants.TASK_ACCOUNT_WHERE;
        if(includeArchive == true) {
           queryToExecute =  queryToExecute + NOT_DELETED + HHNConstants.ORDER_BY_ACCOUNT_ID + ALL_ROWS;
        }
        else{
           queryToExecute = HHNConstants.TASK_FIELDS
                                + ',('  + HHNConstants.TASK_RELATION_FIELDS + HHNConstants.TASK_RELATION_FROM_OBJECT + ') '
                                + HHNConstants.TASK_FROM_OBJECT + HHNConstants.TASK_ACCOUNT_WHERE + HHNConstants.ORDER_BY_ACCOUNT_ID;
        }

        return Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
    }

    /**
     *  @description Convert accounts and associated activities for return to HHN.
     *  @param accountList
     *  @param accountEvents
     *  @param accountTasks
     *  @return List<ActivityOutlineSObjectWrapper> - List of accounts ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformAccounts(List<Account> accountList, Map<String, List<Event>> accountEvents, Map<String, List<Task>> accountTasks) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Account accountRecord : accountList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = accountRecord.Id;
            soWrapper.recordSubject = accountRecord.Name;
            soWrapper.customerName = accountRecord.Name;
            soWrapper.lastModifiedDate = accountRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = accountRecord.LastModifiedBy.Name;
            soWrapper.createdDate = accountRecord.CreatedDate;
            soWrapper.displayDate = accountRecord.CreatedDate;
            soWrapper.sobjectType = String.valueOf(accountRecord.getSObjectType());
            soWrapper.relatedEvents = transformEvents(accountEvents.get(accountRecord.Id));
            soWrapper.relatedTasks = transformTasks(accountTasks.get(accountRecord.Id));
            soWrapper.relatedAccountNotes = transformAccountNotes(accountRecord.Account_Notes__r);
            soWrapper.relatedInteractionSummaries = transformInteractionSummaries(accountRecord.InteractionSummarys__r);
            soWrapper.relatedVirtualMeetings = transformVirtualMeetings(accountRecord.Virtual_Meeting_Participants__r);
            soWrapper.displayIconName = 'standard:person_account';

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedCaseNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedOpportunityNotes = new List<ActivityOutlineSObjectWrapper>();
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert account notes for return to HHN.
     *  @param accountNoteList
     *  @return List<ActivityOutlineSObjectWrapper> - List of account notes ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformAccountNotes(List<Account_Note__c> accountNoteList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Account_Note__c anRecord : accountNoteList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            String comments = anRecord.Comments__c;
            soWrapper.sobjectRecordId = anRecord.Id;
            soWrapper.createdDate = anRecord.CreatedDate;
            soWrapper.lastModifiedDate = anRecord.LastModifiedDate;
            soWrapper.displayDate = anRecord.CreatedDate;
            soWrapper.lastModifiedByName = anRecord.LastModifiedBy.Name;
            soWrapper.status = null;
            soWrapper.customer = anRecord.Account__c;
            soWrapper.lob = null;
            soWrapper.relatedTo = anRecord.Account__c;
            soWrapper.customerName = anRecord.Account__r.Name;
            soWrapper.sobjectType = String.valueOf(anRecord.getSObjectType());
            soWrapper.description = anRecord.Comments__c;
            if(String.isNotBlank(comments) && comments.length()>50){
                soWrapper.recordSubject = anRecord.Comments__c.substring(0,50)+'...';
            } else if(String.isNotBlank(comments) && comments.length()<= 50) {
                soWrapper.recordSubject = anRecord.Comments__c;
            } else {
                soWrapper.recordSubject = 'No Subject';
            }
            soWrapper.displayIconName = 'custom:custom62';
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert billing accounts for return to HHN.
     *  @param billingAccountList
     *  @return List<ActivityOutlineSObjectWrapper> - List of billing accounts ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformBillingAccounts(List<Billing_Account__c> billingAccountList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for (Billing_Account__c billingAccountRecord : billingAccountList) {
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = billingAccountRecord.Id;
            if (billingAccountRecord.SourceSystem__c != null && billingAccountRecord.SourceSystem__c == 'SFPP') {
                soWrapper.recordSubject = 'SFPP Account: ' + billingAccountRecord.Name;
            } else if (billingAccountRecord.SourceSystem__c != null && billingAccountRecord.SourceSystem__c == 'SF Billing') {
                soWrapper.recordSubject = 'SF Billing Account: ' + billingAccountRecord.Name;
            } else {
            	soWrapper.recordSubject = 'Billing Account: ' + billingAccountRecord.Name;
            }
            soWrapper.lastModifiedDate = billingAccountRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = billingAccountRecord.LastModifiedBy.Name;
            soWrapper.createdDate = billingAccountRecord.CreatedDate;
            soWrapper.displayDate = billingAccountRecord.CreatedDate;
            soWrapper.sobjectType = String.valueOf(billingAccountRecord.getSObjectType());
            soWrapper.status = billingAccountRecord.Status__c;
            soWrapper.description = billingAccountRecord.Name;
            soWrapper.assignedToName = null;
            soWrapper.relatedEvents = transformEvents(billingAccountRecord.Events);
            soWrapper.relatedTasks = transformTasks(billingAccountRecord.Tasks);
            soWrapper.displayIconName = 'custom:custom17';
            soWrapper.isClosed = false;

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedAccountNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedCaseNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedOpportunityNotes = new List<ActivityOutlineSObjectWrapper>();

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert cases for return to HHN.
     *  @param caseList
     *  @return List<ActivityOutlineSObjectWrapper> - List of cases ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformCases(List<Case> caseList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Case caseRecord : caseList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = caseRecord.Id;
            soWrapper.createdDate = caseRecord.CreatedDate;
            soWrapper.lastModifiedDate = caseRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = caseRecord.LastModifiedBy.Name;
            soWrapper.status = caseRecord.Status;
            soWrapper.relatedTo = caseRecord.AccountId;
            soWrapper.customerName = caseRecord.Account.Name;
            soWrapper.sobjectType = String.valueOf(caseRecord.getSObjectType());
            if(caseRecord.get('Follow_up_Date__c') == null){
                soWrapper.displayDate = caseRecord.CreatedDate;
            } else {
                soWrapper.displayDate = Datetime.newInstance(caseRecord.Follow_up_Date__c, Time.newInstance(0, 0, 0, 0));
            }
            String caseMapSubject = caseRecord.Subject;
            if(String.isBlank(caseMapSubject)) {
                caseMapSubject = '[No Subject]';
            }
            soWrapper.recordSubject = caseRecord.CaseNumber + ' - ' + caseMapSubject;
            soWrapper.description =  caseRecord.Description;
            soWrapper.assignedToName = caseRecord.Assigned_To__r.Name;
            soWrapper.relatedEvents = transformEvents(caseRecord.Events);
            soWrapper.relatedTasks = transformTasks(caseRecord.Tasks);
            soWrapper.relatedCaseNotes = transformCaseNotes(caseRecord.Case_Notes__r);
            soWrapper.displayIconName = 'standard:case';
            soWrapper.isClosed = caseRecord.IsClosed;

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedAccountNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedOpportunityNotes = new List<ActivityOutlineSObjectWrapper>();

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert case notes for return to HHN.
     *  @param caseNoteList
     *  @return List<ActivityOutlineSObjectWrapper> - List of case notes ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformCaseNotes(List<Case_Note__c> caseNoteList){
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Case_Note__c cnRecord : caseNoteList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = cnRecord.Id;
            soWrapper.createdDate = cnRecord.CreatedDate;
            soWrapper.lastModifiedDate = cnRecord.LastModifiedDate;
            soWrapper.displayDate = cnRecord.createdDate;
            soWrapper.lastModifiedByName = cnRecord.LastModifiedBy.Name;
            soWrapper.status = null;
            soWrapper.customer = cnRecord.Case__r.AccountId;
            soWrapper.recordSubject = cnRecord.Name;
            soWrapper.lob = null;
            soWrapper.relatedTo = cnRecord.Case__r.AccountId;
            soWrapper.sobjectType = String.valueOf(cnRecord.getSObjectType());
            soWrapper.description = cnRecord.Comments__c;
            soWrapper.displayIconName = 'custom:custom62';
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert claims for return to HHN.
     *  @param claimList
     *  @return List<ActivityOutlineSObjectWrapper> - List of claims ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformClaims(List<Claim> claimList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Claim claimRecord : claimList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = claimRecord.Id;
            soWrapper.createdDate = claimRecord.CreatedDate;
            soWrapper.lastModifiedDate = claimRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = claimRecord.LastModifiedBy.Name;
            soWrapper.status = claimRecord.Status;
            soWrapper.relatedTo = claimRecord.AccountId;
            soWrapper.customerName = claimRecord.Account.Name;
            soWrapper.sobjectType = String.valueOf(claimRecord.getSObjectType());

            String claimSubject = claimRecord.ClaimDescription__c;
            if(String.isBlank(claimSubject)) {
                claimSubject = '[No Subject]';
            }
            soWrapper.recordSubject = 'Claim: ' + claimRecord.Name + ' - ' + claimSubject;
            soWrapper.description =  claimRecord.Summary;
            soWrapper.assignedToName = claimRecord.Owner.Name;
            soWrapper.relatedEvents = transformEvents(claimRecord.Events);
            soWrapper.relatedTasks = transformTasks(claimRecord.Tasks);
            soWrapper.displayIconName = 'standard:partner_fund_claim';
            soWrapper.isClosed = claimRecord.IsClosed;

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedAccountNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedCaseNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedOpportunityNotes = new List<ActivityOutlineSObjectWrapper>();

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert events for return to HHN.
     *  @param eventList
     *  @return List<ActivityOutlineSObjectWrapper> - List of events ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformEvents(List<Event> eventList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Event eventRecord : eventList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = eventRecord.Id;
            soWrapper.createdDate = eventRecord.CreatedDate;
            soWrapper.lastModifiedDate = eventRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = eventRecord.LastModifiedBy.Name;
            soWrapper.status = null;
            if(eventRecord.WhoId != null){
                soWrapper.customer = eventRecord.whoId;
                soWrapper.customerName = eventRecord.Who.Name;
            }
            soWrapper.recordSubject = eventRecord.Subject;
            soWrapper.lob = eventRecord.LineofBusiness__c;
            if(eventRecord.What != null){
                soWrapper.relatedTo = eventRecord.What.Id;
                soWrapper.relatedToName = eventRecord.What.Name != null ? eventRecord.What.Name : soWrapper.recordSubject;
            }
            soWrapper.description = eventRecord.Description;
            soWrapper.isAllDayEvent = eventRecord.IsAllDayEvent;
            soWrapper.eventStartDateTime = eventRecord.StartDateTime;
            soWrapper.displayDate = eventRecord.StartDateTime;
            soWrapper.displayIconName = 'standard:event';
            if(soWrapper.IsAllDayEvent){
                soWrapper.displayDate = Datetime.newInstance(eventRecord.ActivityDate, Time.newInstance(0, 0, 0, 0));
            }

            soWrapper.sobjectType = String.valueOf(eventRecord.getSObjectType());
            soWrapper.assignedToName = eventRecord.AssignedTo__r.Name;
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert financial accounts for return to HHN.
     *  @param financialAccountList
     *  @return List<ActivityOutlineSObjectWrapper> - List of financial accounts ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformFinancialAccounts(List<FinServ__FinancialAccount__c> financialAccountList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(FinServ__FinancialAccount__c faRecord : financialAccountList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = faRecord.Id;
            soWrapper.createdDate = faRecord.CreatedDate;
            soWrapper.lastModifiedDate = faRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = faRecord.LastModifiedById; //This is the ID not the name, we might not have this field on FinancialAccount?
            //soWrapper.relatedTo = faRecord.NameInsuredId; //What should this be? We have the names but I don't know if we have IDs
            soWrapper.status = faRecord.FinServ__Status__c;
            //soWrapper.customerName = faRecord.FinancialAccountId__r.AgreDisplayPartyName__c;
            soWrapper.sobjectType = String.valueOf(faRecord.getSObjectType());

            String faSubject = faRecord.FinServ__Description__c;
            if(String.isBlank(faSubject)) {
                faSubject = '[No Description]';
            }
            soWrapper.recordSubject = faSubject; //Get feedback on how this should format
            soWrapper.description =  faSubject;
            //soWrapper.assignedToName = faRecord.FinancialAccountId__r.ServicingAgent__r.Name;
            soWrapper.relatedEvents = transformEvents(faRecord.Events); //Why are these causing an error? Stubbing for now
            soWrapper.relatedTasks = transformTasks(faRecord.Tasks); //..
            soWrapper.displayIconName = 'standard:work_plan';
            soWrapper.isClosed = faRecord.FinServ__Status__c == 'Terminated'; //Is this right?

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedAccountNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedCaseNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedOpportunityNotes = new List<ActivityOutlineSObjectWrapper>();

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert insurance policies for return to HHN.
     *  @param policyList
     *  @return List<ActivityOutlineSObjectWrapper> - List of insurance policies ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformInsurancePolicies(List<InsurancePolicy> policyList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(InsurancePolicy policyRecord : policyList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = policyRecord.Id;
            soWrapper.createdDate = policyRecord.CreatedDate;
            soWrapper.lastModifiedDate = policyRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = policyRecord.LastModifiedBy.Name;
            soWrapper.status = policyRecord.Status;
            soWrapper.relatedTo = policyRecord.NameInsuredId;
            soWrapper.customerName = policyRecord.Owner.Name;
            soWrapper.sobjectType = String.valueOf(policyRecord.getSObjectType());

            String policySubject = policyRecord.PolicyDescription;
            if(String.isBlank(policySubject)) {
                policySubject = '[No Description]';
            }
            soWrapper.recordSubject = policySubject + ' - ' + policyRecord.Name;
            soWrapper.description =  policySubject;
            soWrapper.assignedToName = policyRecord.Owner.Name; //Is this right or should it be servicing agent?
            soWrapper.relatedEvents = transformEvents(policyRecord.Events);
            soWrapper.relatedTasks = transformTasks(policyRecord.Tasks);
            soWrapper.displayIconName = 'standard:work_plan';
            soWrapper.isClosed = policyRecord.Status == 'Terminated'; //Is this right?

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedAccountNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedCaseNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedOpportunityNotes = new List<ActivityOutlineSObjectWrapper>();

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert Interaction Summaries for return to HHN.
     *  @param interactionSummaryList
     *  @return List<ActivityOutlineSObjectWrapper> - List of interaction summaries ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformInteractionSummaries(List<InteractionSummary__c> interactionSummaryList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
          for(InteractionSummary__c intRecord : interactionSummaryList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = intRecord.Id;
            soWrapper.createdDate =intRecord.createdDate;
            soWrapper.lastModifiedDate = intRecord.LastModifiedDate;
            soWrapper.relatedTo = intRecord.Customer__c;
            soWrapper.contactMethodName = intRecord.contact_method_name__c;
            soWrapper.interactionStartTime = intRecord.display_start_timestamp__c;
            soWrapper.interactionEndTime = intRecord.display_end_timestamp__c;
            soWrapper.sobjectType = String.valueOf(intRecord.getSObjectType());
            soWrapper.displayDate = intRecord.display_start_timestamp__c;
            soWrapper.lastModifiedByName = intRecord.LastModifiedBy.Name;
            soWrapper.enterpriseInteractionIdent = intRecord.enterprise_interaction_identifier__c;
            soWrapper.name = intRecord.name;
            soWrapper.displayIconName = 'custom:custom112';
            soWrapper.status = null;
            soWrapper.lob = null;
            soWrapper.recordSubject = intRecord.name;
            soWrapper.description = intRecord.name;
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert opportunities for return to HHN.
     *  @param opportunityList
     *  @return List<ActivityOutlineSObjectWrapper> - List of opportunities ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformOpportunities(List<Opportunity> opportunityList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Opportunity oppRecord : opportunityList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = oppRecord.Id;
            soWrapper.createdDate = oppRecord.CreatedDate;
            soWrapper.lastModifiedDate = oppRecord.LastModifiedDate;
            soWrapper.lastModifiedByName = oppRecord.LastModifiedBy.Name;
            soWrapper.oppStage = oppRecord.StageName;
            soWrapper.status = oppRecord.Status__c;
            soWrapper.relatedTo = oppRecord.AccountId;
            soWrapper.customerName = oppRecord.Account.Name;
            soWrapper.sobjectType = String.valueOf(oppRecord.getSObjectType());
            soWrapper.displayDate = oppRecord.CreatedDate;
            soWrapper.recordSubject = oppRecord.Name;
            String monthlyPremium = (oppRecord.Monthly_Premium__c == null) ? ' ' : '$'+oppRecord.Monthly_Premium__c.toPlainString();
            soWrapper.description =  'Total Contacts Made: ' + oppRecord.Total_Calls_Made__c
                                    + ' \n Monthly Premium:  ' + monthlyPremium;
            soWrapper.assignedToName = oppRecord.Assigned_To__r.Name;
            soWrapper.relatedEvents = transformEvents(oppRecord.Events);
            soWrapper.relatedTasks = transformTasks(oppRecord.Tasks);
            soWrapper.relatedOpportunityNotes = transformOpportunityNotes(oppRecord.Opportunity_Notes__r);
            soWrapper.displayIconName = 'standard:opportunity';
            soWrapper.isClosed = oppRecord.IsClosed;

            // Fill missing fields for support when displaying data from multiple HHN controllers.
            soWrapper.relatedAccountNotes = new List<ActivityOutlineSObjectWrapper>();
            soWrapper.relatedCaseNotes = new List<ActivityOutlineSObjectWrapper>();

            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert opp notes for return to HHN.
     *  @param opportunityNoteList
     *  @return List<ActivityOutlineSObjectWrapper> - List of opp notes ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformOpportunityNotes(List<Opportunity_Note__c> opportunityNoteList){
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Opportunity_Note__c cnRecord : opportunityNoteList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = cnRecord.Id;
            soWrapper.createdDate = cnRecord.CreatedDate;
            soWrapper.lastModifiedDate = cnRecord.LastModifiedDate;
            soWrapper.displayDate = cnRecord.createdDate;
            soWrapper.lastModifiedByName = cnRecord.LastModifiedBy.Name;
            soWrapper.status = null;
            soWrapper.customer = cnRecord.Opportunity__r.AccountId;
            soWrapper.recordSubject = cnRecord.Name;
            soWrapper.lob = null;
            soWrapper.relatedTo = cnRecord.Opportunity__r.AccountId;
            soWrapper.sobjectType = String.valueOf(cnRecord.getSObjectType());
            soWrapper.description = cnRecord.Comments__c;
            soWrapper.displayIconName = 'custom:custom62';
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert tasks for return to HHN.
     *  @param taskList
     *  @return List<ActivityOutlineSObjectWrapper> - List of tasks ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformTasks(List<Task> taskList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Task taskRecord : taskList){
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = taskRecord.Id;
            soWrapper.createdDate = taskRecord.CreatedDate;
            soWrapper.lastModifiedDate = taskRecord.LastModifiedDate;
            if(taskRecord.ActivityDate != null){
                soWrapper.displayDate = taskRecord.RecordTypeId == TaskHandlerConstants.TASK_DEFAULT_RECORD_TYPE_ID ? Datetime.newInstance(taskRecord.ActivityDate, Time.newInstance(0, 0, 0, 0)) : taskRecord.CreatedDate;
                soWrapper.dueDate = taskRecord.ActivityDate;
            } else {
                soWrapper.displayDate = taskRecord.CreatedDate;
                soWrapper.dueDate = null;
            }
            soWrapper.lastModifiedByName = taskRecord.LastModifiedBy.Name;
            soWrapper.status = taskRecord.Status;
            soWrapper.isClosed = taskRecord.isClosed;
            String recordSubject = taskRecord.Subject;
            soWrapper.recordSubject = recordSubject;
            handleWhatValues(taskRecord, soWrapper);
            handleWhoValues(taskRecord, soWrapper);
            soWrapper.description =  taskRecord.Description;
            soWrapper.completedDateTime = taskRecord.CompletedDateTime;
            soWrapper.createdById = taskRecord.CreatedById;

            if(taskRecord.RecordTypeId == HHNConstants.TASK_LOG_ID){
                soWrapper.sobjectType = 'log_a_call';
                soWrapper.displayIconName = 'standard:log_a_call';
                soWrapper.isLogRecord = true;
            }else{
                soWrapper.sobjectType = String.valueOf(taskRecord.getSObjectType());
                soWrapper.displayIconName = 'standard:task';
            }
            soWrapper.flagType = taskRecord.IsHighPriority ? 'HighPriority' : '';
            soWrapper.assignedToName = taskRecord.AssignedTo__r.Name;
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Convert virtual meetings for return to HHN.
     *  @param virtualMeetingParticipantList
     *  @return List<ActivityOutlineSObjectWrapper> - List of virtual meetings ready for display in HHN.
     */
    public static List<ActivityOutlineSObjectWrapper> transformVirtualMeetings(List<Virtual_Meeting_Participant__c> virtualMeetingParticipantList) {
        List<ActivityOutlineSObjectWrapper> sobjectList = new List<ActivityOutlineSObjectWrapper>();
        for(Virtual_Meeting_Participant__c virtualMeetingParticipant : virtualMeetingParticipantList){
            Virtual_Meeting__c vm = new Virtual_Meeting__c();
            vm = (Virtual_Meeting__c)virtualMeetingParticipant.getSObject('Virtual_Meeting__r');
            ActivityOutlineSObjectWrapper soWrapper = new ActivityOutlineSObjectWrapper();
            soWrapper.sobjectRecordId = vm.Id;
            soWrapper.createdDate = vm.CreatedDate;
            soWrapper.lastModifiedDate = vm.LastModifiedDate;
            soWrapper.lastModifiedByName = vm.LastModifiedBy.Name;
            soWrapper.status = vm.Status__c;
            // If customer field is required for use, you must update query to get the Account from Participant
            //soWrapper.customer = vm.AccountId__c;
            //soWrapper.relatedTo = vm.AccountId__c;
            soWrapper.recordSubject = vm.Name;
            soWrapper.lob = null;
            soWrapper.description =  'Meeting Host: ' + vm.Assigned_To__r.Name
                                    + ' <br/> Start Time:  ' + vm.Start_Time__c.format()
                                    + ' <br/> End Time:  ' + vm.End_Time__c.format();
            soWrapper.displayDate = vm.Start_Time__c;

            soWrapper.sobjectType = String.valueOf(vm.getSObjectType());
            soWrapper.assignedToName = vm.Assigned_To__r.Name;
            soWrapper.displayIconName = 'custom:custom71';
            sobjectList.add(soWrapper);
        }
        return sobjectList;
    }

    /**
     *  @description Get events related to the accounts passed in the list.
     *  @param accounts
     *  @param events
     *  @return Map<String, List<Event>> - Mapping of accountIds to events.
     */
    public static Map<String, List<Event>> addEventsToAccounts(List<Account> accounts, List<Event> events) {
        Map<String, List<Event>> accountEvents = new Map<String, List<Event>>();
        for (Account account : accounts) {
            List<Event> eventList = new List<Event>();
            addEventsForAccount(account, events, eventList);
            accountEvents.put(account.Id, eventList);
        }
        return accountEvents;
    }

    private static void addEventsForAccount(Account account, List<Event> events, List<Event> eventList) {
        for (Event event : events) {
            checkForDuplicates(event, eventList, account);
        }
    }

    /**
     *  @description Get tasks related to the accounts passed in the list.
     *  @param accounts
     *  @param tasks
     *  @return Map<String, List<Task>> - Mapping of accountIds to tasks.
     */
    public static Map<String, List<Task>> addTasksToAccounts(List<Account> accounts, List<Task> tasks) {
        Map<String, List<Task>> accountTasks = new Map<String, List<Task>>();
        for (Account account : accounts) {
            List<Task> taskList = new List<Task>();
            addTasksForAccount(account, tasks, taskList);
            accountTasks.put(account.Id, taskList);
        }
        return accountTasks;
    }

    private static void addTasksForAccount(Account account, List<Task> tasks, List<Task> taskList) {
        for (Task task : tasks) {
            checkForDuplicates(task, taskList, account);
        }
    }

    private static void checkForDuplicates(Task task, List<Task> taskList, Account account) {
        Boolean taskHasWhatId = task.What.Id != null;
        Boolean taskHasWhoId = task.WhoId != null;

        // Case 1: Task has RelatedTo (What) and has Name (Who) OR
        // Case 2: Task has RelatedTo (What) but has no Name (Who) OR
        if(taskHasWhatId && !EXCLUDED_OBJECTS.contains(task.What.Id.getSObjectType())) {
            checkTaskRelations(task,taskList, account);
        }

        // Case 3: Task has no RelatedTo (What) but has Name (Who)
        if(!taskHasWhatId && taskHasWhoId) {
            checkTaskRelations(task,taskList, account);
        }
    }

    private static void checkForDuplicates(Event event, List<Event> eventList, Account account) {
        Boolean eventHasWhatId = event.What.Id != null;
        Boolean eventHasWhoId = event.WhoId != null;

        // Case 1: Task has RelatedTo (What) and has Name (Who) OR
        // Case 2: Task has RelatedTo (What) but has no Name (Who) OR
        if(eventHasWhatId && !EXCLUDED_OBJECTS.contains(event.What.Id.getSObjectType())) {
            checkEventRelations(event, eventList, account);
        }

        // Case 3: Task has no RelatedTo (What) but has Name (Who)
        if(!eventHasWhatId && eventHasWhoId) {
            checkEventRelations(event, eventList, account);
        }
    }

    private static void checkEventRelations(Event event, List<Event> eventList, Account account) {
        for (EventRelation eventRelation : event.EventRelations) {
            if (!eventList.contains(event) && eventRelation.AccountId == account.Id) {
                eventList.add(event);
            }
        }
    }

    private static void checkTaskRelations(Task task, List<Task> taskList, Account account) {
        for (TaskRelation taskRelation : task.TaskRelations) {
            if (!taskList.contains(task) && taskRelation.AccountId == account.Id) {
                taskList.add(task);
            }
        }
    }

    private static void handleWhatValues(Task taskRecord, ActivityOutlineSObjectWrapper soWrapper) {
        if(taskRecord.What != null){
            soWrapper.relatedTo = taskRecord.What.Id;
            soWrapper.relatedToName = taskRecord.What.Name != null ? taskRecord.What.Name : taskRecord.Subject;
        }
    }

    private static void handleWhoValues(Task taskRecord, ActivityOutlineSObjectWrapper soWrapper) {
        if(taskRecord.Who != null){
            soWrapper.customerName = taskRecord.Who.Name;
        }
    }


}
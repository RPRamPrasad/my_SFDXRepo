/**
@author CustomerView
@owner Team Atlas
@name CCV_HouseholdStripHouseholdMembers
@createDate 01/28/2023
@ModifiedDate 
@description This class is used by LWC accountHouseholdMembers to fetch Household Members data on load
@version 1.0
*/
public with sharing class CCV_HouseholdStripHouseholdMembers {
    /**
    * @description This method is used to members data in household
    * @name : fetchHouseholdMembersDetails
    * @param hhRecordId : input record id
    * @return CCV_HouseholdMembersWrapper : output Household members wrapper
    */
    @AuraEnabled(cacheable = true)
    public static CCV_HouseholdMembersWrapper fetchHouseholdMembersDetails(String hhRecordId) {
        try {
            return fetchHouseholdMembersDetailsCallout(hhRecordId);
        } catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }
    }

    /**
    * @description This method is used to fetch members data in household with no cacheing
    * @name : fetchHouseholdMembersDetailsNoCache
    * @param hhRecordId : input record id
    * @return CCV_HouseholdMembersWrapper : output Household members wrapper
    */
    @AuraEnabled(cacheable = false)
    public static CCV_HouseholdMembersWrapper fetchHouseholdMembersDetailsNoCache(String hhRecordId) {
        try{
            return fetchHouseholdMembersDetailsCallout(hhRecordId);
        } catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }
    }

    private static CCV_HouseholdMembersWrapper fetchHouseholdMembersDetailsCallout(String hhRecordId) {
        try {
        Integer counter = 0;
        List<AccountContactRelation> lstACR = getHouseholdMembersDetails(hhRecordId);
        List<CCV_HouseholdMembersWrapper.HouseholdMemberWrap> groupMembers = new List<CCV_HouseholdMembersWrapper.HouseholdMemberWrap>();
        for(AccountContactRelation acr:lstACR){
            counter++;
            CCV_HouseholdMembersWrapper.HouseholdMemberWrap member = new CCV_HouseholdMembersWrapper.HouseholdMemberWrap();
            member.id = acr.Contact.AccountId;
            member.clientId = acr.Contact.ClientIdentifier__c;
            member.recordTypeName = acr.Contact.Account.RecordType.Name;
            member.primary = acr.FinServ__Primary__c;
            member.roles = acr.Roles;
            member.memberName = memberName(acr);
            member.memberContact = memberContact(acr);
            member.memberMailingAddress = memberMailingAddress(acr);
            member.memberDate = memberDate(acr);
            member.memberCompliance = memberCompliance(acr);
            groupMembers.add(member);
            if(acr.FinServ__Primary__c == true) {
                //groupMembers.remove(counter-1);
                groupMembers.add(0,member);
            }
        }
        CCV_HouseholdMembersWrapper groupJson= new CCV_HouseholdMembersWrapper();
        groupJson.count = String.valueOf(counter);
            groupJson.members = new List<CCV_HouseholdMembersWrapper.HouseholdMemberWrap>(new Set<CCV_HouseholdMembersWrapper.HouseholdMemberWrap>(groupMembers));
        return groupJson;
        }
        catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }

    }
    
    private static List<AccountContactRelation> getHouseholdMembersDetails(String hhRecordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhRecordId, Account.class);
        return Security.stripInaccessible(
                AccessType.READABLE,
                [ 
                    SELECT Id, AccountId, ContactId, FinServ__Primary__c, Roles, Contact.AccountId, Contact.ClientIdentifier__c,
                    Contact.name, Contact.Account.PreferredFirstName__c, Contact.MobilePhone, Contact.DoNotCall, 
                    Contact.Email, Contact.Account.HasPermissionToMarketingEmail__c, Contact.Account.HasPermissionToServiceText__c,
                    Contact.Account.BillingStreet, Contact.Account.BillingCity, Contact.Account.BillingState, 
                    Contact.Account.BillingPostalCode, Contact.Account.BillingCountry, Contact.Account.DoNotMail__c, Contact.Gender__c,
                    Contact.Birthdate, Contact.Account.Age__c, Contact.IsDeathNotificationReceived__c, Contact.DeathDate__c,
                    Contact.PreferredSpokenLanguage__c, Contact.IsNotShareable__c, Contact.Account.IsProtectedPerson__c,
                    Contact.Account.IsSubjecttoCASL__c, Contact.IsHealthSourced__c, Contact.Account.RecordType.Name
		            FROM AccountContactRelation  
                    WHERE AccountId = :String.escapeSingleQuotes(hhRecordId) 
                    AND IsActive = true 
                    AND FinServ__PrimaryGroup__c = true
                    ORDER BY Contact.name ASC
                ]
            )
            .getRecords();
    }

    private static CCV_HouseholdMembersWrapper.MemberName memberName(AccountContactRelation acr){
        CCV_HouseholdMembersWrapper.MemberName memberName = new CCV_HouseholdMembersWrapper.MemberName();
        memberName.name = acr.Contact.Name;
        memberName.url = '/one/one.app#/sObject/'+acr.Contact.AccountId;
        memberName.preferredName = acr.Contact.Account.PreferredFirstName__c;
        //memberName.gender = acr.Contact.Gender__c; DNS field access/visibility depend on Business discussion 
        memberName.language = acr.Contact.PreferredSpokenLanguage__c;
        return memberName;
    }

    private static CCV_HouseholdMembersWrapper.MemberContact memberContact(AccountContactRelation acr){
        CCV_HouseholdMembersWrapper.MemberContact memberContact = new CCV_HouseholdMembersWrapper.MemberContact();
        memberContact.mobilePhone = acr.Contact.MobilePhone;
       	memberContact.doNotCall = acr.Contact.DoNotCall;
        memberContact.smsUrl = setSMSUrl(acr);
        memberContact.doNotText = acr.Contact.Account.HasPermissionToServiceText__c == 'No'? true : false;
        memberContact.email = acr.Contact.Email;
        memberContact.doNotEmail = acr.Contact.Account.HasPermissionToMarketingEmail__c == 'No'? true : false;
        return memberContact;
    }
    private static CCV_HouseholdMembersWrapper.MemberMailingAddress memberMailingAddress(AccountContactRelation acr){
        CCV_HouseholdMembersWrapper.MemberMailingAddress memberMailingAddress = new CCV_HouseholdMembersWrapper.MemberMailingAddress();
        memberMailingAddress.address = formatAddressIntoLine(acr);
        memberMailingAddress.doNotMail = acr.Contact.Account.DoNotMail__c;
        return memberMailingAddress;
    }
    private static CCV_HouseholdMembersWrapper.MemberDate memberDate(AccountContactRelation acr){
        CCV_HouseholdMembersWrapper.MemberDate memberDate = new CCV_HouseholdMembersWrapper.MemberDate();
        memberDate.birthDate = acr.Contact.Birthdate;
        memberDate.age = String.valueOf(acr.Contact.Account.Age__c);
        memberDate.deceased = acr.Contact.IsDeathNotificationReceived__c;
        memberDate.deceasedDate = acr.Contact.DeathDate__c;
        return memberDate;
    }
    private static CCV_HouseholdMembersWrapper.MemberCompliance memberCompliance(AccountContactRelation acr){
        CCV_HouseholdMembersWrapper.MemberCompliance memberCompliance = new CCV_HouseholdMembersWrapper.MemberCompliance();
        memberCompliance.doNotShare = acr.Contact.IsNotShareable__c;
        memberCompliance.protectedPerson = acr.Contact.Account.IsProtectedPerson__c;
        memberCompliance.subjectToCasl = acr.Contact.Account.IsSubjecttoCASL__c == 'Yes'? true : false;
        memberCompliance.healthSourced = acr.Contact.IsHealthSourced__c;
        return memberCompliance;
    }

    private static String setSMSUrl(AccountContactRelation acr){
        String url;
        if(String.isNotEmpty(acr.Contact.MobilePhone)){
            url = '/c/ExternalLinkApp.app?linkId=52&accountId='+acr.Contact.AccountId
                +'firstTextableMobilePhone='+acr.Contact.MobilePhone;
        }
        return url;
    }
    
    private static String formatAddressIntoLine(AccountContactRelation acr){
        String street = acr.Contact.Account.BillingStreet.replace('\n',' ');
        String city = acr.Contact.Account.BillingCity; 
        String state = acr.Contact.Account.BillingState;
        String zip = acr.Contact.Account.BillingPostalCode; 
        String country = acr.Contact.Account.BillingCountry.trim().toUpperCase();
        return street.normalizeSpace() + '\n' +city + ' ' +state + ' ' +zip + '\n' +country;
    }
}
/**
@author CustomerView
@owner Team Atlas
@name CCV_HouseholdMembersWrapper
@createDate 06/23/2023
@ModifiedDate 
@description The wrapper class is used to store data for Household members and make member Wrapper JSON
@version 1.0
*/

public with sharing class CCV_HouseholdMembersWrapper {

    /**
    * @description count
    */
    @AuraEnabled
    public String count;
    /**
    * @description HouseholdMemberWrapper
    */
    @AuraEnabled
    public List<HouseholdMemberWrap> members;

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : memberName
    */
    public with sharing class MemberName {
        /**
        * @description name
        */
        @AuraEnabled
        public String name {get;set;}
        /**
        * @description url
        */
        @AuraEnabled
        public String url {get;set;}
        /**
        * @description preferredName
        */
        @AuraEnabled
        public String preferredName {get;set;}
        /**
        * @description language
        */
        @AuraEnabled
        public String language {get;set;}
    }

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : memberContact
    */
    public with sharing class MemberContact {
        /**
        * @description mobilePhone
        */
        @AuraEnabled
        public String mobilePhone {get;set;}
        /**
        * @description doNotCall
        */
        @AuraEnabled
        public Boolean doNotCall {get;set;}
        /**
        * @description smsUrl
        */
        @AuraEnabled
        public String smsUrl {get;set;}
        /**
        * @description doNotText
        */
        @AuraEnabled
        public Boolean doNotText {get;set;}
        /**
        * @description email
        */
        @AuraEnabled
        public String email {get;set;}
        /**
        * @description doNotEmail
        */
        @AuraEnabled
        public Boolean doNotEmail {get;set;}
    }

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : memberMailingAddress
    */
    public with sharing class MemberMailingAddress {
        /**
        * @description address
        */
        @AuraEnabled
        public String address {get;set;}
        /**
        * @description doNotMail
        */
        @AuraEnabled
        public Boolean doNotMail {get;set;}
    }

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : memberDate
    */
    public with sharing class MemberDate {
        /**
        * @description birthDate
        */
        @AuraEnabled
        public Date birthDate {get;set;}
        /**
        * @description age
        */
        @AuraEnabled
        public String age {get;set;}
        /**
        * @description deceased
        */
        @AuraEnabled
        public Boolean deceased {get;set;}
        /**
        * @description deceasedDate
        */
        @AuraEnabled
        public Date deceasedDate {get;set;}
    }

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : MemberCompliance
    */
    public with sharing class MemberCompliance {
        /**
        * @description doNotShare
        */
        @AuraEnabled
        public Boolean doNotShare {get;set;}
        /**
        * @description protectedPerson
        */
        @AuraEnabled
        public Boolean protectedPerson {get;set;}
        /**
        * @description subjectToCasl
        */
        @AuraEnabled
        public Boolean subjectToCasl {get;set;}
        /**
        * @description healthSourced
        */
        @AuraEnabled
        public Boolean healthSourced {get;set;}
    }

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : HouseholdMemberWrapper
    */
    public with sharing class HouseholdMemberWrap {
        /**
        * @description id
        */
        @AuraEnabled
        public String id {get;set;}
        /**
        * @description clientId
        */
        @AuraEnabled 
        public String clientId {get;set;}
        /**
        * @description recordTypeName
        */
        @AuraEnabled
        public String recordTypeName {get;set;}
        /**
        * @description recordTypeName
        */
        @AuraEnabled
        public Boolean primary {get;set;}
        /**
        * @description recordTypeName
        */
        @AuraEnabled
        public String roles {get;set;}
        /**
        * @description memberName
        */
        @AuraEnabled
        public MemberName memberName;
        /**
        * @description memberContact
        */
        @AuraEnabled
        public MemberContact memberContact;
        /**
        * @description memberMailingAddress
        */
        @AuraEnabled
        public MemberMailingAddress memberMailingAddress;
        /**
        * @description memberDate
        */
        @AuraEnabled
        public MemberDate memberDate;
        /**
        * @description memberCompliance
        */
        @AuraEnabled
        public MemberCompliance memberCompliance;
    }
}
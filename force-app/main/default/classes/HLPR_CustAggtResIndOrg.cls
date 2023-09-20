/**
 * @name HLPR_CustAggtResIndOrg
 * @description This is a helper class to build customer record with the values received from customer aggregator JSON response
 * @author Team: Stark
 * @createdDate 03/07/2021
 * @modifiedDate 03/07/2021
 */

public with sharing class HLPR_CustAggtResIndOrg {
    
    @TestVisible public static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    private static final String OVERSEAS_MILITARY = 'Overseas Military';
    private static final String US = 'US';
    private static final String UNITED_STATES = 'UNITED STATES';
    private static final String CANADA = 'Canada';
    private static final String FOREIGN = 'Foreign';
    private static final String LINE_BREAK = '\n';
    
    /**
     * @name populateResponseData
     * @description Populate response data values received from customer aggregator response
     * @param customer
     * @param custAggtRes
     */
    public static void populateResponseData(Account customer, AP_CustAggtRes custAggtRes) {
        if(UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME.equalsIgnoreCase(custAggtRes.data.attributes.customerType)) {
            populateIndividualData(customer, custAggtRes);     
            populateMailingAddress(customer, custAggtRes, true);
        }
        else {
            populateOrganizationData(customer, custAggtRes); 
            populateMailingAddress(customer, custAggtRes, false);   
        }
    }

    private static void populateIndividualData(Account customer, AP_CustAggtRes custAggtRes) {
        customer.Salutation = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.individualName.prefix));
        customer.FirstName = custAggtRes.data.attributes.individualCustomer.individualName.firstName;
        customer.MiddleName = custAggtRes.data.attributes.individualCustomer.individualName.middleName;
        customer.LastName = custAggtRes.data.attributes.individualCustomer.individualName.lastName;
        customer.Suffix = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.individualName.suffix));
        customer.Designation__pc = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.individualName.designation));
        customer.PersonBirthdate = Date.valueOf(UTIL_OrchestrationDataTransformation.jsonToDate(custAggtRes.data.attributes.individualCustomer.dateOfBirth));
        customer.DeathDate__pc = Date.valueOf(UTIL_OrchestrationDataTransformation.jsonToDate(custAggtRes.data.attributes.individualCustomer.dateOfDeath));
        customer.IsDeathNotificationReceived__pc = Boolean.valueOf(UTIL_OrchestrationDataTransformation.jsonToCheckbox(custAggtRes.data.attributes.individualCustomer.deathNotificationReceived));
        customer.Citizenship__pc = custAggtRes.data.attributes.individualCustomer.citizenship;
        customer.Gender__pc = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.gender));
        customer.IsHearingImpaired__pc = Boolean.valueOf(UTIL_OrchestrationDataTransformation.jsonToCheckbox(custAggtRes.data.attributes.individualCustomer.hearingImpaired));
        customer.MaritalStatus__pc = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.maritalStatus));
        customer.SSN__pc = custAggtRes.data.attributes.individualCustomer.taxIdentificationNumber;
        customer.PreferredFirstName__c = custAggtRes.data.attributes.individualCustomer.preferredFirstName;
        customer.PersonMobilePhone = custAggtRes.data.attributes.individualCustomer.mobilePhoneNumber;
        customer.Phone = custAggtRes.data.attributes.individualCustomer.workPhoneNumber;
        customer.WorkPhoneExtension__c = custAggtRes.data.attributes.individualCustomer.workPhoneExtension;
        customer.PersonHomePhone = custAggtRes.data.attributes.individualCustomer.homePhoneNumber;
        customer.TDDPhone__c = custAggtRes.data.attributes.individualCustomer.tddPhoneNumber;
        customer.EmployerName__pc = custAggtRes.data.attributes.individualCustomer.employerName;
        customer.OccupationCategory__pc = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.occupation));
        customer.OccupationStartDate__pc = Date.valueOf(UTIL_OrchestrationDataTransformation.jsonToDate(custAggtRes.data.attributes.individualCustomer.occupationStartDate));
        if(Date.newInstance(1700, 01, 01) == customer.OccupationStartDate__pc) {
            customer.OccupationStartDate__pc = null;
        }
        customer.OccupationStatus__pc = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.occupationStatus));
        customer.Occupation__pc = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.jobTitle));
		if(toggleContext.isNotActive(UTIL_Toggles.ADDLBUSINESSDATAFIELDS)){
			customer.BusinessOwnerIndicator__c = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.businessOwnerIndicator));
		}
        if(custAggtRes.data.attributes.individualCustomer.driversLicense!=null) {
            customer.DriversLicenseStateProvince__c = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.individualCustomer.driversLicense.state));
            customer.DriversLicenseNumber__c = custAggtRes.data.attributes.individualCustomer.driversLicense.dlNumber;  
        }
        else {
            customer.DriversLicenseStateProvince__c = null;
            customer.DriversLicenseNumber__c = null;        
        }
    }

    private static void populateOrganizationData(Account customer, AP_CustAggtRes custAggtRes) {
        customer.LastName = custAggtRes.data.attributes.organizationCustomer.organizationName;
         if(customer.LastName.length() > 80){
             customer.LastName = custAggtRes.data.attributes.organizationCustomer.organizationName.subString(0,80);
         }
         customer.Type = String.valueOf(UTIL_OrchestrationDataTransformation.jsonToPicklist(custAggtRes.data.attributes.organizationCustomer.organizationType));
         if(toggleContext.isNotActive(UTIL_Toggles.ADDLBUSINESSDATAFIELDS)){
             customer.Industry = String.valueOf(custAggtRes.data.attributes.organizationCustomer.industry);
             if(!String.isEmpty(custAggtRes.data.attributes.organizationCustomer.revenueAmount)){
                 customer.AnnualRevenue = Decimal.valueOf(custAggtRes.data.attributes.organizationCustomer.revenueAmount);
             }
         }
         customer.TIN__c = custAggtRes.data.attributes.organizationCustomer.taxIdentificationNumber;
         /**added for Tax Id Type response from Aggrt dated 01/13/2022 */
         customer.TIN_Type__c = custAggtRes.data.attributes.organizationCustomer.taxIdType;
         customer.PersonMobilePhone = custAggtRes.data.attributes.organizationCustomer.mobilePhoneNumber;
         customer.Phone = custAggtRes.data.attributes.organizationCustomer.workPhoneNumber;
         customer.WorkPhoneExtension__c = custAggtRes.data.attributes.organizationCustomer.workPhoneExtension;
         customer.Fax = custAggtRes.data.attributes.organizationCustomer.faxPhoneNumber;
         customer.TDDPhone__c = custAggtRes.data.attributes.organizationCustomer.tddPhoneNumber; 
     }

    /**
     * @description Populate Mailing Address
     * @param customer
     * @param custAggtRes
     * @param isIndividual
     */
     private static void populateMailingAddress(Account customer, AP_CustAggtRes custAggtRes, Boolean isIndividual) {
        if(isIndividual) {
            customer.MailingInCareOf__c = custAggtRes.data.attributes.mailingAddress.preAddress;    
        }
        else {
            customer.MailingAttention__c = custAggtRes.data.attributes.mailingAddress.preAddress;   
        }
        customer.BillingAddressType__c = custAggtRes.data.attributes.mailingAddress.addressType;
        customer.BillingCountry = custAggtRes.data.attributes.mailingAddress.country;
        if(OVERSEAS_MILITARY.equalsIgnoreCase(customer.BillingAddressType__c)) {
            customer.BillingAddressType__c = OVERSEAS_MILITARY; 
            customer.BillingCountry = UNITED_STATES;
        }
        else if(US.equalsIgnoreCase(customer.BillingAddressType__c)) {
            customer.BillingCountry = UNITED_STATES;
        }
        else if(CANADA.equalsIgnoreCase(customer.BillingAddressType__c)) {
            customer.BillingCountry = CANADA.toUpperCase();
        }
        populateBillingStreets(customer, custAggtRes);
        customer.BillingCity = custAggtRes.data.attributes.mailingAddress.city;

        customer.BillingPostalCode = custAggtRes.data.attributes.mailingAddress.postalCode;
        customer.BillingState = custAggtRes.data.attributes.mailingAddress.state;   
    }
    
    private static void populateBillingStreets(Account customer, AP_CustAggtRes custAggtRes) {
        customer.BillingStreet = custAggtRes.data.attributes.mailingAddress.street1;
        String billingStreet2 = custAggtRes.data.attributes.mailingAddress.street2;
        String billingStreet3 = custAggtRes.data.attributes.mailingAddress.street3;
        if(!String.isBlank(billingStreet2)) {
            if(String.isBlank(customer.BillingStreet)) {
                customer.BillingStreet = billingStreet2;
            }
            else {
                customer.BillingStreet += LINE_BREAK + billingStreet2;
            }
        }
        if(!String.isBlank(billingStreet3) && FOREIGN.equals(customer.BillingAddressType__c)) {
            if(String.isBlank(customer.BillingStreet)) {
                customer.BillingStreet = billingStreet3;
            }
            else {
                customer.BillingStreet += LINE_BREAK + billingStreet3;
            }
        }
    }
}

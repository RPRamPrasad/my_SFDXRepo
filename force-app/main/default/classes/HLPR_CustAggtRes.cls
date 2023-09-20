/****************************************************************************************
Name: HLPR_CustAggtRes
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description This is a helper class to build customer record with the values received from customer aggregator JSON response

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo		         10/23/2017             R4 Major Release
******************************************************************************************/
public with sharing class HLPR_CustAggtRes {

    private static final String OVERSEAS_MILITARY = 'Overseas Military';
    private static final String US = 'US';
    private static final String UNITED_STATES = 'UNITED STATES';
    private static final String CANADA = 'Canada';
    private static final String FOREIGN = 'Foreign';
    private static final String LINE_BREAK = '\n';
    private static final String CUSTOMER_TEXT = 'Customer';
    private static final String EX_CUSTOMER_TEXT = 'Ex-Customer';
    private static final String CLIENT = 'Client';
    private static final String EX_CLIENT = 'Ex-Client';
    private static final String PROSPECT = 'Prospect';
    private static final String TILDE = '~';
    private static final String UNDERSCORE = '_';
    private static final String PRIMARY = 'Primary';

    /**
     * @name buildCustomerFromAggtRes
     * @description Populate account values with the values received from customer aggregator response
     * @param customer
     * @param custAggtRes
     * @return Account
     */
    public static Account buildCustomerFromAggtRes(Account customer, AP_CustAggtRes custAggtRes) {
        customer.ClientIdentifier__c = custAggtRes.data.clientId;
        customer.PersonEmail = custAggtRes.data.attributes.emailAddress;
        customer.HasConfirmedNoEmail__c = Boolean.valueOf(UTIL_OrchestrationDataTransformation.jsonToCheckbox(custAggtRes.data.attributes.doesNotHaveEmail));
        customer.PersonEmailBouncedReason__c = custAggtRes.data.attributes.emailUndeliverableReason;
        customer.TextBouncedReason__c = custAggtRes.data.attributes.textUndeliverableIndicator;
        HLPR_CustAggtResIndOrg.populateResponseData(customer, custAggtRes);
        if(custAggtRes.data.attributes.residenceAddress!=null) {
            populateResidenceAddress(customer, custAggtRes);
        }
        else {
            emptyResidenceAddress(customer);
        }
        emptyPreferences(customer);
        if(custAggtRes.data.attributes.preferences!=null && !custAggtRes.data.attributes.preferences.isEmpty()) {
            HLPR_CustAggtResIndOrgPreferences.populatePreferences(customer, custAggtRes);
        }
        customer.ExternalSourceSyncTime__c = System.now();
        return customer;
    }


    /**
     * @description HLPR Cust Aggt Res Wrapper
     */
    public class HLPR_CustAggtResWrapper{
        public AP_CustAggtRes custAggtRes;
        public String selectedReason;
        public boolean isUpdateAfterSearch;
        public String agentAssociateId;
    }

    /**
     * @name buildAgentRolesFromAggtRes
     * @description Populate agent role values with the values received from customer aggregator response
     * @param hlprWrap
     * @return List<AgentRole__c>
     */
    public static List<AgentRole__c> buildAgentRolesFromAggtRes(HLPR_CustAggtResWrapper hlprWrap) {

        AP_CustAggtRes custAggtRes = hlprWrap.custAggtRes;
        String selectedReason = hlprWrap.selectedReason;
        boolean isUpdateAfterSearch = hlprWrap.isUpdateAfterSearch;
        String agentAssociateId = hlprWrap.agentAssociateId;

        List<AgentRole__c> agentRoles = new List<AgentRole__c>();
        if(custAggtRes.data.relationships != null && custAggtRes.data.relationships.agents != null && custAggtRes.data.relationships.agents.data != null){
            for(AP_CustAggtRes.cls_agentRoleData agentRoleData : custAggtRes.data.relationships.agents.data) {
                AgentRole__c agentRole = new AgentRole__c();
                agentRole.Customer__r = new Account(ClientIdentifier__c = custAggtRes.data.clientId);
                agentRole.Agent__r = new User(UserExternalID__c = agentRoleData.Id.trim()+UNDERSCORE+agentRoleData.Id.trim());
                agentRole.AgentRoleIdentifier__c = agentRoleData.id + TILDE + custAggtRes.data.clientId;
                agentRole.RelationshipStartDate__c=agentRoleData.attributes.relationshipStartDate;
                agentRoleConditions(agentRole,agentRoleData);
                if(isUpdateAfterSearch && agentRoleData.Id.equalsIgnoreCase(agentAssociateId)) {
                    agentRole.RelationshipReason__c = selectedReason;
                }
                agentRoles.add(agentRole);
            }
        }
        return agentRoles;
    }

    /**
     * @name buildCustomerGroupsFromAggtRes
     * @description Populate customer group values with the values received from customer aggregator response
     * @param custAggtRes
     * @return List<CustomerGroup__c>
     */
    public static List<CustomerGroup__c> buildCustomerGroupsFromAggtRes(AP_CustAggtRes custAggtRes) {
        List<CustomerGroup__c> customerGroups = new List<CustomerGroup__c>();
        if(custAggtRes.data.relationships != null && custAggtRes.data.relationships.agents != null && custAggtRes.data.relationships.agents.data != null){
            for(AP_CustAggtRes.cls_agentRoleData agentRoleData : custAggtRes.data.relationships.agents.data) {
                if(String.isNotBlank(agentRoleData.groupId)) {
	                CustomerGroup__c customerGroup = new CustomerGroup__c();
	                customerGroup.SFGroupIdentifier__c = agentRoleData.groupId;
	                customerGroup.GroupCategory__c = UTIL_CreateCustomerConstants.PRIMARY;
	                customerGroup.Agent__r = new User(UserExternalID__c = agentRoleData.Id.trim()+UNDERSCORE+agentRoleData.Id.trim());
	                customerGroups.add(customerGroup);
                }
            }
        }
        return customerGroups;
    }

    /**
     * @name buildCustomerGroupMembers
     * @description Populate customer group member values with the values received from customer aggregator response
     * @param customerGroups
     * @param clientId
     * @return List<CustomerGroupMember__c>
     */
    public static List<CustomerGroupMember__c> buildCustomerGroupMembers(List<CustomerGroup__c> customerGroups , String clientId) {
    	List<CustomerGroupMember__c> customerGroupMembers = new List<CustomerGroupMember__c>();
    	for(CustomerGroup__c customerGroup : customerGroups) {
    		CustomerGroupMember__c	customerGroupMember = new CustomerGroupMember__c();
    		customerGroupMember.GroupMemberId__c = customerGroup.SFGroupIdentifier__c + TILDE + clientId;
    		customerGroupMember.MemberRoleCd__c = UTIL_CreateCustomerConstants.PRIMARY;
    		customerGroupMember.Group__r = new CustomerGroup__c(SFGroupIdentifier__c = customerGroup.SFGroupIdentifier__c);
    		customerGroupMember.Customer__r = new Account(ClientIdentifier__c = clientId);
    		customerGroupMembers.add(customerGroupMember);
    	}
    	return customerGroupMembers;
    }

    private static void agentRoleConditions(AgentRole__c agentRole, AP_CustAggtRes.cls_agentRoleData agentRoleData) {
        if(agentRoleData.attributes.relationshipNature.equalsIgnoreCase(CLIENT)){
            agentRole.RelationshipNature__c = CUSTOMER_TEXT;
        }
        else if(agentRoleData.attributes.relationshipNature.equalsIgnoreCase(EX_CLIENT)) {
            agentRole.RelationshipNature__c = EX_CUSTOMER_TEXT;
        }
        else {
            agentRole.RelationshipNature__c = PROSPECT;
        }
    }

    private static void populateResidenceAddress(Account customer, AP_CustAggtRes custAggtRes) {
        customer.ShippingAddressType__c = custAggtRes.data.attributes.residenceAddress.addressType;
        customer.ShippingCountry = custAggtRes.data.attributes.residenceAddress.country;
        if(OVERSEAS_MILITARY.equalsIgnoreCase(customer.ShippingAddressType__c)) {
            customer.ShippingAddressType__c = OVERSEAS_MILITARY;
            customer.ShippingCountry = UNITED_STATES;
        }
        else if(US.equalsIgnoreCase(customer.ShippingAddressType__c)) {
            customer.ShippingCountry = UNITED_STATES;
        }
        else if(CANADA.equalsIgnoreCase(customer.ShippingAddressType__c)) {
            customer.ShippingCountry = CANADA.toUpperCase();
        }
        populateShippingStreets(customer, custAggtRes);
        customer.ShippingCity = custAggtRes.data.attributes.residenceAddress.city;
        customer.ShippingPostalCode = custAggtRes.data.attributes.residenceAddress.postalCode;
        customer.ShippingState = custAggtRes.data.attributes.residenceAddress.state;
    }

    private static void populateShippingStreets(Account customer, AP_CustAggtRes custAggtRes) {
        customer.ShippingStreet = custAggtRes.data.attributes.residenceAddress.street1;
        String shippingStreet2 = custAggtRes.data.attributes.residenceAddress.street2;
        String shippingStreet3 = custAggtRes.data.attributes.residenceAddress.street3;
        if(!String.isBlank(shippingStreet2)) {
            if(String.isBlank(customer.ShippingStreet)) {
                customer.ShippingStreet = shippingStreet2;
            }
            else {
                customer.ShippingStreet += LINE_BREAK + shippingStreet2;
            }
        }
        if(!String.isBlank(shippingStreet3) && FOREIGN.equals(customer.ShippingAddressType__c )) {
            if(String.isBlank(customer.ShippingStreet)) {
                customer.ShippingStreet = shippingStreet3;
            }
            else {
                customer.ShippingStreet += LINE_BREAK + shippingStreet3;
            }
        }
    }

    private static void emptyResidenceAddress(Account customer) {
        customer.ShippingAddressType__c = null;
        customer.ShippingCountry = null;
        customer.ShippingStreet = null;
        customer.ShippingCity = null;
        customer.ShippingPostalCode = null;
        customer.ShippingState = null;
    }

    private static void emptyPreferences(Account customer) {
        customer.IsProtectedPerson__c = false;
        customer.IsSubjecttoCASL__c = null;
        customer.PaperlessPrivacyNotice__c = null;
        customer.DoNotMail__c = false;
        customer.PersonDoNotCall = false;
        customer.PreferredSpokenLanguage__pc = null;
        customer.HasPermissionToServiceText__c = null;
        customer.IsPrivacyOptionsShared__c = false;
        customer.IsNotShareable__pc = false;
        customer.HasPermissionToClaimText__c = null;
        customer.HasPermissionToMarketingEmail__c = null;
        customer.HasPermissionToServiceEmail__c = null;
        customer.HasPermissionToClaimEmail__c = null;
        customer.Billing_Statements__c = null;
        customer.Policy_Notices_Email__c = null;
        customer.Policy_Notices_Text__c = null;
        customer.SFPPBillRemindersEmail__c = null;
        customer.PolicyDocuments__c = null;
        customer.IsHealthSourced__pc = false;
    }

}
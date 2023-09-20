/**
@author Team Atlas
@owner Team Atlas
@name UTIL_HouseholdManageAddress_Addtl
@CreateDate 11/11/2022
@modifiedDate 
@description This class is used as an additional non auraEnabled to parent UTIL_HouseholdManageAddress
@version 1.0
*/
public with sharing class UTIL_HouseholdManageAddress_Addtl {
    /**
    * @description This method used to create case and task for members
    * @name : createCasesAndTasksForMembers
    * @param caseAndTaskJson : input account json
    */
    public static void createCasesAndTasksForMembers(String caseAndTaskJson) {
        List<Id> sfdcIds = new List<Id>();
        Map<Id,String> idToDescriptionMap = new Map<Id,String>();
        CaseAddressWrapper wrapper = (CaseAddressWrapper) JSON.deserialize(caseAndTaskJson, CaseAddressWrapper.class);
        for(MembersWrapper member:wrapper.successMembers) {
            String description = descriptionForAddress(member.oldAddress,wrapper.newAddress);
            idToDescriptionMap.put(member.sfdcId,description);
            sfdcIds.add(member.sfdcId);
        }
        UTIL_HouseholdChangeofAddressProcess.assignedCasesAndTasksForMembers(sfdcIds, idToDescriptionMap);
    }

    /**
    * @description This method is used to set description field for case
    * @name : descriptionForAddress
    * @param oldAddress : old address
    * @param newAddress : new address
    * @return String  change description
    */
    private static String descriptionForAddress(AddressWrapper oldAddress, AddressWrapper newAddress) {
        String changeDescription = UTIL_Constants.NO_SPACE;
        Boolean changed = valueChanged(newAddress.city, oldAddress.city) 
                       || valueChanged(newAddress.state, oldAddress.state) 
                       || valueChanged(validateUSZipCode(newAddress.zipCode,newAddress.country), validateUSZipCode(oldAddress.zipCode,oldAddress.country)) 
                       || valueChanged(validateCountry(newAddress.country), validateCountry(oldAddress.country)) 
                       || valueChanged(newAddress.street1, oldAddress.street1) 
                       || valueChanged(newAddress.street2, oldAddress.street2) 
                       || valueChanged(newAddress.street3, oldAddress.street3);

        if(changed) {
            Map<String,String> oldAddressJSON = new Map<String,String>{
                'label'=>'Old Mailing','street1'=>oldAddress.street1,
                'street2'=>oldAddress.street2, 'street3'=>oldAddress.street3,
                'city'=>oldAddress.city,'state'=>oldAddress.state,
                'zipCode'=>oldAddress.zipCode,'country'=>oldAddress.country
            };

            Map<String,String> newAddressJSON = new Map<String,String>{
                'label'=>'New Mailing','street1'=>newAddress.street1,
                'street2'=>newAddress.street2, 'street3'=>newAddress.street3,
                'city'=>newAddress.city,'state'=>newAddress.state,
                'zipCode'=>newAddress.zipCode,'country'=>newAddress.country
            };
        changeDescription = appendToChangeDescription(JSON.serialize(oldAddressJSON),changeDescription);
        changeDescription = appendToChangeDescription(JSON.serialize(newAddressJSON),changeDescription);
        }
        return changeDescription;
    }

    private static String appendToChangeDescription(String addressJSON, String changeDescription) {
        String tempDesc = changeDescription;
        AddressWrapper addressData = (AddressWrapper) JSON.deserializeStrict(addressJSON,AddressWrapper.class);
        String street = addressData.street1 +' '+ addressData.street2 +' '+ addressData.street3;
        street = String.isBlank(street) ? '' : street.normalizeSpace();
        if (String.isEmpty(tempDesc)) {
            tempDesc += 'An address change has been made on this account.\r\n';
        }
        tempDesc += '\r\n' + addressData.label + ' Address:\r\n\t';
        tempDesc += emptyOrValue(street) + '\r\n\t';
        tempDesc += emptyOrValue(addressData.city) + UTIL_Constants.COMMA_WITH_SPACE;
        tempDesc += emptyOrValue(addressData.state) + UTIL_Constants.SPACE_SYMBOL;
        tempDesc += validatePostalCode(addressData.zipCode,addressData.country) + '\r\n\t';
        tempDesc += emptyOrValue(validateCountry(addressData.country)) + '\r\n';
        return tempDesc;
    }

    private static String validateUSZipCode(String postalCode, String country ) {
        if (String.isNotBlank(postalCode) && postalCode.length() > 5 
            && String.isNotBlank(country)
            && (country.trim().equals('US') || country.trim().equals('USA') || country.trim().equalsIgnoreCase('United States'))
            ) {
            return postalCode.substring(0, 5);
        }
        return postalCode;
    }

    private static String validateCountry(String country) {
        if  (String.isNotBlank(country) 
            && (country.trim().equals('US') || country.trim().equals('USA') || country.trim().equalsIgnoreCase('United States'))) {
            return 'UNITED STATES';
        }
        return country;
    }

    private static String validatePostalCode(String postalCode, String country) {
        if (String.isNotBlank(postalCode) && postalCode.length() > 5 
            && String.isNotBlank(country)
            && (country.trim().equals('US') || country.trim().equals('USA') || country.trim().equalsIgnoreCase('United States'))
            ) {
            return postalCode.substring(0, 5) + '-' + postalCode.substring(5);
        }
        return postalCode;
    }

    private static String emptyOrValue(String value) {
        return (String.isBlank(value)) ? '' : value.trim().toUpperCase();
    }

    private static Boolean valueChanged(String newValue, String oldValue) {
        String newVal;
        String oldVal;
        if(String.isNotBlank(newValue)){
            newVal = newValue.trim();
        }
        if(String.isNotBlank(oldValue)){
            oldVal = oldValue.trim();
        }
        return (String.isNotBlank(newVal) && !newVal.equalsIgnoreCase(oldVal))
            || (String.isBlank(newValue) && String.isNotBlank(oldVal));
    }

    /**
    * @description This inner class is used to make request Address Wrapper JSON
    * @name : CaseAddressWrapper
    */
    public with sharing class CaseAddressWrapper {
        public AddressWrapper newAddress;
        public List<MembersWrapper> successMembers;
    }
    /**
    * @description This inner class is used to make request Address Wrapper JSON
    * @name : MembersWrapper
    */
    public with sharing class MembersWrapper {
        public String id;
        public String sfdcId;
        public String name;
        public String address;
        public String recordTypeName;
        public String url;
        public AddressWrapper oldAddress;
    }

    /**
    * @description This inner class is used to make request Address Wrapper JSON
    * @name : AddressWrapper
    */
    public with sharing class AddressWrapper {
        String label;
        String street1;
        String street2;
        String street3;
        String city;
        String state;
        String zipCode;
        String country;
    }
}

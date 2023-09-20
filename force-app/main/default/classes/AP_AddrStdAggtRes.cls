/****************************************************************************************
Name: AP_AddrStdAggtRes
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description This is JSON object for customer aggregator - Address standardization response

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Stark                     11/23/2021             R20 Major Release
******************************************************************************************/
public with sharing class AP_AddrStdAggtRes {
    public Cls_standardizedAddress standardizedAddress;
    public Cls_parsedAddress parsedAddress;
    public String statusCode;
    public Cls_messages[] messages;
    public Boolean success;
    /**
     * @description inner class - standardize address
     */
    public with sharing class Cls_standardizedAddress {
        public String city;
        public String postalCode;
        public String stateProvince;
        public String[] streets;
    }
    /**
     * @description inner class - parse address
     */
    public with sharing class Cls_parsedAddress {
        public String streetNumber;
        public String streetName;
        public String suffix;
        public String unitDesignation;
        public String unit;
        public String fullCityName;
        public String fipsCode;
    }
    /**
     * @description inner class - message
     */
    public with sharing class Cls_messages {
        public String clientInfo;
        public String machineId;
        public String messageCode;
        public String messageSource;
        public String messageText;
    }

    /**
     * @description desrializing json into class
     * @method parse
     * @param json
     * @return AP_AddrStdAggtRes
     */
    public static AP_AddrStdAggtRes parse(String json){
        return (AP_AddrStdAggtRes) System.JSON.deserialize(json, AP_AddrStdAggtRes.class);
    }
}

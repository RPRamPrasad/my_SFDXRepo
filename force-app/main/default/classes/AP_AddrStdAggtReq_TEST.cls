/****************************************************************************************
Name: AP_AddrStdAggtReq_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
@description This is a test for the JSON object for customer aggregator - Address standardization request

Team: Atlas
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Atlas   		          01/18/2023             R3 Major Release
******************************************************************************************/
@isTest(SeeAllData = false)
private class AP_AddrStdAggtReq_TEST {

    @isTest
    private static void shouldParseLoadedData() {
        String testString = '{"address":{"street1":"1048 Bobolink way", "street2":"Apt 6", "city":"Bloomington", "country":"US", "postalCode":"61704", "state":"IL"}, "meta":{"auditInfo":{"callingApplication":"Salesforce.com", "callingArea":"CROM CAAM", "requesterReferenceId":"5ZZFQ1YS000", "requesterReferenceType":"Enterprise ID - Associate", "auditFields":{"auditFieldValue":"ent delivery doc ID", "auditFieldType":"ent delivery doc ID"}}}}';
        AP_AddrStdAggtReq comparisonObject = new AP_AddrStdAggtReq();
        AP_AddrStdAggtReq.Cls_address addr = new AP_AddrStdAggtReq.Cls_address();
        addr.street1 = '1048 Bobolink way';
        addr.street2 = 'Apt 6';
        addr.city = 'Bloomington';
        addr.country = 'US';
        addr.postalCode = '61704';
        addr.state = 'IL';
        comparisonObject.address = addr;
        AP_AddrStdAggtReq.Cls_meta meta = new AP_AddrStdAggtReq.Cls_meta();
        AP_AddrStdAggtReq.Cls_auditInfo info = new AP_AddrStdAggtReq.Cls_auditInfo();
        info.callingApplication = 'Salesforce.com';
        info.callingArea = 'CROM CAAM';
        info.requesterReferenceId = '5ZZFQ1YS000';
        info.requesterReferenceType = 'Enterprise ID - Associate';
        AP_AddrStdAggtReq.Cls_auditFields audit = new AP_AddrStdAggtReq.Cls_auditFields();
        audit.auditFieldValue = 'ent delivery doc ID';
        audit.auditFieldType = 'ent delivery doc ID';
        info.auditFields = audit;
        meta.auditInfo = info;
        comparisonObject.meta = meta;
        
        AP_AddrStdAggtReq requestResponse = AP_AddrStdAggtReq.parse(testString);

        System.assertEquals(requestResponse.address.street1, comparisonObject.address.street1, 'Expected street1 must be equals to the actual street1');
        System.assertEquals(requestResponse.address.street2, comparisonObject.address.street2, 'Expected street2 must be equals to the actual street2');
		System.assertEquals(requestResponse.address.city, comparisonObject.address.city, 'Expected city must be equals to the actual city');
		System.assertEquals(requestResponse.address.country, comparisonObject.address.country, 'Expected country must be equals to the actual country');
        System.assertEquals(requestResponse.address.postalCode, comparisonObject.address.postalCode, 'Expected postalcode must be equals to the actual postalcode');
        System.assertEquals(requestResponse.address.state, comparisonObject.address.state, 'Expected state must be equals to the actual state');
        System.assertEquals(requestResponse.meta.auditInfo.auditFields.auditFieldValue, comparisonObject.meta.auditInfo.auditFields.auditFieldValue, 'Expected auditFieldvalue must be equals to the actual auditFieldvalue');
        System.assertEquals(requestResponse.meta.auditInfo.auditFields.auditFieldType, comparisonObject.meta.auditInfo.auditFields.auditFieldType, 'Expected auditFieldType must be equals to the actual auditFieldType');
        System.assertEquals(requestResponse.meta.auditInfo.callingApplication, comparisonObject.meta.auditInfo.callingApplication, 'Expected callingApplication must be equals to the actual callingApplication');
        System.assertEquals(requestResponse.meta.auditInfo.callingArea, comparisonObject.meta.auditInfo.callingArea, 'Expected callingArea must be equals to the actual callingArea');
        System.assertEquals(requestResponse.meta.auditInfo.requesterReferenceId, comparisonObject.meta.auditInfo.requesterReferenceId, 'Expected requesterReferenceId must be equals to the actual requesterReferenceId');
        System.assertEquals(requestResponse.meta.auditInfo.requesterReferenceType, comparisonObject.meta.auditInfo.requesterReferenceType, 'Expected requesterReferenceType must be equals to the actual requesterReferenceType');
    }
}
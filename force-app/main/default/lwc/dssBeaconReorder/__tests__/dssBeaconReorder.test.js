import { createElement } from 'lwc';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import DssBeaconReorder from 'c/dssBeaconReorder';
import dssTelematicsData from '@salesforce/messageChannel/dss_case__c';
import * as messageService from 'lightning/messageService';
import { registerTestWireAdapter,registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import { setImmediate } from 'timers';

// eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
const getRecordDataAdapter = registerLdsTestWireAdapter(getRecord);
import cccSalesUser from './data/cccSalesUser.json';
import cccServiceUser from './data/cccServiceUser.json';
import dsaUser from './data/dsaUser.json';

const messageContextAdapter = registerTestWireAdapter(messageService.MessageContext);
messageService.unsubscribe = jest.fn();
import createSupportCase from '@salesforce/apex/DssBeaconReorderController.createSupportCase';
import mrsfServiceCall from '@salesforce/apex/DssBeaconReorderController.mrsfServiceCall';
import shipmentServiceCall from '@salesforce/apex/DssBeaconReorderController.shipmentServiceCall';

const DV_SUCCESS_LEGACY = { tc_id: 123456789, telematicsEnrollmentIdentifier: null, telematicsServiceProductCode: '09', telematicsEnrollmentCompletionDate: null, policyNumber: '123MOCK', agreementAccessKey:'3624453934',physicalObjectSerialNumber: '1GNLVGED9AJ216712' };
const DV_SUCCESS_MOD = { tc_id: null, telematicsEnrollmentIdentifier: 123456789, telematicsServiceProductCode: '09', telematicsEnrollmentCompletionDate: '12/31/4000', policyNumber: '123MOCK',agreementAccessKey:'3624453934',physicalObjectSerialNumber: '1GNLVGED9AJ216712' };
const DV_NOT_ACTIVE = { tc_id: null, telematicsEnrollmentIdentifier: null, telematicsServiceProductCode: null, telematicsEnrollmentCompletionDate: null,physicalObjectSerialNumber: null };
const DV_NOT_ENROLLED = { tc_id: null, telematicsEnrollmentIdentifier: 123456789, telematicsServiceProductCode: '09', telematicsEnrollmentCompletionDate: null, physicalObjectSerialNumber: '1GNLVGED9AJ216712' };
const DV_INCORRECT_PRODUCT_CODE_LEGACY = { tc_id: 123456789, telematicsEnrollmentIdentifier: null, telematicsServiceProductCode: '03', telematicsEnrollmentCompletionDate: null,physicalObjectSerialNumber: '1GNLVGED9AJ216712' };
const DV_INCORRECT_PRODUCT_CODE_MOD = { tc_id: null, telematicsEnrollmentIdentifier: 123456789, telematicsServiceProductCode: '03', telematicsEnrollmentCompletionDate: '12/31/4000',physicalObjectSerialNumber: '1GNLVGED9AJ216712' };
const SHIPMENT_ORDER_LEGACY = {shipmentOrder :{clientId: '00xikfhnepc', firstName: 'Fake', lastName: 'Jake', address1: '2915 STONEY CREEK DR',postalState: 'IL',postalCode: '60124-3142', postalCity: 'ELGIN', tempAddressIndicator: false, telemeterOrderReason: 'A-Did not receive beacon package',addSourceIdentifier: 'ECRM',itemModelNumber: 'Bluetooth Device', tc_id: 123456789 }};
const SHIPMENT_ORDER_MOD = {shipmentOrder :{clientId: '00xikfhnepc', firstName: 'Fake', lastName: 'Jake', address1: '2915 STONEY CREEK DR',postalState: 'IL',postalCode: '60124-3142', postalCity: 'ELGIN', tempAddressIndicator: false, telemeterOrderReason: 'A-Did not receive beacon package',addSourceIdentifier: 'ECRM',itemModelNumber: 'Bluetooth Device', enrollmentId: 123456789 }};
const MRSF_NO_ORDERS = "{}";
const MRSF_SHIPPED_LAST_10_DAYS = "{\"TCID\":123456789,\"EnrollmentID\":null,\"LastOrderId\":824192,\"LastOrderDate\":\"2022-10-06T16:33:35.42\",\"LastShipDate\":\"2022-11-13T16:33:35.42\",\"LastCancelDate\":null,\"LastDeliveryDate\":\"2022-06-09T16:33:35.42\",\"LastReturnDate\":null,\"LastExportDate\":\"2022-06-07T16:33:35.42\",\"LastTrackingNumber\":\"93001106880191011120211282\",\"LastOrderStatus\":\"Delivered\",\"Orders\":[{\"OrderId\":824192,\"ClientID\":\"7Z3P5563001\",\"FirstName\":\"Leanne\",\"LastName\":\"Bradshaw\",\"Address1\":\"472 New Way\",\"Address2\":\"\",\"City\":\"Omaha\",\"State\":\"AZ\",\"PostalCode\":\"21840\",\"ItemModelNumber\":\"Bluetooth Device\",\"OrderReason\":\"Automated Beacon Replacement\",\"TempAddress\":null,\"OrderDate\":\"2022-06-06T16:33:35.42\",\"ExportDate\":\"2022-06-07T16:33:35.42\",\"ShipDate\":\"2022-06-08T16:33:35.42\",\"DeliveryDate\":\"2022-06-09T16:33:35.42\",\"ReturnDate\":null,\"ReturnReason\":null,\"CancelDate\":null,\"CancelReason\":null,\"TrackingNumber\":\"93001106880191011120211282\",\"ImportFile\":null,\"OrderStatus\":\"Delivered\"}]}";
const MRSF_SHIPMENTS_GREATER_THAN_10_DAYS = "{\"TCID\":123456789,\"EnrollmentID\":null,\"LastOrderId\":824192,\"LastOrderDate\":\"2022-06-01T16:33:35.42\",\"LastShipDate\":\"2022-07-10T16:33:35.42\",\"LastCancelDate\":null,\"LastDeliveryDate\":\"2022-06-09T16:33:35.42\",\"LastReturnDate\":null,\"LastExportDate\":\"2022-06-07T16:33:35.42\",\"LastTrackingNumber\":\"93001106880191011120211282\",\"LastOrderStatus\":\"Delivered\",\"Orders\":[{\"OrderId\":824192,\"ClientID\":\"7Z3P5563001\",\"FirstName\":\"Leanne\",\"LastName\":\"Bradshaw\",\"Address1\":\"472 New Way\",\"Address2\":\"\",\"City\":\"Omaha\",\"State\":\"AZ\",\"PostalCode\":\"21840\",\"ItemModelNumber\":\"Bluetooth Device\",\"OrderReason\":\"Automated Beacon Replacement\",\"TempAddress\":null,\"OrderDate\":\"2022-06-06T16:33:35.42\",\"ExportDate\":\"2022-06-07T16:33:35.42\",\"ShipDate\":\"2022-06-08T16:33:35.42\",\"DeliveryDate\":\"2022-06-09T16:33:35.42\",\"ReturnDate\":null,\"ReturnReason\":null,\"CancelDate\":null,\"CancelReason\":null,\"TrackingNumber\":\"93001106880191011120211282\",\"ImportFile\":null,\"OrderStatus\":\"Delivered\"}]}";
const MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_PROCESS_SHIPMENT = "{\"TCID\":123456789,\"EnrollmentID\":null,\"LastOrderId\":824192,\"LastOrderDate\":\"2022-06-01T16:33:35.42\",\"LastShipDate\":\"2022-07-10T16:33:35.42\",\"LastCancelDate\":null,\"LastDeliveryDate\":\"2022-06-09T16:33:35.42\",\"LastReturnDate\":null,\"LastExportDate\":\"2022-06-07T16:33:35.42\",\"LastTrackingNumber\":\"93001106880191011120211282\",\"LastOrderStatus\":\"Processing Shipment\",\"Orders\":[{\"OrderId\":824192,\"ClientID\":\"7Z3P5563001\",\"FirstName\":\"Leanne\",\"LastName\":\"Bradshaw\",\"Address1\":\"472 New Way\",\"Address2\":\"\",\"City\":\"Omaha\",\"State\":\"AZ\",\"PostalCode\":\"21840\",\"ItemModelNumber\":\"Bluetooth Device\",\"OrderReason\":\"Automated Beacon Replacement\",\"TempAddress\":null,\"OrderDate\":\"2022-06-06T16:33:35.42\",\"ExportDate\":\"2022-06-07T16:33:35.42\",\"ShipDate\":\"2022-06-08T16:33:35.42\",\"DeliveryDate\":\"2022-06-09T16:33:35.42\",\"ReturnDate\":null,\"ReturnReason\":null,\"CancelDate\":null,\"CancelReason\":null,\"TrackingNumber\":\"93001106880191011120211282\",\"ImportFile\":null,\"OrderStatus\":\"Delivered\"}]}";
const MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_ORDER_SUBMITTED = "{\"TCID\":123456789,\"EnrollmentID\":null,\"LastOrderId\":824192,\"LastOrderDate\":\"2022-06-01T16:33:35.42\",\"LastShipDate\":\"2022-07-10T16:33:35.42\",\"LastCancelDate\":null,\"LastDeliveryDate\":\"2022-06-09T16:33:35.42\",\"LastReturnDate\":null,\"LastExportDate\":\"2022-06-07T16:33:35.42\",\"LastTrackingNumber\":\"93001106880191011120211282\",\"LastOrderStatus\":\"Order Submitted\",\"Orders\":[{\"OrderId\":824192,\"ClientID\":\"7Z3P5563001\",\"FirstName\":\"Leanne\",\"LastName\":\"Bradshaw\",\"Address1\":\"472 New Way\",\"Address2\":\"\",\"City\":\"Omaha\",\"State\":\"AZ\",\"PostalCode\":\"21840\",\"ItemModelNumber\":\"Bluetooth Device\",\"OrderReason\":\"Automated Beacon Replacement\",\"TempAddress\":null,\"OrderDate\":\"2022-06-06T16:33:35.42\",\"ExportDate\":\"2022-06-07T16:33:35.42\",\"ShipDate\":\"2022-06-08T16:33:35.42\",\"DeliveryDate\":\"2022-06-09T16:33:35.42\",\"ReturnDate\":null,\"ReturnReason\":null,\"CancelDate\":null,\"CancelReason\":null,\"TrackingNumber\":\"93001106880191011120211282\",\"ImportFile\":null,\"OrderStatus\":\"Delivered\"}]}";
const MRSF_SHIPPED_10_DAYS_AGO = "{\"TCID\":123456789,\"EnrollmentID\":null,\"LastOrderId\":824192,\"LastOrderDate\":\"2022-10-06T16:33:35.42\",\"LastShipDate\":\"2022-11-08T16:33:35.42\",\"LastCancelDate\":null,\"LastDeliveryDate\":\"2022-06-09T16:33:35.42\",\"LastReturnDate\":null,\"LastExportDate\":\"2022-06-07T16:33:35.42\",\"LastTrackingNumber\":\"93001106880191011120211282\",\"LastOrderStatus\":\"Delivered\",\"Orders\":[{\"OrderId\":824192,\"ClientID\":\"7Z3P5563001\",\"FirstName\":\"Leanne\",\"LastName\":\"Bradshaw\",\"Address1\":\"472 New Way\",\"Address2\":\"\",\"City\":\"Omaha\",\"State\":\"AZ\",\"PostalCode\":\"21840\",\"ItemModelNumber\":\"Bluetooth Device\",\"OrderReason\":\"Automated Beacon Replacement\",\"TempAddress\":null,\"OrderDate\":\"2022-06-06T16:33:35.42\",\"ExportDate\":\"2022-06-07T16:33:35.42\",\"ShipDate\":\"2022-06-08T16:33:35.42\",\"DeliveryDate\":\"2022-06-09T16:33:35.42\",\"ReturnDate\":null,\"ReturnReason\":null,\"CancelDate\":null,\"CancelReason\":null,\"TrackingNumber\":\"93001106880191011120211282\",\"ImportFile\":null,\"OrderStatus\":\"Delivered\"}]}";
const MRSF_NULL_SHIPMENT_DATA = "{\"TCID\":123456789,\"EnrollmentID\":null,\"LastOrderId\":824192,\"LastOrderDate\":\"2022-06-02T16:33:35.42\",\"LastShipDate\":null,\"LastCancelDate\":null,\"LastDeliveryDate\":\"2022-06-09T16:33:35.42\",\"LastReturnDate\":null,\"LastExportDate\":\"2022-06-07T16:33:35.42\",\"LastTrackingNumber\":\"93001106880191011120211282\",\"LastOrderStatus\":\"Delivered\",\"Orders\":[{\"OrderId\":824192,\"ClientID\":\"7Z3P5563001\",\"FirstName\":\"Leanne\",\"LastName\":\"Bradshaw\",\"Address1\":\"472 New Way\",\"Address2\":\"\",\"City\":\"Omaha\",\"State\":\"AZ\",\"PostalCode\":\"21840\",\"ItemModelNumber\":\"Bluetooth Device\",\"OrderReason\":\"Automated Beacon Replacement\",\"TempAddress\":null,\"OrderDate\":\"2022-17-06T16:33:35.42\",\"ExportDate\":\"2022-06-07T16:33:35.42\",\"ShipDate\":\"2022-06-08T16:33:35.42\",\"DeliveryDate\":\"2022-06-09T16:33:35.42\",\"ReturnDate\":null,\"ReturnReason\":null,\"CancelDate\":null,\"CancelReason\":null,\"TrackingNumber\":\"93001106880191011120211282\",\"ImportFile\":null,\"OrderStatus\":\"Delivered\"}]}";

import { PAGE_1_BODY, PAGE_2_BODY, PAGE_3_BODY, PAGE_4_BODY, PAGE_30_BODY, PAGE_31_BODY, PAGE_32_BODY, PAGE_33_BODY, PAGE_99_BODY,PAGE_100_BODY,PAGE_101_BODY } from '../constants';

function shouldBeOnPage1(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_1_BODY);
}

function shouldBeOnPage2(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_2_BODY);
}

function shouldBeOnPage3(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_3_BODY);
}

function shouldBeOnPage4(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_4_BODY);
}

function shouldBeOnDvInactivePage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_30_BODY);
}

function shouldBeOnBeaconShippedLastTenDaysPage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_31_BODY);
}

function shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_101_BODY);
}

function shouldBeOnNoEnrollmentPage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_32_BODY);
}

function shouldBeOnIncorrectProductCodePage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_33_BODY);
}

function shouldBeOnTechnicalErrorPage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_99_BODY);
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
}

function shouldBeOnCCCTechnicalErrorPage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(2);
   expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(2);
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=error-content]')).toBeTruthy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).not.toEqual('');
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeFalsy();
   expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]').value).toStrictEqual(PAGE_100_BODY);
}

function shouldBeOnSubmitSpinnerPage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeTruthy();
}

function shouldBeOnSupportSpinnerPage(dssReorderModal) {
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=cancel-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]')).toBeTruthy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-content]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-padding]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=modal-body-html]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=address-information]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=yes-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=no-button]')).toBeFalsy();
    expect(dssReorderModal.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeTruthy();
}

jest.mock(
    '@salesforce/apex/DssBeaconReorderController.createSupportCase',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/DssBeaconReorderController.mrsfServiceCall',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/DssBeaconReorderController.shipmentServiceCall',
    () => ({ default: jest.fn() }), { virtual: true }
);

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve));
}

describe('c-dss-beacon-reorder', () => {
    let dssReorderModal;

    beforeEach(() => {
        jest.resetAllMocks();
        jest.useFakeTimers().setSystemTime(new Date('2022-11-18'));
        dssReorderModal = createElement('c-dss-beacon-reorder', {
            is: DssBeaconReorder
        });
        messageContextAdapter.emit('MESSAGE CONTEXT');
        document.body.appendChild(dssReorderModal);
    });


    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        dssReorderModal = null;
        jest.clearAllMocks();       
    });

    it('should show modal', async () => {
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);
        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(dssTelematicsData);
    });

    it('should show modal and proceed to through pages', async () => {      
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        dssReorderModal.sourceSystemCode = 1;
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }    
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);
    });

    it('subscribeToDSScaseMessageChannel policyNumber mismatch - stuck on loading test', async () => {
         //agreementAccessKey doesn't match 3624453934
        dssReorderModal.agreementAccessKey='362445';
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        dssReorderModal.sourceSystemCode = 1;
        await Promise.resolve();
        
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeTruthy();
    });


    it('should show modal and proceed to through pages after data returns on mod policy with null shipment data', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_NULL_SHIPMENT_DATA;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);
        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_MOD);
        dssReorderModal.sourceSystemCode = 24;

        expect(mrsfServiceCall).toHaveBeenCalled();
         const expectedMrsfParams = {
           tcId: null,
           enrollmentId:123456789
        }    
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);     

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage4(dssReorderModal);
    });
    it('should show modal, proceed to last page, then click previous button twice to return to beginning', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_NO_ORDERS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);
        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();
        await dssReorderModal.goToNextPage();
        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        dssReorderModal.sourceSystemCode = 1;
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }

        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);      

        await shouldBeOnPage4(dssReorderModal);

        await dssReorderModal.goToPreviousPage();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.goToPreviousPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToPreviousPage();

        await shouldBeOnPage1(dssReorderModal);
    });

    it('should show modal and close modal', async () => {
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.toggleModal();

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);
    });

    it('should show modal with dv api data preventing completion by going to next page on legacy policy with improper product code', async () => {
        const mrsfResponse = MRSF_NULL_SHIPMENT_DATA;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_INCORRECT_PRODUCT_CODE_LEGACY);
        dssReorderModal.sourceSystemCode = 1;

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);   

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnIncorrectProductCodePage(dssReorderModal);
    });

    it('should show modal with dv api data preventing completion by going to next page on mod policy with improper product code', async () => {
        const mrsfResponse = MRSF_NULL_SHIPMENT_DATA;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_INCORRECT_PRODUCT_CODE_MOD);
        dssReorderModal.sourceSystemCode = 24;

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId:123456789
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);   

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnIncorrectProductCodePage(dssReorderModal);
    });

    it('should show modal with dv api data preventing completion by going to next page on mod policy without enrollment date', async () => {
        const mrsfResponse = MRSF_NULL_SHIPMENT_DATA;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_NOT_ENROLLED);
        expect(messageService.subscribe.mock.calls[0][3]).toMatchObject({"scope": "APPLICATION SCOPE"});
        dssReorderModal.sourceSystemCode = 24;

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId:123456789
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnNoEnrollmentPage(dssReorderModal);
    });

    it('should show modal with dv api data preventing completion by going to previous page on legacy policy', async () => {
        const mrsfResponse = MRSF_NO_ORDERS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);
        expect(messageService.subscribe.mock.calls[0][3]).toMatchObject({"scope": "APPLICATION SCOPE"});
        expect(mrsfServiceCall).not.toHaveBeenCalled();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToPreviousPage();

        await shouldBeOnDvInactivePage(dssReorderModal);
    });

    it('unsubscribe is called when component is removed from page', async () => {
        // const mrsfResponse = '{}';        
        const mrsfResponse = MRSF_NO_ORDERS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await flushPromises();
		messageService.unsubscribe = jest.fn();
		while (document.body.firstChild) { document.body.removeChild(document.body.firstChild); }
		expect(messageService.unsubscribe).toHaveBeenCalledTimes(1);
    });


    it('should show modal with dv api data preventing completion by going to previous page on mod policy', async () => {
        // const mrsfResponse = '{}';
        const mrsfResponse = MRSF_NO_ORDERS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();
        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);
        expect(mrsfServiceCall).not.toHaveBeenCalled();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToPreviousPage();

        await shouldBeOnDvInactivePage(dssReorderModal);
    });


    it('should show modal and click no button to proceed to reasons page', async () => {
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnPage3(dssReorderModal);
    });

    it('should show modal and click no button to proceed to reasons page after data has returned', async () => {      
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id=previous-button]').click();

        await shouldBeOnPage1(dssReorderModal);
    });

    it('should show modal and click no button to proceed to reasons page after data has returned with no dss active on legacy policy', async () => {
        const mrsfResponse = MRSF_NO_ORDERS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);

        expect(mrsfServiceCall).not.toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId: null
        }
        expect(mrsfServiceCall).not.toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnDvInactivePage(dssReorderModal);
    });  

    it('should show error toast when subusertype null', async () => {
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);
        dsaUser.fields.SubUserType__c.value = null;
        getRecordDataAdapter.emit(dsaUser);

        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Unable to load policy action buttons');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('User record details incomplete. Please contact support for assistance.');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('Error');
       
        dsaUser.fields.SubUserType__c.value = "SFDC_USER_1_07_Tech_Supp";
    });
   
    it('should show modal and proceed to through pages to select order reason', async () => { 
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);      

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeTruthy();
        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package' } }));
        expect(reorderReasonsGroup.value).toStrictEqual('A-Did not receive beacon package');
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').click();

        await shouldBeOnPage4(dssReorderModal);
    });

    it('should show modal and proceed to through pages to select order reason for CCC Sales Users', async () => {
       dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccSalesUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);      

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeTruthy();
        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));
        expect(reorderReasonsGroup.value).toStrictEqual('C-Did not receive beacon package');
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').click();

        await shouldBeOnPage4(dssReorderModal);
    });

    it('should show modal and proceed to through pages to select order reason for CCC Service Users', async () => {   
       dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccServiceUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);      

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeTruthy();
        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=continue-button]').click();

        await shouldBeOnPage4(dssReorderModal);
    });

    it('should show modal and proceed to through pages with successful submission on legacy policy', async () => { 
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package' } }));

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        dssReorderModal.sourceSystemCode = 1;
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Success";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));
     
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        await shouldBeOnSubmitSpinnerPage(dssReorderModal);
        await flushPromises();

        expect(shipmentServiceCall).toHaveBeenCalled();
        expect(shipmentServiceCall).toHaveBeenCalledWith(SHIPMENT_ORDER_LEGACY);

        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Success');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('Success');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('Your Drive Safe & Save™ beacon request has been submitted! The Customer will be notified once it is shipped.');
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        await dssReorderModal.toggleModal();
        await dssReorderModal.goToNextPage();
        await dssReorderModal.goToNextPage();
        await dssReorderModal.goToNextPage();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
    });

    it('should show modal and proceed to through pages with successful submission on mod policy', async () => {      
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package' } }));

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_MOD);
        dssReorderModal.sourceSystemCode = 24;
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId: 123456789
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Success";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));
        
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        await shouldBeOnSubmitSpinnerPage(dssReorderModal);
        await flushPromises();

        expect(shipmentServiceCall).toHaveBeenCalled();
        expect(shipmentServiceCall).toHaveBeenCalledWith(SHIPMENT_ORDER_MOD);

        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Success');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('Success');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('Your Drive Safe & Save™ beacon request has been submitted! The Customer will be notified once it is shipped.');
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);
    });
    
    it('should show modal and proceed to through pages with business rule error on submission page on legacy policy', async () => {
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);
        await Promise.resolve();
        
        await shouldBeOnPage4(dssReorderModal);


        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        await flushPromises();

        await shouldBeOnDvInactivePage(dssReorderModal);
    });

    it('should show modal and proceed to through pages with business rule error on submission page on mod policy', async () => {
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);
        await Promise.resolve();

        await shouldBeOnPage4(dssReorderModal);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        await flushPromises();

        await shouldBeOnDvInactivePage(dssReorderModal);
    });


    it('should show modal and proceed to through pages with technical error on submit click on legacy policy', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        createSupportCase.mockImplementationOnce(() => Promise.resolve('12345'));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);
        getRecordDataAdapter.emit(dsaUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);


        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package' } }));

        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';
        dssReorderModal.policyNumber = '123MOCK';
        dssReorderModal.accountName = 'Fake Jake';
        dssReorderModal.productDescription = '2050 Honda Mustang';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        await flushPromises();

        expect(shipmentServiceCall).toHaveBeenCalled();
        
        await shouldBeOnTechnicalErrorPage(dssReorderModal);
        
        await dssReorderModal.shadowRoot.querySelector('[data-id=support-button]').click();
        await shouldBeOnSupportSpinnerPage(dssReorderModal);
        await flushPromises();

        expect(createSupportCase).toHaveBeenCalled();
        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Successfully Created Support Case');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('Case #12345 has been created for this request.');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('success');
        const expectedCaseParams = {
            uiParams: {
                policyNumber: '123MOCK',
                clientName: 'Fake Jake',
                clientId: '00xikfhnepc',
                productDescription: '2050 Honda Mustang',
                vin: '1GNLVGED9AJ216712',
                errorDescription: 'A technical error has occurred. Please request support below to initiate the reorder process.'
            }
        }
        expect(createSupportCase).toHaveBeenCalledWith(expectedCaseParams);

        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(null));

        await dssReorderModal.toggleModal();
        await shouldBeOnPage1(dssReorderModal);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();

        await dssReorderModal.goToNextPage();

        await shouldBeOnTechnicalErrorPage(dssReorderModal);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=support-button]').disabled).toBeFalsy();
    });

  

    it('should show modal and proceed to through pages with error on submission on legacy policy because submission data not present', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);
        getRecordDataAdapter.emit(dsaUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package' } }));


        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        await flushPromises();
        expect(shipmentServiceCall).toHaveBeenCalled();

        await shouldBeOnTechnicalErrorPage(dssReorderModal);
    });

    it('should show modal and proceed to through pages with error on submission on legacy policy because submission data not present for CCC Sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        
        getRecordDataAdapter.emit(cccSalesUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));


        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        await flushPromises();
        expect(shipmentServiceCall).toHaveBeenCalled();

        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
    });

    it('should show modal and proceed to through pages with error on submission on legacy policy because submission data not present for CCC Service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        
        getRecordDataAdapter.emit(cccServiceUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));


        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        await flushPromises();
        expect(shipmentServiceCall).toHaveBeenCalled();

        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
    });

    it('should show modal and proceed to through pages with  shipment api fails  for ccc sales and show kickout flow-no case creation', async () => {
        dssReorderModal.agreementAccessKey='3624453934'; 
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));   
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);
    
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);
    
        await dssReorderModal.toggleModal();
    
        await shouldBeOnPage1(dssReorderModal);
    
        await dssReorderModal.goToNextPage();
    
        await shouldBeOnPage2(dssReorderModal);
    
        await dssReorderModal.goToNextPage();
    
        await shouldBeOnPage3(dssReorderModal);
    
        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));
    
    
        await dssReorderModal.goToNextPage();
    
        await shouldBeOnSubmitSpinnerPage(dssReorderModal);
    
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();
    
        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
    
        await shouldBeOnPage4(dssReorderModal);
    
        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';
    
        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));
        getRecordDataAdapter.emit(cccSalesUser);
       
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        await flushPromises();
        expect(shipmentServiceCall).toHaveBeenCalled();
    
        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
       
    });
    it('should show modal and proceed to through pages with  shipment api fails  for ccc Service and show kickout flow-no case creation', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));   
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);
    
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);
    
        await dssReorderModal.toggleModal();
    
        await shouldBeOnPage1(dssReorderModal);
    
        await dssReorderModal.goToNextPage();
    
        await shouldBeOnPage2(dssReorderModal);
    
        await dssReorderModal.goToNextPage();
    
        await shouldBeOnPage3(dssReorderModal);
    
        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));
    
    
        await dssReorderModal.goToNextPage();
    
        await shouldBeOnSubmitSpinnerPage(dssReorderModal);
    
        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        await Promise.resolve();
    
        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
    
        await shouldBeOnPage4(dssReorderModal);
    
        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';
    
        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));
        getRecordDataAdapter.emit(cccServiceUser);
       
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        await flushPromises();
        expect(shipmentServiceCall).toHaveBeenCalled();
    
        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
       
    });

    it('should create support case with dv api data preventing completion on legacy policy', async () => {    
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        createSupportCase.mockImplementationOnce(() => Promise.resolve('12345'));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
            tcId: 123456789,
            enrollmentId: null
         }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        dssReorderModal.policyNumber = '123MOCK';
        dssReorderModal.accountName = 'Fake Jake';
        dssReorderModal.customerClientId = 'FAKEJAKE';
        dssReorderModal.productDescription = '2050 Honda Mustang';
        await dssReorderModal.shadowRoot.querySelector('[data-id=support-button]').click();
        await shouldBeOnSupportSpinnerPage(dssReorderModal);
        await flushPromises();

        expect(createSupportCase).toHaveBeenCalled();
        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Successfully Created Support Case');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('Case #12345 has been created for this request.');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('success');
        const expectedCaseParams = {
            uiParams: {
                policyNumber: '123MOCK',
                clientName: 'Fake Jake',
                clientId: 'FAKEJAKE',
                productDescription: '2050 Honda Mustang',
                vin: "1GNLVGED9AJ216712",
                errorDescription: 'A beacon has been shipped within the last 10 days. Please review the tracking information, and request support below if a beacon is still needed.'
            }
        }
        expect(createSupportCase).toHaveBeenCalledWith(expectedCaseParams);
    });

    it('should create support case with dv api data preventing completion on mod policy', async () => {      
       dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        createSupportCase.mockImplementationOnce(() => Promise.resolve('12345'));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_MOD);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
            tcId: null,
            enrollmentId: 123456789
         }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        dssReorderModal.policyNumber = '123MOCK';
        dssReorderModal.accountName = 'Fake Jake';
        dssReorderModal.customerClientId = 'FAKEJAKE';
        dssReorderModal.productDescription = '2050 Honda Mustang';
        await dssReorderModal.shadowRoot.querySelector('[data-id=support-button]').click();
        await shouldBeOnSupportSpinnerPage(dssReorderModal);
        await flushPromises();

        expect(createSupportCase).toHaveBeenCalled();
        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Successfully Created Support Case');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('Case #12345 has been created for this request.');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('success');
        const expectedCaseParams = {
            uiParams: {
                policyNumber: '123MOCK',
                clientName: 'Fake Jake',
                clientId: 'FAKEJAKE',
                productDescription: '2050 Honda Mustang',
                vin: "1GNLVGED9AJ216712",
                errorDescription: 'A beacon has been shipped within the last 10 days. Please review the tracking information, and request support below if a beacon is still needed.'
            }
        }
        expect(createSupportCase).toHaveBeenCalledWith(expectedCaseParams);
    });

    it('should fail to create support case with dv api data preventing completion on legacy policy', async () => {
        createSupportCase.mockImplementationOnce(() => Promise.resolve(''));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnDvInactivePage(dssReorderModal);

        dssReorderModal.policyNumber = '123MOCK';
        dssReorderModal.accountName = 'Fake Jake';
        dssReorderModal.customerClientId = 'FAKEJAKE';
        dssReorderModal.productDescription = '2050 Honda Mustang';
        await dssReorderModal.createSupportCase();

        expect(createSupportCase).toHaveBeenCalled();
        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Something went wrong');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('A support case could not be created for this request. Please contact your normal support channels for assistance.');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('error');
        const expectedCaseParams = {
            uiParams: {
                policyNumber: '123MOCK',
                clientName: 'Fake Jake',
                clientId: 'FAKEJAKE',
                productDescription: '2050 Honda Mustang',
                vin: null,
                errorDescription: 'This vehicle is not currently enrolled in Drive Safe & Save™ Mobile. You may need to check pending policy transactions or submit a new request. Note: Customer consent is required to add the discount to the policy.'
            }
        }
        expect(createSupportCase).toHaveBeenCalledWith(expectedCaseParams);
    });

    it('should fail to create support case with dv api data preventing completion on mod policy', async () => {
        createSupportCase.mockImplementationOnce(() => Promise.resolve(''));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnDvInactivePage(dssReorderModal);

        dssReorderModal.policyNumber = '123MOCK';
        dssReorderModal.accountName = 'Fake Jake';
        dssReorderModal.customerClientId = 'FAKEJAKE';
        dssReorderModal.productDescription = '2050 Honda Mustang';
        
        await dssReorderModal.createSupportCase();

        expect(createSupportCase).toHaveBeenCalled();
        expect(showToastListener).toHaveBeenCalled();
        expect(showToastListener.mock.calls[0][0].detail.title).toBe('Something went wrong');
        expect(showToastListener.mock.calls[0][0].detail.message).toBe('A support case could not be created for this request. Please contact your normal support channels for assistance.');
        expect(showToastListener.mock.calls[0][0].detail.variant).toBe('error');
        const expectedCaseParams = {
            uiParams: {
                policyNumber: '123MOCK',
                clientName: 'Fake Jake',
                clientId: 'FAKEJAKE',
                productDescription: '2050 Honda Mustang',
                vin: null,
                errorDescription: 'This vehicle is not currently enrolled in Drive Safe & Save™ Mobile. You may need to check pending policy transactions or submit a new request. Note: Customer consent is required to add the discount to the policy.'
            }
        }
        expect(createSupportCase).toHaveBeenCalledWith(expectedCaseParams);
    });

    it('should show modal and click no button to proceed to reasons page after data has returned with no dss active on mod policy', async () => {
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();
        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_NOT_ACTIVE);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnDvInactivePage(dssReorderModal);
    });

    it('should show modal and click yes button to proceed with Beacon Error kickout screen when last ship date is less than 10', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);
        
        
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnBeaconShippedLastTenDaysPage(dssReorderModal);
    });

    it('should show modal and click yes button to proceed with Beacon Error kickout screen when last ship date is less than 10 for CCC Sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccSalesUser);
        
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });

    it('should show modal and click yes button to proceed with Beacon Error kickout screen when last ship date is less than 10 for CCC Service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccServiceUser);
        
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });

    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is less than 10', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
        dssReorderModal.mrsfData = { BeaconShippedLast7Days: true };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPage(dssReorderModal);
    });

    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is less than 10 for CCC Sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccSalesUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
        dssReorderModal.mrsfData = { BeaconShippedLast7Days: true };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });

    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is less than 10 for CCC Service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_LAST_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccServiceUser)
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
        dssReorderModal.mrsfData = { BeaconShippedLast7Days: true };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });


    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is great than 10 days but order status is Processing Shipment', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_PROCESS_SHIPMENT;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
       // dssReorderModal.mrsfData = { lastOrderStatus:'Processing Shipment' };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPage(dssReorderModal);
    });

    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is great than 10 days but order status is Processing Shipment for CCC Sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_PROCESS_SHIPMENT;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccSalesUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
       // dssReorderModal.mrsfData = { lastOrderStatus:'Processing Shipment' };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });

    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is great than 10 days but order status is Processing Shipment for CCC Service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_PROCESS_SHIPMENT;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccServiceUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
       // dssReorderModal.mrsfData = { lastOrderStatus:'Processing Shipment' };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });
    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is great than 10 days but order status is Order Submitted', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_ORDER_SUBMITTED;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
      //  dssReorderModal.mrsfData = {lastOrderStatus:'Order Submittedd' };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPage(dssReorderModal);
    });
    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is great than 10 days but order status is Order Submitted for CCC Sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_ORDER_SUBMITTED;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccSalesUser);


        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
      //  dssReorderModal.mrsfData = {lastOrderStatus:'Order Submittedd' };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });

    
    it('should show modal and click no button to proceed with Beacon Error kickout screen when last ship date is great than 10 days but order status is Order Submitted for CCC Service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS_ORDER_SUBMITTED;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(cccServiceUser);


        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY); 
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
 
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);
      //  dssReorderModal.mrsfData = {lastOrderStatus:'Order Submittedd' };

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.shadowRoot.querySelector('[data-id="no-button"]').click();

        await shouldBeOnBeaconShippedLastTenDaysPageCCC(dssReorderModal);
    });
    it('should show modal and click yes button to proceed with no Beacon Error kickout screen when last ship date is equal to 10', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPPED_10_DAYS_AGO;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);
    });


    it('should show modal and proceed to through pages with technical error on submit click on mod policy', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'A-Did not receive beacon package' } }));


        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_MOD);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId: 123456789
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        expect(shipmentServiceCall).toHaveBeenCalled();
        await flushPromises();

        await shouldBeOnTechnicalErrorPage(dssReorderModal);
    }); 

    it('should show modal and proceed to through pages with technical error on submit click on mod policy for CCC Sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        getRecordDataAdapter.emit(cccSalesUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));


        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_MOD);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId: 123456789
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        expect(shipmentServiceCall).toHaveBeenCalled();
        await flushPromises();

        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
    }); 

    it('should show modal and proceed to through pages with technical error on submit click on mod policy for CCC Service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = MRSF_SHIPMENTS_GREATER_THAN_10_DAYS;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        const showToastListener = jest.fn();
        dssReorderModal.addEventListener(ShowToastEventName, showToastListener);

        getRecordDataAdapter.emit(cccServiceUser);

        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        await dssReorderModal.toggleModal();

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage2(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnPage3(dssReorderModal);

        const reorderReasonsGroup = dssReorderModal.shadowRoot.querySelector('[data-id=reorder-reasons-group]');
        await reorderReasonsGroup.dispatchEvent(new CustomEvent('change', { detail: { label: 'Customer did not receive beacon package', value: 'C-Did not receive beacon package' } }));


        await dssReorderModal.goToNextPage();

        await shouldBeOnSubmitSpinnerPage(dssReorderModal);

        dssReorderModal.sourceSystemCode = 24;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_MOD);
        await Promise.resolve();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: null,
           enrollmentId: 123456789
        }
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage4(dssReorderModal);

        dssReorderModal.customerClientId = '00xikfhnepc';
        dssReorderModal.customerFirstName= 'Fake';
        dssReorderModal.customerLastName = 'Jake';
        dssReorderModal.customerStreet= '2915 STONEY CREEK DR';
        dssReorderModal.customerState='IL';
        dssReorderModal.customerZip='60124-3142';
        dssReorderModal.customerCity='ELGIN';

        const shipmentServiceCallResponse = "Error";
        shipmentServiceCall.mockImplementationOnce(() => Promise.resolve(shipmentServiceCallResponse));

        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeFalsy();
        await dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').click();
        expect(dssReorderModal.shadowRoot.querySelector('[data-id=submit-button]').disabled).toBeTruthy();
        expect(shipmentServiceCall).toHaveBeenCalled();
        await flushPromises();

        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
    }); 


    it('should show modal with mrsf data is not returned response', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = null;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));
        getRecordDataAdapter.emit(dsaUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
     
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnTechnicalErrorPage(dssReorderModal);
    });
    it('should show modal with mrsf data is not returned response for CCC sales', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = null;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));

        getRecordDataAdapter.emit(cccSalesUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
     
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
    });

    it('should show modal with mrsf data is not returned response for CCC service', async () => {
        dssReorderModal.agreementAccessKey='3624453934';
        const mrsfResponse = null;
        mrsfServiceCall.mockImplementationOnce(() => Promise.resolve(mrsfResponse));

        getRecordDataAdapter.emit(cccServiceUser);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="beacon-modal"]').classList.length).toEqual(1);
        expect(dssReorderModal.shadowRoot.querySelector('[data-id="modal-backdrop"]').classList.length).toEqual(1);

        dssReorderModal.sourceSystemCode = 1;
        await messageService.subscribe.mock.calls[0][2](DV_SUCCESS_LEGACY);
        expect(mrsfServiceCall).not.toHaveBeenCalled();
        await dssReorderModal.toggleModal();

        expect(mrsfServiceCall).toHaveBeenCalled();
        const expectedMrsfParams = {
           tcId: 123456789,
           enrollmentId: null
        }
     
        expect(mrsfServiceCall).toHaveBeenCalledWith(expectedMrsfParams);

        await shouldBeOnPage1(dssReorderModal);

        await dssReorderModal.goToNextPage();

        await shouldBeOnCCCTechnicalErrorPage(dssReorderModal);
    });
});

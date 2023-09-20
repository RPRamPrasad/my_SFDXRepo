/* eslint-disable import/namespace */
import policyActions from 'c/policyActions';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter, registerTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import selectedRisk from '@salesforce/messageChannel/risk__c';
import * as messageService from 'lightning/messageService';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';

const mockAutoPrivatePassengerRecord = require('./data/policyData/auto/autoInsurancePolicy_PrivatePassenger.json');

const messageContextAdapter = registerTestWireAdapter(messageService.MessageContext);
const getRecordDataAdapter = registerLdsTestWireAdapter(getRecord);
const mockAccess = {
    'PolicyActions_PolicyTransactions': { read: false },
    'PolicyActions_AutoIDCard': { read: false },
    'PolicyActions_BillingOnlineSystem': { read: false },
    'PolicyActions_CertificateOfInsurance': { read: false }
};

const { setImmediate } = require('timers')

function flushPromises() {

    return new Promise(resolve => setImmediate(resolve));
}

jest.mock('c/dssBeaconReorder');

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.encodeProductDescription',
    () => ({ default: jest.fn(desc => desc.productDescription.split(' ').join('+').split(':').join('%3A')) }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant',
    () => ({
        default: jest.fn(params => {
            return {
                PrimaryParticipantAccountId: 'recordId' + params.lob,
                PrimaryParticipantAccount: {
                    ClientIdentifier__c: 'CID' + params.lob,
                    Name: 'ClientName',
                    PersonEmail: 'ClientEmail@email.com'
                }
            }
        })
    }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase',
    () => ({ default: jest.fn(params => params.inputData.policyNumber) }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatus',
    () => ({ default: jest.fn(() => ({ PLM_Auto_Launch_PC_Active__c: true, PLM_Opp_Redirect_Active__c: true, PLM_Policy_Actions_Active__c: true })) }), { virtual: true }
);
jest.mock('c/checkFeatureAccess', () => {
    return {
        getFeatureAccessMetadataBySubuserType: jest.fn(featureName => Promise.resolve(mockAccess[featureName])),
        getFeatureAccessMetadataByUserCriteria: jest.fn(featureName => Promise.resolve(mockAccess[featureName]))

    };
});

jest.mock('@salesforce/customPermission/Case_Migration_Pilot_User', () => ({ default: false }), { virtual: true });

messageService.unsubscribe = jest.fn();
window.open = jest.fn();

describe('c-policy-actions - no access to Policy Action buttons', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = false;
    mockAccess.PolicyActions_AutoIDCard.read = false;
    mockAccess.PolicyActions_BillingOnlineSystem.read = false;
    mockAccess.PolicyActions_CertificateOfInsurance.read = false;

    beforeEach(() => {
        policyActionsComp = createElement('c-policy-actions', {
            is: policyActions
        });
        messageContextAdapter.emit('MESSAGE CONTEXT');
    })

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        policyActionsComp = null;
        jest.clearAllMocks();
    });

    it('should not render actions for auto', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeNull();


        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]')).toBeFalsy();

        const expectedUserAccess = {
            hasPolicyTransactionAccess: false,
            hasToofLinkAccess: false,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            isGroupPolicy: false,
            hasDSSBeaconReorderAccess: false,
            hasPremiumChangeInquiryAccess: false,
            hasAgentStatusTrackerAccess: false,
            hasPolicyDocumentsAccess: false
        };
        const actualUserAccess = policyActionsComp.getUserAccess;

        expect(actualUserAccess).toBeTruthy();
        expect(Object.keys(actualUserAccess).length).toEqual(11);

        Object.keys(expectedUserAccess).forEach(expectedAccess => {
            const actualAccess = actualUserAccess[expectedAccess];
            expect(actualAccess).toStrictEqual(false);
        })
    });
});
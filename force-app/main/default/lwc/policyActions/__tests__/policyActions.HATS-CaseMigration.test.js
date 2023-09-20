/* eslint-disable import/namespace */
import policyActions from 'c/policyActions';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter, registerTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import { getNavigateCalledWith } from 'lightning/navigation';
import selectedRisk from '@salesforce/messageChannel/risk__c';
import * as messageService from 'lightning/messageService';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import getPLMStatus from '@salesforce/apex/InsurancePolicyController.getPLMStatus';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';
import { constants } from 'c/policyDetailsCommonJS';
import isHatsorHa4cUser from '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser';

const {
    POLICY_CHANGE_CASE,
    ADDED_VEH_CASE
} = constants;


const mockAutoPrivatePassengerRecord = require('./data/policyData/auto/autoInsurancePolicy_PrivatePassenger.json');
const mockAutoPrivatePassengerUserRec = require('./data/policyData/auto/autoInsurancePolicy_PrivatePassenger_AgentUser.json');
const mockAutoPrivatePassengerATMUserRec = require('./data/policyData/auto/autoInsurancePolicy_PrivatePassenger_ATMUser.json');
const mockAutoHDC = require('./data/policyData/auto/autoInsurancePolicy_HDC.json');
const messageContextAdapter = registerTestWireAdapter(messageService.MessageContext);
// eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
const getRecordDataAdapter = registerLdsTestWireAdapter(getRecord);
const mockAccess = {
    'PolicyActions_PolicyTransactions': { read: false },
    'PolicyActions_AutoIDCard': { read: false },
    'PolicyActions_BillingOnlineSystem': { read: false },
    'PolicyActions_CertificateOfInsurance': { read: false }

};

const plmCSAccess = {
    PLM_Auto_Launch_PC_Active__c: true,
    PLM_Opp_Redirect_Active__c: true,
    PLM_Policy_Actions_Active__c: true
}

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
    () => ({ default: jest.fn(desc => desc.productDescription.split(' ').join('+')) }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase',
    () => ({ default: jest.fn(params => params.inputData.policyNumber) }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatus',
    () => ({ default: jest.fn(() => Promise.resolve(plmCSAccess)) }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock('c/checkFeatureAccess', () => {
    return {
        getFeatureAccessMetadataBySubuserType: jest.fn(featureName => Promise.resolve(mockAccess[featureName])),
        getFeatureAccessMetadataByUserCriteria: jest.fn(featureName => Promise.resolve(mockAccess[featureName]))

    };
});

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant',
    () => ({
        default: jest.fn(params => {
            return {
                PrimaryParticipantAccountId: params.recordId,
                PrimaryParticipantAccount: {
                    ClientIdentifier__c: 'CID' + params.recordId,
                    Name: 'ClientName',
                    PersonEmail: 'ClientEmail@email.com'
                }
            }
        })
    }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock('@salesforce/customPermission/Case_Migration_Pilot_User', () => ({ default: true }), { virtual: true });

messageService.unsubscribe = jest.fn();
window.open = jest.fn();

describe('c-policy-actions - render Policy Action buttons', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;
    mockAccess.PolicyActions_CertificateOfInsurance.read = true;

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

    it('should render actions for user with HATS permission', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').label).toEqual('View Policy Details');
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="hdc-helptext"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').disabled).toEqual(false);
    });

    it('should show normal button label for details', async() => {
        getRecordDataAdapter.emit(mockAutoHDC);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').label).toEqual('View Policy Details');
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').disabled).toEqual(true);
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="hdc-helptext"]')).toBeTruthy();
    });
});

describe('c-policy-actions - launch auto Policy Actions', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;

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

    it('should launch Policy Change HATS case', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);

        isHatsorHa4cUser.mockResolvedValueOnce(true);
        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]');
        expect(HATSorHA4CButton).toBeTruthy();
        HATSorHA4CButton.click();
        await flushPromises();

        expect(window.open).not.toHaveBeenCalled();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(POLICY_CHANGE_CASE);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isCaseMigrationAction).toEqual(true);
    });

    it('should launch Add Vehicle HATS case', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);

        isHatsorHa4cUser.mockResolvedValueOnce(true);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]');
        expect(HATSorHA4CButton).toBeTruthy();
        HATSorHA4CButton.click();
        await flushPromises();

        expect(window.open).not.toHaveBeenCalled();

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(ADDED_VEH_CASE);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isCaseMigrationAction).toEqual(true);
    });

    it('should launch Email Auto Id Card Agent', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerUserRec);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]');
        expect(HATSorHA4CButton).toBeTruthy();
        HATSorHA4CButton.click();
        await flushPromises();
        const modalComp = policyActionsComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(modalComp).toBeTruthy();
        modalComp.dispatchEvent(new CustomEvent('sendconfirmation', {
            detail: {
                sendEmail: false,
                userEmail: 'test@123.com'
            }
        }));
        await flushPromises();
        modalComp.dispatchEvent(new CustomEvent('sendconfirmation', {
            detail: {
                sendEmail: true,
                userEmail: 'test@123.com'
            }
        }));
        await flushPromises();
        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "test@123.com",
            "customerName": "JOHN D FILLINGIM",
            "policyNumber": "7563035126"
        });
        modalComp.dispatchEvent(new CustomEvent('closemodal', { detail: { showModal: false } }));
        await flushPromises();
        const modalComp2 = policyActionsComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(modalComp2).toBeFalsy();
    });

    it('should launch Email Auto Id Card ATM', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerATMUserRec);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]');
        expect(HATSorHA4CButton).toBeTruthy();

        const riskPayload = {
            policyRecordId: '123',
            riskStatus: 'In Force',
            riskNumber: '001',
            riskDescription: '2019 CADILLAC XT5 SPORT WG'
        };
        messageService.publish(messageContextAdapter, selectedRisk, riskPayload);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        messageService.subscribe.mock.calls[0][2](riskPayload);
        await flushPromises();

        HATSorHA4CButton.click();
        await flushPromises();
        const modalComp = policyActionsComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(modalComp).toBeTruthy();
        modalComp.dispatchEvent(new CustomEvent('sendconfirmation', {
            detail: {
                sendEmail: true,
                userEmail: 'test@123.com'
            }
        }));
        await flushPromises();
        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "test@123.com",
            "customerName": "JOHN D FILLINGIM",
            "policyNumber": "7563035126001"
        });
    });

    it('should launch Email Auto Id Card ATM 000 Risk', async() => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerATMUserRec);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]');
        expect(HATSorHA4CButton).toBeTruthy();

        const riskPayload = {
            policyRecordId: '123',
            riskStatus: 'In Force',
            riskNumber: '000',
            riskDescription: '2019 CADILLAC XT5 SPORT WG'
        };
        messageService.publish(messageContextAdapter, selectedRisk, riskPayload);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        messageService.subscribe.mock.calls[0][2](riskPayload);
        await flushPromises();

        HATSorHA4CButton.click();
        await flushPromises();
        const modalComp = policyActionsComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(modalComp).toBeTruthy();
        modalComp.dispatchEvent(new CustomEvent('sendconfirmation', {
            detail: {
                sendEmail: true,
                userEmail: 'test@123.com'
            }
        }));
        await flushPromises();
        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "test@123.com",
            "customerName": "JOHN D FILLINGIM",
            "policyNumber": "7563035126"
        });
    });

});

describe('c-policy-actions - launch auto Policy Actions with PLM disabled', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;

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

    it('should launch Policy Change HATS case', async() => {
        plmCSAccess.PLM_Policy_Actions_Active__c = false;
        plmCSAccess.PLM_Auto_Launch_PC_Active__c = false;
        plmCSAccess.PLM_Opp_Redirect_Active__c = false;

        getPLMStatus.mockResolvedValueOnce(plmCSAccess);
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]');
        expect(HATSorHA4CButton).toBeTruthy();
        HATSorHA4CButton.click();
        await flushPromises();

        expect(window.open).not.toHaveBeenCalled();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(POLICY_CHANGE_CASE);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isCaseMigrationAction).toEqual(true);
    });

    it('should launch Add Vehicle HATS case', async() => {
        plmCSAccess.PLM_Policy_Actions_Active__c = false;
        plmCSAccess.PLM_Auto_Launch_PC_Active__c = false;
        plmCSAccess.PLM_Opp_Redirect_Active__c = false;

        getPLMStatus.mockResolvedValueOnce(plmCSAccess);
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123';
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const HATSorHA4CButton = policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]');
        expect(HATSorHA4CButton).toBeTruthy();
        HATSorHA4CButton.click();
        await flushPromises();

        expect(window.open).not.toHaveBeenCalled();

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(ADDED_VEH_CASE);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isCaseMigrationAction).toEqual(true);
    });

});
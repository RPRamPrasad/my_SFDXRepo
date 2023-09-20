/* eslint-disable import/namespace */
import policyActions from 'c/policyActions';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter, registerTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import { getNavigateCalledWith } from 'lightning/navigation';
import selectedRisk from '@salesforce/messageChannel/risk__c';
import * as messageService from 'lightning/messageService';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import encodeProductDescription from '@salesforce/apex/InsurancePolicyController.encodeProductDescription';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';
import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import isHatsorHa4cUser from '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser';
import { constants } from 'c/policyDetailsCommonJS';

const {
    POLICY_CHANGE_CASE,
    ADDED_VEH_CASE
} = constants;

const mockAutoPrivatePassengerRecord = require('./data/policyData/auto/autoInsurancePolicy_PrivatePassenger.json');
const mockAutoTerminatedRecord = require('./data/policyData/auto/autoInsurancePolicy_Terminated.json');
const mockAutoMultiCarRecord = require('./data/policyData/auto/autoInsurancePolicy_MultiCar.json');
const mockAutoCommercialAutoRecord = require('./data/policyData/auto/autoInsurancePolicy_ModCommercialAuto.json');
const mockHealthRecord = require('./data/policyData/health/healthInsurancePolicy.json');

const messageContextAdapter = registerTestWireAdapter(messageService.MessageContext);
const getRecordDataAdapter = registerLdsTestWireAdapter(getRecord);
const mockAccess = {
    'PolicyActions_PolicyTransactions': { read: false },
    'PolicyActions_AutoIDCard': { read: false },
    'PolicyActions_BillingOnlineSystem': { read: false },
    'PolicyActions_CertificateOfInsurance': { read: false },
    'PolicyActions_DSSBeaconReorder': { read: false },
    'PolicyActions_AgentStatusTracker': {read: false},
    'PolicyActions_PolicyDocuments': {read: false}
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
    () => ({ default: jest.fn( desc => desc.productDescription.split(' ').join('+').split(':').join('%3A') )}), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant',
    () => ({ default: jest.fn( params => {
        return {
            PrimaryParticipantAccountId: params.recordId,
            PrimaryParticipantAccount: {
                ClientIdentifier__c: 'CID' + params.recordId,
                Name: 'ClientName',
                PersonEmail: 'ClientEmail@email.com'
            }
        }
    } )}), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase',
    () => ({ default: jest.fn( params => params.inputData.policyNumber )}), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatus',
    () => ({ default: jest.fn( ()=>({ PLM_Auto_Launch_PC_Active__c: true, PLM_Opp_Redirect_Active__c: true, PLM_Policy_Actions_Active__c: true }) )}), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatusForState',
    () => ({ default: () => false }), {virtual: true}
);
jest.mock('c/checkFeatureAccess', () => {
    return {
        getFeatureAccessMetadataBySubuserType: jest.fn(featureName => Promise.resolve(mockAccess[featureName])),
        getFeatureAccessMetadataByUserCriteria: jest.fn(featureName => Promise.resolve(mockAccess[featureName]))

    };
});

jest.mock(
    '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser',
    () => ({ default: jest.fn() }), { virtual: true }
);


messageService.unsubscribe = jest.fn();
window.open = jest.fn();

describe('c-policy-actions - render Policy Action buttons 1', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;
    mockAccess.PolicyActions_CertificateOfInsurance.read = true;
    mockAccess.PolicyActions_DSSBeaconReorder.read = true;
    mockAccess.PolicyActions_AgentStatusTracker.read = true;
    mockAccess.PolicyActions_PolicyDocuments.read = true;

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

    it('should render actions for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalledWith("MESSAGE CONTEXT", "risk__c", expect.any(Function), {"scope": "APPLICATION SCOPE"});
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Reorder Beacon"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Premium Change Inquiry"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Status"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Documents"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
    });


});

describe('c-policy-actions - launch Policy Details 1', () => {
    let policyActionsComp;

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
        jest.clearAllMocks();
    });

    it('should launch for auto', async () => {
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

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=13&` +
            `accountId=001R000001kro3uIAA&` +
            `agreementIndexId=1915&` +
            `policyNumber=011 7968-E19-03L&` +
            `lineOfBusiness=A&` +
            `productDescription=2004+CHEVROLET+K2500+PICKUP&` +
            `agentAssocId=D51WM4NTKAK&` +
            `outOfBookIndicator=TRUE`
        );
    });


});

describe('c-policy-actions - launch auto Policy Actions 1 ', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;
    mockAccess.PolicyActions_DSSBeaconReorder.read = true;

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

    it('should launch Policy Change action and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoCommercialAutoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]').click();
        await flushPromises();


        expect(window.open).toHaveBeenCalledWith(
            '/c/ExternalLinkApp.app?linkId=266' +
            '&policyNumber=0000000-C04-13&agreementIndexID=&requestID='
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('0000000-C04-13');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(POLICY_CHANGE_CASE);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.productDescription).toEqual('2004 CHEVROLET K2500 PICKUP');
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isCaseMigrationAction).toEqual(true);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isLegacyPolicy).toEqual(false);
    });

    it('should launch Add Vehicle action and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoCommercialAutoRecord);
        policyActionsComp.recordId = '123';
        isHatsorHa4cUser.mockResolvedValueOnce(true);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            '/c/ExternalLinkApp.app?linkId=266&' +
            'policyNumber=0000000-C04-13&agreementIndexID=&requestID='
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('0000000-C04-13');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(ADDED_VEH_CASE);
    });


    it('should launch Add Driver and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoCommercialAutoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();

    });

    it('should launch Replace Vehicle and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoCommercialAutoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();

     });


    it('should launch Auto Policy Change and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoCommercialAutoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();

    });

    it('should launch TOOF Reinstatement and make case for terminated auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoTerminatedRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(`/apex/VFP_ExternalLink?LinkId=43`);

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
    });



    it('should launch Email Auto Id Card', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const dropdown = policyActionsComp.shadowRoot.querySelector("lightning-button-menu");
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));
        await flushPromises();

        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "xajcrfxtzgcb2mm@sf.org",
            "customerName": "JOHN D FILLINGIM",
            "policyNumber": "7563035126"
        });
    });

    it('should launch Email Auto Id Card for multi-car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoMultiCarRecord);
        policyActionsComp.recordId = '0YTR00000004D3cOAE';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();

        const riskPayload = {
            policyRecordId: '0YTR00000004D3cOAE',
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

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        const dropdown = policyActionsComp.shadowRoot.querySelector("lightning-button-menu");
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));
        await flushPromises();

        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "gnkezqsf45604@sf.org",
            "customerName": "TONY THRASHER",
            "policyNumber": "5311062659001"
        });
    });

});


describe('c-policy-actions - handle exceptions 1', () => {
    let policyActionsComp;

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

    it('should handle group status exception and build buttons', async () => {
        getGroupPolicyStatus.mockRejectedValueOnce(new Error('Oh no!'));
        getRecordDataAdapter.emit(mockHealthRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
    });

    it('should handle description encode exception and build buttons', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        encodeProductDescription.mockRejectedValueOnce(new Error('Oh no!'));
        getRecordDataAdapter.emit(mockHealthRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Health Policy Change"]')).toBeTruthy();
    });


    it('should handle policy retrieval error', async () => {
        getRecordDataAdapter.error();
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="action-list"]')).toBeFalsy();
    });


});

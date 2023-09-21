/* eslint-disable import/namespace */
import policyActions from 'c/policyActions';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter, registerTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import { getNavigateCalledWith } from 'lightning/navigation';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import selectedRisk from '@salesforce/messageChannel/risk__c';
import * as messageService from 'lightning/messageService';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import encodeProductDescription from '@salesforce/apex/InsurancePolicyController.encodeProductDescription';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';
import getPrimaryInsurancePolicyParticipant from '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant';
import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import { constants } from 'c/policyDetailsCommonJS';

import {
	getFeatureAccessMetadataBySubuserType
} from "c/checkFeatureAccess";

const {
    POLICY_CHANGE_CASE,
    ADDED_VEH_CASE
} = constants;

const mockAutoPrivatePassengerRecord = require('./data/policyData/auto/autoInsurancePolicy_PrivatePassenger.json');
const mockAutoTerminatedRecord = require('./data/policyData/auto/autoInsurancePolicy_Terminated.json');
const mockAutoMultiCarRecord = require('./data/policyData/auto/autoInsurancePolicy_MultiCar.json');
const mockAutoFleetRecord = require('./data/policyData/auto/autoInsurancePolicy_Fleet.json');
const mockAutoAntiqueRecord = require('./data/policyData/auto/autoInsurancePolicy_Antique.json');
const mockFireHomeownersRecord = require('./data/policyData/fire/fireInsurancePolicy_HomeOwners.json');
const mockFireCommercialFireRecord = require('./data/policyData/fire/fireInsurancePolicy_Commercial.json');
const mockFireCondoRecord = require('./data/policyData/fire/fireInsurancePolicy_Condo.json');
const mockLifePMRRecord = require('./data/policyData/life/lifeInsurancePolicy_PMR.json');
const mockLifePMRRecordNoNI = require('./data/policyData/life/lifeInsurancePolicy_PMRNoNI.json');
const mockLifePMRRecordNonOwnerNI = require('./data/policyData/life/lifeInsurancePolicy_PMRNonOwnerNI.json');
const mockLifeASCRecord = require('./data/policyData/life/lifeInsurancePolicy_ASC.json');
const mockLifePNXRecord = require('./data/policyData/life/lifeInsurancePolicy_PNX.json');
const mockLifeModRecord = require('./data/policyData/life/lifeInsurancePolicy_Mod.json');
const mockLifeGroupRecord = require('./data/policyData/life/lifeInsurancePolicy_Group.json');
const mockLifeIncompleteRecord = require('./data/policyData/life/lifeInsurancePolicy_Incomplete.json');
const mockHealthRecord = require('./data/policyData/health/healthInsurancePolicy.json');

const messageContextAdapter = registerTestWireAdapter(messageService.MessageContext);
const getRecordDataAdapter = registerLdsTestWireAdapter(getRecord);
const mockAccess = {
    'PolicyActions_PolicyTransactions': { read: false },
    'PolicyActions_AutoIDCard': { read: false },
    'PolicyActions_BillingOnlineSystem': { read: false },
    'PolicyActions_CertificateOfInsurance': { read: false },
    'PolicyActions_DSSBeaconReorder': { read: false },
    'PolicyActions_PremiumChange' : {read: false},
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

jest.mock('@salesforce/customPermission/DSS_Beacon_Reorder', () => ({ default: true }), { virtual: true });
jest.mock('@salesforce/customPermission/SAE_Policy_Change', () => ({ default: false }), { virtual: true });

messageService.unsubscribe = jest.fn();
window.open = jest.fn();

describe('c-policy-actions - render Policy Action buttons', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;
    mockAccess.PolicyActions_CertificateOfInsurance.read = true;
    mockAccess.PolicyActions_DSSBeaconReorder.read = true;
    mockAccess.PolicyActions_PremiumChange.read = true;
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

        expect(messageService.subscribe).toHaveBeenCalled();
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
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Premium Change Inquiry"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Status"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Documents"]')).toBeTruthy();
        expect(getFeatureAccessMetadataBySubuserType).toHaveBeenCalledTimes(9)
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[0][0]).toBe('PolicyActions_PolicyTransactions')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[1][0]).toBe('PolicyActions_ToofPolicy')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[2][0]).toBe('PolicyActions_AutoIDCard')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[3][0]).toBe('PolicyActions_BillingOnlineSystem')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[4][0]).toBe('PolicyActions_CertificateOfInsurance')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[5][0]).toBe('PolicyActions_DSSBeaconReorder')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[6][0]).toBe('PolicyActions_PremiumChange')
        expect(getFeatureAccessMetadataBySubuserType.mock.calls[7][0]).toBe('PolicyActions_AgentStatusTracker')
    });

    it('should render actions for multi-car auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoMultiCarRecord);
        policyActionsComp.recordId = '0YTR00000004D3cOAE';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();

        const badRiskPayload = {
            policyRecordId: '0YTR00000004D3cOABCDE',
            riskStatus: 'In Force',
            riskNumber: '001',
            riskDescription: 'SHOULD NOT GET HERE'
        };
        messageService.publish(messageContextAdapter, selectedRisk, badRiskPayload);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        messageService.subscribe.mock.calls[0][2](badRiskPayload);
        expect(encodeProductDescription).not.toHaveBeenCalled();
        await flushPromises();

        const riskPayload = {
            policyRecordId: '0YTR00000004D3cOAE',
            riskStatus: 'In Force',
            riskNumber: '001',
            riskDescription: '2014 CHEVROLET C1500 PICKUP'
        };
        messageService.publish(messageContextAdapter, selectedRisk, riskPayload);
        await flushPromises();

        messageService.subscribe.mock.calls[0][2](riskPayload);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
    });

    it('should render actions for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        getRecordDataAdapter.emit(mockFireCondoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]')).toBeTruthy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Reorder Beacon"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Premium Change Inquiry"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Status"]')).toBeTruthy();
    });

    it('should render actions for life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123456';
        getRecordDataAdapter.emit(mockLifePMRRecord);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
    });

    it('should render actions for phoenix life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        policyActionsComp.recordId = '123456';
        getRecordDataAdapter.emit(mockLifePNXRecord);

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelectorAll("lightning-button")).toHaveLength(1);
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeFalsy();
    });

    it('should render actions for health', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockHealthRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Health Policy Change"]')).toBeTruthy();
    });
});

describe('c-policy-actions - launch Policy Details', () => {
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

    it('should launch for multi-car auto', async () => {
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

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();
        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=198&` +
            `accountId=001R000001mOe0EIAS&` +
            `agreementIndexId=76348823&` +
            `policyNumber=106 2659-F06-53V-001&` +
            `lineOfBusiness=A&` +
            `productDescription=MULTIPLE+VEHICLE%3A+2019+CADILLAC+XT5+SPORT+WG&` +
            `agentAssocId=SHZ6F1YS000&` +
            `outOfBookIndicator=TRUE&` +
            `pmrNumber=5311062659001`
        );
    });

    it('should launch for fleet auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        getRecordDataAdapter.emit(mockAutoFleetRecord);
        policyActionsComp.recordId = '0YTR00000004D3cOAE';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="title"]').textContent).toEqual("Policy Actions");
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();

        const riskPayload = {
            policyRecordId: '0YTR00000004D3cOAE',
            riskStatus: 'In Force',
            riskNumber: '777',
            riskDescription: '2019 CADILLAC XT5 SPORT WG'
        };
        messageService.publish(messageContextAdapter, selectedRisk, riskPayload);
        await flushPromises();

        expect(messageService.subscribe).toHaveBeenCalled();
        expect(messageService.subscribe.mock.calls[0][1]).toBe(selectedRisk);
        messageService.subscribe.mock.calls[0][2](riskPayload);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();
        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=198&` +
                `accountId=001R000001tC542IAC&` +
                `agreementIndexId=404341824&` +
                `policyNumber=E71 6130-D01-13A&` +
                `lineOfBusiness=A&` +
                `productDescription=FLEET&` +
                `agentAssocId=J24Y61YS001&` +
                `outOfBookIndicator=TRUE&` +
                `pmrNumber=131E716130`
        );
    });

    it('should launch for fire homeowners', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockFireHomeownersRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001mOe0CIAS&` +
            `agreementIndexId=282751018&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=policy&` +
            `key=03-CU-4825-5&` +
            `lineOfBusiness=F&` +
            `agentAssocId=2VN9S1YS000`
        );
    });

    it('should launch for fire non-homeowners', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        getRecordDataAdapter.emit(mockFireCondoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001mOe06IAC&` +
            `agreementIndexId=224968612&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=policy&` +
            `key=93-K3-8752-0&` +
            `lineOfBusiness=F&` +
            `agentAssocId=FSNX01YS000`
        );
    });

    it('should launch for life mod', async () => {
        jest.spyOn(global.Date, 'now').mockImplementationOnce(() => 'NOW');

        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifeModRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/c/ExternalLinkApp.app?` +
            `linkId=109&` +
            `policyIdentifier=4528322240&` +
            `userSessionId=005000000000000000-NOW`
        );
    });

    it('should launch for phoenix life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifePNXRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=192`
        );
    });

    it('should launch for PMR life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifePMRRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=68&` +
            `accountId=001R000001u1pqzIAA&` +
            `agreementIndexId=439236835&` +
            `policyNumber=LF-3727-8251&` +
            `lineOfBusiness=L&` +
            `agentAssocId=YXT2R1YS000`);
    });

    it('should launch for ASC life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifeASCRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001u1pr0IAA&` +
            `agreementIndexId=389748657&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=policy&` +
            `key=SL-3516-8901&` +
            `lineOfBusiness=L&` +
            `agentAssocId=P1KNH1YS000`);
    });

    it('should launch for incomplete life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifeIncompleteRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith('');
    });

    it('should not launch for group life', async () => {
        const showToastHandler = jest.fn();
        policyActionsComp.addEventListener(ShowToastEventName, showToastHandler);
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        getRecordDataAdapter.emit(mockLifeGroupRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).not.toHaveBeenCalled();
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('NOTICE: Action Not Available');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('Detailed view is not available for Group Life policies.');
    });

    it('should launch for health', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockHealthRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001mOe07IAC&` +
            `agreementIndexId=198861359&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=policy&` +
            `key=3333&` +
            `lineOfBusiness=H&` +
            `agentAssocId=VMHRY57VMAL`);
    });

});

describe('c-policy-actions - launch auto Policy Actions', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_AutoIDCard.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;
    mockAccess.PolicyActions_DSSBeaconReorder.read = true;
    mockAccess.PolicyActions_PremiumChange.read = true;
    mockAccess.PolicyActions_AgentStatusTracker.read = true;

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
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Policy Change"]').click();
        await flushPromises();


        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001kro3uIAA&` +
            `agreementIndexId=1915&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=new pt&` +
            `key=011 7968-E19-03L&` +
            `lineOfBusiness=A&` +
            `agentAssocId=D51WM4NTKAK`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(POLICY_CHANGE_CASE);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.productDescription).toEqual('2004 CHEVROLET K2500 PICKUP');
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isCaseMigrationAction).toEqual(true);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.isLegacyPolicy).toEqual(true);
    });

    it('should launch Add Vehicle action and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Add Vehicle"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001kro3uIAA&` +
            `agreementIndexId=1915&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=new pt&` +
            `key=011 7968-E19-03L&` +
            `lineOfBusiness=A&` +
            `agentAssocId=D51WM4NTKAK`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('011 7968-E19-03L');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual(ADDED_VEH_CASE);
    });

    it('should launch Add Driver and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoAntiqueRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Add Driver"]').click();
        await flushPromises();


        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=258&` +
            `intent=changePolicy&` +
            `agreementNumber=13P8005554&` +
            `stateAgentCode=13-022F`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('8005554-SCP-13');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Added Driver');
    });

    it('should launch Replace Vehicle and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoAntiqueRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=258&` +
            `intent=changePolicy&` +
            `agreementNumber=13P8005554&` +
            `stateAgentCode=13-022F`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('8005554-SCP-13');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Replaced Vehicle');
    });

    it('should launch Auto Policy Change and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoAntiqueRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=258&` +
            `intent=changePolicy&` +
            `agreementNumber=13P8005554&` +
            `stateAgentCode=13-022F`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('8005554-SCP-13');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
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

    it('should launch TOOF Reinstatement and make case for hagerty', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoAntiqueRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(`/apex/VFP_ExternalLink?LinkId=258&intent=changePolicy&agreementNumber=13P8005554&stateAgentCode=13-022F`);

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('8005554-SCP-13');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
    });

    it('should launch Billing Online System', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const dropdown = policyActionsComp.shadowRoot.querySelector("lightning-button-menu");
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Billing Online System (BOS)' },
            bubbles: true
        }));
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=210&` +
            `accountId=001R000001kro3uIAA&` +
            `companyCode=0001&` +
            `policyNumber=0117968E1903L&` +
            `lineOfBusiness=A`
        );
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

    it('should launch Agent Status Tracker modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const astModalCmp = policyActionsComp.shadowRoot.querySelector("c-agent-status-tracker-modal");
        const openModal = jest.spyOn(astModalCmp, 'openModal');

        const astButton = policyActionsComp.shadowRoot.querySelector('[data-id="Status"]');
        expect(astButton).toBeTruthy();
        astButton.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Status' },
            bubbles: true
        }));
        await flushPromises();

        expect(openModal).toHaveBeenCalled();
    });

    it('should launch DSS Beacon Reorder modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const dssModalCmp = policyActionsComp.shadowRoot.querySelector("c-dss-beacon-reorder");
        const modalToggleSpy = jest.spyOn(dssModalCmp, 'toggleModal');

        const dssButton = policyActionsComp.shadowRoot.querySelector('[data-id="Reorder Beacon"]');
        expect(dssButton).toBeTruthy();
        dssButton.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Reorder Beacon' },
            bubbles: true
        }));
        await flushPromises();

        expect(modalToggleSpy).toHaveBeenCalled();
    });

    it('should launch Premium Change Inquiry modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockAutoPrivatePassengerRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

       const pCIModalCmp = policyActionsComp.shadowRoot.querySelector("c-premium-change-inquiry-modal");
       const modalOpenSpy = jest.spyOn(pCIModalCmp, 'openModal');

        const pCIButton = policyActionsComp.shadowRoot.querySelector('[data-id="Premium Change Inquiry"]');
        expect(pCIButton).toBeTruthy();
        pCIButton.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Premium Change Inquiry' },
            bubbles: true
        }));
        await flushPromises();

        expect(modalOpenSpy).toHaveBeenCalled();
    });
});

describe('c-policy-actions - launch fire Policy Actions', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    mockAccess.PolicyActions_BillingOnlineSystem.read = true;
    mockAccess.PolicyActions_CertificateOfInsurance.read = true;
    mockAccess.PolicyActions_PremiumChange.read = true;
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

    it('should launch Fire Policy Change and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockFireCommercialFireRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001mOe0CIAS&` +
            `agreementIndexId=282751018&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=policy&` +
            `key=11-KJ-9999-6&` +
            `lineOfBusiness=F&` +
            `agentAssocId=2VN9S1YS000`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('11-KJ-9999-6');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Policy - Change/Request');
    });

    it('should launch TOOF Reinstatement and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockFireCommercialFireRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeTruthy();
        policyActionsComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]').click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=9&` +
            `accountId=001R000001mOe0CIAS&` +
            `agreementIndexId=282751018&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=policy&` +
            `key=11-KJ-9999-6&` +
            `lineOfBusiness=F&` +
            `agentAssocId=2VN9S1YS000`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('11-KJ-9999-6');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
    });

    it('should launch Billing Online System', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockFireHomeownersRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const bosButton = policyActionsComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]');
        expect(bosButton).toBeTruthy();
        bosButton.click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=210&` +
            `accountId=001R000001mOe0CIAS&` +
            `companyCode=5&` +
            `policyNumber=03CU48255&` +
            `lineOfBusiness=F`
        );
    });

    it('should launch Certificate of Insurance', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        getRecordDataAdapter.emit(mockFireCondoRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const coiButton = policyActionsComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]');
        expect(coiButton).toBeTruthy();
        coiButton.click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?LinkId=211&` +
            `regionCode=5&` +
            `policyNumber=93K387520&` +
            `policyType=V&` +
            `lineOfBusiness=F`
        );
    });
});

describe('c-policy-actions - launch life Policy Action', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;
    jest.mock(
        '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant',
        () => ({ default: jest.fn( () => {
            return {
                PrimaryParticipantAccountId: 'helloId',
                PrimaryParticipantAccount: {
                    ClientIdentifier__c: 'CIDrecordId',
                    Name: 'ClientName',
                    PersonEmail: 'ClientEmail@email.com'
                }
            }
        } )}), { virtual: true }
    );

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

    it('should launch Life Policy Change and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifePMRRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const lifePolicyChangeButton = policyActionsComp.shadowRoot.querySelector('[data-id="Life Policy Change"]');
        expect(lifePolicyChangeButton).toBeTruthy();
        lifePolicyChangeButton.click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?` +
            `LinkId=9&` +
            `accountId=001R000001u1pqzIAA&` +
            `agreementIndexId=439236835&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=main toc&` +
            `key=LF-3727-8251&` +
            `lineOfBusiness=L&` +
            `agentAssocId=YXT2R1YS000`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('LF-3727-8251');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Policy - Change/Request');
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.accountRecordId).toEqual('001R000001u1pqzIAA');
    });

    it('should launch Life Policy Change and make case for missing Named Insured', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifePMRRecordNoNI);
        policyActionsComp.recordId = '12345';

        document.body.appendChild(policyActionsComp);
        policyActionsComp.recordId = '12345';
        await flushPromises();

        const lifePolicyChangeButton = policyActionsComp.shadowRoot.querySelector('[data-id="Life Policy Change"]');
        expect(lifePolicyChangeButton).toBeTruthy();
        lifePolicyChangeButton.click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?` +
            `LinkId=9&` +
            `accountId=null&` +
            `agreementIndexId=439236835&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=main toc&` +
            `key=LF-3727-8251&` +
            `lineOfBusiness=L&` +
            `agentAssocId=YXT2R1YS000`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('LF-3727-8251');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Policy - Change/Request');
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.accountRecordId).toEqual(null);
    });

    it('should launch Life Policy Change and make case when NI is not owner', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockLifePMRRecordNonOwnerNI);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const lifePolicyChangeButton = policyActionsComp.shadowRoot.querySelector('[data-id="Life Policy Change"]');
        expect(lifePolicyChangeButton).toBeTruthy();
        lifePolicyChangeButton.click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?` +
            `LinkId=9&` +
            `accountId=001R000001u1pqzIAA&` +
            `agreementIndexId=439236835&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=main toc&` +
            `key=LF-3727-8251&` +
            `lineOfBusiness=L&` +
            `agentAssocId=YXT2R1YS000`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('LF-3727-8251');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Policy - Change/Request');
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.accountRecordId).toEqual('001R000001u1pqzIAA');
    });
});

describe('c-policy-actions - launch health Policy Action', () => {
    let policyActionsComp;
    mockAccess.PolicyActions_PolicyTransactions.read = true;

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

    it('should launch Health Policy Change and make case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockHealthRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        const healthPolicyChangeButton = policyActionsComp.shadowRoot.querySelector('[data-id="Health Policy Change"]');
        expect(healthPolicyChangeButton).toBeTruthy();
        healthPolicyChangeButton.click();
        await flushPromises();

        expect(window.open).toHaveBeenCalledWith(
            `/apex/VFP_ExternalLink?` +
            `LinkId=9&` +
            `accountId=001R000001mOe07IAC&` +
            `agreementIndexId=198861359&` +
            `clientnamelinkdisabled=Y&` +
            `NechoAppName=main toc&` +
            `key=3333&` +
            `lineOfBusiness=H&` +
            `agentAssocId=VMHRY57VMAL`
        );

        const { pageReference } = getNavigateCalledWith();

        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('3333');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.actionValue).toEqual('Policy - Change/Request');
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.accountRecordId).toEqual('001R000001mOe07IAC');
    });
});

describe('c-policy-actions - handle exceptions', () => {
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

    it('should handle access exception and build buttons', async () => {
        mockAccess.PolicyActions_PolicyTransactions = { something: 'is wrong' };
        mockAccess.PolicyActions_AutoIDCard = { something: 'is wrong' };
        mockAccess.PolicyActions_BillingOnlineSystem = { something: 'is wrong' };
        mockAccess.PolicyActions_CertificateOfInsurance = { something: 'is wrong' };

        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getRecordDataAdapter.emit(mockHealthRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="Health Policy Change"]')).toBeFalsy();
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

    it('should handle pni selection exception and build buttons', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        getPrimaryInsurancePolicyParticipant.mockRejectedValueOnce(new Error('ruh roh'));
        getRecordDataAdapter.emit(mockLifePMRRecord);
        policyActionsComp.recordId = '123';

        document.body.appendChild(policyActionsComp);
        await flushPromises();

        expect(policyActionsComp.shadowRoot.querySelector('[data-id="warning"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="error"]')).toBeFalsy();
        expect(policyActionsComp.shadowRoot.querySelector('[data-id="View Policy Details"]')).toBeTruthy();
    });
});

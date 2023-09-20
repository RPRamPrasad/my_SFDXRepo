import { createElement } from 'lwc';
import policyActions from 'c/policyActions';
// import * as utils from '../utils';
import * as actions from '../actions';
import { getFullLOB, launchNewCase, retrieveEncodedDescription, retrieveGroupPolicyStatus, throwToast, retrievePLMStatus, isStateActivatedForPLM, handlePolicyChange, handleAddVehicle, retrieveIPAssets } from '../utils';
import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import getEncodedDescription from '@salesforce/apex/InsurancePolicyController.encodeProductDescription';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import getPLMStatus from '@salesforce/apex/InsurancePolicyController.getPLMStatus';
import { NavigationMixin } from 'lightning/navigation';
import getPLMStatusForState from '@salesforce/apex/InsurancePolicyController.getPLMStatusForState';
import getTargetAutoPolicyForState from '@salesforce/apex/InsurancePolicyController.getTargetAutoPolicyForState';
import getInsurancePolicyAssets from '@salesforce/apex/InsurancePolicyController.getInsurancePolicyAssets';
import { constants } from "c/policyDetailsCommonJS";
import isHatsorHa4cUser from '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser';

const {
    PERSONAL_AUTO_MOD_CD
} = constants;

jest.mock(
    '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/InsurancePolicyController.encodeProductDescription',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatus',
    () => ({ default: jest.fn(() => ({ PLM_Auto_Launch_PC_Active__c: true, PLM_Opp_Redirect_Active__c: true, PLM_Policy_Actions_Active__c: true })) }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatusForState',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getTargetAutoPolicyForState',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getInsurancePolicyAssets',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock(
    '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser',
    () => ({ default: jest.fn() }), { virtual: true }
);

describe('policyActions - actions', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    const { setImmediate } = require('timers')

    function flushPromises() {

        return new Promise(resolve => setImmediate(resolve));
    }

    it('returns full line of business text', () => {

        let fullLoB = getFullLOB('A');
        expect(fullLoB).toEqual('Auto');

        fullLoB = getFullLOB('F');
        expect(fullLoB).toEqual('Fire');

        fullLoB = getFullLOB('L');
        expect(fullLoB).toEqual('Life');

        fullLoB = getFullLOB('H');
        expect(fullLoB).toEqual('Health');

        fullLoB = getFullLOB('B');
        expect(fullLoB).toEqual('Bank');

        fullLoB = getFullLOB('M');
        expect(fullLoB).toEqual('Mutual Fund');

        fullLoB = getFullLOB('X');
        expect(fullLoB).toBeFalsy();

        fullLoB = getFullLOB('Z');
        expect(fullLoB).toEqual('');
    });

    it('displays an error toast and sticky', async() => {
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        throwToast(component, 'title', 'message', undefined, undefined);

        await flushPromises();

        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('title');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('message');
        expect(showToastHandler.mock.calls[0][0].detail.variant).toBe('error');
        expect(showToastHandler.mock.calls[0][0].detail.mode).toBe('sticky');
    });

    it('calls createPolicyTransationCase and displayes Case Not Created toast message and does not try to navigate to case id', async() => {
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return undefined });

        launchNewCase("caseReason", { accountRecordId: '12345678', lob: 'A', policyNumber: 'ABC 50-12345', agentAssociateId: 'agentAssocId', productDescription: 'Prod Description' }, component);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalled();
        expect(component[NavigationMixin.Navigate]).toBeCalledTimes(0);
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('NOTICE: Case Not Created');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('There was an error creating a case for this service request. Please create a note or activity to document your action, as needed.');

    });

    it('calls createPolicyTransationCase and performs navigation to case message', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123'
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: false, isCaseMigrationAction: false } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls createPolicyTransationCase and performs navigation to case message 2', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123'
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isCaseMigrationAction: true, isLegacyPolicy: false } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls createPolicyTransationCase and performs navigation to case message - sourceSystemCode 1', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            sourceSystemCode: 1
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: true, isCaseMigrationAction: true, "sourceSystemCode": 1 } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls createPolicyTransationCase and performs navigation to case message - sourceSystemCode 3', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            sourceSystemCode: 3
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: true, isCaseMigrationAction: true, "sourceSystemCode": 3 } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls createPolicyTransationCase and performs navigation to case message - sourceSystemCode 7', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            sourceSystemCode: 7
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: true, isCaseMigrationAction: true, "sourceSystemCode": 7 } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls createPolicyTransationCase and performs navigation to case message - sourceSystemCode 8', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            sourceSystemCode: 8
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: true, isCaseMigrationAction: true, "sourceSystemCode": 8 } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls createPolicyTransationCase and performs navigation to case message - sourceSystemCode 10', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            sourceSystemCode: 10
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        component.recordId = '123';
        window.open = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        launchNewCase("caseReason", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "caseReason", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "ABC 50-12345", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: false, isCaseMigrationAction: true, "sourceSystemCode": 10 } });

        expect(showToastHandler).toBeCalledTimes(0);
        expect(component[NavigationMixin.Navigate]).toHaveBeenCalledWith({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: '12345678',
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    });

    it('calls getEncodedDescription to retrieve the encoded product description', async() => {
        getEncodedDescription.mockImplementation((argument) => { return argument });

        let value = await retrieveEncodedDescription('foo');

        expect(getEncodedDescription).toBeCalledWith({ productDescription: 'foo' });
        expect(value).toEqual({ productDescription: 'foo' });
    });

    it('catches an exception while getting encoded product description', async() => {
        getEncodedDescription.mockImplementation(() => { throw new Error('Error') });

        let value = await retrieveEncodedDescription('foo');

        expect(getEncodedDescription).toBeCalledWith({ productDescription: 'foo' });
        expect(value).toBeNull();
    });

    it('calls getGroupPolicyStatus to retrieve the encoded product description', async() => {
        getGroupPolicyStatus.mockImplementation((argument) => { return argument });

        let value = await retrieveGroupPolicyStatus('foo');

        expect(getGroupPolicyStatus).toBeCalledWith({ policyDescription: 'foo' });
        expect(value).toEqual({ policyDescription: 'foo' });
    });

    it('catches an exception while getting group policy status', async() => {
        getGroupPolicyStatus.mockImplementation(() => { throw new Error('Error') });

        let value = await retrieveGroupPolicyStatus('foo');

        expect(getGroupPolicyStatus).toBeCalledWith({ policyDescription: 'foo' });
        expect(value).toBeNull();
    });

    it('catches an exception while getting PLM CS Status', async() => {
        getPLMStatus.mockImplementation(() => { throw new Error('Error') });
        let result = await retrievePLMStatus();
        expect(result).toStrictEqual({});
    });

    it('checks for inactive plm status from Add Vehicle', async() => {
        getPLMStatusForState.mockImplementation(() => { return false; });

        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: '123 4567-F12-34E',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            stateAgentCode: '12-3456',
            agreementIndexId: '54362'
        };

        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        isStateActivatedForPLM("Add Vehicle", paramObj, component, true);

        await flushPromises();

        expect(getPLMStatusForState).toHaveBeenCalledWith({ stateAgentCode: '34' });
        expect(getTargetAutoPolicyForState).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "Add Vehicle", agentAssociateId: "agentAssocId", agreementIndexId: '54362', lob: "Auto", policyNumber: "123 4567-F12-34E", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: false, isCaseMigrationAction: true } });
        expect(showToastHandler).not.toHaveBeenCalled();
    });

    it('checks for active plm status with no target policies', async() => {
        getPLMStatusForState.mockImplementation(() => { return true; });

        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: '123 4567-F12-34E',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            stateAgentCode: '12-3456',

        };

        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        isStateActivatedForPLM("Add Vehicle", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(getPLMStatusForState).toHaveBeenCalledWith({ stateAgentCode: '34' });
        expect(getTargetAutoPolicyForState).toHaveBeenCalledWith({ agentAssocId: paramObj.agentAssociateId, accountId: paramObj.accountRecordId });
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('NOTICE: During PolicyCenter migration, this added vehicle must be processed as a new submission.');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('Please create a New Opportunity to start a quote.');
        getPLMStatusForState.mockClear();
    });

    it('checks for active plm status with target policies', async() => {
        getPLMStatusForState.mockImplementation(() => { return true; });
        getTargetAutoPolicyForState.mockImplementation(() => { return true; });

        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: '123 4567-F12-34E',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            stateAgentCode: '12-3456'
        };

        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        isStateActivatedForPLM("Add Vehicle", paramObj, component, true);

        await flushPromises();

        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(getPLMStatusForState).toHaveBeenCalledWith({ stateAgentCode: '34' });
        expect(getTargetAutoPolicyForState).toHaveBeenCalledWith({ agentAssocId: paramObj.agentAssociateId, accountId: paramObj.accountRecordId });
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('NOTICE: This customer has an existing modernized policy.');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('Please navigate to that policy and select Add Vehicle.');
        getPLMStatusForState.mockClear();
        getTargetAutoPolicyForState.mockClear();
    });

    it('checks for inactive plm status from Add Vehicle for non cm action', async() => {
        getPLMStatusForState.mockImplementation(() => { return false; });

        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: '123 4567-F12-34E',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            stateAgentCode: '12-3456',
            agreementIndexId: '54362'
        };

        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        isStateActivatedForPLM("Add Vehicle", paramObj, component);

        await flushPromises();

        expect(getPLMStatusForState).toHaveBeenCalledWith({ stateAgentCode: '34' });
        expect(getTargetAutoPolicyForState).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "Add Vehicle", agentAssociateId: "agentAssocId", agreementIndexId: '54362', lob: "Auto", policyNumber: "123 4567-F12-34E", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: false, isCaseMigrationAction: false } });
        expect(showToastHandler).not.toHaveBeenCalled();
    });

    it('checks for active plm status with invalid policy number', async() => {
        getPLMStatusForState.mockImplementation(() => { return true; });
        getTargetAutoPolicyForState.mockImplementation(() => { return true; });

        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: '1234567891234567',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            stateAgentCode: '12-3456'
        };

        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component[NavigationMixin.Navigate] = jest.fn();

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        isStateActivatedForPLM("Add Vehicle", paramObj, component, true);

        await flushPromises();

        expect(getPLMStatusForState).not.toHaveBeenCalled();
        expect(getTargetAutoPolicyForState).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toBeCalledWith({ inputData: { actionValue: "Add Vehicle", agentAssociateId: "agentAssocId", lob: "Auto", policyNumber: "1234567891234567", productDescription: "Prod Description", accountRecordId: "12345678", agreAccessKey: '123', isLegacyPolicy: false, isCaseMigrationAction: true } });
        getPLMStatusForState.mockClear();
        getTargetAutoPolicyForState.mockClear();
    });

    it('calls createPolicyTransationCase and performs navigation to case message - sourceSystemCode 24', async() => {
        let paramObj = {
            accountRecordId: '12345678',
            lob: 'A',
            policyNumber: 'ABC 50-12345',
            agentAssociateId: 'agentAssocId',
            productDescription: 'Prod Description',
            agreAccessKey: '123',
            agreementIndexId: '470862496',
            sourceSystemCode: 24
        };
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        component.recordId = '123';
        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });

        component.saPCAgreementIndexID = paramObj.agreementIndexId;
        component.sapcparamObject = paramObj;
        component.policyNumber = 'ZYX 99-98765';

        paramObj.sourceSystemCode = PERSONAL_AUTO_MOD_CD;

        await launchNewCase("caseReason", paramObj, component, true);
        await flushPromises();

        expect(paramObj.sourceSystemCode).toBeTruthy();
        expect(paramObj.sourceSystemCode).toStrictEqual(24);
        const expectedCaseParam = {
            accountRecordId: paramObj.accountRecordId,
            lob: 'Auto',
            policyNumber: component.policyNumber,
            actionValue: "caseReason",
            agentAssociateId: paramObj.agentAssociateId,
            productDescription: paramObj.productDescription,
            agreAccessKey: paramObj.agreAccessKey,
            agreementIndexId: paramObj.agreementIndexId,
            isCaseMigrationAction: true,
            isLegacyPolicy: false,
            sourceSystemCode: 24
        };
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({ inputData: expectedCaseParam });
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.policyNumber).toEqual(component.policyNumber);
        expect(createPolicyTransactionCase.mock.calls[0][0].inputData.policyNumber).not.toEqual(paramObj.policyNumber);
    });

    it('calls handleAddVehicle - mod private passenger', async () => {
        jest.spyOn(actions, 'launchAutoPolicyAction');
        const mockNavigation = jest.fn(() => {});
        const paramObject = {
            productDescription: 'value',
            sourceSystemCode: 24
        };
        let component = {
            policyTypeCode: '0',
            plmActivationStatus: {
                isOppRedirectActive: true,
                isPCAutoLaunchActive: true
            }
        };
        component[NavigationMixin.Navigate] = mockNavigation;
        createPolicyTransactionCase.mockImplementation(() => {return '12345678'});
        await handleAddVehicle(paramObject, component);
        expect(mockNavigation).toHaveBeenCalled();
        expect(actions.launchAutoPolicyAction).toHaveBeenCalled();
    });

    it('calls handleAddVehicle - non private passneger policy type code', async () => {
        const mockNavigation = jest.fn();
        const paramObject = {
            productDescription: 'value',
            sourceSystemCode: 1
        };
        let component = {
            policyTypeCode: '9',
            plmActivationStatus: {
                isOppRedirectActive: true,
                isPCAutoLaunchActive: true
            }
        };
        isHatsorHa4cUser.mockResolvedValueOnce(true);
        component[NavigationMixin.Navigate] = mockNavigation;
        createPolicyTransactionCase.mockImplementation(() => {return '12345678'});
        await handleAddVehicle(paramObject, component);
        expect(mockNavigation).toHaveBeenCalled();
        expect(actions.launchAutoPolicyAction).not.toHaveBeenCalled();
    });

    it('calls handleAddVehicle - opp redirect disabled', async () => {
        const mockNavigation = jest.fn();
        const paramObject = {
            productDescription: 'value',
            sourceSystemCode: 1
        };
        let component = {
            policyTypeCode: '0',
            plmActivationStatus: {
                isOppRedirectActive: false,
                isPCAutoLaunchActive: true
            }
        };
        component[NavigationMixin.Navigate] = mockNavigation;
        isHatsorHa4cUser.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => {return '12345678'});
        await handleAddVehicle(paramObject, component);
        expect(mockNavigation).toHaveBeenCalled();
        expect(actions.launchAutoPolicyAction).not.toHaveBeenCalled();
    });

    it('calls handleAddVehicle - no case with oppty redirect', async () => {
        const mockNavigation = jest.fn();
        const paramObject = {
            productDescription: 'value',
            sourceSystemCode: 1,
            policyNumber: '123 4567-A89-12B'
        };
        let component = {
            policyTypeCode: '0',
            plmActivationStatus: {
                isOppRedirectActive: true,
                isPCAutoLaunchActive: true
            }
        };
        component[NavigationMixin.Navigate] = mockNavigation;
        component.dispatchEvent = jest.fn();
        createPolicyTransactionCase.mockImplementation(() => {return '12345678'});
        getPLMStatusForState.mockImplementation(() => { return true; });
        getTargetAutoPolicyForState.mockImplementation(() => { return true; });
        await handleAddVehicle(paramObject, component);
        expect(mockNavigation).not.toHaveBeenCalled();
        expect(component.dispatchEvent).toHaveBeenCalled();
    });
    
    
    it('should not open the sae modal for a non-plm mod auto policy', async () => {
        const paramObj = {
            sourceSystemCode: 1
        };
        const component = {
            plmActivationStatus: { isPCAutoLaunchActive: false }
        };
        const mockNavigation = jest.fn();
        component[NavigationMixin.Navigate] = mockNavigation;
        createPolicyTransactionCase.mockImplementation(() => { return '12345678' });
        await handlePolicyChange(paramObj, component);
        expect(createPolicyTransactionCase).toHaveBeenCalled();
        expect(mockNavigation).toHaveBeenCalled();
    });

    it('should return assets list when attempting to retrieve ip assets with proper ID', async() => {
        let mockIpAssetRecord = { amIAnIpAsset: 'Yes I Am' };
        getInsurancePolicyAssets.mockImplementation((requestParam) => {
            if(requestParam.recordId === 123) {
                return [mockIpAssetRecord]
            }
            return [];
        });
        let result = await retrieveIPAssets(123);
        expect(getInsurancePolicyAssets).toHaveBeenCalledWith({ recordId: 123 });
        expect(result).toStrictEqual([mockIpAssetRecord]);
    });
    
    it('should throw exception and return empty list when attempting to retrieve ip assets', async() => {
        getInsurancePolicyAssets.mockImplementation(() => { throw new Error('Error') });
        let result = await retrieveIPAssets();
        expect(result).toStrictEqual([]);
    });
});
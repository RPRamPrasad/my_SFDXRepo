import { createElement } from 'lwc';
import policySummaryCard from 'c/policySummaryCard';

import logException from '@salesforce/apex/InsurancePolicyController.logException';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';

import callout from '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation';

const happyPolicyData = require('./data/happyPolicyData.json');
const dvl200JSON = require('./data/dvlResponse200.json');
const dvl200JSONDifferentDrivers = require('./data/dvlResponse200DifferentDrivers.json');
const dvl200JSONNoRatingAssignments = require('./data/dvlResponse200NoRatingAssignments.json');
const dvl200JSONNoCoverage = require('./data/dvlResponse200NoCoverage.json');

//#region Mocks
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant', 
    () => ({ default: jest.fn()  }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.logException',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock(
    '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase',
    () => ({
        default: jest.fn(() => {
            return 'CASE_ID';
        })
    }), { virtual: true }
);
jest.mock("@salesforce/customPermission/PolicySummary_SupportAccess", () => ({ default: false }), { virtual: true });
jest.mock("@salesforce/customPermission/PolicySummary_EarlyAccess", () => ({ default: false }), { virtual: true });

jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionAddDriver',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionAddVehicle',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionAutoPolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionBos',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionCoi',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionEmailAutoId',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionFirePolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionHealthPolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionLifePolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionPolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionReplaceVehicle',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardActionToofReinstatement',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardAgentLink',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardBillingAcctNum',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardOpenClaim',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickCardPolicyNum',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickToggleShowAllRisks',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation',
    () => ({ default: jest.fn() }), { virtual: true });

//#endregion

window.open = jest.fn();

describe('c-policy-summary-card', () => {
    let policySummaryCardComp;
    let dvl200;
    let dvl200DiffDrivers;
    let dvl200NoCoverage;
    let dvl200NoRatingAssignments;

    beforeEach(() => {
        jest.clearAllMocks();
        jest.resetAllMocks();
        jest.resetModules();
        logException.mockImplementation(() => jest.fn());
        callout.mockImplementation(() => jest.fn());

        dvl200 = Object.assign({}, dvl200JSON);
        dvl200.body = JSON.stringify(dvl200JSON.body);

        dvl200DiffDrivers = Object.assign({}, dvl200JSONDifferentDrivers);
        dvl200DiffDrivers.body = JSON.stringify(dvl200JSONDifferentDrivers.body);

        dvl200NoCoverage = Object.assign({}, dvl200JSONNoCoverage);
        dvl200NoCoverage.body = JSON.stringify(dvl200JSONNoCoverage.body);

        dvl200NoRatingAssignments = Object.assign({}, dvl200JSONNoRatingAssignments);
        dvl200NoRatingAssignments.body = JSON.stringify(dvl200JSONNoRatingAssignments.body);

        policySummaryCardComp = createElement('c-policy-summary-card', {
            is: policySummaryCard
        });
    })
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        policySummaryCardComp = null;
        jest.clearAllMocks();
        jest.resetAllMocks();
        jest.resetModules();
    })

    const { setImmediate } = require('timers')
    function flushPromises() {
        return new Promise(resolve => setImmediate(resolve));
    }

    //#region Enhance Summary
    it('should render enhance button for no special access', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvl200NoCoverage);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(happyPolicyData.PolicyName);
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]')).toBeTruthy();
    });
    //#endregion
})

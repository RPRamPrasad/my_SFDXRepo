import { createElement } from 'lwc';
import policySummaryCard from 'c/policySummaryCard';

import logException from '@salesforce/apex/InsurancePolicyController.logException';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import logClickEnhanceSummary from '@salesforce/apex/PolicySummaryEventController.logClickEnhanceSummary';

import callout from '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation';

const happyPolicyData = require('./data/happyPolicyData.json');
const dvl200JSON = require('./data/dvlResponse200.json');
const dvl200JSONMismatchRisks = require('./data/dvlResponse200MismatchRisks.json');
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
jest.mock("@salesforce/customPermission/PolicySummary_EarlyAccess", () => ({ default: true }), { virtual: true });

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
    '@salesforce/apex/PolicySummaryEventController.logClickEnhanceSummary',
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
    let dvl200MismatchRisks;

    beforeEach(() => {
        jest.clearAllMocks();
        jest.resetAllMocks();
        jest.resetModules();
        logException.mockImplementation(() => jest.fn());
        callout.mockImplementation(() => jest.fn());

        dvl200 = Object.assign({}, dvl200JSON);
        dvl200.body = JSON.stringify(dvl200JSON.body);

        dvl200MismatchRisks = Object.assign({}, dvl200JSONMismatchRisks);
        dvl200MismatchRisks.body = JSON.stringify(dvl200JSONMismatchRisks.body);

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

    function calculateAge(dob) { 
        let diffMs = Date.now() - new Date(dob).getTime();
        let ageDt = new Date(diffMs); 
        
        return Math.abs(ageDt.getUTCFullYear() - 1970);
    }
    function buildAgeList(list) {
        let ageList = []
        
        for (let role of list) {
            if (role.party?.birthDate) {
                if (!ageList.includes(calculateAge(role.party?.birthDate))) {
                    ageList.push(calculateAge(role.party?.birthDate))
                }
            }
        }

        return ageList;
    }

    //#region Enhance Summary
    it('should render enhanced summary for card button click with no coverages', async () => {
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

        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalledTimes(1);
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeTruthy();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(callout).toHaveBeenCalledTimes(1);
        expect(logClickEnhanceSummary).toHaveBeenCalled();

        const coverages = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=coverage]')
        expect(coverages.length).toEqual(0)

        const driverNames = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]')
        expect(driverNames.length).toEqual(6)
        expect(driverNames[0].textContent).toEqual('SONIA')
        expect(driverNames[1].textContent).toEqual('AURELIANO')
        expect(driverNames[2].textContent).toEqual('MADALINE')
        expect(driverNames[3].textContent).toEqual('EVA')
        expect(driverNames[4].textContent).toEqual('JOEL')
        expect(driverNames[5].textContent).toEqual('GILBERTO')

        // const driverAges = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        // expect(driverAges.length).toEqual(6)
        // expect(driverAges[0].textContent).toEqual(' (49)')
        // expect(driverAges[1].textContent).toEqual(' (34)')
        // expect(driverAges[2].textContent).toEqual(' (29)')
        // expect(driverAges[3].textContent).toEqual(' (68)')
        // expect(driverAges[4].textContent).toEqual(' (44)')
        // expect(driverAges[5].textContent).toEqual(' (24)')

        const driverAgeComps = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        const driverAges = [];
        driverAgeComps.forEach(ageComp => { driverAges.push(ageComp.textContent) })
        expect(driverAges.length).toEqual(6)

        let ageList = buildAgeList(JSON.parse(dvl200NoCoverage.body).policy.termVersion.insurableRisk[0].riskPartyRole);

        expect(ageList.length).toEqual(driverAges.length) // 6 length
        expect(driverAges).toContain(' (' + ageList[0] + ')')
        expect(driverAges).toContain(' (' + ageList[1] + ')')
        expect(driverAges).toContain(' (' + ageList[2] + ')')
        expect(driverAges).toContain(' (' + ageList[3] + ')')
        expect(driverAges).toContain(' (' + ageList[4] + ')')
        expect(driverAges).toContain(' (' + ageList[5] + ')')

        const driverTypes = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=operator-type]')
        expect(driverTypes.length).toEqual(3)
        expect(driverTypes[0].textContent).toEqual(' P/A')
        expect(driverTypes[1].textContent).toEqual(' A')
        expect(driverTypes[2].textContent).toEqual(' A')
    });
    it('should render enhanced summary for card button click', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvl200);

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

        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalledTimes(1);
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        const dssIcon = policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')
        expect(dssIcon).toBeTruthy();
        expect(dssIcon.title).toEqual('Drive Safe & Save\u2122');

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(callout).toHaveBeenCalledTimes(1);

        const coverages = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=coverage]')
        expect(coverages.length).toEqual(8)
        expect(coverages[0].label).toEqual('A 250/500')
        expect(coverages[1].label).toEqual('A 100')
        expect(coverages[2].label).toEqual('C 5000')
        expect(coverages[3].label).toEqual('D 1000')
        expect(coverages[4].label).toEqual('G 1000')
        expect(coverages[5].label).toEqual('H')
        expect(coverages[6].label).toEqual('U 250/500')
        expect(coverages[7].label).toEqual('W 250/500')
    });
    it('should render enhanced summary for card button click with different drivers', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvl200DiffDrivers);

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

        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalledTimes(1);
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeFalsy();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(callout).toHaveBeenCalledTimes(1);

        const driverNames = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]')
        expect(driverNames.length).toEqual(7)
        expect(driverNames[0].textContent).toEqual('SONIA')
        expect(driverNames[1].textContent).toEqual('EVA')
        expect(driverNames[2].textContent).toEqual('EVA')
        expect(driverNames[3].textContent).toEqual('JOEL')
        expect(driverNames[4].textContent).toEqual('AURELIANO')
        expect(driverNames[5].textContent).toEqual('MADALINE')
        expect(driverNames[6].textContent).toEqual('GILBERTO')

        // const driverAges = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        // expect(driverAges.length).toEqual(7)
        // expect(driverAges[0].textContent).toEqual(' (49)')
        // expect(driverAges[1].textContent).toEqual(' (68)')
        // expect(driverAges[2].textContent).toEqual(' (68)')
        // expect(driverAges[3].textContent).toEqual(' (44)')
        // expect(driverAges[4].textContent).toEqual(' (34)')
        // expect(driverAges[5].textContent).toEqual(' (29)')
        // expect(driverAges[6].textContent).toEqual(' (24)')

        const driverAgeComps = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        const driverAges = [];
        driverAgeComps.forEach(ageComp => { driverAges.push(ageComp.textContent) })
        expect(driverAges.length).toEqual(7)

        let ageList = buildAgeList(JSON.parse(dvl200DiffDrivers.body).policy.termVersion.insurableRisk[0].riskPartyRole);

        expect(ageList.length).toEqual(driverAges.length) // 6 length
        expect(driverAges).toContain(' (' + ageList[0] + ')')
        expect(driverAges).toContain(' (' + ageList[1] + ')')
        expect(driverAges).toContain(' (' + ageList[2] + ')')
        expect(driverAges).toContain(' (' + ageList[3] + ')')
        expect(driverAges).toContain(' (' + ageList[4] + ')')
        expect(driverAges).toContain(' (' + ageList[5] + ')')
        expect(driverAges).toContain(' (' + ageList[6] + ')')

        const driverTypes = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=operator-type]')
        expect(driverTypes.length).toEqual(1)
        expect(driverTypes[0].textContent).toEqual(' P')

        const coverages = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=coverage]')
        expect(coverages.length).toEqual(10)
        expect(coverages[0].label).toEqual('A 100')
        expect(coverages[1].label).toEqual('A 250/500')
        expect(coverages[2].label).toEqual('C 5000')
        expect(coverages[3].label).toEqual('D 1000')
        expect(coverages[4].label).toEqual('G 1000')
        expect(coverages[5].label).toEqual('H')
        expect(coverages[6].label).toEqual('H')
        expect(coverages[7].label).toEqual('U 250/500')
        expect(coverages[8].label).toEqual('U 250/500')
        expect(coverages[9].label).toEqual('W 250/500')
    });
    it('should render enhanced summary for card button click with no rating assignments', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvl200NoRatingAssignments);

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

        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalledTimes(1);
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeFalsy();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(callout).toHaveBeenCalledTimes(1);

        const driverNames = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]')
        expect(driverNames.length).toEqual(7)
        expect(driverNames[0].textContent).toEqual('EVA')
        expect(driverNames[1].textContent).toEqual('EVA')
        expect(driverNames[2].textContent).toEqual('SONIA')
        expect(driverNames[3].textContent).toEqual('JOEL')
        expect(driverNames[4].textContent).toEqual('AURELIANO')
        expect(driverNames[5].textContent).toEqual('MADALINE')
        expect(driverNames[6].textContent).toEqual('GILBERTO')

        // const driverAges = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        // expect(driverAges.length).toEqual(7)
        // expect(driverAges[0].textContent).toEqual(' (68)')
        // expect(driverAges[1].textContent).toEqual(' (68)')
        // expect(driverAges[2].textContent).toEqual(' (49)')
        // expect(driverAges[3].textContent).toEqual(' (44)')
        // expect(driverAges[4].textContent).toEqual(' (34)')
        // expect(driverAges[5].textContent).toEqual(' (29)')
        // expect(driverAges[6].textContent).toEqual(' (24)')

        const driverAgeComps = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        const driverAges = [];
        driverAgeComps.forEach(ageComp => { driverAges.push(ageComp.textContent) })
        expect(driverAges.length).toEqual(7)

        let ageList = buildAgeList(JSON.parse(dvl200NoRatingAssignments.body).policy.termVersion.insurableRisk[0].riskPartyRole);

        expect(ageList.length).toEqual(driverAges.length) // 6 length
        expect(driverAges).toContain(' (' + ageList[0] + ')')
        expect(driverAges).toContain(' (' + ageList[1] + ')')
        expect(driverAges).toContain(' (' + ageList[2] + ')')
        expect(driverAges).toContain(' (' + ageList[3] + ')')
        expect(driverAges).toContain(' (' + ageList[4] + ')')
        expect(driverAges).toContain(' (' + ageList[5] + ')')
        expect(driverAges).toContain(' (' + ageList[6] + ')')

        const driverTypes = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=operator-type]')
        expect(driverTypes.length).toEqual(0)

        const coverages = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=coverage]')
        expect(coverages.length).toEqual(10)
        expect(coverages[0].label).toEqual('A 100')
        expect(coverages[1].label).toEqual('A 250/500')
        expect(coverages[2].label).toEqual('C 5000')
        expect(coverages[3].label).toEqual('D 1000')
        expect(coverages[4].label).toEqual('G 1000')
        expect(coverages[5].label).toEqual('H')
        expect(coverages[6].label).toEqual('H')
        expect(coverages[7].label).toEqual('U 250/500')
        expect(coverages[8].label).toEqual('U 250/500')
        expect(coverages[9].label).toEqual('W 250/500')
    });
    it('should render enhanced summary for card api method', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvl200);

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

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeTruthy();
    });
    it('should handle error for enhanced summary', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockRejectedValueOnce(new Error('ERROR ENHANCING SUMMARY'));

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

        //do enhanced stuff
        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalled();
        expect(logException).toHaveBeenCalledTimes(1);
        expect(logException).toHaveBeenCalledWith({
            "message": "Summary Data Enhance failed: \"ERROR ENHANCING SUMMARY\"",
            "method": "policySummaryCard.enhancePolicy",
        });
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=error]')).toBeTruthy();
    });
    it('should render enhanced summary for policy with no matching risks', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvl200MismatchRisks);

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

        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalledTimes(1);
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeFalsy();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(callout).toHaveBeenCalledTimes(1);

        const coverages = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=coverage]')
        expect(coverages.length).toEqual(0)
    });
    //#endregion
})

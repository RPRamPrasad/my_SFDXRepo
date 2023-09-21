import { createElement } from 'lwc';
import policySummaryCard from 'c/policySummaryCard';

import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import getAccountData from '@salesforce/apex/InsurancePolicyController.getAccountData';
import logException from '@salesforce/apex/InsurancePolicyController.logException';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';
import getPrimaryInsurancePolicyParticipant from '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant';

import logClickCardActionAddDriver from '@salesforce/apex/PolicySummaryEventController.logClickCardActionAddDriver';
import logClickCardActionAddVehicle from '@salesforce/apex/PolicySummaryEventController.logClickCardActionAddVehicle';
import logClickCardActionAutoPolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickCardActionAutoPolicyChange';
import logClickCardActionBos from '@salesforce/apex/PolicySummaryEventController.logClickCardActionBos';
import logClickCardActionCoi from '@salesforce/apex/PolicySummaryEventController.logClickCardActionCoi';
import logClickCardActionEmailAutoId from '@salesforce/apex/PolicySummaryEventController.logClickCardActionEmailAutoId';
import logClickCardActionFirePolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickCardActionFirePolicyChange';
import logClickCardActionHealthPolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickCardActionHealthPolicyChange';
import logClickCardActionLifePolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickCardActionLifePolicyChange';
import logClickCardActionPolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickCardActionPolicyChange';
import logClickCardActionReplaceVehicle from '@salesforce/apex/PolicySummaryEventController.logClickCardActionReplaceVehicle';
import logClickCardActionToofReinstatement from '@salesforce/apex/PolicySummaryEventController.logClickCardActionToofReinstatement';
import logClickCardAgentLink from '@salesforce/apex/PolicySummaryEventController.logClickCardAgentLink';
import logClickCardBillingAcctNum from '@salesforce/apex/PolicySummaryEventController.logClickCardBillingAcctNum';
import logClickCardOpenClaim from '@salesforce/apex/PolicySummaryEventController.logClickCardOpenClaim';
import logClickCardPolicyNum from '@salesforce/apex/PolicySummaryEventController.logClickCardPolicyNum';
import logClickToggleShowAllRisks from '@salesforce/apex/PolicySummaryEventController.logClickToggleShowAllRisks';
import logClickEnhanceSummary from '@salesforce/apex/PolicySummaryEventController.logClickEnhanceSummary';
import isHatsorHa4cUser from '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser';

import callout from '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation';

import { getNavigateCalledWith } from 'lightning/navigation';

const happyPolicyData = require('./data/happyPolicyData.json');
const policyData = require('./data/policyTestData.json');
const happyAutoPolicy2 = require('./data/happyAutoPolicy2.json');
const autoLegacyMultiCar = require('./data/happyMultiCarAutoPolicy.json');
const autoModMultiCar = require('./data/modAutoMultiCarPolicy.json');
const autoModCommercial = require('./data/modCommercialAuto.json');
const autoAntique = require('./data/antiqueAuto.json');
const autoModSingleRisk = require('./data/autoModSingleRisk.json');
const fleetPolicy = require('./data/fleetPolicy.json');
const homeownersPolicy = require('./data/happyFirePolicyData.json');
const homeownersPolicyCOI = require('./data/homeownersPolicyCOI.json');
const happyPhxLifePolicy = require('./data/happyPhxLifePolicy.json');
const fireModCommercial = require('./data/modCommercialFire.json');
const lifePolicy = require('./data/lifePolicy.json');
const lifePolicy2 = require('./data/lifePolicy2.json');
const lifePolicyAS = require('./data/lifePolicyAS.json');
const lifePolicyNonPMR = require('./data/lifePolicyNonPMR.json');
const healthPolicy = require('./data/healthPolicy.json');
const happyPolicyDataTerminated = require('./data/happyPolicyDataTerminated.json');
const happyFirePolicyTerminated = require('./data/happyFirePolicyTerminated.json');
const policyMissingData = require('./data/policyMissingData.json');
const policyWithSfBilling = require('./data/policyWithSfBilling.json');
const policyWithSfBilling2 = require('./data/policyWithSfBilling2.json');
const modAutoMultiCarNotPrivatePassenger = require('./data/modAutoMultiCarNotPrivatePassenger.json');
const autoIncompleteData = require('./data/happyPolicyDataIncompleteRecord.json');
const autoNoServicingAgent = require('./data/happyPolicyDataNoServicingAgent.json')
const dvl200JSON = require('./data/dvlResponse200.json');
const dvl200JSONMismatchRisks = require('./data/dvlResponse200MismatchRisks.json');
const dvl200JSONDifferentDrivers = require('./data/dvlResponse200DifferentDrivers.json');
const dvl200JSONNoRatingAssignments = require('./data/dvlResponse200NoRatingAssignments.json');
const dvl200JSONNoCoverage = require('./data/dvlResponse200NoCoverage.json');
const dvlModAutoWithNoDriverNames = require('./data/dvlModAutoWithNoDriverNames.json');
const dvlModAutoWithNoClientIds = require('./data/dvlModAutoWithNoClientIds.json');

const suretyBondPolicy = require('./data/suretyBondPolicy.json');
const dvlSuretyBondFire = require('./data/dvlResponse200SuretyBond.json');

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
jest.mock(
    '@salesforce/apex/InsurancePolicyController.getAccountData',
    () => ({ default: jest.fn() }), { virtual: true }
);
jest.mock('@salesforce/customPermission/SAE_Policy_Change', () => ({ default: false }), { virtual: true });
jest.mock("@salesforce/customPermission/PolicySummary_SupportAccess", () => ({ default: true }), { virtual: true });
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
    '@salesforce/apex/PolicySummaryEventController.logClickEnhanceSummary',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation',
    () => ({ default: jest.fn() }), { virtual: true });

jest.mock(
    '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser',
    () => ({ default: jest.fn() }), { virtual: true }
);

//#endregion

window.open = jest.fn();

describe('c-policy-summary-card', () => {
    let policySummaryCardComp;
    let allActions = [
        logClickCardActionAddDriver,
        logClickCardActionAddVehicle,
        logClickCardActionAutoPolicyChange,
        logClickCardActionBos,
        logClickCardActionCoi,
        logClickCardActionEmailAutoId,
        logClickCardActionFirePolicyChange,
        logClickCardActionHealthPolicyChange,
        logClickCardActionLifePolicyChange,
        logClickCardActionPolicyChange,
        logClickCardActionReplaceVehicle,
        logClickCardActionToofReinstatement,
        logClickCardAgentLink,
        logClickCardBillingAcctNum,
        logClickCardOpenClaim,
        logClickCardPolicyNum,
        logClickToggleShowAllRisks
    ];
    let dvl200;
    let dvl200DiffDrivers;
    let dvl200NoCoverage;
    let dvl200NoRatingAssignments;
    let dvl200MismatchRisks;
    let dvlModNoDrivers;
    let dvlModNoClientIds;
    let dvlSuretyBond;

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

        dvlModNoDrivers = Object.assign({}, dvlModAutoWithNoDriverNames);
        dvlModNoDrivers.body = JSON.stringify(dvlModAutoWithNoDriverNames.body);

        dvlModNoClientIds = Object.assign({}, dvlModAutoWithNoClientIds);
        dvlModNoClientIds.body = JSON.stringify(dvlModAutoWithNoClientIds.body);

        dvlSuretyBond = Object.assign({}, dvlSuretyBondFire);
        dvlSuretyBond.body = JSON.stringify(dvlSuretyBondFire.body);

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

    function assertActions(expectedActionFunc, times) {
        allActions.forEach(actionFunc => {
            if (actionFunc !== expectedActionFunc) {
                expect(actionFunc).not.toHaveBeenCalled();
            }
            else {
                if (times) {
                    expect(actionFunc).toHaveBeenCalledTimes(times);
                }
                else {
                    expect(actionFunc).toHaveBeenCalled();
                }
            }
        });
    }

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

    //#region Happy Path    
    it('should render list item happy path', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(happyPolicyData.PolicyName);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('11/20/2017');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('05/20/2022');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term"][class="slds-m-right_medium red-text"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627224');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-status]')).toBe(null);

        expect(logException).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Private Passenger"});
        assertActions();
    });

    it('should render list item with incomplete policy data', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = autoIncompleteData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('11/20/2017');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('05/20/2022');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term"][class="slds-m-right_medium red-text"]')).toBeFalsy();

        expect(logException).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": undefined});
        assertActions();
    });

    it('should display "Proposed" status badge', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        
        policySummaryCardComp.policy = {
            ...happyPolicyData,
            Status: "Proposed"};

        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-status]').getAttribute('title')).toEqual("Proposed status applies to a policy not yet In Force. Some amount of processing is required before policy coverage begins.");

        expect(logException).not.toHaveBeenCalled();
        assertActions();
    });

    it('should display "Suspended" status badge', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        
        policySummaryCardComp.policy = {
            ...happyPolicyData,
            Status: "Suspended"};

        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-status]').getAttribute('title')).toEqual("Suspended status applies when a policy is temporarily suspended, with intention of coverage resuming in the future.");

        expect(logException).not.toHaveBeenCalled();
        assertActions();
    });

    it('should display default status badge', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        
        policySummaryCardComp.policy = {
            ...happyPolicyData,
            Status: "Not Real Status"};

        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-status]').getAttribute('title')).toEqual("");

        expect(logException).not.toHaveBeenCalled();
        assertActions();
    });

    it('should display Lightning Card is displayed - And Agent link is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = policyData.data1;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        window.open = jest.fn();
        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term-label"]').textContent).toEqual('Renewal');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term"][class="slds-m-right_medium red-text"]')).toBeFalsy();
        const agentLink = policySummaryCardComp.shadowRoot.querySelector('[data-id="launch-agent"]');
        expect(agentLink).toBeTruthy();
        expect(agentLink.textContent).toEqual('Travis Foster (PPY6)');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]')).toBeFalsy();

        return Promise.resolve()
            .then(() => {
                const launchAgent = policySummaryCardComp.shadowRoot.querySelector('a[data-id="launch-agent"]');
                launchAgent.click();

                expect(window.open).toHaveBeenCalledWith(`/c/ExternalLinkApp.app?linkId=26&primaryStateCode=55&primaryAgentCode=3313`);
                assertActions(logClickCardAgentLink);
            })
    });

    it('should display Lightning Card is displayed - And Agent link is clicked with no servicing agent', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = autoNoServicingAgent;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        window.open = jest.fn();
        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term-label"]').textContent).toEqual('Renewal');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term"][class="slds-m-right_medium red-text"]')).toBeFalsy();
        const agentLink = policySummaryCardComp.shadowRoot.querySelector('[data-id="launch-agent"]');
        expect(agentLink).toBeTruthy();
        expect(agentLink.textContent).toEqual('--');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]')).toBeFalsy();

        return Promise.resolve()
            .then(() => {
                const launchAgent = policySummaryCardComp.shadowRoot.querySelector('a[data-id="launch-agent"]');
                launchAgent.click();

                expect(window.open).toHaveBeenCalledWith(`/c/ExternalLinkApp.app?linkId=26&primaryStateCode=undefined&primaryAgentCode=undefined`);
                assertActions(logClickCardAgentLink);
            })
    });

    it('should click on show/hide risk label', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = policyData.data2;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        return Promise.resolve()
            .then(() => {
                const agentLink = policySummaryCardComp.shadowRoot.querySelector('[data-id="launch-agent"]');
                expect(agentLink).toBeTruthy();
                expect(agentLink.textContent).toEqual('--');

                const showHideText = policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]').label;
                expect(showHideText).toEqual('Show all (26)');
            })
            // click show all risks
            .then(() => {
                const clickShowAll = policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]');
                clickShowAll.click();
                document.body.appendChild(policySummaryCardComp);

                // button changes to Hide
                const showHideText = policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]').label;
                expect(showHideText).toEqual('Hide');
            })
            // click Hide and show only 6 risks
            .then(() => {
                const clickShowAll = policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]');
                clickShowAll.click();
                document.body.appendChild(policySummaryCardComp);

                // button changes to Show all
                const showHideText = policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]').label;
                expect(showHideText).toEqual('Show all (26)');
                assertActions(logClickToggleShowAllRisks, 2);
            });
    });
    it('should render sorted risks for auto legacy multi car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoLegacyMultiCar;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        const risks = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id="multi-car-risk-title"]')
        expect(risks.length).toEqual(6);
        expect(risks[0].textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        expect(risks[1].textContent).toEqual('002: 2014 FORD F150 PICKUP');
        expect(risks[2].textContent).toEqual('003: 2017 CHEVY VOLT');
        expect(risks[3].textContent).toEqual('004: 2016 TESLA MODEL S');
        expect(risks[4].textContent).toEqual('004: 2021 CHEVY SILVERADO');
        expect(risks[5].textContent).toEqual('007: 1965 FORD MUSTANG FASTBACK');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]')).toBeFalsy();
    });
    it('should render sorted risks for mod commercial auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoModCommercial;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        const risks = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id="non-lmc-risk-title"]')
        expect(risks.length).toEqual(4);
        expect(risks[0].textContent).toEqual('Vehicle#001 :Truck/Van 2015 INTL 4300M7 in Illinois');
        expect(risks[1].textContent).toEqual('Vehicle#003 :Truck/Van 2012 MERCEDES 2500 in Illinois');
        expect(risks[2].textContent).toEqual('Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois');
        expect(risks[3].textContent).toEqual('Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois');
    });
    it('should render sorted risks for auto fleet', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = fleetPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        const risks = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id="non-lmc-sa-risk-title"]')
        expect(risks.length).toEqual(6);
        expect(risks[0].textContent).toEqual('2022 NEX EXA TRL TANK');
        expect(risks[1].textContent).toEqual('2019 EXA 150BBL TRL TANK');
        expect(risks[2].textContent).toEqual('2018 FORD F350SD UTIL TRK');
        expect(risks[3].textContent).toEqual('2018 EXA TT TRL TANK');
        expect(risks[4].textContent).toEqual('2018 EXA TRL TANK');
        expect(risks[5].textContent).toEqual('2017 PETERBILT 579 TANK TRK');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="show-hide"]')).toBeTruthy();
    });
    it('should copy policy number', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })
        document.execCommand = jest.fn();

        policySummaryCardComp.policy = fleetPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        policySummaryCardComp.shadowRoot.querySelector('[data-id="copyButton"]').click()
        expect(document.execCommand).toHaveBeenCalledWith("copy");
    });
    it('should fail to copy policy number', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })
        document.execCommand = jest.fn(() => { throw new Error('FAILED TO COPY') });

        policySummaryCardComp.policy = fleetPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        policySummaryCardComp.shadowRoot.querySelector('[data-id="copyButton"]').click()
        expect(document.execCommand).toHaveBeenCalledWith("copy");
        expect(logException).toHaveBeenCalledWith({"message": "Failed to copy policy number: \"FAILED TO COPY\"", "method": "policySummaryCard.copyPolicyNumber"});
    });
    //#endregion

    //#region Navigation Tests
    it('should navigate to policy when policy number is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        // click on links and catch navigation
        policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').click();

        await flushPromises();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.recordId).toBe('0YT2C0000008QVqWAM');
        expect(pageReference.attributes.objectApiName).toBe('InsurancePolicy');
        expect(pageReference.attributes.actionName).toBe('view');

        assertActions(logClickCardPolicyNum);
    });
    it('should navigate to bill when bill account is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        // click on links and catch navigation
        policySummaryCardComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').click();

        await flushPromises();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.recordId).toBe('a3Q2C000000wOPHUA2');
        expect(pageReference.attributes.objectApiName).toBe('Billing_Account__c');
        expect(pageReference.attributes.actionName).toBe('view');

        assertActions(logClickCardBillingAcctNum);
    });
    it('should navigate to claim when claim number is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        // click on links and catch navigation
        policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').click();

        await flushPromises();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.recordId).toBe('0Zk2C0000008OISSA2');
        expect(pageReference.attributes.objectApiName).toBe('Claim');
        expect(pageReference.attributes.actionName).toBe('view');

        assertActions(logClickCardOpenClaim);
    });
    //#endregion

    //#region Action List
    it('should render action list properly for legacy auto policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
    });
    it('should render action list properly for mod auto multicar policy thats not private passenger', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = modAutoMultiCarNotPrivatePassenger;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
    });
    it('should render action list properly for legacy auto policy missing access', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
    });
    it('should render action list properly for Homeowners fire policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = homeownersPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('03/19/2022');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term][class="slds-m-right_medium"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]')).toBeFalsy();
    });
    it('should render action list properly for Homeowners fire policy missing access', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = homeownersPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('03/19/2022');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeFalsy();
    });
    it('should render action list properly for terminated Homeowners fire policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyFirePolicyTerminated;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="renew-term-label"]').textContent).toEqual('Termination');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term][class="slds-m-right_medium red-text"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term][class="slds-m-right_medium red-text"]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OITSA2"]').textContent).toEqual('7570P850T');

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeTruthy();
    });
    it('should render action list properly for Phoenix life policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPhxLifePolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="insureds-title"]').textContent).toEqual('Owner');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Pnx Universal Life-Option 1"});
        expect(getPrimaryInsurancePolicyParticipant).toHaveBeenCalledWith({
            "lob": "L",
            "recordId": "0YT2C0000008QW6WAM"
        });
    });

    it('should render action list properly for AS life policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = lifePolicyAS;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="insureds-title"]').textContent).toEqual('Owner');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Universal Life-Option 1"});
        expect(getPrimaryInsurancePolicyParticipant).toHaveBeenCalledWith({
            "lob": "L",
            "recordId": "0YT2C0000008QW6WAM"
        });
    });

    it('should render action list properly for Non PMR life policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = lifePolicyNonPMR;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="insureds-title"]').textContent).toEqual('Owner');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Universal Life-Option 1"});
        expect(getPrimaryInsurancePolicyParticipant).not.toHaveBeenCalled();
    });
    //#endregion

    //#region Error Handling
    it('should render blank values for policy with missing data', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = policyMissingData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger Long Description With A Lot Of Words');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627224');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA3"]').textContent).toEqual('6140R950T');

        const policyAlert = policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-alert]');
        expect(policyAlert).toBeTruthy();
        expect(policyAlert.alerts).toEqual([
            {
                "accountNumber": "1255627224",
                "alertClass": "past-due-red",
                "billingDetailsLink": "/a3Q2C000000wOPHUA2",
                "message": "There is a past due balance on this SFPP account: ",
                "recordId": "a3Q2C000000wOPHUA2",
                "type": "Billing",
            },
        ]);

        expect(logException).not.toHaveBeenCalled();
    });
    it('should render billing alerts for sf billing', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = policyWithSfBilling;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger Long Description With A Lot Of Words');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627251');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA3"]').textContent).toEqual('6140R950T');
        
        const policyAlert = policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-alert]');
        expect(policyAlert).toBeTruthy();
        expect(policyAlert.alerts).toEqual([
            {
                "accountNumber": "1255627251",
                "alertClass": "past-due-red",
                "billingDetailsLink": "/a3Q2C000000wOPHUA2",
                "message": "There is a past due balance on this SF Billing account: ",
                "recordId": "a3Q2C000000wOPHUA2",
                "type": "Billing",
            },
        ]);

        expect(logException).not.toHaveBeenCalled();
    });
    it('should render billing alerts for sf billing2', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = policyWithSfBilling2;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger Long Description With A Lot Of Words');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627252');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA3"]').textContent).toEqual('6140R950T');
        
        const policyAlert = policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-alert]');
        expect(policyAlert).toBeTruthy();
        expect(policyAlert.alerts).toEqual([
            {
                "accountNumber": "1255627252",
                "alertClass": "past-due-red",
                "billingDetailsLink": "/a3Q2C000000wOPHUA2",
                "message": "There is a past due balance on this SF Billing account: ",
                "recordId": "a3Q2C000000wOPHUA2",
                "type": "Billing",
            },
        ]);

        expect(logException).not.toHaveBeenCalled();
    });
    it('should render values for policy with terminated data', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(null);

        policySummaryCardComp.policy = happyPolicyDataTerminated;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('11/20/2017');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('12/31/2021');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=a3Q2C000000wOPHUA2]').textContent).toEqual('1255627224');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=a3Q2C000000wOPHUA3]').textContent).toEqual('1255627225');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=policy-alert]')).toBeFalsy();

        expect(logException).toHaveBeenCalledWith({ method: 'policySummaryCard.connectedCallback', message: 'Failed to retrieve group policy status' });
    });
    it('should log error when actions fail to load', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        isHatsorHa4cUser.mockResolvedValueOnce(false);
        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = null;
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).toHaveBeenCalledWith({ "message": "Error while fetching policy actions: \"Cannot read properties of null (reading 'hasPolicyTransactionAccess')\"", "method": "policySummaryCard.fetchPolicyActions" });
    });
    it('should log error when policy change action fails', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = null;
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).toHaveBeenCalledWith({
            "message": "Failed to make policy change case: \"Cannot read properties of null (reading 'isPCAutoLaunchActive')\"",
            "method": "policySummaryCard.handleAction",
        });
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
    });
    it('should log error when add vehicle action fails', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { throw new Error('CASE ERROR') });

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = null;
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Add Vehicle' },
            bubbles: true
        }));

        await flushPromises();

        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Added Vehicle",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": null,
                "sourceSystemCode": 1
            }
        });
        expect(window.open).not.toHaveBeenCalled();
        expect(logException).toHaveBeenCalledWith({
            "message": "Failed to make add vehicle case: \"Cannot read properties of null (reading 'isPCAutoLaunchActive')\"",
            "method": "policySummaryCard.handleAction",
        });
    });
    //#endregion

    //#region Action Handling
    it('should click Policy Change for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = happyAutoPolicy2;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')?.disabled).toBeFalsy();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": "2013 HYUNDAI ELANTRA 4DR",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickCardActionPolicyChange);
        expect(getPrimaryInsurancePolicyParticipant).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Private Passenger"});
    });

    it('should click Policy Change for auto without servicing agent', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoNoServicingAgent;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')?.disabled).toBeFalsy();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": undefined,
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": "2013 HYUNDAI ELANTRA 4DR",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickCardActionPolicyChange);
        expect(getPrimaryInsurancePolicyParticipant).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Private Passenger"});
    });

    it('should click Policy Change for auto mod multi car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoModMultiCar;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        
        const carDescs = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id="non-lmc-risk-title"]');
        expect(carDescs.length).toEqual(6);
        expect(carDescs[0].textContent).toEqual('2022 Tesla Model S');
        expect(carDescs[1].textContent).toEqual('2017 Lexus Gx 460');
        expect(carDescs[2].textContent).toEqual('2017 Hyundai Azera');
        expect(carDescs[3].textContent).toEqual('2007 Toyota Camry');
        expect(carDescs[4].textContent).toEqual('2007 Nissan Forerunner');
        expect(carDescs[5].textContent).toEqual('2005 Honda Accord');
        
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();

        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E9FWAU"]')).toBeFalsy();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h37J0QAI",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "35P0053574",
                "agreementIndexId": "466341304",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "0053574-SFP-35",
                "productDescription": "2007 Toyota Camry\n2017 Hyundai Azera\n2017 Lexus Gx 460",
                "sourceSystemCode": 24,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickCardActionPolicyChange);
    });
    it('should click Policy Change for auto mod single car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoModSingleRisk;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeFalsy();

        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E9FWAU"]')).toBeFalsy();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h37J0QAI",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "35P0053574",
                "agreementIndexId": "466341304",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "0053574-SFP-35",
                "productDescription": "2007 Toyota Camry\n2017 Hyundai Azera\n2017 Lexus Gx 460",
                "sourceSystemCode": 24,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickCardActionPolicyChange);
    });
    it('should click Policy Change for auto legacy multi car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoLegacyMultiCar;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004FgaWAE"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkcQAA",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "4334599923",
                "agreementIndexId": "474596043",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "459 9923-B01-43-001",
                "productDescription": "2017 FORD EDGE SPORT WG",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionPolicyChange);
    });
    it('should click Policy Change for auto legacy multi car 2', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoLegacyMultiCar;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6xWAE"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6xWAE"]').textContent).toEqual('002: 2014 FORD F150 PICKUP');
        policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6xWAE"]').click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkcQAA",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "4334599923",
                "agreementIndexId": "474596043",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "459 9923-B01-43-002",
                "productDescription": "2014 FORD F150 PICKUP",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickCardActionPolicyChange);
        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
    });
    it('should click Policy Change for auto legacy multi car and then close modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = autoLegacyMultiCar;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="close-modal-button"]')).toBeTruthy();
        policySummaryCardComp.shadowRoot.querySelector('[data-id="close-modal-button"]').click();

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();

        assertActions();
    });
    it('should click Policy Change for auto fleet', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = fleetPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkZQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "Y0RMH3L7000",
                "agreAccessKey": "5572187676",
                "agreementIndexId": "109835519",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "218 7676-E19-55M",
                "productDescription": "Fleet",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionPolicyChange);
    });
    it('should click Policy Change for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = homeownersPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkVQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "KRLYT3JX000",
                "agreAccessKey": "181014Y5820CV5",
                "agreementIndexId": "429006271",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Fire",
                "policyNumber": "14-CV-Y582-5",
                "productDescription": "Homeowners Policy : 167 YORKSHIRE BLVD W",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionPolicyChange);
    });
    it('should click Add Vehicle for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Add Vehicle' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')?.disabled).toBeFalsy();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Added Vehicle",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": true,
                "isLegacyPolicy": true,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": null,
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionAddVehicle);
    });
    it('should click Add Driver for antique auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoAntique;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Add Driver' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=258&intent=changePolicy&agreementNumber=131E621302&stateAgentCode=13-8475');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkaQAA",
                "actionValue": "Added Driver",
                "agentAssociateId": "BDVHYB31DAL",
                "agreAccessKey": "131E621302",
                "agreementIndexId": "424059611",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "E621302-C01-13",
                "productDescription": `Antique Auto : 
Vehicle#001 :Truck/Van 2015 INTL 4300M7 in Illinois
Vehicle#003 :Truck/Van 2012 MERCEDES 2500 in Illinois
Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois`,
                "sourceSystemCode": 28,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionAddDriver);
    });
    it('should click Replace Vehicle for antique auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoAntique;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Replace Vehicle' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=258&intent=changePolicy&agreementNumber=131E621302&stateAgentCode=13-8475');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkaQAA",
                "actionValue": "Replaced Vehicle",
                "agentAssociateId": "BDVHYB31DAL",
                "agreAccessKey": "131E621302",
                "agreementIndexId": "424059611",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "E621302-C01-13",
                "productDescription": `Antique Auto : 
Vehicle#001 :Truck/Van 2015 INTL 4300M7 in Illinois
Vehicle#003 :Truck/Van 2012 MERCEDES 2500 in Illinois
Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois`,
                "sourceSystemCode": 28,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionReplaceVehicle);
    });
    it('should click Auto Policy Change for antique auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = autoAntique;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="insureds-title"]').textContent).toEqual('Insureds');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeFalsy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Auto Policy Change' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=258&intent=changePolicy&agreementNumber=131E621302&stateAgentCode=13-8475');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkaQAA",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "BDVHYB31DAL",
                "agreAccessKey": "131E621302",
                "agreementIndexId": "424059611",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "E621302-C01-13",
                "productDescription": `Antique Auto : 
Vehicle#001 :Truck/Van 2015 INTL 4300M7 in Illinois
Vehicle#003 :Truck/Van 2012 MERCEDES 2500 in Illinois
Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois`,
                "sourceSystemCode": 28,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionAutoPolicyChange);
    });
    it('should click Fire Policy Change for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = fireModCommercial;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="insureds-title"]').textContent).toEqual('Insureds');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Fire Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkVQAQ&agreementIndexId=429006271&clientnamelinkdisabled=Y&NechoAppName=policy&key=14-CV-Y582-5&lineOfBusiness=F&agentAssocId=KRLYT3JX000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "001R000001mOe0CIAS",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "BDVHYB31DAL",
                "agreAccessKey": "11609999999AB0",
                "agreementIndexId": "282751018",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Fire",
                "policyNumber": "11-KJ-9999-6",
                "productDescription": "Business Fire\\n605 N BULLMOOSE DR",
                "sourceSystemCode": 15,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionFirePolicyChange);
    });
    it('should click Life Policy Change for life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => { return {
            PrimaryParticipantAccountId: 'PrimaryParticipantAccountId',
            PrimaryParticipantAccount: {
                ClientIdentifier__c: 'ClientIdentifier__c',
                Name: 'Name',
                PersonEmail: 'PersonEmail'
            }
        }; })

        policySummaryCardComp.policy = lifePolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Life Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=PrimaryParticipantAccountId&agreementIndexId=341448257&clientnamelinkdisabled=Y&NechoAppName=main toc&key=LF-3348-1872&lineOfBusiness=L&agentAssocId=ZKYH31YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkYQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "ZKYH31YS000",
                "agreAccessKey": "P233481872",
                "agreementIndexId": "341448257",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Life",
                "policyNumber": "LF-3348-1872",
                "productDescription": "Universal Life-Option 1: Benson, Charles",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionLifePolicyChange);
        
        expect(getPrimaryInsurancePolicyParticipant).toHaveBeenCalledWith({
            "lob": "L",
            "recordId": "0YT2C0000008QW6WAM",
        });
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Universal Life-Option 1"});
    });

    it('should click Life Policy Change for life with different ni code', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => { return {
            PrimaryParticipantAccountId: 'PrimaryParticipantAccountId',
            PrimaryParticipantAccount: {
                ClientIdentifier__c: 'ClientIdentifier__c',
                Name: 'Name',
                PersonEmail: 'PersonEmail'
            }
        }; })

        policySummaryCardComp.policy = lifePolicy2;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Life Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=PrimaryParticipantAccountId&agreementIndexId=341448257&clientnamelinkdisabled=Y&NechoAppName=main toc&key=LF-3348-1872&lineOfBusiness=L&agentAssocId=ZKYH31YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "PrimaryParticipantAccountId",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "ZKYH31YS000",
                "agreAccessKey": "P233481872",
                "agreementIndexId": "341448257",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Life",
                "policyNumber": "LF-3348-1872",
                "productDescription": "Universal Life-Option 1: Benson, Charles",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionLifePolicyChange);
    });
    it('should click Life Policy Change for life with different ni code but failed role promise', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })
        getPrimaryInsurancePolicyParticipant.mockRejectedValueOnce(new Error('PARTICIPANT ERROR'));

        policySummaryCardComp.policy = lifePolicy2;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Life Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkYQAQ&agreementIndexId=341448257&clientnamelinkdisabled=Y&NechoAppName=main toc&key=LF-3348-1872&lineOfBusiness=L&agentAssocId=ZKYH31YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkYQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "ZKYH31YS000",
                "agreAccessKey": "P233481872",
                "agreementIndexId": "341448257",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Life",
                "policyNumber": "LF-3348-1872",
                "productDescription": "Universal Life-Option 1: Benson, Charles",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionLifePolicyChange);
    });
    it('should have no Life Policy Change for phoenix life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = happyPhxLifePolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeFalsy();
    });

    it('should click Health Policy Change for health', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = healthPolicy;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="insureds-title"]').textContent).toEqual('Owner');
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Health Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Health Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkYQAQ&agreementIndexId=341448258&clientnamelinkdisabled=Y&NechoAppName=main toc&key=XXXXXXX 0039&lineOfBusiness=H&agentAssocId=ZKYH31YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkYQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "ZKYH31YS000",
                "agreAccessKey": "0039",
                "agreementIndexId": "341448258",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Health",
                "policyNumber": "XXXXXXX 0039",
                "productDescription": "Long Term Care: Benson, Charles",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionHealthPolicyChange);
    });
    it('should click TOOF Reinstatement for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryCardComp.policy = happyPolicyDataTerminated;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'TOOF Reinstatement' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkXQAQ&agreementIndexId=424149269&clientnamelinkdisabled=Y&NechoAppName=policy&key=131 6408-E20-31&lineOfBusiness=A&agentAssocId=P4XSN1YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "TOOF Reinstatement",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": "2013 HYUNDAI ELANTRA 4DR",
                "sourceSystemCode": 1,
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickCardActionToofReinstatement);
    });
    it('should click Email Auto ID Card for auto with no modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryCardComp.loggedInSubuser = 'SFDC_USER_1_07_Tech_Supp'
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "vwejo7fblxvddajea@sf.org",
            "customerName": "SHAWN F FELLNER",
            "policyNumber": "3121316408"
        });

        assertActions(logClickCardActionEmailAutoId);
    });
    it('should click Email Auto ID Card for auto with modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryCardComp.loggedInSubuser = 'Agent'
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeFalsy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();

        // see email modal
        const stcModal = policySummaryCardComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(stcModal).toBeTruthy();
        const saveButton = stcModal.shadowRoot.querySelector('[data-id="saveButton"]');
        expect(saveButton).toBeTruthy();
        saveButton.click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "vwejo7fblxvddajea@sf.org",
            "customerName": "SHAWN F FELLNER",
            "policyNumber": "3121316408"
        });

        assertActions(logClickCardActionEmailAutoId);
        expect(policySummaryCardComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeFalsy();
    });
    it('should click Email Auto ID Card for auto then close modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryCardComp.loggedInSubuser = 'Agent'
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();

        // see email modal
        const stcModal = policySummaryCardComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(stcModal).toBeTruthy();
        const cancelButton = stcModal.shadowRoot.querySelector('[data-id="cancelButton"]');
        expect(cancelButton).toBeTruthy();
        cancelButton.click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(emailAutoIdCardCallout).not.toHaveBeenCalled();
        assertActions(logClickCardActionEmailAutoId);
        expect(policySummaryCardComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeFalsy();
    });
    it('should click Email Auto ID Card for auto legacy multi car with modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = autoLegacyMultiCar;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryCardComp.loggedInSubuser = 'Agent';
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryCardComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

        await flushPromises();

        // see email modal
        const stcModal = policySummaryCardComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(stcModal).toBeTruthy();
        const saveButton = stcModal.shadowRoot.querySelector('[data-id="saveButton"]');
        expect(saveButton).toBeTruthy();
        saveButton.click();

        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(emailAutoIdCardCallout).toHaveBeenCalledWith({
            "customerEmail": "dflg.ajqlh53468ux@sf.org",
            "customerName": "LUKE G HATCH",
            "policyNumber": "4334599923001"
        });

        assertActions(logClickCardActionEmailAutoId);
    });
    it('should click BOS for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyPolicyData;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Billing Online System (BOS)' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=210&accountId=0012C00000h2hkXQAQ&companyCode=0001&policyNumber=1316408E2031&lineOfBusiness=A');
        assertActions(logClickCardActionBos);
    });
    it('should click COI for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = homeownersPolicyCOI;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: false,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Certificate Of Insurance (COI)' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=211&regionCode=18&policyNumber=14CVY5825&policyType=V&lineOfBusiness=F');

        assertActions(logClickCardActionCoi);
    });
    it('should click COI for Auto and launch with client ID', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = happyAutoPolicy2;
        policySummaryCardComp.userAccess = {
            hasPolicyTransactionAccess: false,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryCardComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]')).toBeTruthy();
        const dropdown = policySummaryCardComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Certificate Of Insurance (COI)' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=264&clientId=JSJ541MF00S');

        assertActions(logClickCardActionCoi);
    });
    //#endregion

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

        const driverAgeComps = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        const driverAges = [];
        driverAgeComps.forEach(ageComp => { driverAges.push(ageComp.textContent) })
        expect(driverAges.length).toEqual(7)

        let ageList = buildAgeList(JSON.parse(dvl200DiffDrivers.body).policy.termVersion.insurableRisk[0].riskPartyRole);

        expect(ageList.length).toEqual(driverAges.length) // 7 length
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
        const driverAgeComps = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        const driverAges = [];
        driverAgeComps.forEach(ageComp => { driverAges.push(ageComp.textContent) })
        expect(driverAges.length).toEqual(7)

        let ageList = buildAgeList(JSON.parse(dvl200NoRatingAssignments.body).policy.termVersion.insurableRisk[0].riskPartyRole);

        expect(ageList.length).toEqual(driverAges.length) // 7 length
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

        expect(getAccountData).not.toHaveBeenCalled()
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
    it('should throw toast for Fleet policy enhance', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        const showToastHandler = jest.fn();
        policySummaryCardComp.addEventListener(ShowToastEventName, showToastHandler);

        policySummaryCardComp.policy = fleetPolicy;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(fleetPolicy.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(fleetPolicy.PolicyName);
        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).not.toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeFalsy();

        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('Additional policy data is not available for Fleet policies.');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBeFalsy();
    });
    it('should render enhanced summary for card button click on surety bond policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvlSuretyBond);

        policySummaryCardComp.policy = suretyBondPolicy;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(suretyBondPolicy.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(suretyBondPolicy.PolicyName);
        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.shadowRoot.querySelector('[data-id=enhance-button]').click();

        await flushPromises();

        expect(callout).toHaveBeenCalledTimes(1);
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=card-obligee]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=card-obligee]').textContent).toEqual('STATE OF CALIFORNIA')
    });
    it('should handle enhanced summary api call stopping for life policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = lifePolicy;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(lifePolicy.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(lifePolicy.PolicyName);
        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).not.toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(getAccountData).not.toHaveBeenCalled()
    });
    it('should handle enhanced summary api call stopping for non-surety fire policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryCardComp.policy = homeownersPolicy;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(homeownersPolicy.Name);
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(homeownersPolicy.PolicyName);
        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).not.toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(getAccountData).not.toHaveBeenCalled()
    });

    it('should query account for missing driver names', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvlModNoDrivers);
        getAccountData.mockResolvedValueOnce([
            { firstName: 'JOHN', clientId: 'KDJN47TSQGF' }, 
            { firstName: 'JANE', clientId: 'TH8S65YB00F' }, 
            { firstName: 'JIM', clientId: '7N8318Z71AK' }, 
            { firstName: 'JOE', clientId: 'J62PG5C7005' } 
        ]);
        
        policySummaryCardComp.policy = autoModMultiCar;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(getAccountData).toHaveBeenCalledWith({ clientIdList: ['KDJN47TSQGF', 'TH8S65YB00F', '7N8318Z71AK', 'J62PG5C7005'] })

        const driverFirstNames = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]')
        expect(driverFirstNames.length).toBe(4)
        expect(driverFirstNames[0].textContent).toBe('JANE');
        expect(driverFirstNames[1].textContent).toBe('JOHN');
        expect(driverFirstNames[2].textContent).toBe('JIM');
        expect(driverFirstNames[3].textContent).toBe('JOE');

        // const driverAges = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        // expect(driverAges[0].textContent).toBe(' (59)');
        // expect(driverAges[1].textContent).toBe(' (51)');
        // expect(driverAges[2].textContent).toBe(' (21)');
        // expect(driverAges[3].textContent).toBe(' (19)');

        const driverAgeComps = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]')
        const driverAges = [];
        driverAgeComps.forEach(ageComp => { driverAges.push(ageComp.textContent) })
        expect(driverAges.length).toEqual(4)

        let ageList = buildAgeList(JSON.parse(dvlModNoDrivers.body).policy.termVersion.insurableRisk[0].riskPartyRole);

        expect(ageList.length).toEqual(driverAges.length) // 6 length
        expect(driverAges).toContain(' (' + ageList[0] + ')')
        expect(driverAges).toContain(' (' + ageList[1] + ')')
        expect(driverAges).toContain(' (' + ageList[2] + ')')
        expect(driverAges).toContain(' (' + ageList[3] + ')')

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeTruthy();

        expect(policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-semicolon]').length).toBe(3)
    });

    it('should handle error for account query', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvlModNoDrivers);
        getAccountData.mockRejectedValueOnce(new Error('ERROR'));
        
        policySummaryCardComp.policy = autoModMultiCar;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).toHaveBeenCalled();
        expect(logException).toHaveBeenCalledWith({ 
            "message": "Failed to retrieve account names: \"ERROR\"",
            "method": "policySummaryCard.buildDrivers"
        });
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(getAccountData).toHaveBeenCalledWith({ clientIdList: ['KDJN47TSQGF', 'TH8S65YB00F', '7N8318Z71AK', 'J62PG5C7005'] })

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeTruthy();

        expect(policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]').length).toBe(0);
    });
    it('should handle account query for missing driver names with empty response', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvlModNoDrivers);
        getAccountData.mockResolvedValueOnce([]);
        
        policySummaryCardComp.policy = autoModMultiCar;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(getAccountData).toHaveBeenCalledWith({ clientIdList: ['KDJN47TSQGF', 'TH8S65YB00F', '7N8318Z71AK', 'J62PG5C7005'] })

        expect(policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]').length).toBe(0);
 
        expect(policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-age]').length).toBe(0);
 
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeTruthy();
    });
    it('should skip query account for missing driver names with no client ids', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        callout.mockResolvedValueOnce(dvlModNoClientIds);
        
        policySummaryCardComp.policy = autoModMultiCar;
        policySummaryCardComp.userAccess = {};
        policySummaryCardComp.plmActivationStatus = {};
        policySummaryCardComp.accountPageRecordId = {};
        policySummaryCardComp.isHousehold = {};
        policySummaryCardComp.accountList = {};
        policySummaryCardComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryCardComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        policySummaryCardComp.enhancePolicy();

        await flushPromises();

        expect(callout).toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=loading-spinner]')).toBeFalsy();

        expect(getAccountData).not.toHaveBeenCalled()

        const driverFirstNames = policySummaryCardComp.shadowRoot.querySelectorAll('[data-id=driver-first-name]')
        expect(driverFirstNames.length).toBe(0)

        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=driver-title]')).toBeFalsy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=coverages]')).toBeTruthy();
        expect(policySummaryCardComp.shadowRoot.querySelector('[data-id=dss-icon]')).toBeTruthy();
    });
    //#endregion
})

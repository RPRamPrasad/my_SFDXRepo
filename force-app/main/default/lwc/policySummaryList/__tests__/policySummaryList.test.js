import { createElement } from 'lwc';
import policySummaryList from 'c/policySummaryList';

import logException from '@salesforce/apex/InsurancePolicyController.logException';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';
import getPrimaryInsurancePolicyParticipant from '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant';

import logClickListActionAddDriver from '@salesforce/apex/PolicySummaryEventController.logClickListActionAddDriver';
import logClickListActionAddVehicle from '@salesforce/apex/PolicySummaryEventController.logClickListActionAddVehicle';
import logClickListActionAutoPolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickListActionAutoPolicyChange';
import logClickListActionBos from '@salesforce/apex/PolicySummaryEventController.logClickListActionBos';
import logClickListActionCoi from '@salesforce/apex/PolicySummaryEventController.logClickListActionCoi';
import logClickListActionEmailAutoId from '@salesforce/apex/PolicySummaryEventController.logClickListActionEmailAutoId';
import logClickListActionFirePolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickListActionFirePolicyChange';
import logClickListActionHealthPolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickListActionHealthPolicyChange';
import logClickListActionLifePolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickListActionLifePolicyChange';
import logClickListActionPolicyChange from '@salesforce/apex/PolicySummaryEventController.logClickListActionPolicyChange';
import logClickListActionReplaceVehicle from '@salesforce/apex/PolicySummaryEventController.logClickListActionReplaceVehicle';
import logClickListActionToofReinstatement from '@salesforce/apex/PolicySummaryEventController.logClickListActionToofReinstatement';
import logClickListBillingAcctNum from '@salesforce/apex/PolicySummaryEventController.logClickListBillingAcctNum';
import logClickListOpenClaim from '@salesforce/apex/PolicySummaryEventController.logClickListOpenClaim';
import logClickListPolicyNum from '@salesforce/apex/PolicySummaryEventController.logClickListPolicyNum';

import { getNavigateCalledWith } from 'lightning/navigation';

const happyPolicyData = require('./data/happyPolicyData.json');
const happyAutoPolicy2 = require('./data/happyAutoPolicy2.json');
const autoLegacyMultiCar = require('./data/happyMultiCarAutoPolicy.json');
const autoLegacyMultiCarSingleRisk = require('./data/happyMultiCarAutoPolicySingleRisk.json');
const autoLegacyMultiCarTerminated = require('./data/multiCarAutoTerminated.json');
const modCommercialAuto = require('./data/modCommercialAuto.json');
const autoNoRisks = require('./data/autoPolicyNoRisks.json');
const autoModMultiCar = require('./data/modAutoMultiCarPolicy.json');
const autoModSingleRisk = require('./data/autoModSingleRisk.json');
const fleetPolicy = require('./data/fleetPolicy.json');
const homeownersPolicy = require('./data/happyFirePolicyData.json');
const homeownersPolicyCOI = require('./data/homeownersPolicyCOI.json');
const happyPhxLifePolicy = require('./data/happyPhxLifePolicy.json');
const lifePolicy = require('./data/lifePolicy.json');
const lifePolicy2 = require('./data/lifePolicy2.json');
const healthPolicy = require('./data/healthPolicy.json');
const happyPolicyDataTerminated = require('./data/happyPolicyDataTerminated.json');
const happyFirePolicyTerminated = require('./data/happyFirePolicyTerminated.json');
const policyMissingData = require('./data/policyMissingData.json');
const policyWithSfBilling = require('./data/policyWithSfBilling.json');
const policyWithSfBilling2 = require('./data/policyWithSfBilling2.json');
const modAutoMultiCarNotPrivatePassenger = require('./data/modAutoMultiCarNotPrivatePassenger.json');
const autoIncompleteData = require('./data/happyPolicyDataIncompleteRecord.json');
const autoNoServicingAgent = require('./data/happyPolicyDataNoServicingAgent.json');

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
jest.mock('@salesforce/customPermission/SAE_Policy_Change', () => ({ default: false }), { virtual: true });

jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionAddDriver',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionAddVehicle',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionAutoPolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionBos',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionCoi',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionEmailAutoId',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionFirePolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionHealthPolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionLifePolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionPolicyChange',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionReplaceVehicle',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListActionToofReinstatement',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListBillingAcctNum',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListOpenClaim',
    () => ({ default: jest.fn() }), { virtual: true });
jest.mock(
    '@salesforce/apex/PolicySummaryEventController.logClickListPolicyNum',
    () => ({ default: jest.fn() }), { virtual: true });

window.open = jest.fn();

//#endregion

describe('c-policy-summary-list', () => {
    let policySummaryListComp;
    let allActions = [
        logClickListActionAddDriver,
        logClickListActionAddVehicle,
        logClickListActionAutoPolicyChange,
        logClickListActionBos,
        logClickListActionCoi,
        logClickListActionEmailAutoId,
        logClickListActionFirePolicyChange,
        logClickListActionHealthPolicyChange,
        logClickListActionLifePolicyChange,
        logClickListActionPolicyChange,
        logClickListActionReplaceVehicle,
        logClickListActionToofReinstatement,
        logClickListBillingAcctNum,
        logClickListOpenClaim,
        logClickListPolicyNum
    ];

    beforeEach(() => {
        jest.clearAllMocks();
        jest.resetAllMocks();
        jest.resetModules();
        logException.mockImplementation(() => jest.fn());

        policySummaryListComp = createElement('c-policy-summary-list', {
            is: policySummaryList
        });
    })
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        policySummaryListComp = null;
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

    //#region Happy Path
    it('should render list item happy path', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false,
            hasPremiumChangeInquiryAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        let agentNameParts = happyPolicyData.Servicing_Agent__r.Name.split(', ');
        let agentName = agentNameParts[0] + ' (' + agentNameParts[1] + ')';

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(happyPolicyData.PolicyName);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=single-risk-desc]').textContent).toEqual(happyPolicyData.InsurancePolicyAssets[0].Description__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual(agentName);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(happyPolicyData.AgreDisplayPartyName__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('11/20/2017');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('05/20/2022');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="renew-term"][class="text-red"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="renew-term"]').classList.length).toEqual(0);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="renew-term"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627224');
        expect(policySummaryListComp.shadowRoot.querySelector('div[class="claim-column slds-m-top_x-small"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=policy-status]')).toBe(null);

        expect(logException).not.toHaveBeenCalled();
        assertActions();
    });
    it('should render list item happy path for no risks', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = autoNoRisks;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        let agentNameParts = autoNoRisks.Servicing_Agent__r.Name.split(', ');
        let agentName = agentNameParts[0] + ' (' + agentNameParts[1] + ')';

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(autoNoRisks.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(autoNoRisks.PolicyName);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="single-risk-desc"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="multi-risk-label"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="no-risks"]').textContent).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual(agentName);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(autoNoRisks.AgreDisplayPartyName__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('08/01/2020');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('08/01/2022');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="renew-term"][class="text-red"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="renew-term"]')).toBeTruthy();

        expect(logException).not.toHaveBeenCalled();
        assertActions();
    });
    it('should render list item happy path with multiple risks', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = autoLegacyMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        let agentNameParts = autoLegacyMultiCar.Servicing_Agent__r.Name.split(', ');
        let agentName = agentNameParts[0] + ' (' + agentNameParts[1] + ')';

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(autoLegacyMultiCar.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual(autoLegacyMultiCar.PolicyName);
        // expect(policySummaryListComp.shadowRoot.querySelector('[data-id=single-risk-desc]').textContent).toEqual(autoLegacyMultiCar.InsurancePolicyAssets[0].Description__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual(agentName);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(autoLegacyMultiCar.AgreDisplayPartyName__c);
        const risks = policySummaryListComp.shadowRoot.querySelector('c-policy-summary-risk-hover')?.risks;
        expect(risks).toBeTruthy();
        expect(risks.length).toEqual(5);
        expect(risks[0].riskNumDesc).toEqual('001: 2017 FORD EDGE SPORT WG');
        expect(risks[1].riskNumDesc).toEqual('002: 2014 FORD F150 PICKUP');
        expect(risks[2].riskNumDesc).toEqual('003: 2017 CHEVY VOLT');
        expect(risks[3].riskNumDesc).toEqual('004: 2021 CHEVY SILVERADO');
        expect(risks[4].riskNumDesc).toEqual('004: 2016 TESLA MODEL S');
    });
    it('should render list item happy path with commercial multiple risks', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = modCommercialAuto;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        const risks = policySummaryListComp.shadowRoot.querySelector('c-policy-summary-risk-hover')?.risks;
        const insuredHover = policySummaryListComp.shadowRoot.querySelector('[data-id="insured-icon"]')?.popoverTitle
        expect(risks).toBeTruthy();
        expect(risks.length).toEqual(4);
        expect(insuredHover).toEqual('Insureds');
        expect(risks[0].Description__c).toEqual('Vehicle#001 :Truck/Van 2015 INTL 4300M7 in Illinois');
        expect(risks[1].Description__c).toEqual('Vehicle#003 :Truck/Van 2012 MERCEDES 2500 in Illinois');
        expect(risks[2].Description__c).toEqual('Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois');
        expect(risks[3].Description__c).toEqual('Vehicle#004 :Truck/Van 2012 INTL 4300M7 in Illinois');
    });

    it('should render policy in "Proposed" status', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = {
            ...happyPolicyData,
            "Status": "Proposed"
        };
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=policy-status]').getAttribute('title')).toEqual("Proposed status applies to a policy not yet In Force. Some amount of processing is required before policy coverage begins.");
    });

    it('should render policy in "Suspended" status', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = {
            ...happyPolicyData,
            "Status": "Suspended"
        };
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=policy-status]').getAttribute('title')).toEqual("Suspended status applies when a policy is temporarily suspended, with intention of coverage resuming in the future.");
    });

    it('should render default status badge case', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = {
            ...happyPolicyData,
            "Status": "Not a Real Status"
        };
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=policy-status]').getAttribute('title')).toEqual("");
    });
    it('should render with incomplete policy data', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = autoIncompleteData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
    });

    it('should render sorted risks for auto fleet', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = fleetPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        const risks = policySummaryListComp.shadowRoot.querySelector('c-policy-summary-risk-hover')?.risks;
        expect(risks).toBeTruthy();
        expect(risks.length).toEqual(26);
        expect(risks[0].Description__c).toEqual('2022 NEX EXA TRL TANK');
        expect(risks[1].Description__c).toEqual('2019 EXA 150BBL TRL TANK');
        expect(risks[2].Description__c).toEqual('2018 FORD F350SD UTIL TRK');
        expect(risks[3].Description__c).toEqual('2018 EXA TT TRL TANK');
    });
    it('should copy policy number', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        document.execCommand = jest.fn();

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        policySummaryListComp.shadowRoot.querySelector('[data-id="copyButton"]').click();
        expect(document.execCommand).toHaveBeenCalledWith('copy');

    });
    it('should fail to copy policy number', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        document.execCommand = jest.fn(() => { throw new Error('FAILED TO COPY') });

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        policySummaryListComp.shadowRoot.querySelector('[data-id="copyButton"]').click();
        expect(document.execCommand).toHaveBeenCalledWith('copy');
        expect(logException).toHaveBeenCalledWith({"message": "Failed to copy policy number: \"FAILED TO COPY\"", "method": "policySummaryList.copyPolicyNumber"});
    });
    //#endregion

    //#region Navigation Tests
    it('should navigate to policy when policy number is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        // click on links and catch navigation
        policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').click();

        await flushPromises();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.recordId).toBe('0YT2C0000008QVqWAM');
        expect(pageReference.attributes.objectApiName).toBe('InsurancePolicy');
        expect(pageReference.attributes.actionName).toBe('view');

        assertActions(logClickListPolicyNum);
    });
    it('should navigate to bill when bill account is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        // click on links and catch navigation
        policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').click();

        await flushPromises();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.recordId).toBe('a3Q2C000000wOPHUA2');
        expect(pageReference.attributes.objectApiName).toBe('Billing_Account__c');
        expect(pageReference.attributes.actionName).toBe('view');

        assertActions(logClickListBillingAcctNum);
    });
    it('should navigate to claim when claim number is clicked', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        // click on links and catch navigation
        policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').click();

        await flushPromises();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.recordId).toBe('0Zk2C0000008OISSA2');
        expect(pageReference.attributes.objectApiName).toBe('Claim');
        expect(pageReference.attributes.actionName).toBe('view');

        assertActions(logClickListOpenClaim);
    });
    //#endregion

    //#region Action List
    it('should render action list properly for legacy auto policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="insured-icon"]')?.popoverTitle).toEqual('Insureds');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
    });
    it('should render action list properly for mod auto multicar policy thats not private passenger', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = modAutoMultiCarNotPrivatePassenger;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
    });
    it('should render action list properly for legacy auto policy missing access', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Driver"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Replace Vehicle"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
    });
    it('should render action list properly for Homeowners fire policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = homeownersPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="insured-icon"]')?.popoverTitle).toEqual('Insureds');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('03/19/2022');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=claims-section]').textContent).toEqual('Multiple (3)');

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
    });
    it('should render action list properly for Homeowners fire policy missing access', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = homeownersPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('03/19/2022');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=claims-section]').textContent).toEqual('Multiple (3)');

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeFalsy();
    });
    it('should render action list properly for terminated Homeowners fire policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyFirePolicyTerminated;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OITSA2"]').textContent).toEqual('7570P850T');

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeTruthy();
    });
    it('should render action list properly for Phoenix life policy', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPhxLifePolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="TOOF Reinstatement"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="insured-icon"]')?.popoverTitle).toEqual('Owner');
    });
    //#endregion

    //#region Error Handling
    it('should render blank values for policy with missing data', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = policyMissingData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger Long D...');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=single-risk-desc]').textContent).toEqual('2013 HYUNDAI ELANTRA 4DR LONG DESCR...');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(happyPolicyData.AgreDisplayPartyName__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627224');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA3"]').textContent).toEqual('6140R950T');

        const policyAlert = policySummaryListComp.shadowRoot.querySelector('[data-id=policy-alert]');
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

        policySummaryListComp.policy = policyWithSfBilling;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger Long D...');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=single-risk-desc]').textContent).toEqual('2013 HYUNDAI ELANTRA 4DR LONG DESCR...');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(happyPolicyData.AgreDisplayPartyName__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('div[class="billing-column slds-m-top_x-small"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627251');
        expect(policySummaryListComp.shadowRoot.querySelector('div[class="claim-column"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA3"]').textContent).toEqual('6140R950T');

        const policyAlert = policySummaryListComp.shadowRoot.querySelector('[data-id=policy-alert]');
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

        policySummaryListComp.policy = policyWithSfBilling2;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger Long D...');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=single-risk-desc]').textContent).toEqual('2013 HYUNDAI ELANTRA 4DR LONG DESCR...');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(happyPolicyData.AgreDisplayPartyName__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('--');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wOPHUA2"]').textContent).toEqual('1255627252');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA2"]').textContent).toEqual('6140R950R');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0Zk2C0000008OISSA3"]').textContent).toEqual('6140R950T');

        const policyAlert = policySummaryListComp.shadowRoot.querySelector('[data-id=policy-alert]');
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

        policySummaryListComp.policy = happyPolicyDataTerminated;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {};
        policySummaryListComp.accountPageRecordId = {};
        policySummaryListComp.isHousehold = {};
        policySummaryListComp.accountList = {};
        policySummaryListComp.loggedInSubuser = {};
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=launch-policy]').textContent).toEqual(happyPolicyData.Name);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=list-item-desc]').textContent).toEqual('Private Passenger');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=single-risk-desc]').textContent).toEqual('2013 HYUNDAI ELANTRA 4DR');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=agent-icon]').popoverBody).toEqual('Rick Paul (G2LM)');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=insured-icon]').popoverBody).toEqual(happyPolicyData.AgreDisplayPartyName__c);
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=inception]').textContent).toEqual('11/20/2017');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=renew-term]').textContent).toEqual('12/31/2021');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="renew-term"][class="text-red"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('div[class="billing-column"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=a3Q2C000000wOPHUA2]').textContent).toEqual('1255627224');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=a3Q2C000000wOPHUA3]').textContent).toEqual('1255627225');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id=policy-alert]')).toBeFalsy();

        expect(logException).toHaveBeenCalledWith({ method: 'policySummaryList.connectedCallback', message: 'Failed to retrieve group policy status' });
    });
    it('should log error when actions fail to load', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = null;
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).toHaveBeenCalledWith({ "message": "Error while fetching policy actions: \"Cannot read properties of null (reading 'hasPolicyTransactionAccess')\"", "method": "policySummaryList.fetchPolicyActions" });
    });
    it('should log error when policy change action fails', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = null;
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).toHaveBeenCalledWith({
            "message": "Failed to make policy change case: \"Cannot read properties of null (reading 'isPCAutoLaunchActive')\"",
            "method": "policySummaryList.handleAction",
        });
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
    });
    it('should log error when add vehicle action fails', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { throw new Error('CASE ERROR') });

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = null;
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
            "method": "policySummaryList.handleAction",
        });
    });
    //#endregion

    //#region Action Handling
    it('should click Policy Change for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyAutoPolicy2;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')?.disabled).toBeFalsy();

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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionPolicyChange);
        expect(getPrimaryInsurancePolicyParticipant).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Private Passenger"});
    });

    it('should click Policy Change for auto with no servicing agent', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoNoServicingAgent;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')?.disabled).toBeFalsy();

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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionPolicyChange);
        expect(getPrimaryInsurancePolicyParticipant).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Private Passenger"});
    });

    it('should click Policy Change for auto mod multi car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoModMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="multi-billing"]').textContent).toEqual('Multiple (3)')

        const risks = policySummaryListComp.shadowRoot.querySelector('c-policy-summary-risk-hover')?.risks;
        expect(risks).toBeTruthy();
        expect(risks.length).toEqual(3);
        expect(risks[0].Description__c).toEqual('2017 Lexus Gx 460');
        expect(risks[1].Description__c).toEqual('2017 Hyundai Azera');
        expect(risks[2].Description__c).toEqual('2007 Toyota Camry');

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E9FWAU"]')).toBeFalsy();

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
                "sourceSystemCode": 24
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionPolicyChange);
    });
    it('should click Policy Change for auto mod single car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoModSingleRisk;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wNwKUAU"]').textContent).toEqual('1227350151');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="a3Q2C000000wNwFUAU"]').textContent).toEqual('1227337151');

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeFalsy();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E9FWAU"]')).toBeFalsy();

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
                "sourceSystemCode": 24
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionPolicyChange);
    });
    it('should click Policy Change for auto legacy multi car', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoLegacyMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="multi-risk-label"]').textContent).toEqual('Multiple Risks... ');
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004FgaWAE"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionPolicyChange);
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
    });
    it('should click Policy Change for auto legacy multi car 2', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoLegacyMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6xWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6xWAE"]').textContent).toEqual('002: 2014 FORD F150 PICKUP');
        policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6xWAE"]').click();

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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionPolicyChange);
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
    });
    it('should click Policy Change for auto legacy multi car terminated', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoLegacyMultiCarTerminated;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'TOOF Reinstatement' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004FgaWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalled();
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkcQAA",
                "actionValue": "TOOF Reinstatement",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "4334599923",
                "agreementIndexId": "474596043",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "459 9923-B01-43-001",
                "productDescription": "2017 FORD EDGE SPORT WG",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionToofReinstatement);
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
    });
    it('should click Policy Change for auto legacy multi car and then close modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = autoLegacyMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="close-modal-button"]')).toBeTruthy();
        policySummaryListComp.shadowRoot.querySelector('[data-id="close-modal-button"]').click();

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeFalsy();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        assertActions();
    });
    it('should click Policy Change for auto fleet', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(true);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = fleetPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionPolicyChange);
    });
    it('should click Policy Change for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = homeownersPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionPolicyChange);
    });
    it('should click Add Vehicle for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Add Vehicle' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Add Vehicle"]')?.disabled).toBeFalsy();

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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionAddVehicle);
    });
    it('should click Add Driver for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Add Driver' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkXQAQ&agreementIndexId=424149269&clientnamelinkdisabled=Y&NechoAppName=new pt&key=131 6408-E20-31&lineOfBusiness=A&agentAssocId=P4XSN1YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Added Driver",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": "2013 HYUNDAI ELANTRA 4DR",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionAddDriver);
    });
    it('should click Replace Vehicle for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Replace Vehicle' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkXQAQ&agreementIndexId=424149269&clientnamelinkdisabled=Y&NechoAppName=new pt&key=131 6408-E20-31&lineOfBusiness=A&agentAssocId=P4XSN1YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Replaced Vehicle",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": "2013 HYUNDAI ELANTRA 4DR",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionReplaceVehicle);
    });
    it('should click Auto Policy Change for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Auto Policy Change' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkXQAQ&agreementIndexId=424149269&clientnamelinkdisabled=Y&NechoAppName=new pt&key=131 6408-E20-31&lineOfBusiness=A&agentAssocId=P4XSN1YS000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkXQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "P4XSN1YS000",
                "agreAccessKey": "3121316408",
                "agreementIndexId": "424149269",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "131 6408-E20-31",
                "productDescription": "2013 HYUNDAI ELANTRA 4DR",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionAutoPolicyChange);
    });
    it('should click Auto Policy Change for auto legacy multi car', async () => {
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

        policySummaryListComp.policy = autoLegacyMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Auto Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Auto Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=21&Key=A4599923001&absclient=22XN18LNRGE&StateAgentCode=431226');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkcQAA",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "4334599923",
                "agreementIndexId": "474596043",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "459 9923-B01-43-001",
                "productDescription": "2017 FORD EDGE SPORT WG",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionAutoPolicyChange);
    });
    it('should click Auto Policy Change for auto legacy multi car single risk', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = autoLegacyMultiCarSingleRisk;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Auto Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=21&Key=A4599923001&absclient=22XN18LNRGE&StateAgentCode=431226');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkcQAA",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "PL1H35CZXAK",
                "agreAccessKey": "4334599923",
                "agreementIndexId": "474596043",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Auto",
                "policyNumber": "459 9923-B01-43-001",
                "productDescription": "2017 FORD EDGE SPORT WG",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');
        assertActions(logClickListActionAutoPolicyChange);
    });
    it('should click Fire Policy Change for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = homeownersPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Fire Policy Change"]')).toBeFalsy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Fire Policy Change' },
            bubbles: true
        }));

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=0012C00000h2hkVQAQ&agreementIndexId=429006271&clientnamelinkdisabled=Y&NechoAppName=policy&key=14-CV-Y582-5&lineOfBusiness=F&agentAssocId=KRLYT3JX000');
        expect(createPolicyTransactionCase).toHaveBeenCalledWith({
            "inputData": {
                "accountRecordId": "0012C00000h2hkVQAQ",
                "actionValue": "Policy - Change/Request",
                "agentAssociateId": "KRLYT3JX000",
                "agreAccessKey": "181014Y5820CV5",
                "agreementIndexId": "429006271",
                "isCaseMigrationAction": false,
                "isLegacyPolicy": false,
                "lob": "Fire",
                "policyNumber": "14-CV-Y582-5",
                "productDescription": "Homeowners Policy : 167 YORKSHIRE BLVD W",
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionFirePolicyChange);
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

        policySummaryListComp.policy = lifePolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="insured-icon"]')?.popoverTitle).toEqual('Owner');
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionLifePolicyChange);

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

        policySummaryListComp.policy = lifePolicy2;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionLifePolicyChange);
    });
    it('should click Life Policy Change for life with different ni code but failed role promise', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })
        getPrimaryInsurancePolicyParticipant.mockRejectedValueOnce(new Error('PARTICIPANT ERROR'));

        policySummaryListComp.policy = lifePolicy2;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionLifePolicyChange);
    });
    it('should have no Life Policy Change for phoenix life', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyPhxLifePolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(getGroupPolicyStatus).toHaveBeenCalledWith({"policyDescription": "Pnx Universal Life-Option 1"});
        expect(getPrimaryInsurancePolicyParticipant).toHaveBeenCalledWith({
            "lob": "L",
            "recordId": "0YT2C0000008QW6WAM"
        });
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Life Policy Change"]')).toBeFalsy();
    });
    it('should click Health Policy Change for health', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = healthPolicy;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Health Policy Change"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="insured-icon"]')?.popoverTitle).toEqual('Owner');

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionHealthPolicyChange);
    });
    it('should click TOOF Reinstatement for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);
        createPolicyTransactionCase.mockImplementation(() => { return 'CASE_ID'; })

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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
                "sourceSystemCode": 1
            }
        });

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference.type).toBe('standard__app');
        expect(pageReference.attributes.pageRef.type).toBe('standard__recordPage');
        expect(pageReference.attributes.pageRef.attributes.recordId).toBe('CASE_ID');
        expect(pageReference.attributes.pageRef.attributes.objectApiName).toBe('Case');
        expect(pageReference.attributes.pageRef.attributes.actionName).toBe('view');

        assertActions(logClickListActionToofReinstatement);
    });
    it('should click Email Auto ID Card for auto with no modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryListComp.loggedInSubuser = 'SFDC_USER_1_07_Tech_Supp'
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
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

        assertActions(logClickListActionEmailAutoId);
    });
    it('should click Email Auto ID Card for auto with modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryListComp.loggedInSubuser = 'Agent'
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeFalsy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();

        // see email modal
        const stcModal = policySummaryListComp.shadowRoot.querySelector('c-send-to-customer-modal');
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
        assertActions(logClickListActionEmailAutoId);
        expect(policySummaryListComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeFalsy();
    });
    it('should click Email Auto ID Card for auto then close modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryListComp.loggedInSubuser = 'Agent'
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Email Auto ID Card"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();

        // see email modal
        const stcModal = policySummaryListComp.shadowRoot.querySelector('c-send-to-customer-modal');
        expect(stcModal).toBeTruthy();
        const cancelButton = stcModal.shadowRoot.querySelector('[data-id="cancelButton"]');
        expect(cancelButton).toBeTruthy();
        cancelButton.click();

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).not.toHaveBeenCalled();
        expect(emailAutoIdCardCallout).not.toHaveBeenCalled();
        assertActions(logClickListActionEmailAutoId);
        expect(policySummaryListComp.shadowRoot.querySelector('c-send-to-customer-modal')).toBeFalsy();
    });
    it('should click Email Auto ID Card for auto legacy multi car with modal', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = autoLegacyMultiCar;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: true
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        policySummaryListComp.loggedInSubuser = 'Agent';
        document.body.appendChild(policySummaryListComp);

        await flushPromises();

        expect(logException).not.toHaveBeenCalled();

        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Email Auto ID Card' },
            bubbles: true
        }));

        await flushPromises();

        expect(policySummaryListComp.shadowRoot.querySelector('.slds-modal')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]')).toBeTruthy();
        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').textContent).toEqual('001: 2017 FORD EDGE SPORT WG');
        policySummaryListComp.shadowRoot.querySelector('[data-id="0YW2C0000004E6wWAE"]').click();

        await flushPromises();

        // see email modal
        const stcModal = policySummaryListComp.shadowRoot.querySelector('c-send-to-customer-modal');
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
        assertActions(logClickListActionEmailAutoId);
    });
    it('should click BOS for auto', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyPolicyData;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: true,
            hasCOILinkAccess: false,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Billing Online System (BOS)"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Billing Online System (BOS)' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=210&accountId=0012C00000h2hkXQAQ&companyCode=0001&policyNumber=1316408E2031&lineOfBusiness=A');
        assertActions(logClickListActionBos);
    });
    it('should click COI for fire', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = homeownersPolicyCOI;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: false,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Certificate Of Insurance (COI)' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=211&regionCode=18&policyNumber=14CVY5825&policyType=V&lineOfBusiness=F');
        assertActions(logClickListActionCoi);
    });
    it('should click COI for Auto and launch with client ID', async () => {
        getGroupPolicyStatus.mockResolvedValueOnce(false);

        policySummaryListComp.policy = happyAutoPolicy2;
        policySummaryListComp.userAccess = {
            hasPolicyTransactionAccess: false,
            hasAutoIdCardAccessforSubuserType: false,
            hasAutoIdCardAccessforUserCriteria: false,
            hasBOSLinkAccess: false,
            hasCOILinkAccess: true,
            hasCaseMigrationAccess: false
        };
        policySummaryListComp.plmActivationStatus = {
            isPCAutoLaunchActive: false
        }
        document.body.appendChild(policySummaryListComp);

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();

        expect(policySummaryListComp.shadowRoot.querySelector('[data-id="Certificate Of Insurance (COI)"]')).toBeTruthy();
        const dropdown = policySummaryListComp.shadowRoot.querySelector('[data-id="list-item-actions"]');
        expect(dropdown).toBeTruthy();
        dropdown.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Certificate Of Insurance (COI)' },
            bubbles: true
        }));

        await flushPromises();
        expect(logException).not.toHaveBeenCalled();
        expect(createPolicyTransactionCase).not.toHaveBeenCalled();
        expect(window.open).toHaveBeenCalledWith('/apex/VFP_ExternalLink?LinkId=264&clientId=JSJ541MF00S');
        assertActions(logClickListActionCoi);
    });

    //#endregion
})
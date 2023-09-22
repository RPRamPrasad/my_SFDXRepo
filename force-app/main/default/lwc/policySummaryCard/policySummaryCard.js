import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import logException from '@salesforce/apex/InsurancePolicyController.logException';
import getAccountData from '@salesforce/apex/InsurancePolicyController.getAccountData';

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
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getVFOrigin from '@salesforce/apex/HA4C_PKCE.getVFOrigin';
import getHA4CToken from '@salesforce/apex/HA4C_PKCE.getHA4CToken';
import getPolicyDetailsParmHA4C from '@salesforce/apex/Ha4cWebController.getPolicyDetailsParmHA4C';

import policyLogos from '@salesforce/resourceUrl/policySummaryLogos'

// import hasSupportAccess from '@salesforce/customPermission/PolicySummary_SupportAccess';
// import hasEarlyAccess from '@salesforce/customPermission/PolicySummary_EarlyAccess';

import {
    buildActionsList,
    retrievePrimaryNamedInsured,
    retrieveGroupPolicyStatus,
    handlePolicyChange,
    handleAddVehicle,
    handleTOOF,
    handleEmailAutoIDCard,
    launchAutoPolicyAction,
    launchFirePolicyAction,
    launchWebNecho,
    launchEmailAutoIDCard,
    launchBillingOnlineSystem,
    launchCertificateOfInsurance,
    launchNewCase,
    throwToast
} from 'c/policyActions';
import { constants } from 'c/policyDetailsCommonJS';
import { retrieveDetails } from 'c/policySummaryCommonJS';
import { buildAutoCoverages } from 'c/policyDetailsCoverage'
const {
    TERMINATED_STATUS,
    ADD_DRIVER,
    REPLACE_VEHICLE,
    POLICY_CHANGE,
    ADD_VEHICLE,
    AUTO_POLICY_CHANGE,
    FIRE_POLICY_CHANGE,
    LIFE_POLICY_CHANGE,
    HEALTH_POLICY_CHANGE,
    TOOF_REINSTATEMENT,
    EMAIL_AUTO_ID_CARD,
    BILLING_ONLINE_SYSTEM,
    CERTIFICATE_OF_INSURANCE,
    ADD_DRIVER_CASE,
    REPLACE_VEH_CASE,
    POLICY_CHANGE_CASE,
    NECHO_MAIN_TOC,
    MULTI_VEHICLE,
    FLEET,
    PERSONAL_AUTO_MOD_CD,
    STATUS_PROPOSED_AV,
    STATUS_SUSPENDED_AV
} = constants;
const SHOW_ALL_RISKS_LENGTH = 6;
const EXCLUDED_DRIVER_CD = 'Z';

const SUCCESS_STATUS = 200;
const UNKNOWN = 'unknown';

const isJsonString = (jsonString) => {
    try {
        const o = JSON.parse(jsonString);
        if (o && typeof o === "object") {
            return true;
        }
    }
    catch (e) {
        // returning false
    }
    return false;
};

const parseJSON = (jsonString) => {
    if (isJsonString(jsonString)) {
        return JSON.parse(jsonString);
    }
    return {};
};

export default class PolicySummaryCard extends NavigationMixin(LightningElement) {
    @api policy;
    @api userAccess;
    @api plmActivationStatus; // access object for actions
    @api accountPageRecordId;
    @api isHousehold;
    @api accountList;

    showAllRisks = false;
    isGroupPolicy;
    isSavingRecord;
    showRiskModal;
    accountContext = {};
    selectedAction;
    risk;
    risks;

    loadFrame;
    WORKSTATION = 'ha4c_workstation_id';
    calledRenderedCallback = false;
    vfMessageListener;
    parmString;
    caseId;

    dssIconPath = `${policyLogos}/DSS_red36.svg`;
    dssIconTitle = 'Drive Safe & Save\u2122'

    enhanceIsLoading = false;
    dvlError = '';

    // EMAIL AUTO ID CARD FIELDS
    @api loggedInSubuser;
    showSendModal = false;
    riskNumber;
    agreementAccessKey;
    policyNumber;

    policyActions = [];

    get servicingAgent() {
        if (this.policy.Servicing_Agent__r) {
            let agentParts = this.policy.Servicing_Agent__r.Name.split(', ');

            return `${agentParts[0]} (${agentParts[1]})`
        }

        return '--';
    }
    get policyStatusHelpText() {
        switch(this.policy.Status) {
            case 'Proposed':
                return STATUS_PROPOSED_AV;
            case 'Suspended': 
                return STATUS_SUSPENDED_AV;
            default:
                return '';
        }
    }

    // RISK SHOW ALL
    get showRiskShowAll() {
        return this.risks?.length > SHOW_ALL_RISKS_LENGTH ? true : false;
    }
    get getRisksForShowAll() {
        return this.showAllRisks ? this.risks : this.risks.slice(0, SHOW_ALL_RISKS_LENGTH);
    }
    get showAllRisksLabel() {
        return this.showAllRisks ? 'Hide' : `Show all (${this.risks.length})`;
    }
    toggleRiskShowAll() {
        this.showAllRisks = !this.showAllRisks;
        logClickToggleShowAllRisks();
    }

    // DATE GETTERS
    get inceptionDate() {
        const incept = this.policy.EffectiveDate ? this.policy.EffectiveDate.slice(0, 10) : null;
        return incept ? `${incept.substring(5, 7)}/${incept.substring(8)}/${incept.substring(0, 4)}` : '--';
    }
    get renewTermLabel() {
        return this.policy.Status === 'Terminated' ? 'Termination' : 'Renewal';
    }
    get renewTermDate() {
        return this.policy.Status === TERMINATED_STATUS ? this.termDate : this.renewDate;
    }
    get termDate() {
        const term = this.policy.CancellationDate?.split('T')[0];
        return term ? `${term.substring(5, 7)}/${term.substring(8)}/${term.substring(0, 4)}` : '--';
    }
    get renewDate() {
        const renew = this.policy.RenewalDate?.split('T')[0];
        return renew ? `${renew.substring(5, 7)}/${renew.substring(8)}/${renew.substring(0, 4)}` : '--';
    }
    get renewTermClass() {
        return this.policy.Status === TERMINATED_STATUS ? 'slds-m-right_medium red-text' : 'slds-m-right_medium';
    }

    // policy getters
    get isLegacyMultiCar() {
        return this.policy.PolicyDescription?.toUpperCase().includes(MULTI_VEHICLE);
    }
    get isModMultiCar() {
        return parseInt(this.policy.AgreSourceSysCd__c, 10) === PERSONAL_AUTO_MOD_CD && this.policy.InsurancePolicyAssets?.length > 1;
    }
    get isMultiCarAuto() {
        return this.isLegacyMultiCar || this.isModMultiCar;
    }
    get isPMRLife() {
        return this.policy.Name.startsWith('LF') || this.policy.Name.startsWith('AS');
    }
    get insuredTitle() {
        return this.policy.ProdLineCd__c === 'H' || this.policy.ProdLineCd__c === 'L' ? 'Owner' : 'Insureds';
    }
    get policyStatusNotInForceOrTerm() {
        return this.policy.Status !== TERMINATED_STATUS && this.policy.Status !== "In Force";
    }
    get isPolicyTerminated() {
        return this.policy.Status === TERMINATED_STATUS;
    }
    get isFleet() {
        return this.policy.PolicyName?.toUpperCase() === FLEET;
    }

    
    constructor() {
        super();
        // save a reference to the bound function 
        // because bind() returns a new function 
        // and the component would not be able to call 
        // removeEventListener() with the same function instance
        this.vfMessageListener = this.handleAuthResponse.bind(this);
    }

    async connectedCallback() {
        window.addEventListener('message', this.vfMessageListener);

        // need new list of risks with display field of `RiskNumber: Description` for modal button labels
        this.risks = this.policy.InsurancePolicyAssets?.
            filter(risk => (!(this.policy.Status !== TERMINATED_STATUS && risk.RiskStatusText__c === TERMINATED_STATUS)) ).
            map(risk => { return { ...risk, riskNumDesc: `${risk.RiskNumber__c}: ${risk.Description__c}` } }).
            sort((a,b) => { 
                if (parseInt(this.policy.AgreSourceSysCd__c, 10) === PERSONAL_AUTO_MOD_CD || this.policy.PolicyDescription?.toUpperCase().includes(FLEET)) {
                    if (a.Description__c < b.Description__c) { return 1 }
                    else if (a.Description__c > b.Description__c) { return -1 }
                    return 0;
                }
                else if (this.isLegacyMultiCar) {
                    if (a.RiskNumber__c < b.RiskNumber__c) { return -1 }
                    else if (a.RiskNumber__c > b.RiskNumber__c) { return 1 }
                    return 0;
                }
                if (a.Description__c < b.Description__c) { return -1 }
                else if (a.Description__c > b.Description__c) { return 1 }
                return 0;
            });

        this.agreementAccessKey = this.policy.AgreAccessKey__c;
        this.policyNumber = this.policy.Name;

        const pniPromise = retrievePrimaryNamedInsured({
            lob: this.policy.ProdLineCd__c,
            namedInsured: this.policy.NameInsuredId,
            niClientId: this.policy.NameInsured.ClientIdentifier__c,
            niName: this.policy.NameInsured.Name,
            niEmail: this.policy.NameInsured.PersonEmail,
            isPMRLife: this.isPMRLife,
            niRoleCd: this.policy.NI_RoleNameCd__c,
            niSecondaryRoleCd: this.policy.NI_SecondaryRoleNameCd__c,
            recordId: this.policy.Id
        }).then(pni => {
            if (pni && pni.accountRecordId && pni.accountClientId) {
                this.accountContext.recordId = pni.accountRecordId;
                this.accountContext.clientId = pni.accountClientId;
                this.accountContext.name = pni.accountName;
                this.accountContext.email = pni.accountEmail;
            } else {
                this.accountContext.recordId = this.policy.NameInsuredId;
                this.accountContext.clientId = this.policy.NameInsured.ClientIdentifier__c;
                this.accountContext.name = this.policy.NameInsured.Name;
                this.accountContext.email = this.policy.NameInsured.PersonEmail;
            }
        });

        const groupPromise = retrieveGroupPolicyStatus(this.policy.PolicyName).then(isGroupPolicy => {
            if (isGroupPolicy !== null) {
                this.isGroupPolicy = isGroupPolicy; //false is an allowed value, so this must have direct null check
            } else {
                this.logError('Failed to retrieve group policy status', 'policySummaryCard.connectedCallback');
            }
        });

        await Promise.all([
            pniPromise,
            groupPromise
        ]);

        await this.fetchPolicyActions();
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.vfMessageListener);
    }

    async handleAuthResponse(event) {
        const vfOrigin = await getVFOrigin();
        if (event.data && (event.origin === vfOrigin)) {
            const msg = parseJSON(event.data);
            if (msg.ha4cVfReady === true) {
                this.initiateVFAuthCall(vfOrigin);
            }
            if (msg.ha4cToken === true) {
                await this.processToken();
            }
            if (msg.ha4cToken === false) {
                this.processWorkstationId(UNKNOWN);
            }
        }
    }

    initiateVFAuthCall(vfOrigin) {
        //call vf to initiate auth flow
        const message = { ha4cPkceLogin: true }
        this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(message), vfOrigin);
    }

    async processToken() {
        const token = await getHA4CToken();
        const deviceId = parseJSON(window.atob(token.split('.')[1])).deviceid;
        const workstationId = await this.determineWorkstationId(token, deviceId);
        this.processWorkstationId(workstationId);
    }

    async determineWorkstationId(token, deviceId) {
        // call microsoftGraph API if the deviceId is not undefined
        if (typeof deviceId != 'undefined') {
            const endpoint = `https://graph.microsoft.com/v1.0/devices?$filter=deviceId+eq+'${deviceId}'&$select=displayName`;
            const respJson = await this.callMSGraph(endpoint, token);
            return respJson?.value[0]?.displayName || UNKNOWN;
        }
        return UNKNOWN
    }

    processWorkstationId(workstationId) {
        sessionStorage.setItem(this.WORKSTATION, workstationId);
        this.navigateToWeb(workstationId);

    }

    async handleClick() {
        const workstationId = sessionStorage.getItem(this.WORKSTATION);
        if (workstationId) {
            this.navigateToWeb(workstationId);
        } else {
            this.loadFrame = true;
        }    }


    //This method will launch URL in new Browser Window tab after setting up all paramters
    async navigateToWeb(workstationId) {
        this.parmString = await getPolicyDetailsParmHA4C({ caseId: this.caseId });
        window.open(this.parmString + '&workstationID=' + workstationId + '&pgmName=PCA21&callingApp=Case');
    }

    async callMSGraph(endpoint, accessToken) {
        const bearer = `Bearer ${accessToken}`;
        const options = {
            method: "GET",
            headers: {
                'Authorization': bearer,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'ConsistencyLevel': 'eventual'
            }
        };
        try {
            const response = await fetch(endpoint, options);
            // return response json only if the status code is 200
            if (response.status === SUCCESS_STATUS) {
                const responseBody = await response.json();
                return responseBody;
            }
        } catch (e) {
            // nothing to do here - just returning null
        }
        return null;
    }

    showToast(title, type, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: type,
            message: message
        });
        this.dispatchEvent(toastEvent);
    }


    // ALERTS
    get alerts() {
        let alerts = [];

        alerts.push.apply(alerts, this.buildBillingAlerts());
        return alerts;
    }
    buildBillingAlerts() {
        let billAlerts = [];
        if (this.policy.BillingPolicyAccounts__r?.length) {
            for (let bill of this.policy.BillingPolicyAccounts__r) {
                if (bill.BillingAccountID__r.PastDueIndicator__c) {

                    billAlerts.push({
                        type: 'Billing',
                        recordId: bill.BillingAccountID__c,
                        accountNumber: bill.BillingAccountID__r.AccountNumber__c,
                        message: this.buildPastDueMessage(bill),
                        billingDetailsLink: `/${bill.BillingAccountID__c}`,
                        alertClass: 'past-due-red'
                    });
                }
            }
        }

        return billAlerts;
    }

    buildPastDueMessage(bill) {
        let sourceSystem = bill.BillingAccountID__r.SourceSystem__c;
        return `There is a past due balance on this ${sourceSystem} account: `;
    }

    // NAVIGATION
    navigateTo(objectName, recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectName,
                actionName: 'view',
            },
        });
    }
    navigateToPolicy() {
        this.navigateTo('InsurancePolicy', this.policy.Id);
        logClickCardPolicyNum();
    }
    navigateToBill(event) {
        this.navigateTo('Billing_Account__c', event.currentTarget.dataset.id);
        logClickCardBillingAcctNum();
    }
    navigateToClaim(event) {
        this.navigateTo('Claim', event.currentTarget.dataset.id);
        logClickCardOpenClaim();
    }
    launchAgentLink() {
        let stateCode = this.policy.Servicing_Agent__r?.State_Agent_Code__c?.substring(0, 2);
        let agentCode = this.policy.Servicing_Agent__r?.State_Agent_Code__c?.substring(3);

        window.open(`/c/ExternalLinkApp.app?linkId=26&primaryStateCode=${stateCode}&primaryAgentCode=${agentCode}`);
        logClickCardAgentLink();
    }

    // POLICY ACTIONS
    async fetchPolicyActions() {
        let policyParams = {
            sourceSystemCode: parseInt(this.policy.AgreSourceSysCd__c, 10),
            isStatusTerminated: this.policy.Status === TERMINATED_STATUS,
            lob: this.policy.ProdLineCd__c,
            isPhoenixLife: this.policy.PolicyName?.toUpperCase().startsWith('PNX'),
            isMultiCarAuto: this.isMultiCarAuto,
            policyName: this.policy.PolicyName,
            productDescription: this.policy.PolicyName,
            policyTypeCode: this.policy.PlcyTypeCd__c
        };

        try {
            let actions = await buildActionsList(this.userAccess, policyParams);
            this.policyActions = actions.actionsButtonList.concat(actions.actionsMenuList);
        } catch (e) {
            this.logError('Error while fetching policy actions: ' + JSON.stringify(e.message), 'policySummaryCard.fetchPolicyActions');
        }
    }

    // ENHANCE
    get isAuto() {
        return this.policy.ProdLineCd__c === 'A';
    }
    get isSuretyBond() {
        return this.policy.PolicyName?.toUpperCase().includes('SURETY BOND');
    }
    get isAutoOrSurety() {
        return this.isAuto || this.isSuretyBond;
    }
    @api
    async enhancePolicy() {
        this.enhanceIsLoading = true;
        let details;

        if (this.details) { 
            this.enhanceIsLoading = false;
            return;
        }

        if (this.isFleet) {
            throwToast(
                this,
                'Additional policy data is not available for Fleet policies.',
                null,
                'warning',
                'dismissible'
            );

            this.enhanceIsLoading = false;
            return;
        }

        try {
            details = await retrieveDetails(this.policy.ProdLineCd__c, this.policy.AgreAccessKey__c, this.policy.AgreSourceSysCd__c)
            await this.extractDetails(details);
        } catch (e) {
            this.dvlError = e.message
            this.logError('Summary Data Enhance failed: ' + JSON.stringify(e.message), 'policySummaryCard.enhancePolicy');
        }
        
        this.enhanceIsLoading = false;

        logClickEnhanceSummary();
    }
    async extractDetails(details) {
        this.details = details;

        if (details?.termVersion?.insurableRisk?.length) {
            for (let dvlRisk of details.termVersion.insurableRisk) {

                let uiRisk = this.risks.find(risk => dvlRisk.vehicle?.length && risk.VIN_Address_Cov_Amt__c === dvlRisk.vehicle[0].physicalObjectSerialNumber)
                
                if (uiRisk && this.isAuto) {
                    // eslint-disable-next-line no-await-in-loop
                    await this.buildDrivers(uiRisk, dvlRisk);
                    this.buildCoverageStrip(uiRisk, dvlRisk);
                    this.buildDSSDiscount(uiRisk, dvlRisk);
                }
            }
        }

        if (this.isSuretyBond) {
            if (details?.policyPartyRole?.length) {
                this.buildObligee(details);
            }
        }
    }
    async buildDrivers(uiRisk, dvlRisk) {
        let drivers = [];
        let clientIds = [];

        if (dvlRisk.riskPartyRole?.length) {
            dvlRisk.riskPartyRole.forEach(operator => {
                if (operator.exposureRatingCode !== EXCLUDED_DRIVER_CD) {

                    let driver = { 
                        firstName: operator.party?.partyName?.firstName,
                        age: this.calculateAge(operator.party?.birthDate),
                        clientId: operator.party?.partyIdentifier,
                        isPrincipalOperator: this.findPrincipalOperator(operator, dvlRisk.legacyRatingAssignment),
                        isAssignedDriver: this.findAssignedDriver(operator, dvlRisk.legacyRatingAssignment),
                        isPrincipalAndAssigned: (this.findPrincipalOperator(operator, dvlRisk.legacyRatingAssignment) && this.findAssignedDriver(operator, dvlRisk.legacyRatingAssignment))
                    }

                    if (!driver.firstName && operator.party?.partyIdentifier) {
                        clientIds.push(operator.party.partyIdentifier)
                    }

                    drivers.push(driver)
                }
            })

            if (clientIds.length) {
                try {
                    const res = await getAccountData({ clientIdList: clientIds });
                    res.forEach(account => {
                        let driverFound = drivers.find(driver => driver.clientId === account.clientId)
                        driverFound.firstName = account.firstName;
                    })
                } catch (e) {
                    this.logError('Failed to retrieve account names: ' + JSON.stringify(e.message), 'policySummaryCard.buildDrivers');
                }
            }

            uiRisk.drivers = [...drivers
                .filter(driver => driver.firstName && driver.age)
                .sort((a,b) => { return this.sortDrivers(a, b) })];

            if (uiRisk.drivers.length) {
                uiRisk.drivers[uiRisk.drivers.length - 1].isLastDriver = true;
            }
        }
    }
    findPrincipalOperator(operator, ratingAssignments) {
        let returnVal = false;
        if (ratingAssignments?.length) {
            ratingAssignments.forEach(ratingAssignment => {
                if (ratingAssignment.ratingAssignmentRoleCode === '04' && operator.party.autoClientIdentifier === ratingAssignment.party.autoClientIdentifier) {
                    returnVal = true
                }
            })
        }
        return returnVal;
    }
    findAssignedDriver(operator, ratingAssignments) {
        let returnVal = false;
        if (ratingAssignments?.length) {
            ratingAssignments.forEach(ratingAssignment => {
                if (ratingAssignment.ratingAssignmentRoleCode === '01' && operator.party.autoClientIdentifier === ratingAssignment.party.autoClientIdentifier) {
                    returnVal = true
                }
            })
        }
        return returnVal;
    }
    sortDrivers(a, b) {
        if (a.isPrincipalOperator) {
            return -1;
        } else if (b.isPrincipalOperator) {
            return 1;
        }

        if (a.isAssignedDriver) {
            return -1;
        } else if (b.isAssignedDriver) {
            return 1;
        }

        if (a.age > b.age) {
            return -1;
        } else if (a.age < b.age) {
            return 1;
        }

        return 0;
    }
    calculateAge(dob) { 
        if (dob) {
            let diffMs = Date.now() - new Date(dob).getTime();
            let ageDt = new Date(diffMs); 
          
            return Math.abs(ageDt.getUTCFullYear() - 1970);
        }
        return undefined
    }
    buildCoverageStrip(uiRisk, dvlRisk) {
        if (this.isAuto && dvlRisk.coverageSet?.coverage) {
            const coverageRes = buildAutoCoverages(dvlRisk.coverageSet.coverage);
            uiRisk.coverageAbbreviations = this.sortAbbreviations(coverageRes.coverageText);
        }
    }
    sortAbbreviations(coverageText) {
        return coverageText.split(", ").sort((a, b) => {
            if (a[0] > b[0]) { return 1; }
            else if (a[0] < b[0]) { return -1; }
            return 0;
        });
    }
    buildDSSDiscount(uiRisk, dvlRisk) {
        uiRisk.hasDssDiscount = false;

        let dssDiscount = dvlRisk.vehicle[0].driveSafeAndSaveEnrollmentSwitch

        if (dssDiscount) uiRisk.hasDssDiscount = true;
    }
    buildObligee(details) {
        for (let role of details.policyPartyRole) {
            if (role.roleNameCode === 20) {
                this.obligee = role.party?.partyName?.fullName;
            }
        }
    }
    
    handleOnSelect(event) {
        this.selectedAction = event.detail.value;

        if (this.isLegacyMultiCar) {
            this.showRiskModal = true;
        } else {
            this.handleAction(event.detail.value);
        }
    }
    handleModalSelect(event) {
        let riskId = event.currentTarget.dataset.id;
        let selectedRisk = this.policy.InsurancePolicyAssets.find(risk => {
            return risk.Id === riskId;
        })

        this.risk = selectedRisk;
        this.riskNumber = selectedRisk.RiskNumber__c;
        this.handleAction(this.selectedAction)
        this.showRiskModal = false;
    }
    closeRiskModal() {
        this.selectedAction = null;
        this.showRiskModal = false;
    }
    handleAction(actionLabel) {
        const paramObject = {
            sourceSystemCode: parseInt(this.policy.AgreSourceSysCd__c, 10),
            agreementIndexId: this.policy.SourceSystemIdentifier,
            isMultiCarAuto: this.isLegacyMultiCar,
            agentAssociateId: this.policy.Servicing_Agent__r?.Associate_ID__c,
            stateAgentCode: this.policy.Servicing_Agent__r?.State_Agent_Code__c,
            lob: this.policy.ProdLineCd__c,
            policyNumber: this.isLegacyMultiCar ? this.policy.Name + '-' + this.risk.RiskNumber__c : this.policy.Name,
            accountRecordId: this.accountContext.recordId,
            accountClientId: this.accountContext.clientId,
            riskNumber: this.risk?.RiskNumber__c,
            productDescription: this.isLegacyMultiCar ? this.risk.Description__c : this.isGroupPolicy ? this.policy.PolicyName : this.policy.PolicyDescription,
            agreAccessKey: this.policy.AgreAccessKey__c,
            unformattedPolicyNumber: this.policy.SFDCPolicyNumberSearchKey__c
        };

        if (this.policy.NI_RoleNameCd__c === '22') {
            paramObject.policyOwner = this.policy.NameInsuredId
        }

        // eslint-disable-next-line default-case
        switch (actionLabel) {
            case POLICY_CHANGE:
                this.isSavingRecord = true;
                handlePolicyChange(paramObject, this)
                    .then((caseId) => {this.caseId = caseId ; this.handleClick(); })
                    .catch((e) => {
                        this.logError('Failed to make policy change case: ' + JSON.stringify(e.message), 'policySummaryCard.handleAction');
                    })
                    .finally(() => { this.isSavingRecord = false });
                logClickCardActionPolicyChange();
                break;
            case ADD_VEHICLE:
                this.isSavingRecord = true;
                handleAddVehicle(paramObject, this)
                    .then((caseId) => {this.caseId = caseId ; this.handleClick(); })
                    .catch((e) => {
                        this.logError('Failed to make add vehicle case: ' + JSON.stringify(e.message), 'policySummaryCard.handleAction');
                    })
                    .finally(() => { this.isSavingRecord = false });
                logClickCardActionAddVehicle();
                break;
            case ADD_DRIVER:
                launchAutoPolicyAction(paramObject);
                launchNewCase(ADD_DRIVER_CASE, paramObject, this);
                logClickCardActionAddDriver();
                break;
            case REPLACE_VEHICLE:
                launchAutoPolicyAction(paramObject);
                launchNewCase(REPLACE_VEH_CASE, paramObject, this);
                logClickCardActionReplaceVehicle();
                break;
            case AUTO_POLICY_CHANGE:
                launchAutoPolicyAction(paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                logClickCardActionAutoPolicyChange();
                break;
            case FIRE_POLICY_CHANGE:
                launchFirePolicyAction(paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                logClickCardActionFirePolicyChange();
                break;
            case TOOF_REINSTATEMENT:
                handleTOOF(paramObject, this);
                logClickCardActionToofReinstatement();
                break;
            case LIFE_POLICY_CHANGE:
            case HEALTH_POLICY_CHANGE:
                launchWebNecho(NECHO_MAIN_TOC, paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                if (actionLabel === LIFE_POLICY_CHANGE) {
                    logClickCardActionLifePolicyChange();
                }
                else {
                    logClickCardActionHealthPolicyChange();
                }
                break;
            case EMAIL_AUTO_ID_CARD:
                handleEmailAutoIDCard(this);
                logClickCardActionEmailAutoId();
                break;
            case BILLING_ONLINE_SYSTEM:
                launchBillingOnlineSystem(this.accountContext.recordId, this.policy.CoCd__c, this.policy.Name, this.policy.ProdLineCd__c);
                logClickCardActionBos();
                break;
            case CERTIFICATE_OF_INSURANCE:
                launchCertificateOfInsurance(this.policy.MasterDataLocationCd__c, this.policy.Name, this.policy.PlcyTypeCd__c, this.policy.ProdLineCd__c, this.accountContext.clientId);
                logClickCardActionCoi();
                break;
        }
    }

    copyPolicyNumber() {
        try {
            // create temporary element to clip from
            const temp = document.createElement("input");
            document.body.appendChild(temp);

            // Set temporary component value, select and copy.
            temp.value = this.policy.Name;
            temp.select();
            document.execCommand("copy");

            // Remove temporary element as its not needed anymore
            document.body.removeChild(temp);
        } catch (e) {
            this.logError('Failed to copy policy number: ' + JSON.stringify(e.message), 'policySummaryCard.copyPolicyNumber')
        }
    }

    onCloseModal(event) {
        this.showSendModal = event.detail.showModal;
    }
    onSendEmail(event) {
        this.sendEmail = event.detail.sendEmail;
        this.accountContext.email = event.detail.userEmail;
        this.showSendModal = false;

        launchEmailAutoIDCard(this.accountContext, this.riskNumber ? this.agreementAccessKey + this.riskNumber : this.agreementAccessKey, this);
    }

    logError(message, method) {
        try {
            logException({
                message: message,
                method: method
            });
        } catch (e) {
            //log failed
        }
    }
}
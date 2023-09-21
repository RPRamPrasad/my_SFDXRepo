import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import logException from '@salesforce/apex/InsurancePolicyController.logException';
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
    launchNewCase
} from 'c/policyActions';
import { constants } from 'c/policyDetailsCommonJS';

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

export default class PolicySummaryList extends NavigationMixin(LightningElement) {
    @api policy;
    @api userAccess;
    @api plmActivationStatus;
    @api accountPageRecordId;
    @api isHousehold;
    @api accountList;

    isGroupPolicy;
    isSavingRecord; // UI flag to disable actions
    showRiskModal; // UI flag for risk selection modal
    accountContext = {}; // account context to use for action launches
    selectedAction; // selected policy action when risk modal is displayed
    risk;
    risks;

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

    // dynamic css classes
    get billingColumnClass() {
        return this.policy.BillingPolicyAccounts__r?.length > 1 ? 'billing-column' : 'billing-column slds-m-top_x-small';
    }
    get claimColumnClass() {
        return this.policy.Claims?.length === 2 ? 'claim-column' : 'claim-column slds-m-top_x-small';
    }
    get hasOneOrTwoBills() {
        return this.policy.BillingPolicyAccounts__r.length === 1 || this.policy.BillingPolicyAccounts__r.length === 2;
    }
    get hasOneOrTwoClaims() {
        return this.policy.Claims.length === 1 || this.policy.Claims.length === 2;
    }
    get policyStatusNotInForceOrTerm() {
        return this.policy.Status !== TERMINATED_STATUS && this.policy.Status !== "In Force";
    }

    // date field getters
    get inceptionDate() {
        const incept = this.policy.EffectiveDate ? this.policy.EffectiveDate.slice(0, 10) : null;
        return incept ? `${incept.substring(5, 7).trim()}/${incept.substring(8).trim()}/${incept.substring(0, 4).trim()}` : '--';
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
        return this.policy.Status === TERMINATED_STATUS ? 'text-red' : '';
    }

    // dynamic risk section getters
    get checkForRisks() {
        return this.risks?.length > 0;
    }
    get multipleRisks() {
        return this.risks.length > 1;
    }

    // truncated description getters
    get policyDescription() {
        return this.policy.PolicyName?.length > 26 ? this.policy.PolicyName.substring(0, 24) + '...' : this.policy.PolicyName;
    }
    get firstRiskDescriptionTrunc() {
        return this.firstRiskDescription.length > 35 ? this.firstRiskDescription.substring(0, 35) + '...' : this.firstRiskDescription;
    }
    get firstRiskDescription() {
        return this.risks[0].Description__c;
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


    async connectedCallback() {
        // need new list of risks with display field of `RiskNumber: Description` for modal button labels
        this.risks = this.policy.InsurancePolicyAssets?.
            filter(risk => (!(this.policy.Status !== TERMINATED_STATUS && risk.RiskStatusText__c === TERMINATED_STATUS)) ).
            map(risk => { return { ...risk, riskNumDesc: `${risk.RiskNumber__c}: ${risk.Description__c}` } }).
            sort((a,b) => { 
                if (parseInt(this.policy.AgreSourceSysCd__c, 10) === PERSONAL_AUTO_MOD_CD || this.policy.PolicyDescription?.toUpperCase().includes(FLEET)) {
                    if (a.Description__c < b.Description__c) { return 1 }
                    if (a.Description__c > b.Description__c) { return -1 }
                    return 0;
                }
                if (this.isLegacyMultiCar) {
                    if (a.RiskNumber__c > b.RiskNumber__c) { return 1 }
                    if (a.RiskNumber__c < b.RiskNumber__c) { return -1 }
                    return 0;
                }
                if (a.Description__c > b.Description__c) { return 1 }
                if (a.Description__c < b.Description__c) { return -1 }
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
                this.logError('Failed to retrieve group policy status', 'policySummaryList.connectedCallback');
            }
        });

        await Promise.all([
            pniPromise,
            groupPromise
        ]);
        
        await this.fetchPolicyActions();
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
        logClickListPolicyNum();
    }
    navigateToBill(event) {
        this.navigateTo('Billing_Account__c', event.currentTarget.dataset.id)
        logClickListBillingAcctNum();
    }
    navigateToClaim(event) {
        this.navigateTo('Claim', event.currentTarget.dataset.id)
        logClickListOpenClaim();
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
            this.logError('Error while fetching policy actions: ' + JSON.stringify(e.message), 'policySummaryList.fetchPolicyActions');
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
                handlePolicyChange(paramObject, this).then(() => { this.isSavingRecord = false }).catch((e) => {
                    this.logError('Failed to make policy change case: ' + JSON.stringify(e.message), 'policySummaryList.handleAction');
                    this.isSavingRecord = false
                });
                logClickListActionPolicyChange();
                break;
            case ADD_VEHICLE:
                this.isSavingRecord = true;
                handleAddVehicle(paramObject, this).then(() => { this.isSavingRecord = false }).catch((e) => {
                    this.logError('Failed to make add vehicle case: ' + JSON.stringify(e.message), 'policySummaryList.handleAction');
                    this.isSavingRecord = false
                });
                logClickListActionAddVehicle();
                break;
            case ADD_DRIVER:
                launchAutoPolicyAction(paramObject);
                launchNewCase(ADD_DRIVER_CASE, paramObject, this);
                logClickListActionAddDriver();
                break;
            case REPLACE_VEHICLE:
                launchAutoPolicyAction(paramObject);
                launchNewCase(REPLACE_VEH_CASE, paramObject, this);
                logClickListActionReplaceVehicle();
                break;
            case AUTO_POLICY_CHANGE:
                launchAutoPolicyAction(paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                logClickListActionAutoPolicyChange();
                break;
            case FIRE_POLICY_CHANGE:
                launchFirePolicyAction(paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                logClickListActionFirePolicyChange();
                break;
            case TOOF_REINSTATEMENT:
                handleTOOF(paramObject, this);
                logClickListActionToofReinstatement();
                break;
            case LIFE_POLICY_CHANGE:
            case HEALTH_POLICY_CHANGE:
                launchWebNecho(NECHO_MAIN_TOC, paramObject);
                launchNewCase(POLICY_CHANGE_CASE, paramObject, this);
                if (actionLabel === LIFE_POLICY_CHANGE) { logClickListActionLifePolicyChange(); } else { logClickListActionHealthPolicyChange(); }
                break;
            case EMAIL_AUTO_ID_CARD:
                handleEmailAutoIDCard(this);
                logClickListActionEmailAutoId();
                break;
            case BILLING_ONLINE_SYSTEM:
                launchBillingOnlineSystem(this.accountContext.recordId, this.policy.CoCd__c, this.policy.Name, this.policy.ProdLineCd__c);
                logClickListActionBos();
                break;
            case CERTIFICATE_OF_INSURANCE:
                launchCertificateOfInsurance(this.policy.MasterDataLocationCd__c, this.policy.Name, this.policy.PlcyTypeCd__c, this.policy.ProdLineCd__c, this.accountContext.clientId);
                logClickListActionCoi();
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
            this.logError('Failed to copy policy number: ' + JSON.stringify(e.message), 'policySummaryList.copyPolicyNumber')
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
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { LightningElement, api, wire } from 'lwc';

import fetchAllPolicies from '@salesforce/apex/PolicySummaryQueryController.fetchAllPolicies';
import fetchUserPreference from '@salesforce/apex/PolicySummaryPreferenceController.fetchUserPreference';
import updateUserView from '@salesforce/apex/PolicySummaryPreferenceController.updateUserView';
import getAccountIdsForHouseholdFSC from '@salesforce/apex/BillingActionsController.getRecordIdsForHousehold';
import logException from '@salesforce/apex/InsurancePolicyController.logException';

import logClickActiveInactiveSlider from '@salesforce/apex/PolicySummaryEventController.logClickActiveInactiveSlider';
import logClickCollapseAll from '@salesforce/apex/PolicySummaryEventController.logClickCollapseAll';
import logClickExpandAll from '@salesforce/apex/PolicySummaryEventController.logClickExpandAll';
import logClickAlert from '@salesforce/apex/PolicySummaryEventController.logClickAlert';
import logSetAlert from '@salesforce/apex/PolicySummaryEventController.logSetAlert';
import logClickEnhanceAll from '@salesforce/apex/PolicySummaryEventController.logClickEnhanceAll';

import hasSAEPolicyChangeAccess from '@salesforce/customPermission/SAE_Policy_Change';

import ACCT_RECORD_TYPE_ID from '@salesforce/schema/Account.RecordTypeId';
import CLIENT_ID from '@salesforce/schema/Account.ClientIdentifier__c';
import USER_ID from '@salesforce/user/Id';
import SUBUSER_TYPE from '@salesforce/schema/User.SubUserType__c';

// import hasSupportAccess from '@salesforce/customPermission/PolicySummary_SupportAccess';
// import hasEarlyAccess from '@salesforce/customPermission/PolicySummary_EarlyAccess';

import {
    getFeatureAccessMetadataBySubuserType,
    getFeatureAccessMetadataByUserCriteria
} from 'c/checkFeatureAccess';
import {
    retrievePLMStatus
} from 'c/policyActions';

const TERMINATED = 'Terminated';
const LIST_VIEW = 'policy-list';
const CARD_VIEW = 'policy-card';

export default class PolicySummaryMain extends LightningElement {
    @api recordId;
    isHousehold;
    acctRecordTypeId;

    policies;
    policiesByStatus;
    policiesByLob;
    activePolicies = [];
    inactivePolicies = [];
    accountList;

    // View Selector Bools
    policyCardView;
    policyListView;

    isLoading = true;
    showingActive = true;
    alertFound = false;
    hasLoggedAlertClick = false;

    userAccess = {};
    plmActivationStatus = {};

    disableEnhance = false;

    enhanceAllPolicies() {
        this.disableEnhance = true;
        let cards = this.template.querySelectorAll('c-policy-summary-card');
        cards.forEach(card => { card.enhancePolicy() });
        logClickEnhanceAll();
    }

    // Accordion Sections/Status Toggle
    activeSections = this.setAllSectionsActive();
    handleExpand(_, isFromToggleStatus) {
        this.activeSections = this.setAllSectionsActive();

        if (!isFromToggleStatus) {
            logClickExpandAll();
        }
    }
    handleCollapse() {
        this.activeSections = [];
        logClickCollapseAll();
    }
    setAllSectionsActive() {
        return ['Auto', 'Fire', 'Life', 'Health'];
    }

    handleAlertClick(event) {
        if (event.detail.value === this.recordId && !this.hasLoggedAlertClick) {
            this.hasLoggedAlertClick = true;
            logClickAlert()
        }
    }

    async toggleStatus(event) {
        const desiredStatus = event.target.checked;

        this.policiesByLob.forEach(lob => {
            lob.policies = desiredStatus ? lob.activePolicies : lob.inactivePolicies;
            lob.length = lob.policies.length;
        });

        this.policiesByStatus = desiredStatus ? this.activePolicies : this.inactivePolicies;
        this.showingActive = desiredStatus;
        await Promise.resolve(); // need to wait for current updates, or accordion sections will remain closed
        this.handleExpand(null, true);

        logClickActiveInactiveSlider();
    }

    // POLICY PROCESSING
    @wire(getRecord, { recordId: '$recordId', fields: [ACCT_RECORD_TYPE_ID, CLIENT_ID] })
    async getRecordData(result) {
        if (result.data) {
            this.acctRecordTypeId = getFieldValue(result.data, ACCT_RECORD_TYPE_ID);
            this.clientId = getFieldValue(result.data, CLIENT_ID);

            try {
                await Promise.all([
                    this.getUserAccess(),
                    this.getPolicies(),
                    this.getViewPreference(),
                    this.loadHouseholdData()
                ]);

                this.isLoading = false;
            }
            catch (e) {
                this.logError('Error while running main promises: ' + JSON.stringify(e.message), 'policySummaryMain.getRecordData');
            }

            this.checkForAlerts()
            if (this.alertFound) {
                logSetAlert();
            }

        } else if (result.error) {
            this.logError('Error while retrieving account record type: ' + JSON.stringify(result.error), 'policySummaryMain.getRecordData');
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [SUBUSER_TYPE] })
    async getUserRecordData(result) {
        if (result.data) {
            this.loggedInSubuser = getFieldValue(result.data, SUBUSER_TYPE);
        } else if (result.error) {
            this.logError('Error retrieving user data: ' + JSON.stringify(result.error), 'policySummaryMain.getUserRecordData');
        }
    }

    async loadHouseholdData() {
        this.isHousehold = !this.clientId ? true : false;
        let householdData;

        if (this.isHousehold) {
            try {
                householdData = await getAccountIdsForHouseholdFSC({ recordId: this.recordId });

                this.accountIds = Object.keys(householdData);
                this.accountValues = Object.values(householdData);
                this.accountList = this.accountValues.map(acct => ({ value: acct.Id, label: acct.Name }));
            } catch (e) {
                this.logError('Error retrieving Household Data ' + JSON.stringify(e.message), 'policySummaryMain.loadHouseholdData');
            }
        }
    }

    async getPolicies() {
        try {
            this.policies = await fetchAllPolicies({ inputRecordId: this.recordId, inputRecordTypeId: this.acctRecordTypeId });
        } catch (e) {
            this.logError('Error retrieving policies data: ' + JSON.stringify(e.message), 'policySummaryMain.getPolicies');
        }

        this.sortPoliciesByStatusAndLob();
    }
    sortPoliciesByStatusAndLob() {
        const auto = {
            lob: 'Auto',
            activePolicies: [],
            inactivePolicies: []
        };
        const fire = {
            lob: 'Fire',
            activePolicies: [],
            inactivePolicies: []
        };
        const life = {
            lob: 'Life',
            activePolicies: [],
            inactivePolicies: []
        };
        const health = {
            lob: 'Health',
            activePolicies: [],
            inactivePolicies: []
        };

        if (this.policies?.length) {
            this.policies.forEach(policy => {
                switch (policy.PolicyType) {
                    case 'Auto':
                        this.sortPolicyByStatus(auto, policy);
                        break;
                    case 'Fire':
                        this.sortPolicyByStatus(fire, policy);
                        break;
                    case 'Life':
                        this.sortPolicyByStatus(life, policy);
                        break;
                    case 'Health':
                        this.sortPolicyByStatus(health, policy);
                        break;
                    default:
                }
            })
        }

        this.policiesByLob = [auto, fire, life, health];
        this.policiesByLob.forEach(lob => {
            lob.policies = lob.activePolicies;
            lob.length = lob.policies.length;
        });
        this.policiesByStatus = this.activePolicies;
    }
    sortPolicyByStatus(policyList, newPolicy) {
        if (newPolicy.Status === TERMINATED) {
            policyList.inactivePolicies.push(newPolicy);
            this.inactivePolicies.push(newPolicy);
        } else {
            policyList.activePolicies.push(newPolicy);
            this.activePolicies.push(newPolicy);
        }
    }

    // VIEW PREFERENCE
    async getViewPreference() {
        let userPref;

        try {
            userPref = await fetchUserPreference();
        } catch (e) {
            this.logError('Failed to fetch user view preference: ' + JSON.stringify(e.message), 'policySummaryMain.getViewPreference');
        }

        switch (userPref) {
            case LIST_VIEW:
                this.policyListView = true;
                this.policyCardView = false;
                break;
            case CARD_VIEW:
            default:
                this.policyListView = false;
                this.policyCardView = true;
                break;
        }
    }

    async updateViewPreference(viewPref) {
        try {
            await updateUserView({ userView: viewPref });
        } catch (e) {
            this.logError('Failed to update user preference: ' + JSON.stringify(e.message), 'policySummaryMain.updateViewPreference');
        }
    }
    showPolicyList() {
        this.policyListView = true;
        this.policyCardView = false;

        this.updateViewPreference(LIST_VIEW);
    }
    showPolicyCard() {
        this.policyListView = false;
        this.policyCardView = true;

        this.updateViewPreference(CARD_VIEW);
    }

    // USER ACCESS
    async getUserAccess() {
        await Promise.all(this.buildAccessPromises());

        this.userAccess.hasSAEPolicyChangeAccess = hasSAEPolicyChangeAccess;
    }
    buildAccessPromises() {
        const policyTransactionPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_PolicyTransactions')
            .then(data => { this.handleAccessAssignment(data, 'hasPolicyTransactionAccess') });
        const toofLinkPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_ToofPolicy')
            .then(data => { this.handleAccessAssignment(data, 'hasToofLinkAccess') });    
        const autoIdCardforSubuserTypePromise = getFeatureAccessMetadataBySubuserType('PolicyActions_AutoIDCard')
            .then(data => { this.handleAccessAssignment(data, 'hasAutoIdCardAccessforSubuserType') });
        const autoIdCardforUserCriteriaPromise = getFeatureAccessMetadataByUserCriteria('PolicyActions_AutoIDCard')
            .then(data => { this.handleAccessAssignment(data, 'hasAutoIdCardAccessforUserCriteria') });
        const BOSPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_BillingOnlineSystem')
            .then(data => { this.handleAccessAssignment(data, 'hasBOSLinkAccess') });
        const COIPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_CertificateOfInsurance')
            .then(data => { this.handleAccessAssignment(data, 'hasCOILinkAccess') });
        // const dssBeaconReorderPromise = getFeatureAccessMetadataBySubuserType('PolicyActions_DSSBeaconReorder')
        //     .then(data => { this.handleAccessAssignment(data, 'hasDSSBeaconReorderAccess') });
        const csPLMStatus = retrievePLMStatus().then(plmStatus => {
            this.plmActivationStatus.isOppRedirectActive = plmStatus.PLM_Opp_Redirect_Active__c;
            this.plmActivationStatus.isPCAutoLaunchActive = plmStatus.PLM_Auto_Launch_PC_Active__c;
            this.plmActivationStatus.isPolicyActionsActive = plmStatus.PLM_Policy_Actions_Active__c;
        });

        return [
            policyTransactionPromise,
            toofLinkPromise,
            autoIdCardforSubuserTypePromise,
            autoIdCardforUserCriteriaPromise,
            BOSPromise,
            COIPromise,
            // dssBeaconReorderPromise,
            csPLMStatus
        ];
    }

    handleAccessAssignment(data, accessName) {
        this.userAccess[accessName] = data?.read ? data.read : false;
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

    checkForAlerts() {
        if (this.policies?.length) {
            this.policies.forEach(policy => {
                if (policy.BillingPolicyAccounts__r) {
                    policy.BillingPolicyAccounts__r.forEach(bill => {
                        if (bill.BillingAccountID__r.PastDueIndicator__c) {
                            this.alertFound = true;
                            // eslint-disable-next-line no-useless-return
                            return;
                        }
                    })
                }
            })
        }
    }
}
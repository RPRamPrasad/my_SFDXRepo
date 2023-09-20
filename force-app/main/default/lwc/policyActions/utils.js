import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import createPolicyTransactionCase from '@salesforce/apex/InsurancePolicyController.createPolicyTransactionCase';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';
import getEncodedDescription from '@salesforce/apex/InsurancePolicyController.encodeProductDescription';
import getPLMStatus from '@salesforce/apex/InsurancePolicyController.getPLMStatus';
import getPLMStatusForState from '@salesforce/apex/InsurancePolicyController.getPLMStatusForState';
import getTargetAutoPolicyForState from '@salesforce/apex/InsurancePolicyController.getTargetAutoPolicyForState';
import getInsurancePolicyAssets from '@salesforce/apex/InsurancePolicyController.getInsurancePolicyAssets';
import isHatsorHa4cUser from '@salesforce/apex/HA4C_PKCE.isHatsORha4cUser';

import {
    launchAutoPolicyAction,
    launchFirePolicyAction,
    launchEmailAutoIDCard
} from './actions';
import { constants } from 'c/policyDetailsCommonJS';
const {
    AUTO, FIRE, LIFE, HEALTH, BANK, MUTUAL_FUND,
    POLICY_CHANGE_CASE, ADDED_VEH_CASE, TOOF_REINSTATEMENT,
    PERSONAL_AUTO_MOD_CD,COMMERCIAL_MOD_CD,LEGACY_CD
} = constants;

export const throwToast = (component, title, message, variant, mode) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant ? variant : 'error',
        mode: mode ? mode : 'sticky'
    });
    component.dispatchEvent(event);
}

export const removeSpacesDashes = (word) => {
    let returnWord = word.split(' ').join('');
    returnWord = returnWord.split('-').join('');
    return returnWord;
}

export const getFullLOB = (lob) => {
    let fullLob;

    switch (lob) {
        case AUTO:
            fullLob = 'Auto';
            break;
        case FIRE:
            fullLob = 'Fire';
            break;
        case LIFE:
            fullLob = 'Life';
            break;
        case HEALTH:
            fullLob = 'Health';
            break;
        case BANK:
            fullLob = 'Bank';
            break;
        case MUTUAL_FUND:
            fullLob = 'Mutual Fund';
            break;
        default:
            fullLob = '';
            break;
    }

    return fullLob;
}

export const launchNewCase = async(caseReason, paramObj, component, isCaseMigrationAction = false) => {
    const isLegacyPolicy = isCaseMigrationAction && (paramObj.sourceSystemCode === 1 || paramObj.sourceSystemCode === 3 ||
        paramObj.sourceSystemCode === 7 || paramObj.sourceSystemCode === 8);

    const inputData = {
        accountRecordId: paramObj.policyOwner ? paramObj.policyOwner : paramObj.accountRecordId,
        lob: getFullLOB(paramObj.lob),
        policyNumber: paramObj.sourceSystemCode === 24 ? component.policyNumber :  paramObj.policyNumber,
        actionValue: caseReason,
        agentAssociateId: paramObj.agentAssociateId,
        productDescription: paramObj.productDescription,
        agreAccessKey: paramObj.agreAccessKey,
        agreementIndexId: paramObj.agreementIndexId,
        isCaseMigrationAction: isCaseMigrationAction,
        isLegacyPolicy: isLegacyPolicy,
        sourceSystemCode: paramObj.sourceSystemCode
    }

    try {
        let caseId = await createPolicyTransactionCase({ inputData: inputData });

        if (!caseId) {
            throw new Error();
        } else {
            component[NavigationMixin.Navigate]({
                type: 'standard__app',
                attributes: {
                    pageRef: {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: caseId,
                            objectApiName: 'Case',
                            actionName: 'view'
                        }
                    }
                }
            });
        }
    } catch (err) {
        throwToast(
            component,
            'NOTICE: Case Not Created',
            'There was an error creating a case for this service request. Please create a note or activity to document your action, as needed.'
        );
    }
}

const checkForTargetPolicy = async(component, paramObj) => {
    const hasTargetPolicies = await getTargetAutoPolicyForState({ agentAssocId: paramObj.agentAssociateId, accountId: paramObj.accountRecordId });
    if (hasTargetPolicies) {
        // throw toast message to direct user to create from target policy
        throwToast(component, 'NOTICE: This customer has an existing modernized policy.', 'Please navigate to that policy and select Add Vehicle.');
    } else {
        // direct user to go through opp
        throwToast(component, 'NOTICE: During PolicyCenter migration, this added vehicle must be processed as a new submission.', 'Please create a New Opportunity to start a quote.');
    }
}

export const isStateActivatedForPLM = async(caseReason, paramObj, component, isCaseMigrationAction = false) => {
    let stateAgentCode;
    const policyNumberRegex = /[A-Za-z0-9]{3}\s[A-Za-z0-9]{4}-\w\d{2}-\d{2}/;
    const isValidPolicyNumber = policyNumberRegex.test(paramObj.policyNumber);
    if (isValidPolicyNumber) {
        stateAgentCode = paramObj.policyNumber.replace(/\s/g, '').replace(/-/g, '').substring(10, 12);
    }
    let stateIsPLMActivated = false;
    if (stateAgentCode) {
        stateIsPLMActivated = await getPLMStatusForState({ stateAgentCode });
    }
    if (stateIsPLMActivated) {
        checkForTargetPolicy(component, paramObj);
    } else {
        launchNewCase(caseReason, paramObj, component, isCaseMigrationAction);
        const isHatsorHa4cAccess = await isHatsorHa4cUser();
        if (!isHatsorHa4cAccess) {
            launchAutoPolicyAction(paramObj);
        }
    }
}

export const handleAgentStatusTracker = async (component) => {
    const agentStatusTrackerModal = component.template.querySelector("c-agent-status-tracker-modal");
    agentStatusTrackerModal.openModal();
}

export const handlePolicyChange = async(paramObj, component) => {

    /////This is for SA Policy change modal launch
    //this.plmActivationStatus.isPCAutoLaunchActive
    const isHatsorHa4cAccess = await isHatsorHa4cUser();
    if (component.plmActivationStatus.isPCAutoLaunchActive && (!isHatsorHa4cAccess || paramObj.sourceSystemCode !== LEGACY_CD)) {
        launchAutoPolicyAction(paramObj);
    }
    await launchNewCase(POLICY_CHANGE_CASE, paramObj, component, true);

}

export const handleAddVehicle = async(paramObj, component) => {
    paramObj.productDescription = null;
    if (paramObj.sourceSystemCode === PERSONAL_AUTO_MOD_CD || paramObj.sourceSystemCode === COMMERCIAL_MOD_CD || parseInt(component.policyTypeCode, 10) !== 0 || !component.plmActivationStatus.isOppRedirectActive) {
        await launchNewCase(ADDED_VEH_CASE, paramObj, component, true);
        // policy action only needs to be launched to URL gateway if it is for mod policy to policy center
        const isHatsorHa4cAccess = await isHatsorHa4cUser();
        if (component.plmActivationStatus.isPCAutoLaunchActive && (!isHatsorHa4cAccess || paramObj.sourceSystemCode === PERSONAL_AUTO_MOD_CD || paramObj.sourceSystemCode === COMMERCIAL_MOD_CD)) {
            await launchAutoPolicyAction(paramObj);
        }
    } else {
        await isStateActivatedForPLM(ADDED_VEH_CASE, paramObj, component, true);
    }
}

export const handleTOOF = async(paramObj, component) => {
    if (component.isStatusTerminated) {
        window.open('/apex/VFP_ExternalLink?LinkId=43');
    } else if (component.lob === AUTO) {
        launchAutoPolicyAction(paramObj);
    } else {
        launchFirePolicyAction(paramObj);
    }
    launchNewCase(TOOF_REINSTATEMENT, paramObj, component);
}

export const handleDSSBeaconReorder = async (component) => {
    const beaconReorderModal = component.template.querySelector("c-dss-beacon-reorder");
    beaconReorderModal.toggleModal();
}

export const handlePremiumChangeInquiry = async (component) => {
    const premiumChangeInquiryModal = component.template.querySelector("c-premium-change-inquiry-modal");
    premiumChangeInquiryModal.openModal();
}

export const handleEmailAutoIDCard = async (component) => {
    if(component.loggedInSubuser==='Agent' || component.loggedInSubuser==='ATM')
    {
        component.showSendModal=true;
    }
    else
    {
        launchEmailAutoIDCard(component.accountContext, component.riskNumber && component.riskNumber !== '000' ? component.agreementAccessKey + component.riskNumber : component.agreementAccessKey, component);
    }
}

export const retrieveEncodedDescription = async(productDescription) => {
    try {
        return await getEncodedDescription({ productDescription: productDescription });
    } catch (err) {
        return null;
    }
}

export const retrieveGroupPolicyStatus = async(productDescription) => {
    try {
        return await getGroupPolicyStatus({ policyDescription: productDescription });
    } catch (err) {
        return null;
    }
}

export const retrievePLMStatus = async() => {
    try {
        return await getPLMStatus();
    } catch (err) {
        return {};
    }
}

export const retrieveIPAssets = async(recordId) => {
    try {
        return await getInsurancePolicyAssets({ recordId });
    } catch(e) {
        return [];
    }
}
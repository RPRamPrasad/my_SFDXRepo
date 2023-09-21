import { constants } from 'c/policyDetailsCommonJS';
import { throwToast, removeSpacesDashes } from './utils';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';

const {
    AUTO, FIRE, LIFE, HEALTH,
    CASE_MIGRATION_ACTIONS, AUTO_POLICY_ACTIONS, FIRE_POLICY_ACTIONS,
    LIFE_POLICY_CHANGE, HEALTH_POLICY_CHANGE, POLICY_CHANGE,
    TOOF_REINSTATEMENT, EMAIL_AUTO_ID_CARD, BILLING_ONLINE_SYSTEM, CERTIFICATE_OF_INSURANCE,
    LEGACY_CD, PERSONAL_AUTO_MOD_CD, PERSONAL_FIRE_MOD_CD, HAGERTY_CD, HDC_POLICY_TYPE,
    DSS_BEACON_REORDER, COMMERCIAL_MOD_CD, PREMIUM_CHANGE_INQUIRY,
    AUTO_PL_POLICYNAME, FIRE_PL_POLICYNAME, AUTO_BL_POLICYNAME, FIRE_BL_POLICYNAME,AGENT_STATUS_TRACKER,POLICY_DOCUMENTS
} = constants;
const NECHO_POLICY_PAGE = 'policy';
const NECHO_POLICY_TRANSACTION = 'new pt';
const MOTORCYCLE = 'MOTORCYCLE';
const PRIVATE_PASSENGER = 'PRIVATE PASSENGER';
const CONDO_POLICY_TYPE = 'V';

const buildActionsForLob = (params, actions, isCaseMigrationPolicy) => {
    let returnActions = [];
    switch (params.lob) {
        case AUTO:
            returnActions = isCaseMigrationPolicy ? [...CASE_MIGRATION_ACTIONS] : [...AUTO_POLICY_ACTIONS];
            break;
        case FIRE:
            returnActions = isCaseMigrationPolicy ? [POLICY_CHANGE] : [...FIRE_POLICY_ACTIONS];
            break;
        case LIFE:
            returnActions = !params.isPhoenixLife ? [LIFE_POLICY_CHANGE] : [];
            break;
        case HEALTH:
            returnActions = [HEALTH_POLICY_CHANGE];
            break;
        default: //no default statement - returnActions initialized to [] above
    }
    return returnActions;
}

const buildPolicyTransactions = (userAccess, params, actions, isCaseMigrationPolicy) => {
    if (userAccess.hasPolicyTransactionAccess) {
        if (!params.isStatusTerminated) {
            actions.push.apply(actions, buildActionsForLob(params, actions, isCaseMigrationPolicy));
        } else if (params.lob === AUTO || params.lob === FIRE) {
            actions.push(TOOF_REINSTATEMENT);
        }
    } else if (userAccess.hasToofLinkAccess && (params.lob === AUTO || params.lob === FIRE)) {
        if (params.isStatusTerminated) {
            actions.push(TOOF_REINSTATEMENT);
        }
    }
}

const agentStatusTrackerAction = (userAccess, params, actions) => {
    if (userAccess.hasAgentStatusTrackerAccess && params.sourceSystemCode === 1) {
        if((params.lob === AUTO ) || (params.lob === FIRE)){
            actions.push(AGENT_STATUS_TRACKER);
        }
    }
}

const policyDocumentsAction = (userAccess, params, actions) => {
        if((params.lob === AUTO ) || (params.lob === FIRE)){
            if (userAccess.hasPolicyDocumentsAccess && params.sourceSystemCode !== 28) {
            actions.push(POLICY_DOCUMENTS);
        }
    }
}

const proofOfInsuranceAndBilling = (userAccess, params, actions) => {
    // Email Auto ID Card Action
    if ((userAccess.hasAutoIdCardAccessforSubuserType || userAccess.hasAutoIdCardAccessforUserCriteria) &&
        params.lob === AUTO &&
        !params.isStatusTerminated)
        {
        if (params.isMultiCarAuto ||
            params.policyName.toUpperCase().includes(PRIVATE_PASSENGER) ||
            params.productDescription.toUpperCase().includes(MOTORCYCLE)) {
            actions.push(EMAIL_AUTO_ID_CARD);
        }

    }

    // BOS Policy Locate Action
    if (userAccess.hasBOSLinkAccess &&
        !params.isPhoenixLife &&
        params.sourceSystemCode !== 28 &&
        (params.lob === AUTO || params.lob === FIRE || params.lob === LIFE)) {
        actions.push(BILLING_ONLINE_SYSTEM);
    }

    // Certificate of Insurance Action
    if (userAccess.hasCOILinkAccess && (params.lob === AUTO || params.lob === FIRE))  {
        actions.push(CERTIFICATE_OF_INSURANCE);
    }
}

const dssBeaconReorderAction = (userAccess, params, actions) => {
    if (userAccess.hasDSSBeaconReorderAccess && params.lob === AUTO && (params.sourceSystemCode === 1 || params.sourceSystemCode === 24) && !params.isStatusTerminated) {
        actions.push(DSS_BEACON_REORDER);
    }
};

const premiumChangeInquiryAction = (userAccess, params, actions) => {

    let polName = params?.policyName;
    if(polName){
    let policyName = polName.toUpperCase();
    let isPLAutoPolicyName = AUTO_PL_POLICYNAME.includes(policyName);
    let isPLFirePolicyName = FIRE_PL_POLICYNAME.includes(policyName);
    let isBLAutoPolicyName = AUTO_BL_POLICYNAME.includes(policyName);
    let isBLFirePolicyName = FIRE_BL_POLICYNAME.includes(policyName);

    if (userAccess.hasPremiumChangeInquiryAccess && params.sourceSystemCode === 1) {
        if((params.lob === AUTO && (isPLAutoPolicyName || isBLAutoPolicyName)) || (params.lob === FIRE && (isPLFirePolicyName || isBLFirePolicyName))){
            actions.push(PREMIUM_CHANGE_INQUIRY);
        }
    }
    }
};

export const buildActionsList = async(userAccess, params) => {
    let actions = [];
    let actionsButtonList;
    let actionsMenuList;
    const BUTTON_LIST_LENGTH = 4;
    const isCaseMigrationPolicy = params.sourceSystemCode === LEGACY_CD || params.sourceSystemCode === PERSONAL_AUTO_MOD_CD || (params.lob === AUTO && params.sourceSystemCode === COMMERCIAL_MOD_CD);

    if (params.sourceSystemCode === HAGERTY_CD && params.policyTypeCode === HDC_POLICY_TYPE) {
        return {
            actionsButtonList: [],
            actionsMenuList: []
        };
    }

    // Policy Change Actions (Case Migration/Legacy)
    buildPolicyTransactions(userAccess, params, actions, isCaseMigrationPolicy);

    // Email Auto ID Card Action, BOS Policy Locate Action, and Certificate of Insurance Action
    proofOfInsuranceAndBilling(userAccess, params, actions);

    // DSS Beacon Reorder Modal
    dssBeaconReorderAction(userAccess, params, actions);

    // Premium Change Inquiry Modal
    premiumChangeInquiryAction(userAccess, params, actions);

    agentStatusTrackerAction(userAccess, params, actions);

    policyDocumentsAction(userAccess, params, actions);

    // splits constant number of buttons in buttonGroup, remaining set in dropdown menu if any
    actionsButtonList = actions.slice(0, BUTTON_LIST_LENGTH);
    actionsMenuList = actions.slice(BUTTON_LIST_LENGTH);

    return {
        actionsButtonList: actionsButtonList,
        actionsMenuList: actionsMenuList
    };
}

export const launchWebNecho = (nechoAppName, linkParams) => {
    if (linkParams.agentAssociateId) {
        window.open(
            `/apex/VFP_ExternalLink?LinkId=9&accountId=${linkParams.accountRecordId}` +
            `&agreementIndexId=${linkParams.agreementIndexId}` +
            `&clientnamelinkdisabled=Y&NechoAppName=${nechoAppName}` +
            `&key=${linkParams.policyNumber}` +
            `&lineOfBusiness=${linkParams.lob}` +
            `&agentAssocId=${linkParams.agentAssociateId}`
        );
    } else {
        window.open(
            `/apex/VFP_ExternalLink?LinkId=69&accountId=${linkParams.accountRecordId}` +
            `&agreementIndexId=${linkParams.agreementIndexId}` +
            `&clientnamelinkdisabled=Y&NechoAppName=${nechoAppName}` +
            `&key=${linkParams.policyNumber}` +
            `&lineOfBusiness=${linkParams.lob}`
        );
    }
}

export const launchAutoPolicyAction = (apvLinkParams) => {
    if (apvLinkParams.sourceSystemCode === PERSONAL_AUTO_MOD_CD) {
        window.open(
            `/apex/VFP_ExternalLink?LinkId=269` +
            `&agreementIndexId=${apvLinkParams.agreementIndexId}` +
            `&agreementNumber=${apvLinkParams.agreAccessKey}` +
            `&applicationName=Auto` +
            `&sourceSystemCode=${apvLinkParams.sourceSystemCode}`
        );
    } else if (apvLinkParams.sourceSystemCode === HAGERTY_CD) {
        window.open(
            `/apex/VFP_ExternalLink?` +
            `LinkId=258&` +
            `intent=changePolicy&` +
            `agreementNumber=${apvLinkParams.agreAccessKey}&` +
            `stateAgentCode=${apvLinkParams.stateAgentCode}`
        );
    } else if (apvLinkParams.isMultiCarAuto) {
        const formattedPolicyNumber = removeSpacesDashes(apvLinkParams.policyNumber).substring(0, 7); // apvLinkParams.policyNumber.replaceAll(' ', '').replaceAll('-', '').substring(0, 7);
        if (apvLinkParams.agentAssociateId) {
            const formattedStateAgentCode = removeSpacesDashes(apvLinkParams.stateAgentCode); //apvLinkParams.stateAgentCode.replaceAll(' ', '').replaceAll('-', '');
            window.open(
                `/apex/VFP_ExternalLink?LinkId=21&Key=${apvLinkParams.lob + formattedPolicyNumber + apvLinkParams.riskNumber}` +
                `&absclient=${apvLinkParams.accountClientId}` +
                `&StateAgentCode=${formattedStateAgentCode}`
            );
        } else {
            window.open(
                `/apex/VFP_ExternalLink?LinkId=101&Key=${apvLinkParams.lob + formattedPolicyNumber + apvLinkParams.riskNumber}` +
                `&absclient=${apvLinkParams.accountClientId}`
            );
        }
    } else if (apvLinkParams.sourceSystemCode === COMMERCIAL_MOD_CD && apvLinkParams.lob === AUTO) {
        window.open(
            `/c/ExternalLinkApp.app?linkId=266&policyNumber=${apvLinkParams.policyNumber}&agreementIndexID=&requestID=`
        );
    } else {
        launchWebNecho(NECHO_POLICY_TRANSACTION, apvLinkParams);
    }
}

export const launchFirePolicyAction = (fpvParamObject) => {
    if (fpvParamObject.sourceSystemCode === PERSONAL_FIRE_MOD_CD) {
        window.open(
            `/apex/VFP_ExternalLink?LinkId=96` +
            `&agreementIndexId=${fpvParamObject.agreementIndexId}` +
            `&intent=changePolicy`
        );
    } else {
        launchWebNecho(NECHO_POLICY_PAGE, fpvParamObject);
    }
}

export const launchEmailAutoIDCard = async(accountContext, policyNumber, component) => {
    try {
        let responseString = await emailAutoIdCardCallout({
            customerEmail: accountContext.email,
            customerName: accountContext.name,
            policyNumber: policyNumber
        });

        const response = JSON.parse(responseString);

        if (response.statusCode === 200) {
            throwToast(
                component,
                'NOTICE: Customer Email Sent',
                `Auto ID Card emailed to customer ${accountContext.name} at ${accountContext.email}`,
                'success',
                'dismissable'
            );
        } else {
            throw new Error();
        }
    } catch (err) {
        throwToast(
            component,
            'NOTICE: Customer Email Failed',
            'Email Unsuccessful - Follow manual procedure to send Auto ID Card'
        );
    }
}

export const launchBillingOnlineSystem = (accountRecordId, companyCode, policyNumber, lob) => {
    window.open(
        `/apex/VFP_ExternalLink?LinkId=210&accountId=${accountRecordId}` +
        `&companyCode=${companyCode}` +
        `&policyNumber=${policyNumber.replace(/-|\s/g, "")}` +
        `&lineOfBusiness=${lob}`
    );
}

export const launchCertificateOfInsurance = (masterDataLocationCode, policyNumber, policyTypeCode, lob,clientId) => {

    if ( lob === FIRE && policyTypeCode === CONDO_POLICY_TYPE) {
    window.open(
        `/apex/VFP_ExternalLink?LinkId=211` +
        `&regionCode=${masterDataLocationCode}` +
        `&policyNumber=${policyNumber.replace(/-|\s/g, "")}` +
        `&policyType=${policyTypeCode}` +
        `&lineOfBusiness=${lob}`
    );
    } else {
        window.open(
            `/apex/VFP_ExternalLink?LinkId=264` +
            `&clientId=${clientId}`
        );
    }
}
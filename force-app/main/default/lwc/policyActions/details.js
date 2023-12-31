import { constants } from 'c/policyDetailsCommonJS';

const {
    AUTO, FIRE, LIFE, HEALTH, 
    LEGACY_CD, COMMERCIAL_MOD_CD, LIFE_MOD_CD, PERSONAL_AUTO_MOD_CD, PERSONAL_FIRE_MOD_CD, HAGERTY_CD, HDC_POLICY_TYPE
} = constants;

const AGENT_PROFILE = '2.00 Agent';
const AGENT_TEAM_MEMBER_PROFILE = '2.01 Agent Team Member';
const TRUE = 'TRUE';
const FALSE = 'FALSE';

export const buildAutoPolicyViewLink = (params) => {
    let detailsURL;

    if (params.agentAssociateId) {
        detailsURL = '/apex/VFP_ExternalLink?LinkId=13' + 
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&policyNumber=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob + 
            '&productDescription=' + params.encodedDescription + 
            '&agentAssocId=' + params.agentAssociateId +
            '&outOfBookIndicator=' + params.outOfBook;
    } else {
        detailsURL = '/apex/VFP_ExternalLink?LinkId=28' + 
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&policyNumber=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob + 
            '&productDescription=' + params.encodedDescription + 
            '&outOfBookIndicator=' + params.outOfBook;
    }

    return detailsURL;
}

export const buildAutoPolicyViewForMultiCarLink = (params) => {
    return '/apex/VFP_ExternalLink?LinkId=198' + 
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&policyNumber=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob + 
            '&productDescription=' + params.encodedDescription + 
            '&agentAssocId=' + params.agentAssociateId +
            '&outOfBookIndicator=' + params.outOfBook + 
            '&pmrNumber=' + params.accessKey;
}

export const buildLifePolicyViewLink = (params) => {
    let detailsURL;

    if (params.agentAssociateId) {
        detailsURL = '/apex/VFP_ExternalLink?LinkId=68' +
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&policyNumber=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob + 
            '&agentAssocId=' + params.agentAssociateId;
    } else {
        detailsURL = '/apex/VFP_ExternalLink?LinkId=105' +
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&policyNumber=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob;
    }

    return detailsURL;
}

export const buildLifeModLink = (agreementIndexId, userId) => {
    return '/c/ExternalLinkApp.app?linkId=109&policyIdentifier=' + agreementIndexId + 
            '&userSessionId=' + userId + '-' + Date.now();
}

export const buildPhoenixLifeLink = () => {
    return '/apex/VFP_ExternalLink?LinkId=192';
}

export const buildNECHODetailsLink = (params) => {
    let detailsURL;

    if (params.agentAssociateId) {
        detailsURL = '/apex/VFP_ExternalLink?LinkId=9' + 
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&clientnamelinkdisabled=Y&NechoAppName=policy' +
            '&key=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob + 
            '&agentAssocId=' + params.agentAssociateId;
    } else {
        detailsURL = '/apex/VFP_ExternalLink?LinkId=69' + 
            '&accountId=' + params.accountRecordId + 
            '&agreementIndexId=' + params.agreementIndexId + 
            '&clientnamelinkdisabled=Y&NechoAppName=policy' +
            '&key=' + params.policyNumber + 
            '&lineOfBusiness=' + params.lob
    }

    return detailsURL;
}

export const buildPolicyCenterLink = (linkId, agreementIndexId) => {
    return '/c/ExternalLinkApp.app?linkId=' + linkId + 
            '&agreementIndexId=' + agreementIndexId + 
            '&intent=viewPolicy';
}

export const buildHagertyLink = (params, intent) => {
    return `/apex/VFP_ExternalLink?` +
            `LinkId=258&` +
            `intent=${intent}&` + 
            `agreementNumber=${params.accessKey}&` +
            `stateAgentCode=${params.stateAgentCode}`;
}

export const isOutOfBookPolicy = (agentAssociateId, loggedInProfile, loggedInAgentAssociateId) => {
    let oobIndicator = TRUE;

    if (loggedInProfile === AGENT_PROFILE || loggedInProfile === AGENT_TEAM_MEMBER_PROFILE) {
        if(agentAssociateId && loggedInAgentAssociateId && agentAssociateId === loggedInAgentAssociateId) {
            oobIndicator = FALSE;
        }
    }
    
    return oobIndicator; 
}

const buildAutoLaunchout = (params) => {
    let detailsURL = '';

    if (params.isMultiCarAuto && params.sourceSystemCode === LEGACY_CD) {
        params.accessKey += params.riskNumber;
        detailsURL = buildAutoPolicyViewForMultiCarLink(params);
    } else if (params.isFleetAuto) {
        detailsURL = buildAutoPolicyViewForMultiCarLink(params);
    } else if (params.sourceSystemCode === LEGACY_CD || params.sourceSystemCode === COMMERCIAL_MOD_CD) {
        detailsURL = buildAutoPolicyViewLink(params);        
    } else if (params.sourceSystemCode === PERSONAL_AUTO_MOD_CD) {
        detailsURL = buildPolicyCenterLink('92', params.agreementIndexId);
    } else if (params.sourceSystemCode === HAGERTY_CD) {
        let intent = params.policyTypeCode === HDC_POLICY_TYPE ? 'viewDriversClub' : 'viewPolicy';
        detailsURL = buildHagertyLink(params, intent);
    }

    return detailsURL;
}

const buildFireLaunchout = (params) => {
    let detailsURL = '';

    if (params.sourceSystemCode === LEGACY_CD || params.sourceSystemCode === COMMERCIAL_MOD_CD) {
        detailsURL = buildNECHODetailsLink(params);
    } else if (params.sourceSystemCode === PERSONAL_FIRE_MOD_CD) {
        detailsURL = buildPolicyCenterLink('94', params.agreementIndexId);
    }

    return detailsURL;
}

const buildLifeLaunchout = (params) => {
    let detailsURL = '';

    if (params.sourceSystemCode === LIFE_MOD_CD) {
        detailsURL = buildLifeModLink(params.agreementIndexId, params.userId);
    } else if (params.isPhoenixLife) {
        detailsURL = buildPhoenixLifeLink();
    } else if (params.isPMRLife) {
        detailsURL = buildLifePolicyViewLink(params);
    } else if (params.isASCLife) {
        detailsURL = buildNECHODetailsLink(params);
    }

    return detailsURL;
}

export const buildDetailsLaunchout = async (params) => {
    let detailsURL;

    switch (params.lob) {
        case AUTO:
            detailsURL = buildAutoLaunchout(params);
            break;
        case FIRE:
            detailsURL = buildFireLaunchout(params);
            break;
        case LIFE:
            detailsURL = buildLifeLaunchout(params);
            break;
        case HEALTH:
            detailsURL = buildNECHODetailsLink(params);
            break;
        default:
            detailsURL = '';
            break;
    }

    return detailsURL;
}
import {
    buildActionsList,
    launchWebNecho,
    launchAutoPolicyAction,
    launchFirePolicyAction,
    launchEmailAutoIDCard,
    launchBillingOnlineSystem,
    launchCertificateOfInsurance
} from '../actions';
import emailAutoIdCardCallout from '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import policyActions from 'c/policyActions';
import { createElement } from 'lwc';
import { constants } from 'c/policyDetailsCommonJS';

const MOTORCYCLE = 'MOTORCYCLE';
const PRIVATE_PASSENGER = 'PRIVATE PASSENGER';
const CONDO_POLICY_TYPE = 'V';
const HOMEOWNERS_POLICY = 'HOMEOWNERS POLICY';

const {
    AUTO, FIRE, LIFE, HEALTH,
    LIFE_POLICY_CHANGE,
    LEGACY_CD, PERSONAL_FIRE_MOD_CD,
    HAGERTY_CD, HDC_POLICY_TYPE,
    PERSONAL_AUTO_MOD_CD, COMMERCIAL_MOD_CD,
    AUTO_PL_POLICYNAME, FIRE_PL_POLICYNAME, AGENT_STATUS_TRACKER, POLICY_DOCUMENTS
} = constants;

const userAccess = {
    hasPolicyTransactionAccess: true
};

const userAccessToofPolicyLink = {
    hasPolicyTransactionAccess: false,
    hasToofLinkAccess:true
};

const userAccessNoPolicyTransaction = {
    hasPolicyTransactionAccess: false
};

const userAccessHasAutoIdCard = {
    hasAutoIdCardAccessforSubuserType: true,
    hasPolicyTransactionAccess: false
};

const userAccessHasAgentStatusTracker = {
    hasAgentStatusTrackerAccess: true
};

const userDoesNotHaveAgentStatusTracker = {
    hasAgentStatusTrackerAccess: false
};

const userAccessHasPolicyDocuments = {
    hasPolicyDocumentsAccess: true
};

const userAccessDoesNotHavePolicyDocuments = {
    hasPolicyDocumentsAccess: false
};

const userAccessHasBOSLink = {
    hasBOSLinkAccess : true,
    hasAutoIdCardAccessforSubuserType: false,
    hasPolicyTransactionAccess: false
};

const userAccessHasCOILink  = {
    hasCOILinkAccess: true
};

const userAccessHasDSSBeaconReorder = {
    hasDSSBeaconReorderAccess: true
};

const userDoesNotHaveDSSBeaconReorder = {
    hasDSSBeaconReorderAccess: false
};

const userAccessHasPremiumChangeInquiry = {
    hasPremiumChangeInquiryAccess: true
};

const userDoesNotHavePremiumChangeInquiry = {
    hasPremiumChangeInquiryAccess: false
};

jest.mock(
    '@salesforce/apex/InsurancePolicyController.emailAutoIdCardCallout',
    () => ({ default: jest.fn() }), { virtual: true }
);

jest.mock('@salesforce/customPermission/SAE_Policy_Change', () => ({ default: false }), { virtual: true });

describe('policyActions - actions', () => {

    const parms = require('./data/parms.json');
    const parmsNoAssociateId = require('./data/parmsNoAgentAssocId.json');

    const { setImmediate } = require('timers')
function flushPromises() {

        return new Promise(resolve => setImmediate(resolve));
    }

    it('builds action list with no policy change when user has HATS access with line of business that is not auto or fire and source system code of LEGACY_CD', async() => {
        let params = {
            lob: HEALTH,
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Policy Change')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when user has HATS access with AUTO line of business and source system code which is not LEGACY_CD', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: PERSONAL_FIRE_MOD_CD,
            policyName: 'Mock Passenger'

        };

        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Add Driver', 'Replace Vehicle', 'Auto Policy Change', 'TOOF Reinstatement']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when user has HATS access with FIRE line of business and source system code which is not LEGACY_CD', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: PERSONAL_FIRE_MOD_CD,
            policyName: 'Mock Passenger'

        };

        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Fire Policy Change', 'TOOF Reinstatement']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when user has HATS access with AUTO line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER
        };

        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Policy Change', 'Add Vehicle']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when user has HATS access with FIRE line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName: 'HOMEOWNERS POLICY'

        };

        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(FIRE_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Policy Change']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when does not have HATS access with AUTO line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER
        };

        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Policy Change', 'Add Vehicle']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when does not have HATS access with FIRE line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Policy Change']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when does not have HATS access with LIFE line of business with policy transaction access and source system code of LEGACY_CD', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual([LIFE_POLICY_CHANGE]);
        expect(actions.actionsMenuList).toEqual([]);
    });


    it('builds action list when does not have HATS access with HEALTH line of business with policy transaction access and source system code of LEGACY_CD', async() => {
        let params = {
            lob: HEALTH,
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Health Policy Change']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when does not have HATS access with an UNKNOWN line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: 'U',
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual([]);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds empty action list when does not have policy transaction access', async() => {
        let params = {
            lob: 'U',
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccessNoPolicyTransaction, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual([]);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list with TOOF_REINSTATEMENT when lob is AUTO and policy status is terminated', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: true,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['TOOF Reinstatement']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list with TOOF_REINSTATEMENT when lob is FIRE and policy status is terminated', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: true,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['TOOF Reinstatement']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list does not set TOOF Reinstatement when lob is not FIRE or AUTO and policy status is terminated', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: true,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual([]);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list for active Hagerty Antique policy', async () => {
        let params = {
            lob: AUTO,
            sourceSystemCode: HAGERTY_CD,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Add Driver', 'Replace Vehicle', 'Auto Policy Change', 'TOOF Reinstatement']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list for inactive Hagerty Antique policy', async () => {
        let params = {
            lob: AUTO,
            sourceSystemCode: HAGERTY_CD,
            isStatusTerminated: true,
            policyName: 'Mock Passenger'
        };
        let actions = await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);

        expect(actions.actionsButtonList).toEqual(['TOOF Reinstatement']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds no actions for Hagerty Drivers Club subscription', async () => {
        let params = {
            lob: AUTO,
            sourceSystemCode: HAGERTY_CD,
            policyTypeCode: HDC_POLICY_TYPE
        };
        let actions = await buildActionsList(userAccess, params);

        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList).toEqual([]);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list for motorcycle when user has auto id card access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: false,
            isMultiCarAuto: false,
            policyName: 'foo',
            productDescription: MOTORCYCLE
        };
        let actions = await buildActionsList(userAccessHasAutoIdCard, params);

        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList).toEqual(['Email Auto ID Card']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list for private passenger when user has auto id card access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: false,
            isMultiCarAuto: false,
            policyName: PRIVATE_PASSENGER,
            productDescription: 'foo'
        };
        let actions = await buildActionsList(userAccessHasAutoIdCard, params);

        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList).toEqual(['Email Auto ID Card']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list for multi-car auto when user has auto id card access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: false,
            isMultiCarAuto: true,
            policyName: 'foo',
            productDescription: 'foo'
        };

        let actions = await buildActionsList(userAccessHasAutoIdCard, params);

        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList).toEqual(['Email Auto ID Card']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list with no auto id card access when not an auto or multi-auto policy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isStatusTerminated: false,
            isMultiCarAuto: false,
            policyName: 'foo',
            productDescription: 'foo'
        };

        let actions = await buildActionsList(userAccessHasAutoIdCard, params);

        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList).toEqual([]);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list BOS link Access Auto', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: false,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasBOSLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Billing Online System (BOS)']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list without BOS link Access when line of business is not auto fire or life', async() => {
        let params = {
            lob: HEALTH,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: false,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasBOSLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Billing Online System (BOS)')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list BOS link Access FIRE', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: false,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasBOSLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Billing Online System (BOS)']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list BOS link Access LIFE', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: false,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasBOSLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList).toEqual(['Billing Online System (BOS)']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list BOS link Access empty when Phoenix Life is true', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: true,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasBOSLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual([]);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list COI link Access FIRE', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyTypeCode: CONDO_POLICY_TYPE,
            policyName:'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasCOILink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Certificate Of Insurance (COI)']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list without COI link Access when policy type is not Condo ', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyTypeCode: "CONDO_POLICY_TYPE",
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasCOILink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Certificate Of Insurance (COI)')).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });



    it('builds action list without COI link Access when line of business is not FIRE', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyTypeCode: CONDO_POLICY_TYPE,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasCOILink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Certificate Of Insurance (COI)')).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds empty lists when no policy transaction access is true but not a valid line of business', async() => {
        let params = {
            lob: 'Z',
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger'
        };

        let actions =  await buildActionsList(userAccess, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.length).toEqual(0);
        expect(actions.actionsMenuList.length).toEqual(0);
    })

    it('does not include email auto id card for non auto lines of business', async() => {
        let access = {
            hasPolicyTransactionAccess: false,
            hasAutoIdCardAccessforSubuserType: true
        };

        let params = {
            lob: FIRE,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(access, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Email Auto ID Card')).toBeFalsy();
        expect(actions.actionsMenuList.includes('Email Auto ID Card')).toBeFalsy();
    });

    it('builds menu list when action list is greater than maximum number of buttons', async() => {
        const userAccessMaximumNumberOfActions = {
            hasPolicyTransactionAccess: true,
            hasAutoIdCardAccessforSubuserType: true,
            hasDSSBeaconReorderAccess: true,
            hasCOILinkAccess: true
        };

        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isMultiCarAuto: false,
            policyName: PRIVATE_PASSENGER,
            productDescription: 'foo'
        };

        let actions = await buildActionsList(userAccessMaximumNumberOfActions, params);

        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList.length).toEqual(4);
        expect(actions.actionsMenuList.length).toEqual(1);
    });

    it('launches web NECHO with an agent associate id', () => {
        window.open = jest.fn();

        launchWebNecho ('AppName', parms);

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=accountRecordId&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=AppName&key=policyNumber&lineOfBusiness=lob&agentAssocId=agentAssociateId');
    });

    it('launches web NECO without an agent associate id', () => {
        window.open = jest.fn();

        launchWebNecho ('AppName', parmsNoAssociateId);

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=69&accountId=accountRecordId&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=AppName&key=policyNumber&lineOfBusiness=lob');
    });

    it('launches Policy Action with PERSONAL_AUTO_MOD_CD', () => {
        window.open = jest.fn();

        launchAutoPolicyAction({agreementIndexId:"agreementIndexId", sourceSystemCode:24});

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=269&agreementIndexId=agreementIndexId&agreementNumber=undefined&applicationName=Auto&sourceSystemCode=24');
    });

    it('launches Policy Action with multi car policy true and no agent associate ID', () => {
        window.open = jest.fn();

        launchAutoPolicyAction({agreementIndexId:"agreementIndexId", lob:'A', accountClientId:"accountId", riskNumber:'riskNumber', policyNumber:"ABC 50-123", isMultiCarAuto: true});

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=101&Key=AABC5012riskNumber&absclient=accountId');
    });

    it('launches Policy Action with multi car policy true and agent associate ID', () => {
        window.open = jest.fn();

        launchAutoPolicyAction({agreementIndexId:"agreementIndexId", lob:'A', stateAgentCode:"50-50", agentAssociateId:"agentAssociateId", accountClientId:"accountId", riskNumber:'riskNumber', policyNumber:"ABC 50-123", isMultiCarAuto: true});

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=21&Key=AABC5012riskNumber&absclient=accountId&StateAgentCode=5050');
    });

    it('launches necho when multi car policy is false', () => {
        window.open = jest.fn();

        launchAutoPolicyAction({agreementIndexId:"agreementIndexId", lob:'A', stateAgentCode:"50-50", agentAssociateId:"agentAssociateId", accountClientId:"accountId", riskNumber:'riskNumber', policyNumber:"ABC 50-123", isMultiCarPolicy: false});

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=undefined&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=new pt&key=ABC 50-123&lineOfBusiness=A&agentAssocId=agentAssociateId');
    });

    it('launches Hagerty for Antique policy', () => {
        window.open = jest.fn();

        launchAutoPolicyAction({
            agreementIndexId:"agreementIndexId",
            lob:'A',
            stateAgentCode:"50-6070",
            agentAssociateId:"agentAssociateId",
            accountClientId:"accountId",
            riskNumber:'riskNumber',
            policyNumber:"ABC 50-123",
            isMultiCarPolicy: false,
            agreAccessKey: 'agreAccessKey',
            sourceSystemCode: 28
        });

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=258&intent=changePolicy&agreementNumber=agreAccessKey&stateAgentCode=50-6070');
    });

    it('launches Policy Action with sourceSystemCode equals PERSONAL_FIRE_MOD_CD', () => {
        window.open = jest.fn();

        launchFirePolicyAction({agreementIndexId:"agreementIndexId", sourceSystemCode:26});

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=96&agreementIndexId=agreementIndexId&intent=changePolicy');
    });

    it('launches Policy Action with sourceSystemCode not equal to PERSONAL_FIRE_MOD_CD', () => {
        window.open = jest.fn();

        launchFirePolicyAction(parms);

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=9&accountId=accountRecordId&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=policyNumber&lineOfBusiness=lob&agentAssocId=agentAssociateId');
    });

    it('launches Billing Online System with account record id, company code, policy number and line of business', () => {
        window.open = jest.fn();

        launchBillingOnlineSystem ("accountId", "companyCode", "ABC 50-123", "A");

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=210&accountId=accountId&companyCode=companyCode&policyNumber=ABC50123&lineOfBusiness=A');
    });

    it('launches certificate of insurance with regionCode, Fire policy number, Condo policy type code and line of business', () => {
        window.open = jest.fn();

        launchCertificateOfInsurance("regionCode", "FIRE 50-123", "V", "F");

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=211&regionCode=regionCode&policyNumber=FIRE50123&policyType=V&lineOfBusiness=F');
    });

    it('launches certificate of insurance with client ID for Auto policy', () => {
        window.open = jest.fn();

        launchCertificateOfInsurance("", "AUTO 50-123", "", "A","ABCD12345");

        expect(window.open).toBeCalledWith('/apex/VFP_ExternalLink?LinkId=264&clientId=ABCD12345');
    });

    it('calls emailAutoIdCardCallout and displayes success toast message', async () => {
        let emailAutoIdCalloutArguments = {
            customerEmail: "test@something.com",
            customerName: "Frank Smith",
            policyNumber: "ABC 50-12345"
        };

        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        emailAutoIdCardCallout.mockImplementation(() => {return '{"statusCode": 200, "foo":"foo"}'});
        launchEmailAutoIDCard({email:"test@something.com", name:"Frank Smith"}, "ABC 50-12345", component);

        await flushPromises();

        expect(emailAutoIdCardCallout).toBeCalledWith(emailAutoIdCalloutArguments);
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('NOTICE: Customer Email Sent');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('Auto ID Card emailed to customer Frank Smith at test@something.com');
        expect(showToastHandler.mock.calls[0][0].detail.variant).toBe('success');
        expect(showToastHandler.mock.calls[0][0].detail.mode).toBe('dismissable');
    });

    it('calls emailAutoIdCardCallout and displayes error toast message', async () => {
        let component = createElement('c-policy-actions', {
            is: policyActions
        });

        const showToastHandler = jest.fn();
        component.addEventListener(ShowToastEventName, showToastHandler);

        emailAutoIdCardCallout.mockImplementation(() => {return '{"statusCode": 400, "foo":"foo"}'});
        launchEmailAutoIDCard({email:"test@something.com", name:"Frank Smith"}, "ABC 50-12345", component);

        await flushPromises();

        expect(emailAutoIdCardCallout).toBeCalled();
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('NOTICE: Customer Email Failed');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('Email Unsuccessful - Follow manual procedure to send Auto ID Card');
    });

    it('builds action list for Policy Documents Access - pl auto legacy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName : PRIVATE_PASSENGER
        };

        let actions = await buildActionsList(userAccessHasPolicyDocuments, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes(POLICY_DOCUMENTS)).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });


    it('builds action list for Policy Documents Access - pl auto mod', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: PERSONAL_AUTO_MOD_CD,
            isPhoenixLife: false,
            policyName: 'Mock passenger'
        };

        let actions = await buildActionsList(userAccessHasPolicyDocuments, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes(POLICY_DOCUMENTS)).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list for Policy Documents Access -  BL policy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: COMMERCIAL_MOD_CD,
            isPhoenixLife: false,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasPolicyDocuments, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes(POLICY_DOCUMENTS)).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list without Policy Documents Access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER
        };
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        let actions = await buildActionsList(userAccessDoesNotHavePolicyDocuments, params);
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes(POLICY_DOCUMENTS)).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Policy Documents Access Fire', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName : HOMEOWNERS_POLICY
        };

        let actions = await buildActionsList(userAccessHasPolicyDocuments, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(FIRE_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes(POLICY_DOCUMENTS)).toBeTruthy();

        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Policy Documents Access when Non Auto and Fire', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            policyName : 'MOCK PASSENGER'
        };

        let actions = await buildActionsList(userAccessHasPolicyDocuments, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes(POLICY_DOCUMENTS)).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Agent Status Tracker Access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName : PRIVATE_PASSENGER
        };

        let actions = await buildActionsList(userAccessHasAgentStatusTracker, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes(AGENT_STATUS_TRACKER)).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list without Agent Status Tracker Access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER
        };
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        let actions = await buildActionsList(userDoesNotHaveAgentStatusTracker, params);
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes(AGENT_STATUS_TRACKER)).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Agent Status Tracker Access Fire', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName : HOMEOWNERS_POLICY
        };

        let actions = await buildActionsList(userAccessHasAgentStatusTracker, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(FIRE_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes(AGENT_STATUS_TRACKER)).toBeTruthy();

        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Agent Status Tracker Access when Non Auto and Fire', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            policyName : 'MOCK PASSENGER'
        };

        let actions = await buildActionsList(userAccessHasAgentStatusTracker, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes(AGENT_STATUS_TRACKER)).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list DSS Beacon Reorder', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: false,
            policyName:'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasDSSBeaconReorder, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Reorder Beacon']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list without DSS Beacon Reorder', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            isPhoenixLife: false,
            policyName: 'Mock PAssenger'
        };

        let actions = await buildActionsList(userDoesNotHaveDSSBeaconReorder, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Reorder Beacon')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list DSS Beacon Reorder on PL policy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: PERSONAL_AUTO_MOD_CD,
            isPhoenixLife: false,
            policyName: 'Mock passenger'
        };

        let actions = await buildActionsList(userAccessHasDSSBeaconReorder, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Reorder Beacon']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list with DSS Beacon Reorder for BL policy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: COMMERCIAL_MOD_CD,
            isPhoenixLife: false,
            policyName: 'Mock Passenger'
        };

        let actions = await buildActionsList(userAccessHasDSSBeaconReorder, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Reorder Beacon')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Premium Change Inquiry Access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName : PRIVATE_PASSENGER
        };

        let actions = await buildActionsList(userAccessHasPremiumChangeInquiry, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Premium Change Inquiry']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Premium Change Inquiry Access Auto with incorrect policy name', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName : HOMEOWNERS_POLICY
        };

        let actions = await buildActionsList(userAccessHasPremiumChangeInquiry, params);
        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList.includes('Premium Change Inquiry')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Premium Change Inquiry Access Fire', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName : HOMEOWNERS_POLICY
        };

        let actions = await buildActionsList(userAccessHasPremiumChangeInquiry, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(FIRE_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList).toEqual(['Premium Change Inquiry']);
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Premium Change Inquiry Access Fire with incorrect policy name', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName : PRIVATE_PASSENGER
        };

        let actions = await buildActionsList(userAccessHasPremiumChangeInquiry, params);
        expect(actions).toBeTruthy();
        expect(actions.actionsButtonList.includes('Premium Change Inquiry')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list without Premium Change Inquiry Access', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER
        };
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        let actions = await buildActionsList(userDoesNotHavePremiumChangeInquiry, params);
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes('Premium Change Inquiry')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Premium Change Inquiry on PL policy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: PERSONAL_AUTO_MOD_CD,
            policyName: 'Mock Passenger'
        };
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        let actions = await buildActionsList(userAccessHasPremiumChangeInquiry, params);
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Premium Change Inquiry')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list Premium Change Inquiry on PL policy 2', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: PERSONAL_AUTO_MOD_CD,
            policyName: 'Mock Passenger'

        };

        let actions = await buildActionsList(userAccessHasPremiumChangeInquiry, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('Premium Change Inquiry')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when CCC Service user has ToofLinkAccess with AUTO line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER,
            isStatusTerminated: true
        };

        let actions = await buildActionsList(userAccessToofPolicyLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes('TOOF Reinstatement')).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when CCC Service user has ToofLinkAccess with AUTO line of business and source system code of LEGACY_CD Non terminated policy', async() => {
        let params = {
            lob: AUTO,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER,
            isStatusTerminated: false
        };

        let actions = await buildActionsList(userAccessToofPolicyLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes('TOOF Reinstatement')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when CCC Service user has ToofLinkAccess with FIRE line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: FIRE,
            sourceSystemCode: LEGACY_CD,
            policyName: PRIVATE_PASSENGER,
            isStatusTerminated: true
        };

        let actions = await buildActionsList(userAccessToofPolicyLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).toContain(policyName);
        expect(actions.actionsButtonList.includes('TOOF Reinstatement')).toBeTruthy();
        expect(actions.actionsMenuList).toEqual([]);
    });

    it('builds action list when CCC Service user has ToofLinkAccess with Non AUTO FIRE line of business and source system code of LEGACY_CD', async() => {
        let params = {
            lob: LIFE,
            sourceSystemCode: LEGACY_CD,
            policyName: 'Mock Passenger',
            isStatusTerminated: true
        };

        let actions = await buildActionsList(userAccessToofPolicyLink, params);
        let polName = params.policyName;
        let policyName = polName.toUpperCase();
        expect(actions).toBeTruthy();
        expect(AUTO_PL_POLICYNAME).not.toContain(policyName);
        expect(actions.actionsButtonList.includes('TOOF Reinstatement')).toBeFalsy();
        expect(actions.actionsMenuList).toEqual([]);
    });

});
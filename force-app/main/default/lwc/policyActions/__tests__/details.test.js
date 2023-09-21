import { buildAutoPolicyViewLink, buildAutoPolicyViewForMultiCarLink, buildLifePolicyViewLink, buildLifeModLink, buildPhoenixLifeLink, buildNECHODetailsLink, buildPolicyCenterLink, isOutOfBookPolicy, buildDetailsLaunchout } from '../details';

import { constants } from 'c/policyDetailsCommonJS';

const {
    AUTO, FIRE, LIFE, HEALTH, 
    LEGACY_CD, COMMERCIAL_MOD_CD, LIFE_MOD_CD, 
    PERSONAL_AUTO_MOD_CD, PERSONAL_FIRE_MOD_CD
} = constants;

describe('policyActions - details', () => {

    const parms = require('./data/parms.json');
    const parmsNoAssociateId = require('./data/parmsNoAgentAssocId.json');

    it('builds an auto policy view link with an agent associate id', () => {
        const url = buildAutoPolicyViewLink(parms);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=13&accountId=accountRecordId&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=lob&productDescription=encodedDescription&agentAssocId=agentAssociateId&outOfBookIndicator=outOfBook');
    });

    it('builds an auto policy view link with no agent associate id', () => {
        const url = buildAutoPolicyViewLink(parmsNoAssociateId);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=28&accountId=accountRecordId&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=lob&productDescription=encodedDescription&outOfBookIndicator=outOfBook');
    });

    it('builds an Auto Policy View For Multi-Car link', () => {
        const url = buildAutoPolicyViewForMultiCarLink(parms);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=198&accountId=accountRecordId&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=lob&productDescription=encodedDescription&agentAssocId=agentAssociateId&outOfBookIndicator=outOfBook&pmrNumber=accessKey');
    });

    it('builds a Life Policy View link with agent associate id', () => {
        const url = buildLifePolicyViewLink(parms);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=68&accountId=accountRecordId&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=lob&agentAssocId=agentAssociateId');
    });

    it('builds a Life Policy View link without an agent associate id', () => {
        const url = buildLifePolicyViewLink(parmsNoAssociateId);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=105&accountId=accountRecordId&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=lob');
    });

    it('builds a Life Mod link', () => {
        const url = buildLifeModLink('agreementIndexId', 'userId');

        expect(url).toContain('/c/ExternalLinkApp.app?linkId=109&policyIdentifier=agreementIndexId&userSessionId=userId-');
    });

    it('builds a Phoenix Life link', () => {
        const url = buildPhoenixLifeLink();

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=192');
    });

    it('builds a NECO link with agent associate id', () => {
        const url = buildNECHODetailsLink(parms);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=9&accountId=accountRecordId&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=policyNumber&lineOfBusiness=lob&agentAssocId=agentAssociateId');
    });

    it('builds a NECO link without an agent associate id', () => {
        const url = buildNECHODetailsLink(parmsNoAssociateId);

        expect(url).toEqual('/apex/VFP_ExternalLink?LinkId=69&accountId=accountRecordId&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=policyNumber&lineOfBusiness=lob');
    });

    it('builds a Policy Center link', () => {
        const url = buildPolicyCenterLink('555', parms.agreementIndexId);

        expect(url).toEqual('/c/ExternalLinkApp.app?linkId=555&agreementIndexId=agreementIndexId&intent=viewPolicy');
    });

    it('returns true when agent profile is used with an undefined logged in associate id', () => {
        const oobp = isOutOfBookPolicy(undefined, '2.00 Agent', '1234');

        expect(oobp).toEqual('TRUE');
    });

    it('returns true when agent profile is used with undefined agent associate id', () => {
        const oobp = isOutOfBookPolicy('1234', '2.00 Agent', undefined);

        expect(oobp).toEqual('TRUE');
    });

    it('returns true both the associate id of the logged in user and the agent associate id are undefined', () => {
        const oobp = isOutOfBookPolicy(undefined, '2.00 Agent', undefined);

        expect(oobp).toEqual('TRUE');
    });

    it('returns false when agent profile is used with agent associate id and logged in agent associate id are equal', () => {
        const oobp = isOutOfBookPolicy('1234', '2.00 Agent', '1234');

        expect(oobp).toEqual('FALSE');
    });

    it('returns true when agent profile is used with agent associate id and logged in agent associate id are not equal', () => {
        const oobp = isOutOfBookPolicy('1234', '2.00 Agent', '4567');

        expect(oobp).toEqual('TRUE');
    });

    it('returns false when agent team member profile is used with agent associate id and logged in agent associate id are equal', () => {
        const oobp = isOutOfBookPolicy('1234', '2.01 Agent Team Member', '1234');

        expect(oobp).toEqual('FALSE');
    });

    it('returns true when agent team member profile is used with agent associate id and logged in agent associate id are not equal', () => {
        const oobp = isOutOfBookPolicy('1234', '2.01 Agent Team Member', '456');

        expect(oobp).toEqual('TRUE');
    });

    it('returns true when a 1.07 profile is used with agent associate id and logged in agent associate id are equal', () => {
        const oobp = isOutOfBookPolicy('1234', '1.07 Technical Support', '1234');

        expect(oobp).toEqual('TRUE');
    });

    // eslint-disable-next-line jest/expect-expect
    it('buildDetailsLaunchout calls buildAutoPolicyViewForMultiCarLink for multi-car', async() =>{
        let detailsLaunchParams = {
            isMultiCarAuto: true,
            lob: AUTO,
            accessKey: 'accessKey',
            riskNumber: 'riskNumber',
            sourceSystemCode: 1
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toContain('LinkId=198');
        expect(value).toContain('pmrNumber=accessKeyriskNumber');
    });
    
    it('buildDetailsLaunchout calls buildNECHODetailsLink for multi-car for NOT LEGACY_CD', async() =>{
        let detailsLaunchParams = {
            isMultiCarAuto: true,
            lob: AUTO,
            policyNumber: '123-A-45678',
            riskNumber: '009' 
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toBeFalsy();
    });

    it('buildDetailsLaunchout calls buildAutoPolicyViewForMultiCarLink for fleet policy', async() =>{
        let detailsLaunchParams = {
            isFleetAuto: true,
            lob: AUTO,
            accessKey: 'accessKey',
            riskNumber: 'riskNumber'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toContain('LinkId=198');
        expect(value).toContain('pmrNumber=accessKey');
    });

    it('buildDetailsLaunchout calls buildAutoPolicyViewLink for COMMERCIAL_MOD_CD', async() =>{
        let detailsLaunchParams = {
            lob: AUTO,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            policyNumber: 'policyNumber',
            productDescription:'productDescription',
            outOfBookIndicator:'outOfBookIndicator',
            accessKey: 'accessKey',
            riskNumber: 'riskNumber',
            sourceSystemCode: COMMERCIAL_MOD_CD
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=28&accountId=undefined&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=A&productDescription=undefined&outOfBookIndicator=undefined');
    });

    it('buildDetailsLaunchout calls buildAutoPolicyViewLink for LEGACY_CD', async() =>{
        let detailsLaunchParams = {
            lob: AUTO,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            policyNumber: 'policyNumber',
            productDescription:'productDescription',
            outOfBookIndicator:'outOfBookIndicator',
            accessKey: 'accessKey',
            riskNumber: 'riskNumber',
            sourceSystemCode: LEGACY_CD 
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=28&accountId=undefined&agreementIndexId=agreementIndexId&policyNumber=policyNumber&lineOfBusiness=A&productDescription=undefined&outOfBookIndicator=undefined');
    });

    it('buildDetailsLaunchout calls buildPolicyCenterLink for PERSONAL_AUTO_MOD_CD', async() =>{
        let detailsLaunchParams = {
            lob: AUTO,
            accessKey: 'accessKey',
            riskNumber: 'riskNumber',
            sourceSystemCode: PERSONAL_AUTO_MOD_CD,
            agreementIndexId: '123'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/c/ExternalLinkApp.app?linkId=92&agreementIndexId=123&intent=viewPolicy');
    });

    it('buildDetailsLaunchout calls nothing for an unexpected source system code', async() =>{
        let detailsLaunchParams = {
            lob: AUTO,
            accessKey: 'accessKey',
            riskNumber: 'riskNumber',
            sourceSystemCode: 'unexpected value'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toBeFalsy();
    });

    it('buildDetailsLaunchout calls buildHagertyLink for antique', async() =>{
        let detailsLaunchParams = {
            isMultiCarAuto: false,
            isFleetAuto: false,
            lob: AUTO,
            sourceSystemCode: 28,
            agentAssociateId: 'agentAssocId',
            stateAgentCode: 'stateAgentCode',
            accessKey: 'accessKey'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=258&intent=viewPolicy&agreementNumber=accessKey&stateAgentCode=stateAgentCode');
    });

    it('buildDetailsLaunchout calls buildHagertyLink for drivers club', async() =>{
        let detailsLaunchParams = {
            isMultiCarAuto: false,
            isFleetAuto: false,
            lob: AUTO,
            sourceSystemCode: 28,
            agentAssociateId: 'agentAssocId',
            stateAgentCode: 'stateAgentCode',
            accessKey: 'accessKey',
            policyTypeCode: 'DC'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=258&intent=viewDriversClub&agreementNumber=accessKey&stateAgentCode=stateAgentCode');
    });

    it('buildDetailsLaunchout calls buildNECHODetailsLink when homeowners fire is true and source system code is LEGACY_CD', async() =>{
        let detailsLaunchParams = {
            lob: FIRE,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            policyNumber: '12-HO-45678',
            sourceSystemCode: LEGACY_CD,
            isHomeownersFire: true
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=69&accountId=undefined&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=12-HO-45678&lineOfBusiness=F');
    });

    it('buildDetailsLaunchout calls buildNECHODetailsLink when homeowners fire is true and source system code is COMMERCIAL_MOD_CD', async() =>{
        let detailsLaunchParams = {
            lob: FIRE,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            policyNumber: '12-HO-45678',
            sourceSystemCode: COMMERCIAL_MOD_CD,
            isHomeownersFire: true
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=69&accountId=undefined&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=12-HO-45678&lineOfBusiness=F');
    });

    it('buildDetailsLaunchout calls buildNECHODetailsLink when homeowners fire is false and source system code is COMMERCIAL_MOD_CD', async() =>{
        let detailsLaunchParams = {
            lob: FIRE,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            policyNumber: '12-HO-45678',
            sourceSystemCode: COMMERCIAL_MOD_CD,
            isHomeownersFire: false
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=69&accountId=undefined&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=12-HO-45678&lineOfBusiness=F');
    });

    it('buildDetailsLaunchout calls buildPolicyCenterLink with link id 94 source system code is PERSONAL_FIRE_MOD_CD', async() =>{
        let detailsLaunchParams = {
            lob: FIRE,
            accessKey: 'accessKey',
            riskNumber: 'riskNumber',
            sourceSystemCode: PERSONAL_FIRE_MOD_CD,
            isHomeownersFire: false,
            agreementIndexId: '123'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/c/ExternalLinkApp.app?linkId=94&agreementIndexId=123&intent=viewPolicy');
    });

    it('buildDetailsLaunchout calls nothing for FIRE when unexpected source system code is passed', async() =>{
        let detailsLaunchParams = {
            lob: FIRE,
            sourceSystemCode: 'unexpected value',
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toBeFalsy();
    });

    it('buildDetailsLaunchout calls buildLifeModLink for LIFE_MOD_CD', async() =>{
        let detailsLaunchParams = {
            lob: LIFE,
            sourceSystemCode: LIFE_MOD_CD,
            agreementIndexId: '123',
            userId: 'userId'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toContain('/c/ExternalLinkApp.app?linkId=109&policyIdentifier=123&userSessionId=userId-');
    });

    it('buildDetailsLaunchout calls buildPhoenixLifeLink when phoenix life is true', async() =>{
        let detailsLaunchParams = {
            lob: LIFE,
            isPhoenixLife: true
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=192');
    });

    it('buildDetailsLaunchout calls buildLifePolicyViewLink when isPMRLife is true', async() =>{
        let detailsLaunchParams = {
            lob: LIFE,
            isPMRLife: true
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toContain('LinkId=105');
    });

    it('buildDetailsLaunchout calls buildNECHODetailsLink when isASCLife is true', async() =>{
        let detailsLaunchParams = {
            lob: LIFE,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            key:'key',
            isASCLife: true
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=69&accountId=undefined&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=undefined&lineOfBusiness=L');
    });

    it('buildDetailsLaunchout calls nothing for LIFE when no expected input is provided', async() =>{
        let detailsLaunchParams = {
            lob: LIFE
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toBeFalsy();
    });

    it('buildDetailsLaunchout calls buildNECHODetailsLink for HEALTH line of business', async() =>{
        let detailsLaunchParams = {
            lob: HEALTH,
            accountId: 'accountId',
            agreementIndexId: 'agreementIndexId',
            key:'key'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('/apex/VFP_ExternalLink?LinkId=69&accountId=undefined&agreementIndexId=agreementIndexId&clientnamelinkdisabled=Y&NechoAppName=policy&key=undefined&lineOfBusiness=H');
    });

    it('buildDetailsLaunchout calls nothing for unknown line of business', async() =>{
        let detailsLaunchParams = {
            lob: 'X'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toBeFalsy();
    });

    it('buildDetailsLaunchout returns nothing for unknown line of business', async() =>{
        let detailsLaunchParams = {
            lob: 'Z'
        };

        let value = await buildDetailsLaunchout(detailsLaunchParams);

        expect(value).toEqual('');
    });
});
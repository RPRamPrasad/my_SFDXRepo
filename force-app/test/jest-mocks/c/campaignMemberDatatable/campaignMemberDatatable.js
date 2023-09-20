import clickToDial from './clickToDial.html';
import onClickAccountForCti from './onClickAccountForCti.html';
import SortedDatatable from 'c/sortedDatatable';
import campaignMembActions from './campaignMemberActions.html';
import sobjectLinkAndHover from './sobjectLinkAndHover.html';
import statusPicklist from './statusPicklist.html';
import displayString from './displayString.html';
import policyNumber from './policyNumber.html';

export default class CampaignMemberDatatable extends SortedDatatable {

    static customTypes = {
        clickToDialDisplay: {
            template: clickToDial,
            typeAttributes: ['displayType', 'phoneNumber', 'isDoNotMarket', 'metaData','overrideUserPreferences','theme','clickToDialEnabled','clickToDialPreference','isDoNotCall']
        },
        campMembActionsDisplay: {
            template: campaignMembActions,
            typeAttributes: ['accountId','campaignMemberId',  'leadId','campaignMemberName','campaignMemberStatus','campaignMemberEmail','campaignMemberSendText','campaignId','buttonOption','dropdownOptions']
        },
        statusDisplay: {
            template: statusPicklist,
            typeAttributes: ['disableCombobox', 'valuesToRemove', 'objectName', 'metaData', 'selectedValue','fieldName','campMembEmail']
        },displayString:{
            template: displayString,
            typeAttributes:['content']
        },
        sobjectLinkAndHover:{
            template: sobjectLinkAndHover,
            typeAttributes:['displayName','sobjectId','target','enableAccountAlertAlertHover','accountAlertPosition','campaignId','campaignMemberId','accountId']
        },
        onClickAccountForCti: {
            template: onClickAccountForCti,
            typeAttributes: ['recordName','accountId','agentAssocId']
        },
        policyNumber:{
            template: policyNumber,
            typeAttributes: ['policyData','position']
        }
    };
}
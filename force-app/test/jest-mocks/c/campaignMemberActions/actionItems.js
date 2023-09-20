import { actionButtonOptions, actionDropdownOptions } from 'c/campaignConstants'
import campaignMemberSendEmail from '@salesforce/customPermission/CampaignMemberSendEmail';
import campaignMemberSendTextPermission from '@salesforce/customPermission/CampaignMemberSendText';
import campaignMemberNewLog from '@salesforce/customPermission/CampaignMemberNewLog';
import CampaignMemberNewCase from '@salesforce/customPermission/CampaignMemberNewCase';

export function getActionButtonDetails(value) {
    if (value === actionButtonOptions.NEW_LOG && campaignMemberNewLog) {
        return { id: actionButtonOptions.NEW_LOG, label: 'New Log'}
    } else if (value === actionButtonOptions.QUICK_OPPORTUNITY) {
        return { id: actionButtonOptions.QUICK_OPPORTUNITY, label: 'New Opportunity'}
    } else if (value === actionButtonOptions.CONVERT_LEAD) {
        return { id: actionButtonOptions.CONVERT_LEAD, label: 'Convert'}
    }
    return undefined;
}
export function getDropdownOptions(values,status,campaignMemberEmail,campaignMemberSendText) {
    var options = [];
    var option;
    var value;
    for (value of values) {
        option = getDropdownOption(value,status,campaignMemberEmail,campaignMemberSendText);
        if (option !== undefined) {
            options.push(option);
        }
    }
    return options;
}

function getDropdownOption(value,status,campaignMemberEmail,campaignMemberSendText) {
    if (value === actionDropdownOptions.NEW_LOG && campaignMemberNewLog) {
        return { id: actionDropdownOptions.NEW_LOG, label: 'New Log' }
    }else if (value === actionDropdownOptions.REMOVE_ACCOUNT) {
            return { id: actionDropdownOptions.REMOVE_ACCOUNT, label: 'Remove' }
    }else if(value === actionDropdownOptions.REMOVE_LEAD) {
        if (status === 'Removed') {
            return { id: actionDropdownOptions.UNDO_REMOVE_LEAD, label: 'Undo Remove' }
        }
        return { id: actionDropdownOptions.REMOVE_LEAD, label: 'Remove' }
    } else if (value === actionDropdownOptions.SEND_EMAIL && campaignMemberSendEmail && campaignMemberEmail) {
        return { id: actionDropdownOptions.SEND_EMAIL, label: 'Send Email' }
    } else if (value === actionDropdownOptions.NEW_CASE && CampaignMemberNewCase) {
        return { id: actionDropdownOptions.NEW_CASE, label: 'New Case'}
    } else if (canSFConnectBeDisplay(value, campaignMemberSendTextPermission, campaignMemberSendText)){
        return { id: actionDropdownOptions.SF_CONNECT, label: 'Send Text'}
    }

    return undefined;
}

function canSFConnectBeDisplay(value,textPermission,campaignMemberSendText){
    if(value === actionDropdownOptions.SF_CONNECT && textPermission && campaignMemberSendText === 'Yes'){
        return true;
    }
    return false;
}
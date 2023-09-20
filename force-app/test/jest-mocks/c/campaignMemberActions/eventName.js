import { actionButtonOptions, actionDropdownOptions } from 'c/campaignConstants'

export function getEventName(value){
    if (value.includes(actionDropdownOptions.NEW_LOG)) {
        return 'newlogforcampaignmember'
    }else if (value.includes(actionDropdownOptions.REMOVE_ACCOUNT)) {
            return 'removeaccountcampaignmember'
    }else if (value.includes(actionDropdownOptions.UNDO_REMOVE_LEAD)) {
        return 'undoremoveleadcampaignmember'
    }else if(value.includes(actionDropdownOptions.REMOVE_LEAD)) {
        return 'removeleadcampaignmember'
    } else if (value.includes( actionDropdownOptions.SEND_EMAIL)) {
        return 'sendemailtocampaignmember'
    } else if (value.includes(actionDropdownOptions.SEND_TEXT)) {
        return 'sendtexttocampaignmember'
    }else if (value.includes(actionButtonOptions.QUICK_OPPORTUNITY)) {
        return 'quickopportunitycreate'
    }else if (value.includes(actionButtonOptions.CONVERT_LEAD)) {
        return 'convertleadcampaignmember'
    }else if (value.includes(actionDropdownOptions.NEW_CASE)){
        return 'newcaseforcampaignmember';
    }else if (value.includes(actionDropdownOptions.SF_CONNECT)){
        return 'sfconnectforcampaignmember';
    }

    return undefined;
}
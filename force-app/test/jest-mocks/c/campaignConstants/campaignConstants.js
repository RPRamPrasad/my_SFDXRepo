import campaignMessageChannel from '@salesforce/messageChannel/Campaign__c';
import caseMessageChannel from '@salesforce/messageChannel/case__c';

export const SUPPORT_PROFILES = 'Corporate Support';

export const events = {
    CAMPAIGN_MEMBER_DATA_REFRESH: 'campaignmemberrefresh',
    CAMPAIGN_MEMBER_MINIFIED_DATA_REFRESH: 'campaignmemberminifiedrefresh',
    CAMPAIGN_MEMBER_ASSIGN_TO_COUNT_DATA_REFERESH: 'campaignmemberassigntocountsdatarefresh',
    AGENT_OFFICE_DATA_REFRESH: 'agentofficedatarefresh',
    CAMPAIGN_MEMBER_BULK_ASSIGNMENT: 'campaignmemberbulkassignment',
    CAMPAIGN_MEMBER_FILTER_CHANGE: 'campaignmemberfilterchange',
    CAMPAIGN_MEMBER_SORT_CHANGE: 'campaignmembersortchange',
    CAMPAIGN_MEMBER_DISPLAY_BULK_ASSIGN: 'campaignmemberdisplaybulkassign',
    USER_DATA_REFRESH: 'userdatarefresh',
    START_STOP_JOURNEY: 'startstopcampaignjourney',
    JOURNEY_STARTED: 'journeystarted',
    JOURNEY_STOPPED: 'journeystopped',
    CASE_JOURNEY_STOPPED: 'casejourneystopped',
    CASE_JOURNEY_STARTED: 'casejourneystarted',
    OPP_JOURNEY_STARTSTOPPED: 'oppjourneystartstopped',
    SET_FOLLOW_UP: 'setfollowup',
    DATA_REQUEST: 'campaigndatarequest',
    QUICK_OPPORTUNITY: 'campaignquickopportunity',
    QUICK_OPPORTUNITY_CREATED_SUCCESS:'campaignquickopportunitycreatedsuccess',
    CLICK_TO_DIAL_CLICK:'clicktodialclick',
    CAMPAIGN_PATH_REFRESH: 'campaignpathrefresh',
    DISPLAY_CAMPAIGN_SUMMARY: 'displaycampaignsummary',
    CAMPAIGN_MEMBER_DISPLAY_FILTER: 'campaignmemberdisplayfilter',
    UPDATE_CAMPAIGN_PATH_STEP: 'updatecampaignpathstep',
    NEW_LOG: 'newlog',
    NEW_LOG_CREATE_SUCCESS: 'newlogcreatesuccess',
    NEW_CASE: 'newcase',
    NEW_CASE_CREATE_SUCCESS: 'newcasecreatesuccess',
    SIMPLE_CONVERSATION: 'simpleconversation',
    SIMPLE_CONVERSATION_CREATED_SUCCESS:'simpleconvtocampaignincrement',
    DISPLAY_PHONE_FOLLOW_UP: 'displaycampaignphonefollowup',
    GOOD_NEIGHBOR_CONNECT: 'goodneighborconnect',
    NEW_GOOD_NEIGHBOR_CONNECT_SUCCESS: 'goodneighborconnectcreatesuccess',
    SF_CONNECT: 'sfconnect',
    SF_CONNECT_SUCCESS: 'sfconnectcreatesuccess'
}

export const eventData = {
    CAMPAIGN_MEMBER: 'campaignMember',
    CAMPAIGN_MEMBER_MINIFIED: 'campaignMemberMinified',
    CAMPAIGN_MEMBER_ASSIGNED_TO_COUNTS: 'campaignMemberAssignedToCounts',
    AGENT_OFFICE: 'agentOffice',
    USER: 'userData'
}

export function buildEventName(recordId, event) {
    return `${recordId}_${event}`;
}

export const campaignMessage = campaignMessageChannel;
export const caseMessage = caseMessageChannel;

export function buildMessage(recordId, messageType, data) {
    return {
        messageChannel: campaignMessage,
        message: {
            recordId: recordId,
            messageType: messageType,
            data: data
        }
    };
}
export function caseBuildMessage(recordId, messageType, data) {
    return {
        messageChannel: caseMessage,
        message: {
            recordId: recordId,
            messageType: messageType,
            data: data
        }
    };
}

export const actionButtonOptions = {
    QUICK_OPPORTUNITY:'QUICK_OPPORTUNITY',
    CONVERT_LEAD:'CONVERT_LEAD',
    NEW_LOG:'NEW_LOG'
}
export const actionDropdownOptions = {
    REMOVE_ACCOUNT:'REMOVE_ACCOUNT',
    REMOVE_LEAD:'REMOVE_LEAD',
    UNDO_REMOVE_LEAD:'UNDO_REMOVE_LEAD',
    NEW_LOG:'NEW_LOG',
    SEND_EMAIL:'SEND_EMAIL',
    SEND_TEXT:'SEND_TEXT',
    NEW_CASE:'NEW_CASE', 
    SIMPLE_CONVERSATION: 'SIMPLE_CONVERSATION',
    GOOD_NEIGHBOR_CONNECT: 'GOOD_NEIGHBOR_CONNECT',
    SF_CONNECT: 'SF_CONNECT'
}

export const failedLeadUploadUrl = 'http://sfnet.opr.statefarm.org/agency/training/rollout/enterprise_customer_relationship_manager/pdfs/upload_leads_workflow.pdf'
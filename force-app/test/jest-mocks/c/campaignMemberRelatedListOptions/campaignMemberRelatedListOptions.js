import { api, LightningElement, track, wire } from 'lwc';
import { events, campaignMessage } from 'c/campaignConstants';
import { publish, MessageContext } from 'lightning/messageService';
import { buildMessage } from 'c/messageServiceHelper'
import hasCampaignAssignToEditPermission from '@salesforce/customPermission/CampaignAssignToEdit'
import hasCampaignAssignToViewPermission from '@salesforce/customPermission/CampaignAssignToView';
import CampaignMemberBulkAssignToModal from 'c/campaignMemberBulkAssignToModal'

export default class CampaignMemberRelatedListOptions extends LightningElement {
    @wire(MessageContext)
    messageContext;
    @api recordId;

    @track displayAssignToButton;

    connectedCallback() {
        this.displayAssignToButton = hasCampaignAssignToEditPermission || hasCampaignAssignToViewPermission
    }

    handleFilterClick() {
        publish(this.messageContext, campaignMessage, buildMessage(events.CAMPAIGN_MEMBER_DISPLAY_FILTER));

    }

    async displayBulkAssignTo() {
        // publish(this.messageContext, campaignMessage, buildMessage(events.CAMPAIGN_MEMBER_DISPLAY_BULK_ASSIGN));
        await CampaignMemberBulkAssignToModal.open({
            recordId: this.recordId // added recordId
        });
    }


}
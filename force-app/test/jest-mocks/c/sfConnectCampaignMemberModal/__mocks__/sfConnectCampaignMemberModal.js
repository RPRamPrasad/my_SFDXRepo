import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SfConnectCampaignMemberModal extends NavigationMixin(LightningElement) {
    @api campaignId;
    @api accountId;
    @api accountName;
    @api campMembId;
    @api campaignMemberBulkText;
}
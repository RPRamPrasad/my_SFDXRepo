import { LightningElement,api } from 'lwc';
export default class CampaignMemberTabset extends LightningElement {

    @api
    campaignMemberId;
    @api
    campaignId;
    @api
    accountId;
}
import { LightningElement,api } from 'lwc';

export default class CampaignMemberTabset extends LightningElement {

    @api
    campaignMemberId;
    @api
    campaignId;
    @api
    get accountId(){
        return this.accountIdHolder;
    }
    set accountId(value){
        this.accountIdHolder = value;
    }

    numberOfRows=2;
}
import { api, LightningElement } from 'lwc';

export default class CampaignMemberRelatedListOptions extends LightningElement {
    @api recordId;
    @api currentUserProfile;

}
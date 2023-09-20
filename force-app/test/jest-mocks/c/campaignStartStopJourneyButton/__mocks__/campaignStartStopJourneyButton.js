import { LightningElement,api } from 'lwc';

export default class CampaignStartStopJourneyButton extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api sourceJourneyButton;
    showModal;
    journeyRequest;
    buttonName; 

}
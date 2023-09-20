import { LightningElement, api} from "lwc";
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import updateCampMessagesAndCallAcxiom from '@salesforce/apex/HLPR_CampaignDirectMails.processStopDirectMails';
import showStopDirectMails from '@salesforce/apex/HLPR_CampaignDirectMails.showStopDirectMails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasOpportunityStartStopPermission from '@salesforce/customPermission/PerformOpportunityStartStopJourney';
export default class StopCampaignDirectMailers extends LightningElement {

    @api recordId;
    isButtonDisabled;
    campaignMessageList;


   connectedCallback() {
        this.handleButtonDisplay();
    }

    handleButtonDisplay() {
        showStopDirectMails({ campaignId: this.recordId})
        .then(result => {
            this.isButtonDisabled = result
        })
    }

    handleClick () {
        if(this.canUserStopCampMailers) {
            this.callApexAndCancelMessages();
        } else {
            this.showToastEvent("", "This action is not available for your user type", "error");
        }
    }

    callApexAndCancelMessages() {
        updateCampMessagesAndCallAcxiom({ campaignId: this.recordId})
        .then(result => {
            if(result){
                const updatedRecords = result.map(rec => {
                    return { 'recordId': rec };
                });
                this.isButtonDisabled = true;
                getRecordNotifyChange(updatedRecords);
                this.showToastEvent("", "Direct Mail stopped successfully", "success");
            } else {
                this.showToastEvent("", "An unexpected error has occurred. Please contact your normal support channel for assistance.", "error");
            }
        })
    }

    showToastEvent(title,message,variant){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    get canUserStopCampMailers() {
        return hasOpportunityStartStopPermission;
    }

}
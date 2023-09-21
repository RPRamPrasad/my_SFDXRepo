import { LightningElement, api } from 'lwc';
import logAgentStatusTrackerOpen from '@salesforce/apex/PremiumChangeController.logAgentStatusTrackerOpen';


export default class AgentStatusTracker extends LightningElement {
    @api isModalOpen;  

    @api
    openModal() {
        this.isModalOpen = true;

        logAgentStatusTrackerOpen();
    }

    @api
    closeModal() {
        this.isModalOpen = false;
    }
  
}
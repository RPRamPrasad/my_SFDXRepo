import { LightningElement, track, api } from 'lwc';
export default class AccountCreateEditButtons extends LightningElement {
    @track buttonSelect = null;
    @api isButtonDisabled;
    
    handleClick(event){
        this.buttonSelect = event.target.label;
        //set the values to be sent
        const buttonVal = [this.buttonSelect];
        //construct the custom event, and put the array into the values slot, then dispatch it to the Throne
        const buttonValEvent = new CustomEvent('buttonval', { detail: {buttonVal}, });
        this.dispatchEvent(buttonValEvent);
    }
}
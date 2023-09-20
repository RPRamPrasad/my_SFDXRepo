import { LightningElement, track, api } from 'lwc';
export default class AccountEmailPopUp extends LightningElement {
    @api enteredEmail;
    @api get verifyEmailResult() { return this.verifyEmailAddressResult }
        set verifyEmailResult(value) {
            this.verifyEmailAddressResult = value;
        }
    
    @track verifyEmailAddressResult = this.verifyEmailResult;
    @track isEmailPopUp;

    renderedCallback(){
        this.template.querySelector(`[data-id="edit"]`).focus();
    }

    editEmail() {
        const myEvent = new CustomEvent("editemail");
        this.dispatchEvent(myEvent);
    }

    continueEmail() {
        const myEvent = new CustomEvent("continueemail");
        this.dispatchEvent(myEvent);
    }

    continueFocus(){
        this.template.querySelector(`[data-id="edit"]`).focus();
    }

    editFocus(){
        this.template.querySelector(`[data-id="continue"]`).focus();
    }

}
import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord } from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class ClaimEmail extends LightningElement {
    @api claimsEmailAddress;
    @api buttonLabel = 'Email Claims';
    @api claimNumber;
    userEmailAddress; 

    @wire(getRecord, {
        recordId: currentUserId,
        fields: [EMAIL_FIELD]
    }) wireUser({error, data}) {
        if (data) {
            this.userEmailAddress = data.fields.Email.value;
        } else if (error) {
            this.showToast('Error', 'error', 'Unable to get user\'s email.');
        }
    }

    @api 
    get emailValue() {
        let email;
        if (this.userEmailAddress && this.claimsEmailAddress && this.claimNumber) {
            email = this.claimsEmailAddress + '?cc=' + this.userEmailAddress + '&subject=' + this.claimNumber;
        }
        return email;
    }

    showToast(title, type, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            variant: type,
            message: message
        })
        this.dispatchEvent(toastEvent);
    }
}
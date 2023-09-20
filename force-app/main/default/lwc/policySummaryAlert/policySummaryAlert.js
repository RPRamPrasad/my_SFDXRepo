import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import logClickCardAlertBillingAcctNum from '@salesforce/apex/PolicySummaryEventController.logClickCardAlertBillingAcctNum';
import logClickCardAlertPayBills from '@salesforce/apex/PolicySummaryEventController.logClickCardAlertPayBills';
import logClickListAlertBillingAcctNum from '@salesforce/apex/PolicySummaryEventController.logClickListAlertBillingAcctNum';
import logClickListAlertPayBills from '@salesforce/apex/PolicySummaryEventController.logClickListAlertPayBills';

export default class PolicySummaryAlert extends NavigationMixin(LightningElement) {

    @api accountList;
    @api accountPageRecordId;
    @api alerts;
    @api isCardView;
    @api isHousehold;

    showHover = false;
    showAccountPickerModal = false;

    get popoverHeader() {
        return this.alerts.length > 1 ? 'Multiple warnings' : 'Warning';
    }

    get hasAlertLength() {
        return this.alerts.length > 1 ? true : false;
    }

    get alertLength(){
    return `(${this.alerts.length})`;
    }

    handleClickToggle(event) {
        event.preventDefault();
        this.showHover = !this.showHover

        if (this.showHover) {
            this.dispatchEvent(new CustomEvent('alertclick', { detail: { value: this.accountPageRecordId }, bubbles: true, composed: true } ))
        }
    }

    navigateTo(objectName, recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectName,
                actionName: 'view',
            },
        });
    }

    navigateToBillingAccount(event) {
        this.navigateTo('Billing_Account__c', event.currentTarget?.dataset?.id);
        if (this.isCardView) {
            logClickCardAlertBillingAcctNum();
        }
        else {
            logClickListAlertBillingAcctNum();
        }
    }

    navigateToPayBills() {
        if (this.isHousehold) {
            this.showAccountPickerModal = true;
        } else {
            window.open(this.getPayBillsUrl(this.accountPageRecordId));
        }

        if (this.isCardView) {
            logClickCardAlertPayBills();
        }
        else {
            logClickListAlertPayBills();
        }
    }

    onAccountSelect(event) {
        this.showAccountPickerModal = false;
        this.accountPicked = event.detail;
        window.open(this.getPayBillsUrl(event.detail));
    }

    getPayBillsUrl(accountId) {
        return `/c/ExternalLinkApp.app?linkId=232&accountId=${accountId}`;
    }

    onCloseModal() {
        this.showAccountPickerModal = false;
    }
}

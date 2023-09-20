/**
 * Created by Team Kraken 08/23/21
 * This component will be used for the SF Billing Button. In order to allow customization for SF Billing without sacraficing existing functionality
 * we need a special component. A magical and brillint component that makes us better human beings.
 */

import { LightningElement, api } from 'lwc';

export default class BillingButtonSfBilling extends LightningElement {

    @api billingAccountNumber;
    @api billingAccountUrl;
    @api billingAccountUrlDescription;

    openSFBillingAccountUrl() {
        window.open(this.billingAccountUrl);
    }

    copySFBillingNumber() {

        // create temporary element to clip from
        const temp = document.createElement("input");
        document.body.appendChild(temp);

        // Set temporary component value, select and copy.
        temp.value = this.billingAccountNumber;
        temp.select();
        document.execCommand("copy");

        // Remove temporary element as its not needed anymore
        document.body.removeChild(temp);
    }

}


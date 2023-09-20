/**
 * Created by Team Kraken 08/23/21
 * This component will be used for the SFPP Button. In order to make this work with SFPP without sacraficing existing functionality
 * we need a special component. A magical and brillint component that makes us better human beings.
 */

import { LightningElement, api } from 'lwc';

export default class BillingButtonSfpp extends LightningElement {

    @api billingAccountNumber;
    @api stateAgentCode;
    @api status;

    openSFPPAccountUrl() {
        window.open(`/c/ExternalLinkApp.app?linkId=255&STAGTCODE=${this.stateAgentCode}&AccountNumber=${this.billingAccountNumber}`);
    }

    copySFPPNumber() {

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


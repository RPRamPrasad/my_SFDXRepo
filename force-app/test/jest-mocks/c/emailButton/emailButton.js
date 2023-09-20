import { LightningElement, api} from 'lwc';

export default class EmailButton extends LightningElement {
    @api buttonLabel;
    @api emailValue;
    @api iconName = 'action:email';

    clickFormattedEmail() {
        this.template.querySelector('lightning-formatted-email').click();
    }
}
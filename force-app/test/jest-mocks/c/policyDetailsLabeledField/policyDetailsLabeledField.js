import { LightningElement, api } from 'lwc';

export default class PolicyDetailsLabeledField extends LightningElement {
    @api label;
    @api value;
    @api help;
    @api valueHighlight;
    @api valueBorder;

    @api url;
    @api urlLabel;

    get isTextValue() {
        return typeof this.value === 'string';
    }

    get cssForBlock() {
        return this.valueBorder ? 'data-block slds-border_bottom' : 'data-block';
    }
}
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api name;
    @api disableCombobox;
    @api dropdownAlignment = 'auto';
    @api variant = 'label-hidden';

    //capture the picklist change and fire a valuechange event with details payload.
    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('valuechange', {
            composed:true,
            bubbles:true,
            cancelable:true,
            detail : {
                data: {
                    context: this.context, 
                    value: this.value
                }
            } 
        }));
    }
}

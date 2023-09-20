/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';

export default class DatatableToggle extends LightningElement {
    @api context;
    @api label;
    @api type;
    @api name;
    @api checked;
    @api disabled = false;
    @api activeMessage = 'Enabled';
    @api inActiveMessage = 'Disabled';
    @api variant = 'label-hidden';

    handleChange(event) {
        this.checked = event.detail.checked;
        const toggleEvent = CustomEvent('togglechange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail : {
                data: {
                    context: this.context, 
                    value: this.checked
                }
            }
        });
        this.dispatchEvent(toggleEvent);
    }

}
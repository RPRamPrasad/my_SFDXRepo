import { LightningElement, api } from 'lwc';
export default class CheckboxGroupForm extends LightningElement {
    @api
    checkboxGroupLabel;
    @api
    submitButtonText;
    @api
    preSelectedOptions;
    @api
    submitEventName;
    @api
    checkboxColumnCount;
    @api
    options;
    @api
    label;
    @api
    disableCheckboxes;
    @api
    clearCheckboxes = jest.fn();
}
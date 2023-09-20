import { LightningElement,api } from 'lwc';
export default class CheckboxGroupSelectionForm extends LightningElement {


    @api 
    checkboxGroupLabel;
    @api
    submitButtonText;
    @api
    preSelectedCheckboxOptions = [];
    @api
    checkboxOptions;
    @api
    submitEventName;
    @api
    comboboxLabel;
    @api
    comboboxOptions;
    @api
    comboboxVariant;
    @api
    comboboxValue;
    @api
    comboboxChangeEventName;
    @api
    checkboxColumnCount;
    @api
    showCombobox;
    @api
    disableCombobox;
    @api
    disableCheckboxes;
    @api
    clearCheckboxes = jest.fn();
}
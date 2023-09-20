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
    comboboxOptionsHolder;
    @api
    set comboboxOptions(value) {
        this.comboboxOptionsHolder = this.parseIfString(value)
    }
    get comboboxOptions() {
        return this.comboboxOptionsHolder
    }
    @api
    comboboxVariant;
    @api
    comboboxValue;
    @api
    comboboxChangeEventName;

    firstSubmitEventName='submit';

    @api
    showCombobox 

    @api
    disableCombobox

    @api
    disableCheckboxes

    @api clearCheckboxes() {
        this.template.querySelector("c-checkbox-group-form").clearCheckboxes();
    }

    @api
    checkboxColumnCount = 2

    dispatchRefresh() {
        this.comboboxValue = undefined
        this.dispatchEvent(new CustomEvent('templaterefresh', {
            cancelable: true,
            composed: true,
            bubbles: true
        }))
    }
    handleOnChange(event){
        this.comboboxValue = event.detail.value;
        this.dispatchEvent(new CustomEvent(this.comboboxChangeEventName, {
            cancelable: true,
            detail: this.comboboxValue
        }))
    }
    handleSubmit(event){
        var eventDetails = {
            selectedOptions:event.detail,
            comboboxValue:this.comboboxValue
        };
        event.preventDefault();
        this.dispatchEvent(new CustomEvent(this.submitEventName, {
            cancelable: true,
            bubbles: true,
            detail: eventDetails
        }))
    }
    parseIfString(value) {
        if (typeof value === 'string') {
            return JSON.parse(value);
        }
        return value;
    }
}
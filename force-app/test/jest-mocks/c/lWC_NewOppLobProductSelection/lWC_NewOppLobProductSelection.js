import { LightningElement, api } from 'lwc';
import "c/checkBrowser";
export default class LWC_NewOppLobProductSelection extends LightningElement {
    @api lobItem;
    @api lobProdDependentOptions;
    @api cssForMobileText;

    handleLOBChange(e) {
        const productDropdown = this.template.querySelector("[data-id='productDropdown']");
        productDropdown.disabled = !e.target.checked;
        this.dispatchEvent(new CustomEvent('lobselected', {
            detail: { 'lob': e.target.name, 'checked': e.target.checked },
            bubbles: true,
            composed: true
        }));
        if (productDropdown.value && e.target.checked) {
            this.dispatchProductSelectionEvent(productDropdown.value);
        }
    }

    handleProductSelection(e) {
        this.dispatchProductSelectionEvent(e.target.value);
    }

    dispatchProductSelectionEvent(productName) {
        this.dispatchEvent(new CustomEvent('productselected', {
            detail: { 'lob': this.lobItem.label, 'product': productName },
            bubbles: true,
            composed: true
        }));
    }

    get isProdComboDisabled() {
        return !this.lobItem.isSelected;
    }

    @api
    focus() {
        this.template.querySelector("[data-id='lobCheckbox']").focus();
    }

    get options() {
        if (this.lobProdDependentOptions && this.lobItem.label in this.lobProdDependentOptions) {
            let options = [{ 'label': '--None--', 'value': '' }];
            options = [...options, ...this.lobProdDependentOptions[this.lobItem.label]];
            return options;
        }
        return [];
    }

    get defaultProduct() {
        let defaultPrdt = '';
        if(this.lobItem.defaultProduct === undefined) { // For Opportunity
            defaultPrdt = (this.lobItem.label === 'Auto') ? 'Private Passenger' : '';
        } else { // For Lead and Campaign Member
            defaultPrdt =  this.lobItem.defaultProduct;
        }
        return defaultPrdt;
    }
}
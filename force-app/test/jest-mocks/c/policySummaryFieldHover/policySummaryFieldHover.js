import { LightningElement, api } from 'lwc';

export default class PolicySummaryFieldHover extends LightningElement {
    @api iconName;
    @api popoverTitle;
    @api popoverBody;

    showHover = false;

    handleHoverOpen() {
        this.showHover = true;
    }

    handleHoverClose() {
        this.showHover = false;
    }
}
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ClaimDatatableObjectLink extends NavigationMixin(LightningElement) {
    @api objectId;
    @api label;

    get hasObjectId() {
        if (this.objectId) {
            return true;
        }

        return false;
    }

    navigateToView(event) {
        const objectId = event.target.dataset.objectId;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: objectId,
                actionName: "view",
            },
        });
    }
}
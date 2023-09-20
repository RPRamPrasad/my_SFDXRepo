import { api, LightningElement } from 'lwc';

export default class BillingStatus extends LightningElement {

	@api billingStatus;
	@api cancellationDate;
	@api accountType;
	isSfpp;
	
	connectedCallback() {
		this.isSfpp = false;
		if(this.accountType === 'sfpp'){
			this.isSfpp = true;
		}
	}
	
	get cancellationTooltip() {
		return this.cancellationDate ? 'Will be removed from ECRM after: ' + this.cancellationDate : "";
		
	}
}

/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';
import callPremiumChange from '@salesforce/apex/PremiumChangeController.callPremiumChange';



export default class PremiumChangeInquiryModal extends LightningElement {
    @api isModalOpen = false;
    @api recordId;

    premiumChangeResponse;
    responseStatus;
    shouldShowSpinner= true;
    isPLAuto;
    isPLFire;
    isBLAuto;
    isBLFire;
    isError;
    isDssShowHide = false;

    

    @api
    openModal() {
        this.isModalOpen = true;      
        this.premiumChangeCallout();
    }

    @api
    closeModal() {
        this.isModalOpen = false;
    }

    dssViewMore() {        
        this.isDssShowHide = true;       
     }

    dssViewLess() {       
        this.isDssShowHide = false;       
    }

    @api
    premiumChangeCallout() {
        callPremiumChange({ policyId: this.recordId })
            .then(result => {
                if (JSON.parse(result).responseStatus === 200) {
                    this.responseStatus = true;
                } else {
                    this.responseStatus = false;
                }
                
                if (JSON.parse(result).flowType) {
                    switch (JSON.parse(result).flowType.toUpperCase()) {
                        case "PLAUTO":
                                this.isPLAuto= true;        
                                break;
                        case "PLFIRE":
                                this.isPLFire= true;
                                break;
                         case "BLAUTO":
                                this.isBLAuto= true;
                                break;
                         case "BLFIRE":
                                this.isBLFire= true;
                                this.responseStatus = true;
                                break;
                        default:
                            break;
                    }
                }

                if (this.responseStatus) {
                    this.shouldShowSpinner = false;
                    this.premiumChangeResponse = JSON.parse(result)?.premiumChange;   
                } else {
                    this.shouldShowSpinner = false;
                    this.premiumChangeResponse = JSON.parse(result);
                    this.unableToLocatePolicy = true;
                    this.isError = false;                          
                }
            }).catch(() => {                
                this.shouldShowSpinner = false; 
                this.isError = true;             
            })

        
    } 

            
}

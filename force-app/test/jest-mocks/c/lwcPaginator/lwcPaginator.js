import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Paginator extends LightningElement {
    @api maxPerPage;
    @api showPageInput;
    @api pagePlaceholder;
    totalPages;
    totalDataSizeHolder;
    currentPageHolder;
    showpaginator;
    inputTypeValue = 'text';
    goToPageEvent = 'gotopageprovided';
        
    @api
    set totalDataSize(value){
        this.totalDataSizeHolder = value;
        this.totalPages = this.calculateTotalPages();
        if(this.totalDataSizeHolder === 0){
            this.showPaginator = false;
        }else{
            this.showPaginator = true;
        }
    }
    get totalDataSize(){
        return this.totalDataSizeHolder;
    }
    
    previousPage(){
        this.dispatchCustomEvent('paginationchanged',this.currentPage - 1);
    }
    nextPage(){
        this.dispatchCustomEvent('paginationchanged',this.currentPage + 1);
    }
    handlePageRequest(e){
        const page = e.detail.searchBarText;
        
        // Since we are using the change-event-input-text component, we only want to change pages if the user hits "Enter".  Checking for not Null and not Spaces will accomplish this.
        if(page !== null && page !== ''){
            const pageNum = parseInt(page,10);
            
            if(this.isPageNumValid(pageNum)){
                this.dispatchCustomEvent('paginationchanged',pageNum);

            } else {
                const message = `You entered an invalid page number of "${page}"`;
                this.showToastEvent("",message,'error');
            }

            const inputComponent = this.template.querySelector('c-change-event-input-text');
            inputComponent.setInputValue('');
        }
    }
    get displayLeftButton(){
        if(this.currentPageHolder > 1){
            return true;
        }
        return false;
    }

    get displayRightButton(){
        if(this.currentPageHolder < this.totalPages){
            return true;
        }
        return false;
    }
    calculateTotalPages(){
        let totalPages = Math.ceil(this.totalDataSize / this.maxPerPage);
        return totalPages;
    }
    @api
    set currentPage(value){
        this.currentPageHolder = value;
        if(this.totalDataSize === undefined){
            this.showPaginator = false;
        }
    }
    get currentPage(){
        return this.currentPageHolder;
    }
    isPageNumValid(pageNum){
        const regex = /^[1-9]\d*$/
        const passRegex = regex.test(pageNum);
            
        if(passRegex && pageNum <= this.totalPages){
            return true;
        }
        return false;
    }
    showToastEvent(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    dispatchCustomEvent(eventName, eventDetails) {
        const customEvent = new CustomEvent(eventName, 
            {
                composed: false,
                bubbles: false,
                cancelable: false,
                detail: eventDetails
            });
        this.dispatchEvent(customEvent);
    }

}
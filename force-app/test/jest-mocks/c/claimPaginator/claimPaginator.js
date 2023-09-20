import { LightningElement,api } from 'lwc';

export default class ClaimPaginator extends LightningElement {
    maxPerPageHolder;
    totalPages;
    totalDataSize;
    currentPageHolder;
    showPaginator;

    @api 
    set maxPerPage(value) {
        this.maxPerPageHolder = value;
    }

    get maxPerPage() {
        return this.maxPerPageHolder;
    }

    @api
    set totalDataSize(value) {
        this.totalDataSizeHolder = value;
        this.totalPages = this.calculateTotalPages();
        this.showPaginator = this.totalDataSizeHolder !== 0;
    }
    
    get totalDataSize() {
        return this.totalDataSizeHolder;
    }
    
    previousPage() {
        this.dispatchCustomEvent('paginationchanged',this.currentPage - 1);
    }

    nextPage() {
        this.dispatchCustomEvent('paginationchanged',this.currentPage + 1);
    }

    get displayLeftButton() {
        return this.currentPageHolder > 1;
    }

    get displayRightButton() {
        return this.currentPageHolder < this.totalPages;
    }

    calculateTotalPages() {
        return Math.ceil(this.totalDataSize / this.maxPerPageHolder);
    }

    @api
    set currentPage(value) {
        this.currentPageHolder = value;
        if(this.totalDataSize === undefined) {
            this.showPaginator = false;
        }
    }

    get currentPage() {
        return this.currentPageHolder;
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
import { LightningElement,api,track } from 'lwc';
export default class PaginationDataTable extends LightningElement {
    @api sortedDirection;
    @api sortedBy;
    @api headers;
    @api tableTitle;
    @api iconName;
    @track
    tableContents;
    @api maxPerPage;
    @api titleClass;
    @api disableDefaultSortHandling = false;
    @api customId;
    @api showPageInput;
    @api pagePlaceholder;

    enableHeaderHolder=true;
    currentPageHolder=1;
    totalDataSize;
    completeListHolder;

    @api 
    set currentPage(value){
        var firstIndex;
        var lastIndex;
        this.currentPageHolder = value;

        firstIndex = ((this.currentPageHolder - 1) * (this.maxPerPage));
        lastIndex = (firstIndex + (this.maxPerPage));
        if(this.completeList !== undefined){
            this.tableContents = this.completeList.slice(firstIndex,lastIndex);
        }
    }
    get currentPage(){
        return this.currentPageHolder;
    }
    @api
    set completeList(value){
        if(typeof value ==='string'){
            this.completeListHolder = JSON.parse(value);
        }else{
            this.completeListHolder = value;
        }
        if(this.completeListHolder !== undefined){
            this.totalDataSize = this.completeListHolder.length;
        }
        this.currentPage = this.currentPageHolder;
    }
    get completeList(){
        return this.completeListHolder;
    }

    @api
    set enableHeader(value){
        this.enableHeaderHolder = value;
    }
    get enableHeader(){
        return this.enableHeaderHolder;
    }

    handleSort(event){
        if(this.disableDefaultSortHandling){
            this.dispatchCustomEvent('sort',event.detail);
        }
    }
    handlePagination(event){
            this.currentPage = event.detail;
            this.dispatchCustomEvent('paginationchanged', event.detail);
    }

    dispatchCustomEvent(eventName, eventDetails) {
        const customEvent = new CustomEvent(eventName, 
            {
                detail: eventDetails
            });
        this.dispatchEvent(customEvent);
    }


   
}
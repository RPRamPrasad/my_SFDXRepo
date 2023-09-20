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
    @api currentPage;
    @api completeList;
    @api enableHeader;
    @api showPageInput;
    @api pagePlaceholder;
}
/**
 * Created by Team Kraken 03/05/21
 * Example implementation:
 * 
 * <c-list-picker-modal title="Select an Account" list={accountList} page-size="20" onitemclick={onAccountSelect}
            onclose={onCloseModal}>
        </c-list-picker-modal>
 * 
 */

import { LightningElement, api } from 'lwc';

export default class ListPickerModal extends LightningElement {

    @api title;
    @api list;
    @api pageSize;
    @api sortedList;

    isLoading = false;

    activePage;
    paginatedList;

    get showPaginator() {
        return this.sortedList.length > this.pageSize;
    }

    connectedCallback() {
        this.sortedList = this.sortList(this.list);
        this.setActivePage(1);
    }

    sortList(list) {
        return JSON.parse(JSON.stringify(list)).sort(function(a, b) {
            return (a.label.toUpperCase() < b.label.toUpperCase()) ? -1 : 1; 
        });
    }

    setActivePage(pageNumber) {
        this.activePage = pageNumber;
        this.getActivePageData();
    }

    handlePageChange(event) {
        this.setActivePage(event.detail);
    }

    getActivePageData = () => {
        // Get our current position in the list
        const first = (this.activePage - 1) * this.pageSize;

        // Get our last position in the list
        const last = first + this.pageSize;

        this.paginatedList = this.sortedList.slice(first, last);
    }

    onItemClicked(event) {
        const itemClick = new CustomEvent(
            'itemclick', { detail: event.currentTarget.dataset.id });
        this.dispatchEvent(itemClick);
    }

    onCloseClick() {
        const closeEvent = new CustomEvent(
            'close', {});
        this.dispatchEvent(closeEvent);
    }
}
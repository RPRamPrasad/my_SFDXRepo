import LightningDatatable from 'lightning/datatable';
import {api} from 'lwc';

const DEFAULT_SORT_DIRECTION = 'asc';
export default class SortedDatatable extends LightningDatatable {

    @api disableDefaultSortHandling = false;

    connectedCallback() {
        super.connectedCallback();

        if(!this.disableDefaultSortHandling && this.data) {
            this.addEventListener('sort', this.handleDefaultSort);
        }
    }

    handleDefaultSort = (event) => {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;

        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        
        let sortedData = JSON.parse(JSON.stringify(this.data));
        sortedData = this.doTheSort(sortedData,fieldName);

        if(sortDirection !== DEFAULT_SORT_DIRECTION){
            sortedData.reverse();
        }

        this.data = sortedData;
    };

    doTheSort(object, fieldName){
        object.sort(function(a,b){
            if(a[fieldName] === undefined){
                return 1;
            } 
            if(b[fieldName] === undefined){
                return -1;
            }
            if(typeof a[fieldName] === 'string'){
                return a[fieldName].localeCompare(b[fieldName]);
            }
            if(typeof a[fieldName] === 'number'){
                return a[fieldName] - b[fieldName];
            }

            //sorting for booleans
            return b[fieldName] - a[fieldName];
       
            
        });
        return object;
    }
  
}
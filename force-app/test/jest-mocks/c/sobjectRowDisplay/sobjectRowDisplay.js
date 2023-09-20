import { LightningElement, api } from 'lwc';
import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjectsNotCacheable';
import { NavigationMixin } from 'lightning/navigation';

/*
Field Data Example

[
    {
        fieldName: 'Campaign.Name', *field api name
        fieldLabel: 'Campaign', *label for field
        hyperlinkToSobjectFieldName: CampaignId *Optional. The field value will hyperlink to the value of this field. 
    }
]

*/


export default class SobjectRowDisplay extends NavigationMixin(LightningElement) {

    @api
    title
    @api
    titleIconName
    @api
    titleIconSize = 'medium'
    @api
    sobjectName
    @api
    fieldData
    @api
    numberOfRows
    @api
    viewAllNavigationPayload
    @api
    noRowsFoundMessage

    queryfilterCriteriaHolder;
    rowsFound;
    noRowsFoundDisplay = 'loading...'
    displayData;
    sobjects;
    showSpinner = true;

    @api
    get queryFilterCriteria() {
        return this.queryFilterCriteriaHolder;
    }
    set queryFilterCriteria(value) {
        this.queryFilterCriteriaHolder = value;

        retrieveSObjects({ request: this.buildSObjectRequest() }).then((result) => {
            this.sobjects = result.sobjects;
            if (result.sobjects.length > 0) {
                this.rowsFound = true;
            } else {
                this.noRowsFoundDisplay = this.noRowsFoundMessage;
            }
            this.showSpinner = false;
            this.createDisplayData();
        });

    }
    get displayViewAll() {
        return this.viewAllNavigationPayload !== undefined;
    }
    buildSObjectRequest() {
        return {
            sobjectName: this.sobjectName,
            fieldNames: this.getFieldApiNames(),
            filterCriteriaIn: this.queryFilterCriteria,
            queryLimit: this.numberOfRows
        }
    }
    getFieldApiNames() {
        var fieldApiNames = [];
        this.fieldData.forEach(function (field) {
            fieldApiNames.push(field.fieldName);
            if (field.hyperlinkToSobjectFieldName !== undefined) {
                fieldApiNames.push(field.hyperlinkToSobjectFieldName);
            }
        });
        return fieldApiNames;
    }
    createDisplayData() {
        var displayData = [];
        var holder;
        var counter = 0;
        this.sobjects.forEach(function (sobject) {
            holder = [];
            this.fieldData.forEach((field) => {
                holder.push({
                    fieldLabel: field.fieldLabel,
                    fieldValue: this.captureNestedValue(sobject, this.captureTextInParintheses(field.fieldName)),
                    linkId: sobject[field.hyperlinkToSobjectFieldName],
                    id: counter++
                });
            });
            displayData.push({ holder: holder, id: counter });
        }.bind(this));
        this.displayData = displayData;
    }
    handleViewAll() {
        this[NavigationMixin.Navigate](this.viewAllNavigationPayload);
    }
    captureTextInParintheses(value) {
        var matched = value.match(/\(([^)]+)\)/);
        if (matched !== null) {
            return matched[1];
        }
        return value;
    } 
    captureNestedValue(item, key) {
        var tempItem, tempKey, remainingKey;
        if (item === undefined) {
            return '';
        }else if(!key.includes('.')){
            return item[key];
        }
        tempKey = key.substr(0, key.indexOf('.'));
        remainingKey = key.substr(key.indexOf('.') + 1);
        tempItem = item[tempKey];
        return this.captureNestedValue(tempItem, remainingKey);
    }
}
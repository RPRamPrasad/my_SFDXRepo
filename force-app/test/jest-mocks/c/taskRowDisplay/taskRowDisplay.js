import { LightningElement, api } from 'lwc';
export default class TaskRowDisplay extends LightningElement {


    @api
    accountId;

    @api
    get numberOfRows() {
        return this.numberOfRowsHolder;
    }
    set numberOfRows(value) {
        this.numberOfRowsHolder = value;
        this.setValues();
        
    }
    
    setValues(){
        this.title = 'Tasks';
        this.titleIconName = 'standard:task';
        this.titleIconSize ='large';
        this.sobjectName = 'Task';
        this.fieldData = [{ fieldName: 'Subject', fieldLabel: 'Subject', hyperlinkToSobjectFieldName: 'Id' },
        { fieldName: 'AssignedTo__r.Name', fieldLabel: 'Assigned To'},
        { fieldName: 'Status', fieldLabel: 'Status' },
        { fieldName: 'FORMAT(ActivityDate)', fieldLabel: 'Due Date' },
        { fieldName: 'Priority', fieldLabel: 'Priority' }
        ];

        this.viewAllNavigationPayload = 

        {
            type: 'standard__webPage',
            attributes: {
                url: '/runtime_sales_activities/activityViewAll.app?parentRecordId=' + this.accountId
            }
        }
    
    ;
        this.noRowsFoundMessage = 'No tasks were found';

        this.queryFilterCriteria = [{
            enable: true,
            filterFieldName: 'WhatId',
            queryNullValues: false,
            filterValues: [this.accountId],
            filterType: 'LIST_OF_STRING'
        }];
    }

}
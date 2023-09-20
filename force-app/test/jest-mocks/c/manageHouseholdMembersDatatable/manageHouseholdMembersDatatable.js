/*
 *  @Author             : Targaryen
 * @File Name          : manageHouseholdMembersDatatable.js
 * @Description        : Common JS for all custom data type HTML templates, Contains 
 *                       logic to define custom data type and link with html template.
 * 
**/
import LightningDatatable from 'lightning/datatable';
import householdRolePicklist from './householdRolePicklist.html';
import householdPrimaryMemberToggle from './householdPrimaryMemberToggle.html';

export default class CustomLightningDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: householdRolePicklist,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        },
        toggle: {
            template: householdPrimaryMemberToggle,
            standardCellLayout: true,
            typeAttributes: ['label', 'type', 'disabled', 'checked', 'context', 'activeMessage', 'inActiveMessage','variant' ,'name'],
        }
    };
}
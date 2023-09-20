import { LightningElement, api } from 'lwc';
import 'c/checkBrowser';


export default class fuzzySearch extends LightningElement {
   
    @api
    search = jest.fn();

}
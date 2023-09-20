import { LightningElement,api } from 'lwc';
const SOBJECT_LINK_URL = '/one/one.app#/sObject/';

export default class SobjectLinkAndHover extends LightningElement {
    @api linkText;
    @api enableAccountAlertHover = false; 
    @api target;
    
    @api campaignId;
    @api campaignMemberId;
    @api accountId;
    sObjectLink;
    displayAccountAlertHover;
    accountAlertCss;
    displayHoverAboveTextHolder = false;
    constructor(){
        super();
        this.accountAlertCss = 'width: 400px;transform: translate(calc(175px),calc(-50% - 17px)); position:absolute; padding: 0% 2% 0% 2%;'
    }
    @api
    get accountAlertPosition(){
        return this.accountAlertPositionHolder;
    }
    set accountAlertPosition(value){
        var css = 'height:380px;width: 400px; position:absolute; padding: 0% 2% 0% 2%;';
        this.accountAlertPositionHolder = value;
        if(value === 'TOP'){
            css = css.concat('transform: translateY(calc(-100% - 17px));');
        }else if(value === 'RIGHT'){
            css = css.concat('transform: translate(calc(175px),calc(-50% + 50px));');
        }else if(value ==='BOTTOM'){
            css = css.concat('transform: translateX(20px));');
        }else if(value ==='RIGHT_UP'){
            css = css.concat('transform: translate(calc(175px),calc(-62%));');
        }
        this.accountAlertCss = css;
    }
    @api
    set sobjectId(value){
        this.sobjectIdHolder = value;
        this.sObjectLink = SOBJECT_LINK_URL + this.sobjectIdHolder;
    }
    get sobjectId(){
        return this.sobjectIdHolder;
    }

     displayAccountAlerts(){
        if(this.enableAccountAlertHover === true){
            this.displayAccountAlertHover = true;
        }
     }
     closeAccountAlerts(){
        if(this.enableAccountAlertHover === true){
            this.displayAccountAlertHover = false;
        }
     }

}
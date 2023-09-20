import { LightningElement, api } from 'lwc';

const heightMultiplier = 40;
const maxNumberOfDropdownItems = 3;
const baseUpwardTransform = -46;
const lobToMask = ['BANK','B','HEALTH', 'H', 'MUTUAL FUND' , 'MUTUAL FUNDS' , 'MF', 'M'];
const lobBank = ['BANK','B'];
export default class CampaignMemberPolicyNumberDisplay extends LightningElement {


    dropdownToggled;
    displayDropdown;
    firstPolicyId
    numberOfPolicies
    policyDisplayData
    url

    dropdownCss;
    
    @api
    position;
    @api
    get policyData() {
        return this.policyDataHolder;
    }
    
    set policyData(value) {
        var policy;
        var policyDataTemp;
        try {
            value = JSON.parse(value);
            this.policyDataHolder = value;
            policyDataTemp = value.policyData;
            this.policyDisplayData = [];
            
            for (policy of policyDataTemp) {
                let policyNumberDisplay = policy.policyNumber;
                if(policy.policyNumberDisplay){
                    policyNumberDisplay = this.getPolicyNumberMasked(policy.lob,policy.policyNumberDisplay);
                } else{
                    policyNumberDisplay = this.getCreditCardPolicyMasked(policy.lob, policyNumberDisplay);
                }
                if ( policyNumberDisplay !== undefined && policy.lob !== undefined  && policy.description !== undefined ) {
                    this.policyDisplayData.push({ id: policy.policyNumber, label: policy.lob + ' - ' + policyNumberDisplay +' - ',url:"https://google.com" ,description:policy.description, lob: policy.lob, policyNumber:policyNumberDisplay});        
                }
            }
            
            if (this.policyDisplayData.length>0) {
                this.url="https://google.com"
                this.numberOfPolicies = this.policyDisplayData.length;
                this.firstPolicyId = this.policyDisplayData[0].lob + ' - ' + this.policyDisplayData[0].policyNumber + ' (' + this.numberOfPolicies + ')';  
            }

            this.displayDropdown = true;
            this.dropdownCss = this.getDropdownCss(this.numberOfPolicies)
        } catch (error) {
            this.policyDataHolder = undefined;
            this.firstPolicyId = undefined;
            this.policyDisplayData = undefined;

        }
       
    }

    getDropdownCss(numberOfItems){
        var numberOfItemsWithCeiling
        var dropdownCss
        var transform;
        if(numberOfItems > maxNumberOfDropdownItems){
            numberOfItemsWithCeiling = maxNumberOfDropdownItems;
        }else{
            numberOfItemsWithCeiling = numberOfItems;
        }
        if(this.position === 'TOP'){
            transform = baseUpwardTransform - ((numberOfItemsWithCeiling - 1)*heightMultiplier);
        }else{
            transform = 25;
        }
        dropdownCss = "transform:translateY(" + transform + "px);height:" + numberOfItemsWithCeiling * heightMultiplier + "px;";
        return dropdownCss;
    }

    getPolicyNumberMasked(policyLOB, policyDisplayNumber){
        if(policyLOB && lobToMask.includes(policyLOB.toUpperCase())){
            policyDisplayNumber = this.maskpolicyNumber(policyDisplayNumber);
        }
        return policyDisplayNumber;
    }
    getCreditCardPolicyMasked(lob, policyNumberDisplay){
        if(lob && lobBank.includes(lob.toUpperCase())){ // credit card policy
            return 'XXXXXXXX XXXX'; 
        }
        return policyNumberDisplay;
    }

    maskpolicyNumber(policyDisplayNumber){
        if (policyDisplayNumber.length < 5){
            policyDisplayNumber = 'XXXXXXXX '+ policyDisplayNumber;
        } else{
            policyDisplayNumber = 'XXXXXXXX '+ policyDisplayNumber.slice(policyDisplayNumber.length - 4);
        }
        return policyDisplayNumber;
    }

    toggleDropdown() {
        if (this.dropdownToggled) {
            this.dropdownToggled = false;
        } else {
            this.dropdownToggled = true;
        }
    }
    toggleOffDropdown() {
        this.dropdownToggled = false;
    }
}
import { LightningElement, api } from 'lwc';

const COLUMNS = [
    {
        label: 'Description',
        fieldName: 'name',
        type: 'text'
    }
];

export default class PolicyDetailsPremiumAdjustments extends LightningElement {
    @api details;

    discounts;
    discountsDisplayed;
    discountColumns = COLUMNS;

    connectedCallback() {
        this.buildDiscounts();
        this.discountsDisplayed = this.discounts;
    }

    readDiscountList(discountList) {
        let gatherDiscounts = [];

        discountList
            .filter(discount => discount.pricingRuleSetDisplayName)
            .forEach(discount => {
                let discountItem = {};

                discountItem.name = discount.pricingRuleSetDisplayName;
                gatherDiscounts.push(discountItem);
            });

        return gatherDiscounts;
    }

    buildDiscounts() {
        const details = this.details;
        let discounts = [];

        if (details?.termVersion?.insurableRisk?.length && details.termVersion.insurableRisk[0].pricingRuleSet?.pricingAdjustment) {

            const discountList = details.termVersion.insurableRisk[0].pricingRuleSet.pricingAdjustment;
            discounts = this.readDiscountList(discountList);
        }

        if (details?.termVersion?.policyPricingRuleSet?.pricingAdjustment) {

            const discountList = details.termVersion.policyPricingRuleSet.pricingAdjustment;
            discounts = discounts.concat(this.readDiscountList(discountList));
        }

        this.discounts = discounts;
    }
}
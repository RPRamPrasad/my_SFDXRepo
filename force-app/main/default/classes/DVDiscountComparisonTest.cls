@isTest
public class DVDiscountComparisonTest {
    @isTest private static void discounts_match() {
        ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution mockVehicle = new ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution();
        mockVehicle.pricingAdjustment = new List<ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment>();
        ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment mockSetAdjustment = new ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment();
        mockSetAdjustment.pricingRuleSetUniqueName = 'Mock Name';
        mockSetAdjustment.pricingRuleSetAdjustmentAmount = 2.00;
        mockVehicle.pricingAdjustment.add(mockSetAdjustment);
        mockVehicle.pricingAdjustment.add(mockSetAdjustment);
        ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution compVehicle = new ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution();
        compVehicle.pricingAdjustment = new List<ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment>();
        ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment compSetAdjustment = new ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment();
        compSetAdjustment.pricingRuleSetUniqueName = 'Mock Name';
        compSetAdjustment.pricingRuleSetAdjustmentAmount = 2.00;
        compVehicle.pricingAdjustment.add(compSetAdjustment);
        compVehicle.pricingAdjustment.add(compSetAdjustment);
        
        List<Object> returnValue = DVDiscountComparison.findDiscountsRemoved(mockVehicle, compVehicle);
        System.assert(returnValue.size() == 0, returnValue);
    }
    
    @isTest private static void discounts_removed() {
        ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution mockVehicle = new ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution();
        mockVehicle.pricingAdjustment = new List<ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment>();
        ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment mockSetAdjustment = new ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment();
        mockSetAdjustment.pricingRuleSetUniqueName = 'Mock Name';
        mockSetAdjustment.pricingRuleSetAdjustmentAmount = 2.00;
        mockVehicle.pricingAdjustment.add(mockSetAdjustment);
        ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution compVehicle = new ExternalService.PolicyRetrievalAPI_PricingRuleSetExecution();
        compVehicle.pricingAdjustment = new List<ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment>();
        ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment compSetAdjustment = new ExternalService.PolicyRetrievalAPI_PricingRuleSetAdjustment();
        compSetAdjustment.pricingRuleSetUniqueName = 'Test Name';
        compSetAdjustment.pricingRuleSetAdjustmentAmount = 2.00;
        compVehicle.pricingAdjustment.add(compSetAdjustment);
        
        List<Object> returnValue = DVDiscountComparison.findDiscountsRemoved(mockVehicle, compVehicle);
        System.assert(returnValue.size() == 1, returnValue);
    }    
}
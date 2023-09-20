@IsTest
public class DVComparisonDSSHelperTest {
    @isTest
    static void dss_1() {
        ExternalService.PolicyRetrievalAPI_Vehicle mockVehicle = new ExternalService.PolicyRetrievalAPI_Vehicle();
        mockVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount = '1';
        mockVehicle.driveSafeAndSaveIndexScaleCount = '3';
        ExternalService.PolicyRetrievalAPI_Vehicle compVehicle = new ExternalService.PolicyRetrievalAPI_Vehicle();
        compVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount = '1';
        compVehicle.driveSafeAndSaveIndexScaleCount = '1';
        String returnValue = DVComparisonDSSIHelper.displayDSSIVerbiage(mockVehicle, compVehicle);
        System.assert(returnValue == 'DSS1', returnValue);
    }
    
    @isTest
    static void dss_2() {
        ExternalService.PolicyRetrievalAPI_Vehicle mockVehicle = new ExternalService.PolicyRetrievalAPI_Vehicle();
        mockVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount = '1';
        mockVehicle.driveSafeAndSaveIndexScaleCount = '3';
        ExternalService.PolicyRetrievalAPI_Vehicle compVehicle = new ExternalService.PolicyRetrievalAPI_Vehicle();
        compVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount = '3';
        compVehicle.driveSafeAndSaveIndexScaleCount = '1';
        String returnValue = DVComparisonDSSIHelper.displayDSSIVerbiage(mockVehicle, compVehicle);
        System.assert(returnValue == 'DSS2', returnValue);
    }
    
    @isTest
    static void dss_3() {
        ExternalService.PolicyRetrievalAPI_Vehicle mockVehicle = new ExternalService.PolicyRetrievalAPI_Vehicle();
        mockVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount = '1';
        mockVehicle.driveSafeAndSaveIndexScaleCount = '1';
        ExternalService.PolicyRetrievalAPI_Vehicle compVehicle = new ExternalService.PolicyRetrievalAPI_Vehicle();
        compVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount = '3';
        compVehicle.driveSafeAndSaveIndexScaleCount = '1';
        String returnValue = DVComparisonDSSIHelper.displayDSSIVerbiage(mockVehicle, compVehicle);
        System.assert(returnValue == 'DSS3', returnValue);
    }
}
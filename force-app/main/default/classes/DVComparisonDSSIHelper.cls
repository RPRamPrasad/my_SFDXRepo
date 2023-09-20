public with sharing class DVComparisonDSSIHelper {
    


    //DSSI Display based on requirement rules
    //@param initVehicle - vehicle stats we are comparing against
    //@param compVehicle - new vehicle that we are comparing
    //
    //@return DSSI Verbiage display
    public static String displayDSSIVerbiage(ExternalService.PolicyRetrievalAPI_Vehicle initVehicle,ExternalService.PolicyRetrievalAPI_Vehicle compVehicle){
        String response = '';

        Integer initDSScamc;
        Integer compDSScamc;
        Integer initDSSisc;
        Integer compDSSisc;

        if (initVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount != null && initVehicle.driveSafeAndSaveIndexScaleCount != 'INIT') {
            initDSScamc = Integer.valueOf(initVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount.replaceAll(',','')); 
            compDSScamc = Integer.valueOf(compVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount.replaceAll(',',''));
            
            //for driveSafeAndSaveIndexScaleCount
            initDSSisc = Integer.valueOf(initVehicle.driveSafeAndSaveIndexScaleCount.replaceAll(',','')); 
            compDSSisc = Integer.valueOf(compVehicle.driveSafeAndSaveIndexScaleCount.replaceAll(',',''));
            //tempList.add('Drive Safe & Save ™ Discount');
            //Need to remove this section after testing
                
            //Need to remove this section after testing
            if (initDSScamc == compDSScamc && compDSSisc < initDSSisc) {
                response = 'DSS1';
                
            } else if (initDSScamc < compDSScamc && compDSSisc < initDSSisc) {
                response = 'DSS2';
                
            } else if (initDSScamc < compDSScamc && compDSSisc == initDSSisc) {
                response = 'DSS3';
                
            }       
        }
        return response;
    }

}
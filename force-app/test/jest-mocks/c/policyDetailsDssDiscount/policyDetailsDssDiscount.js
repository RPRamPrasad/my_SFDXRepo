import { LightningElement, api } from 'lwc';


export default class PolicyDetailsDssDiscount extends LightningElement {

    @api details;

    isDssVisible = false;
    dssDiscountVisible = false;
    dssOptionVisibility = false;
    dssSetupVisibility = false;
    dssMileageVisibility = false;
    dssOdometerVisibility = false;
    dssEnrollmentVisibility = false; // if enrollment data is available and can be displayed, used in isEnrollmentVisible to determine if section should be displayed

    dssDiscountAmount;
    dssSetupText;
    productOption;
    dssEnrollmentText;
    calcAnnualMileageValue;
    calcAnnualMileageHelpText;
    dssEnrollmentHelpText;

    odometerColumns = [
        { label: 'Date', fieldName: 'date', type: 'text' },
        { label: 'Reading', fieldName: 'reading', type: 'text' },
        { label: 'Source', fieldName: 'source', type: 'text' },
        { label: 'VIN', fieldName: 'vin', type: 'text' },
    ];

    odometersDisplayed = [];

    connectedCallback() {
        this.initDssSection();

        if (this.dssDiscountVisible || this.dssSetupVisibility || this.dssMileageVisibility 
            || this.dssOdometerVisibility || this.dssOptionVisibility){

                this.isDssVisible = true;
        }
    }

    isFloat(n) {
        return Number(n) === n && n % 1 !== 0;
    }

    compareDate(a,b){
        if (new Date(a.odometerReadingMonthYearDate) > new Date(b.odometerReadingMonthYearDate)){
            return -1;
        }
        if (new Date(a.odometerReadingMonthYearDate) < new Date(b.odometerReadingMonthYearDate)){
            return 1;
        }
        return 0;
    }

    formatDate(date,delimiter='/') { // Formats dates from YYYY-MM-DD to MM/DD/YYYY
        let [year, month, day] = date.split('-');

        return [month, day, year].join(delimiter);
    }

    decodeProductOption(option) {
        let decodedOption;
        switch(option){
            case '01':
                decodedOption = 'OnStar';
                break;
            case '09': 
                decodedOption = 'Mobile';
                break;
            case '11':
            case '12':
                decodedOption = 'Connected Car';
                break;
            default:
                decodedOption = 'N/A';
        }
        return decodedOption
    }

    decodeOdometerSourceCode(option) {
        let decodedOption;
        switch(option){
            case 1:
                decodedOption = 'OnStar';
                break;
            case 2: 
                decodedOption = 'Carfax';
                break;
            case 3:
                decodedOption = 'Self Report';
                break;
            case 4:
                decodedOption = 'In-Drive';
                break;
            case 5:
                decodedOption = 'Ford / Sync';
                break;
            default:
                decodedOption = 'N/A';
        }
        return decodedOption
    }

    buildAnnualMileage(vehicle) { // Validates and displays dss mileage value & help text
        if (vehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount){
            this.calcAnnualMileageValue = vehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount;
            this.dssMileageVisibility = true;

        } else if (vehicle.telematicsInitialAnnualMileageText) {
            this.calcAnnualMileageValue = vehicle.telematicsInitialAnnualMileageText;
            this.calcAnnualMileageHelpText = vehicle.telematicsInitialAnnualMileageText === 'No Mileage' ? 'The customer has not reported odometer readings' : 'The customer is still receiving the initial participation discount and annual mileage has not yet been calculated';
            this.dssMileageVisibility = true;
        }
    }

    buildSetUp(vehicle) { // Validates and displays dss registration status text
        if(vehicle?.telematicsDriveSafeAndSaveRegistrationStatusText ){
            this.dssSetupText = vehicle.telematicsDriveSafeAndSaveRegistrationStatusText;
            this.dssSetupVisibility = true;
        }
    }

    buildOdometerTable(vehicle) { // Validates and displays dss odometer related fields
        if (vehicle.odometerReading?.length) {
            const parsedReadings =  JSON.parse(JSON.stringify(vehicle.odometerReading));
            parsedReadings.sort(this.compareDate)
                        .filter(reading => reading.odometerReadingMonthYearDate && reading.odometerMileageCount &&
                                            reading.odometerReadingSourceCode && vehicle.physicalObjectSerialNumber)
                        .slice(0,4)
                        .forEach(reading =>{
                            this.odometersDisplayed.push({
                                date: this.formatDate(reading.odometerReadingMonthYearDate),
                                reading: reading.odometerMileageCount.toLocaleString(),
                                source: this.decodeOdometerSourceCode(reading.odometerReadingSourceCode),
                                vin: vehicle.physicalObjectSerialNumber
                            })
                        });

            if(this.odometersDisplayed.length){ this.dssOdometerVisibility = true; }
        }
    }
    
    buildProductOption(vehicle){
        this.productOption = this.decodeProductOption(vehicle.telematicsServiceProductCode);
        if (this.productOption !== 'N/A'){ this.dssOptionVisibility = true; }  
    }

    buildEnrollment(vehicle) {
        this.dssEnrollmentText = isNaN(Date.parse(vehicle.telematicsEnrollmentCompletionDate)) ? 'Incomplete' : 'Complete';
        this.dssEnrollmentHelpText = "To complete enrollment, customer must log into the Drive Safe & Save app, accept consent, and order a beacon or indicate they already have one.";
        this.dssEnrollmentVisibility = true;
    }

    buildDiscounts(discountList) {
        let dssDiscount = discountList
            .filter(discount => discount.pricingRuleSetUniqueName)
            .find(discount => discount.pricingRuleSetUniqueName === 'DRV_SAFE_SAVE_DISC');


        if (dssDiscount) {
            this.dssDiscountAmount = dssDiscount.pricingRuleSetAdjustmentAmount
                && (Number.isInteger(dssDiscount.pricingRuleSetAdjustmentAmount)
                    ||
                    this.isFloat(dssDiscount.pricingRuleSetAdjustmentAmount))
                ? '$' + dssDiscount.pricingRuleSetAdjustmentAmount : 'N/A';
            this.dssDiscountVisible = true;
        }
    }

    initDssSection(){
        const details = this.details;

        if (details?.termVersion?.insurableRisk[0]?.pricingRuleSet?.pricingAdjustment &&
            details.termVersion.insurableRisk[0]?.vehicle[0]
            ){

            const insurableRisk = details.termVersion.insurableRisk[0];
            const vehicle = insurableRisk.vehicle[0];
            const discountList = insurableRisk.pricingRuleSet.pricingAdjustment;


            if (details.agreSourceSystemCode === 1){                // if legacy policy
                this.buildOdometerTable(vehicle);
                this.buildAnnualMileage(vehicle);
            }
            if (details.agreSourceSystemCode === 24){               // if mod policy
                this.buildEnrollment(vehicle);
            }

            this.buildSetUp(vehicle);
            this.buildDiscounts(discountList);
            this.buildProductOption(vehicle);
        }
    }
}
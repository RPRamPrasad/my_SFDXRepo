import { getAutoInsurableRiskAddress } from 'c/policyDetailsCommonJS';

export const getVehicleStr = vehicle => {
    let stringData = '';

    if (vehicle.modelYearNumber) {
        stringData += vehicle.modelYearNumber + ' ';
    }
    if (vehicle.makeName) {
        stringData += vehicle.makeName + ' ';
    }
    if (vehicle.modelName) {
        stringData += vehicle.modelName + ' ';
    }
    if (vehicle.bodyStyleDescriptionText) {
        stringData += vehicle.bodyStyleDescriptionText;
    }

    return stringData;
}

export const getDescription = riskPrimaryUseCode => {
    let description = '';

    switch (riskPrimaryUseCode) {
        case '07':
            description = 'Other';
            break;
        case '08':
            description = 'PleasureWorkSchool';
            break;
        case '09':
            description = 'Business';
            break;
        case '10':
            description = 'Farm';
            break;
        case '11':
            description = 'Antique/Classic';
            break;
        default:
            description = 'N/A';
            break;
    }

    return description;
}

export const buildVehicleData = details => {
    let vehicleStr = 'N/A';
    let vin = 'N/A';
    let annualMiles = 'N/A';
    let garageAddress;
    let odometerReadings = [];
    let vehicleUsageDescription = 'N/A';

    if (details.termVersion && details.termVersion.insurableRisk[0]
        && details.termVersion.insurableRisk[0].vehicle && details.termVersion.insurableRisk[0].vehicle[0]) {
        const insurableRisk = details.termVersion.insurableRisk[0];
        const vehicle = insurableRisk.vehicle[0];

        garageAddress = getAutoInsurableRiskAddress(insurableRisk);
        vehicleStr = getVehicleStr(vehicle);
        vehicleUsageDescription = getDescription(insurableRisk.riskPrimaryUseCode);

        if (vehicle.physicalObjectSerialNumber) {
            vin = vehicle.physicalObjectSerialNumber;
        }
        if (vehicle.vehicleUsage && vehicle.vehicleUsage.estAnnualDistanceDrivenCount) {
            annualMiles = vehicle.vehicleUsage.estAnnualDistanceDrivenCount;
        }

        if (vehicle.odometerReading) {

            odometerReadings = [...vehicle.odometerReading];

            if (odometerReadings.length > 1) {
                odometerReadings = odometerReadings.sort((p1, p2) => { return new Date(p2.odometerReadingMonthYearDate) - new Date(p1.odometerReadingMonthYearDate) }).slice(0, 2);
            }
        }

    }

    return { vehicleStr, vin, annualMiles, garageAddress, odometerReadings, vehicleUsageDescription };
}
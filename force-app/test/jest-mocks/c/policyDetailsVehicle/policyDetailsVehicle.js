import { LightningElement, api } from 'lwc';
import { buildVehicleData, getVehicleStr } from './buildVehicleData';
import { constants } from 'c/policyDetailsCommonJS';

const { AUTO } = constants;

export default class PolicyDetailsVehicle extends LightningElement {

    @api details;
    @api lob;
    @api hasFullAccess;

    vehicle;
    vin;
    vehicleUsageDescription;
    annualMiles;
    odometerReadings;
    garageAddress;

    connectedCallback() {
        this.buildOverview(this.details);
    }

    buildOverview(policy) {
        if (this.lob === AUTO) {
            const vehicleDetails = buildVehicleData(policy);
            this.vehicle = vehicleDetails.vehicleStr;
            this.vin = vehicleDetails.vin;
            this.vehicleUsageDescription = vehicleDetails.vehicleUsageDescription;
            this.garageAddress = vehicleDetails.garageAddress;
            this.odometerReadings = vehicleDetails.odometerReadings;
            this.annualMiles = vehicleDetails.annualMiles.toString();
        }
    }

}

export {
    getVehicleStr
}
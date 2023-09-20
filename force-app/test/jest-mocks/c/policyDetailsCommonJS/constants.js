// Any update to this file should also flow into "/lwc/policyDetails/__tests__/data/constants.json"
const TRY_AGAIN_MESSAGE = 'Please refresh your browser window or contact your normal support channels for assistance.';

const OVERVIEW = 'Overview';
const COVERAGES = 'Coverages';
const DRIVERS = 'Drivers';
const ENDORSEMENTS = 'Endorsements';
const ADDITIONAL_INTERESTS = 'Additional Interests';
const DISCOUNTS_SURCHARGES = 'Premium Adjustments';
const RATING_INFO = 'Rating';
const BILLING_INFO = 'Billing';

const ADD_DRIVER = 'Add Driver';
const REPLACE_VEHICLE = 'Replace Vehicle';
const POLICY_CHANGE = 'Policy Change';
const ADD_VEHICLE = 'Add Vehicle';
const AUTO_POLICY_CHANGE = 'Auto Policy Change';
const FIRE_POLICY_CHANGE = 'Fire Policy Change';
const LIFE_POLICY_CHANGE = 'Life Policy Change';
const HEALTH_POLICY_CHANGE = 'Health Policy Change';
const TOOF_REINSTATEMENT = 'TOOF Reinstatement';
const EMAIL_AUTO_ID_CARD = 'Email Auto ID Card';
const BILLING_ONLINE_SYSTEM = 'Billing Online System (BOS)';
const CERTIFICATE_OF_INSURANCE = 'Certificate Of Insurance (COI)';
const DSS_BEACON_REORDER = 'Reorder Beacon';
const PREMIUM_CHANGE_INQUIRY = 'Premium Change Inquiry';
const AUTO_PL_POLICYNAME = ['PRIVATE PASSENGER','PRIVATE','MOTORHOME','MOTORCYCLE','UTILITY TRAILER','GOLFMOBILE','MULTIPLE VEHICLE'];
const FIRE_PL_POLICYNAME = ['HOMEOWNERS SPECIAL FORM POLICY','HOMEOWNERS POLICY','CONDOMINIUM UNITOWNERS POLICY','PERSONAL ARTICLES POLICY','PERSONAL LIABILITY UMBRELLA POLICY','PREMISES/ PERSONAL LIABILITY POLICY','MANUFACTURED HOME POLICY','BOATOWNERS POLICY','MANUFACTURED HOME SPECIAL FORM POLICY','RENTERS POLICY'];
const AUTO_BL_POLICYNAME = ['COMMERCIAL','PRIVATE PASSENGER','PRIVATE','CHURCH BUS','FLEET'];
const FIRE_BL_POLICYNAME = ['WORKERS COMPENSATION POLICY','COMMERCIAL LIABILITY UMBRELLA POLICY',

'WORKERS COMPENSATION POLICY','COMMERCIAL LIABILITY UMBRELLA POLICY','INLAND MARINE POLICY',

'APARTMENT POLICY','RELIGIOUS ORGANIZATION POLICY','CONTRACTORS POLICY','ARTISAN AND SERVICE CONTRACTOR POLICY',

'OFFICE POLICY','MEDICAL OFFICE POLICY','HOME PRODUCT SALES POLICY','COMMERCIAL',

'ANIMAL CARE SERVICES','ANIMAL CARE SERVICES POLICY','APARTMENT POLICY','AUTO SERVICES','AUTO SERVICES POLICY',

'BUSINESS - MERCANTILE / SERVICE POLICY','BUSINESS - OFFICE POLICY','BUSINESS SERVICES POLICY','BUSINESSOWNERS',

'BUSINESSOWNERS POLICY','DISTRIBUTORS','DISTRIBUTORS POLICY','DRUG STORE','DRUG STORE POLICY',

'DRY CLEANING AND LAUNDERING SERVICES','DRY CLEANING AND LAUNDERING SERVICES POLICY','FLORIST',

'FLORIST POLICY','FOOD SHOP','FOOD SHOP POLICY','GROCERY STORE','GROCERY STORE POLICY','HAIR SALON',

'DAY SPA AND BARBER','DAY SPA AND BARBER POLICY','HOME PRODUCT SALES','HOME PRODUCT SALES POLICY',

'MEDICAL OFFICE','MEDICAL OFFICE POLICY','RESTAURANT','RESTAURANT POLICY','RETAIL SALES','RETAIL SALES POLICY'];


const ADD_DRIVER_CASE = 'Added Driver';
const REPLACE_VEH_CASE = 'Replaced Vehicle';
const POLICY_CHANGE_CASE = 'Policy - Change/Request';
const ADDED_VEH_CASE = 'Added Vehicle';
const NECHO_MAIN_TOC = 'main toc';
const AGENT_STATUS_TRACKER = 'Status';
const POLICY_DOCUMENTS = 'Policy Documents';

export default {
    AUTO: 'A',
    FIRE: 'F',
    LIFE: 'L',
    HEALTH: 'H',
    BANK: 'B',
    MUTUAL_FUND: 'M',
    TERMINATED_STATUS: 'Terminated',
    OVERVIEW,
    COVERAGES,
    DRIVERS,
    ENDORSEMENTS,
    ADDITIONAL_INTERESTS,
    DISCOUNTS_SURCHARGES,
    RATING_INFO,
    BILLING_INFO,
    AUTO_CONTENT_PANES_PARTIAL_VIEW: [OVERVIEW, DRIVERS, COVERAGES, ENDORSEMENTS, ADDITIONAL_INTERESTS],
    FIRE_CONTENT_PANES_PARTIAL_VIEW: [OVERVIEW, COVERAGES, ENDORSEMENTS, ADDITIONAL_INTERESTS],
    AUTO_CONTENT_PANES_FULL_VIEW: [OVERVIEW, DRIVERS, COVERAGES, ENDORSEMENTS, ADDITIONAL_INTERESTS, DISCOUNTS_SURCHARGES, RATING_INFO, BILLING_INFO],
    FIRE_CONTENT_PANES_FULL_VIEW: [OVERVIEW, COVERAGES, ENDORSEMENTS, ADDITIONAL_INTERESTS, RATING_INFO, BILLING_INFO],
    POLICY_RETRIEVAL_ERROR: `An error has occurred retrieving policy data. ${TRY_AGAIN_MESSAGE}`,
    POLICY_DATA_CONNECTION_ERROR: `An error has occurred while connecting to the policy information system. ${TRY_AGAIN_MESSAGE}`,
    POLICY_DRIVER_RETRIEVAL_ERROR: `An error has occurred retrieving policy driver data. ${TRY_AGAIN_MESSAGE}`,
    PARTIAL_POLICY_RETRIEVAL_ERROR: `An error has occurred retrieving some data related to this policy. Policy actions may not launch properly. ${TRY_AGAIN_MESSAGE}`,
    NOT_FOUND_ERROR: `No data was found for this policy. ${TRY_AGAIN_MESSAGE}`,
    NOT_FOUND_ERROR_DRIVER: `No driver data was found for this policy. ${TRY_AGAIN_MESSAGE}`,
    POLICY_TERMINATED_WARNING: 'This policy is in a terminated status. The policy details are as of the last effective date for this policy.',
    ADJUSTED_DATE_WARNING: 'The date was adjusted to the closest known active date for this policy.',
    DVL_BY_RISK_AND_DATE: 'PolicyDetailsDVLByRiskAndDate_TP2',
    DVL_BY_RISK: 'PolicyDetailsDVLByRisk_TP2',
    DVL_BY_PO_ID: 'PolicyDetailsDVLByPoId_TP2',
    DVL_BY_LOCN_NUM: 'PolicyDetailsDVLByLocNum_TP2',
    DVL_BY_DATE: 'PolicyDetailsDVLByDate_TP2',
    DVL: 'PolicyDetailsDVL_TP2',
    DVL_DRIVER_BY_RISK: 'PolicyDriverDetailsDVLByRisk_TP2',
    AUTO_POLICY_ACTIONS: [ADD_DRIVER, REPLACE_VEHICLE, AUTO_POLICY_CHANGE, TOOF_REINSTATEMENT],
    CASE_MIGRATION_ACTIONS: [POLICY_CHANGE,ADD_VEHICLE],
    FIRE_POLICY_ACTIONS: [FIRE_POLICY_CHANGE, TOOF_REINSTATEMENT],
    ADD_DRIVER,
    REPLACE_VEHICLE,
    POLICY_CHANGE,
    ADD_VEHICLE,
    AUTO_POLICY_CHANGE,
    FIRE_POLICY_CHANGE,
    LIFE_POLICY_CHANGE,
    HEALTH_POLICY_CHANGE,
    TOOF_REINSTATEMENT,
    EMAIL_AUTO_ID_CARD,
    BILLING_ONLINE_SYSTEM,
    CERTIFICATE_OF_INSURANCE,
    DSS_BEACON_REORDER,
    LEGACY_CD: 1,
    COMMERCIAL_MOD_CD: 15,
    LIFE_MOD_CD: 23,
    PERSONAL_AUTO_MOD_CD: 24,
    PERSONAL_FIRE_MOD_CD: 26,
    HAGERTY_CD: 28,
    ADD_DRIVER_CASE,
    REPLACE_VEH_CASE,
    POLICY_CHANGE_CASE,
    ADDED_VEH_CASE,
    NECHO_MAIN_TOC,
    HDC_POLICY_TYPE: 'DC',
    FLEET: 'FLEET',
    MULTI_VEHICLE: 'MULTIPLE VEHICLE',
    PREMIUM_CHANGE_INQUIRY,
    AGENT_STATUS_TRACKER,
    POLICY_DOCUMENTS,
    AUTO_PL_POLICYNAME,
    FIRE_PL_POLICYNAME,
    AUTO_BL_POLICYNAME,
    FIRE_BL_POLICYNAME,
    STATUS_PROPOSED_AV: 'Proposed status applies to a policy not yet In Force. Some amount of processing is required before policy coverage begins.',
    STATUS_SUSPENDED_AV: 'Suspended status applies when a policy is temporarily suspended, with intention of coverage resuming in the future.'
};
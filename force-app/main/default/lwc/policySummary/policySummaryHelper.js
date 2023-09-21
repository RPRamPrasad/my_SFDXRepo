// Helper Constants
const STATUS_TERMINATED = 'Terminated';

const POLICY_TYPE_AUTO = 'Auto';
const POLICY_TYPE_FIRE = 'Fire';
const POLICY_TYPE_LIFE = 'Life';
const POLICY_TYPE_HEALTH = 'Health';


const isModPolicy = (agreSrcSysCode) => {
    switch (agreSrcSysCode) {
        case '1':
        case '3':
        case '7':
        case '8':
            return false
        default:
            return true;
    }
};

const toTitleCase = (rawStr) => {
    return rawStr.toLowerCase().replace(
        /\b\w/g,
        char => char.toUpperCase()
    );
};

const buildResultRow = (matchingPolicy, matchingRiskDescriptions) => {
    let row = {};

    if (isModPolicy(matchingPolicy.AgreSourceSysCd__c))
        row.ModInd = 'utility:check';

    row.Id = matchingPolicy.Id;
    row.LinkId = '/lightning/r/InsurancePolicy/' + matchingPolicy.Id + '/view';
    row.Name = matchingPolicy.Name;
    row.PolicyName = toTitleCase(matchingPolicy.PolicyName);
    row.MatchingRiskDescriptions = toTitleCase(matchingRiskDescriptions.slice(0, -2));
    row.Status = matchingPolicy.Status;
    row.EffectiveDate = matchingPolicy.EffectiveDate;
    row.RenewalDate = matchingPolicy.RenewalDate;

    return row;
};

const buildSumTotals = (rollupPolicies) => {
    let auto = 0;
    let fire = 0;
    let life = 0;
    let health = 0;

    // Grab Non-Terminated Policies from policies
    let nonTerminatedPolicies = rollupPolicies.filter(p => p.Status !== STATUS_TERMINATED);

    // Add to totals
    auto = nonTerminatedPolicies.filter(p => p.PolicyType === POLICY_TYPE_AUTO).length;
    fire = nonTerminatedPolicies.filter(p => p.PolicyType === POLICY_TYPE_FIRE).length;
    life = nonTerminatedPolicies.filter(p => p.PolicyType === POLICY_TYPE_LIFE).length;
    health = nonTerminatedPolicies.filter(p => p.PolicyType === POLICY_TYPE_HEALTH).length;

    // Build sum totals string
    return {
        data: `Active Policies: Auto (${auto}) Fire (${fire}) Life (${life}) Health (${health})`
    };
}

const buildTable = (policies, searchCriteria) => {

    const matchingPolicies = [];
    const searchCriteriaLower = searchCriteria.toLowerCase();

    policies.forEach(ip => {

        if (ip.InsurancePolicyAssets) {
            let matchingRiskDescriptions = "";
            ip.InsurancePolicyAssets.forEach(ipa => {

                if (
                    (ipa.AssetName && ipa.AssetName.toLowerCase().includes(searchCriteriaLower))
                    || (ipa.VIN__c && ipa.VIN__c.toLowerCase().includes(searchCriteriaLower))
                ) {
                    matchingRiskDescriptions += ipa.AssetName + ',\n';
                }
            });

            if (matchingRiskDescriptions.length > 0) {
                matchingPolicies.push(buildResultRow(ip, matchingRiskDescriptions));
            }
        }
    });

    return matchingPolicies;
}

export {
    buildSumTotals,
    buildTable
};
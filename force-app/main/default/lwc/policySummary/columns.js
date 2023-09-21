export const SEARCH_RESULT_COLUMNS = [
    {
        label: 'Mod',
        fieldName: '',
        initialWidth: 1,
        sortable: true,
        cellAttributes: {
            iconName: {
                fieldName: 'ModInd'
            },
            iconAlternativeText: 'Mod'
        },
        hideDefaultActions: "true"
    },
    {
        label: 'Policy#',
        fieldName: 'LinkId',
        type: 'url',
        initialWidth: 180,
        typeAttributes: {
            label: {
                fieldName: 'Name'
            }
        },
        hideDefaultActions: "true"
    },
    {
        label: 'Policy Description',
        fieldName: 'PolicyName',
        initialWidth: 180,
        type: 'text'
    },
    {
        label: 'Matching Risks',
        fieldName: 'MatchingRiskDescriptions',
        type: 'text'
    },
    {
        label: 'Policy Status',
        fieldName: 'Status',
        initialWidth: 150,
        type: 'text',
        hideDefaultActions: "true"
    },
    {
        label: 'Inception',
        fieldName: 'EffectiveDate',
        initialWidth: 120,
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric'
        },
        hideDefaultActions: "true"
    },
    {
        label: 'Renewal',
        fieldName: 'RenewalDate',
        initialWidth: 120,
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric'
        },
        hideDefaultActions: "true"
    }
];

export const SEARCH_RESULT_COLUMNS_NEW = [
    {
        label: 'Mod',
        fieldName: '',
        initialWidth: 1,
        sortable: true,
        cellAttributes: {
            iconName: {
                fieldName: 'ModInd'
            },
            iconAlternativeText: 'Mod'
        },
        hideDefaultActions: "true"
    },
    {
        label: 'Policy#',
        fieldName: 'LinkId',
        type: 'url',
        initialWidth: 160,
        typeAttributes: {
            label: {
                fieldName: 'Name'
            }
        },
        hideDefaultActions: "true"
    },
    {
        label: 'Policy Description',
        fieldName: 'PolicyName',
        initialWidth: 180,
        type: 'text'
    },
    {
        label: 'Matching Risks',
        fieldName: 'MatchingRiskDescriptions',
        type: 'text'
    },
    {
        label: 'Policy Status',
        fieldName: 'Status',
        initialWidth: 100,
        type: 'text',
        hideDefaultActions: "true"
    }
];
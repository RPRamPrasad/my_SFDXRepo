export const PERSONAL_ARTICLES_ITEM_SCHEDULE_COLUMNS = [
    {
        label: 'Class. Name/Cd.',
        fieldName: 'classificationNameAndCd',
        initialWidth: 150,
        type: 'text',
        wrapText: true
    },
    {
        label: 'Stated Value',
        fieldName: 'statedValueAmount',
        initialWidth: 125,
        type: 'currency',
        cellAttributes: {
            alignment: 'right'
        },
        typeAttributes: {
            currencyCode: 'USD'
        },
        
    },
    {
        label: 'Description',
        fieldName: 'descriptionText',
        wrapText: true
    }
]
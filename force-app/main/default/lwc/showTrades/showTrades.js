import { LightningElement, track, wire }    from 'lwc';
import getTrades                            from '@salesforce/apex/Controller_NewTrade.getTrades';
import { NavigationMixin }                  from 'lightning/navigation';



export default class ShowTrades extends NavigationMixin(LightningElement) {
    @track data = [];
    @track columns = [
        { label: 'Sell CCY',            type: 'name',          fieldName: 'SellCurrency__c'   },
        { label: 'Sell Amount',         type: 'number',        fieldName: 'SellAmount__c' },
        { label: 'Buy CCY',             type: 'name',          fieldName: 'BuyCurrency__c'   },
        { label: 'Buy Amount',          type: 'number',        fieldName: 'BuyAmount__c' },
        { label: 'Rate',                type: 'number',        fieldName: 'Rate__c' },
        { label: 'Date Booked',         type: 'date',          fieldName: 'DateBooked__c', 
            typeAttributes:{
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }    
        },
    ];

    connectedCallback() {
        getTrades().then(result =>{
            this.data = result;
        })
    }

    goToNewTrade() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'New_Trade'
            },
        });
    }
    
}
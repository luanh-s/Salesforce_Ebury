import { LightningElement, track }          from 'lwc';
import getCurrencyValue                     from '@salesforce/apex/Controller_NewTrade.getCurrencyValue';
import searchBuy                            from '@salesforce/apex/Controller_NewTrade.searchBuy';
import searchSell                           from '@salesforce/apex/Controller_NewTrade.searchSell';
import insertTrade                          from '@salesforce/apex/Controller_NewTrade.insertTrade';
import {ShowToastEvent}                     from 'lightning/platformShowToastEvent';
import { NavigationMixin }                  from 'lightning/navigation';


export default class NewTrade extends NavigationMixin(LightningElement) {

    // LIST OF ALL CURRENCIES IN THE WORLD.
    @track buyCurrencyOptions = [];
    @track sellCurrencyOptions = [];

    @track sellCurrency = '';
    @track buyCurrency = '';
    @track sellAmount = 1000;
    @track buyAmount = null;
    @track rate = null;

    /***  import { registerListener } from 'c/pubsub'; ***/
    connectedCallback() {
        searchBuy().then(result => {
            console.log({result});
            this.buyCurrencyOptions = result;
        });
        searchSell().then(result => {
            console.log({result});
            this.sellCurrencyOptions = result;
        });
    }
    
    @track loading = false;
    handleChangeCurr(event){

        this[event.target.name] = event.target.value;

        if (this.sellCurrency != null && this.sellCurrency != '' && this.buyCurrency != null && this.buyCurrency != '' && this.sellAmount != null && this.sellAmount != 0) {
            console.log('CALLED');
            this.loading = true;
            getCurrencyValue({
                toCurrency: this.sellCurrency,
                fromCurrency: this.buyCurrency,
                amount: this.sellAmount,
            }).then(data => {
                console.log({data});
                let dados = JSON.parse(data.result);

                this.rate = dados.info.rate;
                this.buyAmount = this.rate * this.sellAmount;
                this.loading = false;
                
            });
        }
    }

    submitForm(){
        this.loading = true;

        let params = {
            sellCurrency: this.sellCurrency,
            buyCurrency: this.buyCurrency,
            sellAmount: this.sellAmount,
            buyAmount: this.buyAmount,
            rate: this.rate,
        };

        insertTrade(params).then(result => {
            console.log({result});

            if (result.error == false && result.message == 'A new trade has been created and the Chatter message was Posted.') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: result.message,
                    variant: 'success'
                }));

                this.sellCurrency = '';
                this.buyCurrency = '';
                this.sellAmount = 1000;
                this.buyAmount = null;
                this.rate = null;

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.recordId,
                        objectApiName: 'BookedTrade__c',
                        actionName: 'view'
                    },
                });
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: result.message,
                    variant: 'error'
                }));
            }
            this.loading = false;
        });
    }

    returnToTrades() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'BookedTrades'
            },
        });
    }
}

// sfdx force:org:create -s -f config/project-scratch-def.json -a dreamhouse-org
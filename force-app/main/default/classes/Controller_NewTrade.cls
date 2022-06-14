public with sharing class Controller_NewTrade {

    @AuraEnabled
    public static List<BookedTrade__c> getTrades() {
        return [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, BuyCurrency__c, SellCurrency__c, SellAmount__c, BuyAmount__c, Rate__c, DateBooked__c FROM BookedTrade__c];
    }

    @AuraEnabled
    public static Map<String, Object> getCurrencyValue(String toCurrency, String fromCurrency, Decimal amount) {

        Map<String, Object> result = new Map<String, Object>();
        try {
            HttpRequest req = new HttpRequest();
                req.setEndpoint('https://api.apilayer.com/fixer/convert?to='+String.escapeSingleQuotes(toCurrency)+'&from='+String.escapeSingleQuotes(fromCurrency)+'&amount='+amount+'');
                req.setMethod('GET');
                req.setHeader('apikey', 'ST8Zc6OPYIQrTGnbSgVU2YeFBZ9tJAlw');
            Http http = new Http();
            HttpResponse res  = http.send(req);

                result.put('statusCode', res.getStatusCode());
                result.put('message', 'Currency Retrieved Successfully.');
                result.put('errorMessage', 'Currency Retrieved Successfully.');
                result.put('error', false);
                result.put('result', res.getBody());
                        
                // EXPECTED RESULT
                // {
                //     "date": "2018-02-22",
                //     "historical": "",
                //     "info": {
                //       "rate": 148.972231,
                //       "timestamp": 1519328414
                //     },
                //     "query": {
                //       "amount": 25,
                //       "from": "GBP",
                //       "to": "JPY"
                //     },
                //     "result": 3724.305775,
                //     "success": true
                // }

            return result;

        } catch (Exception err) {
                result.put('statusCode', null);
                result.put('error', true);
                result.put('message', 'Error Retrieving Currency.');
                result.put('errorMessage', err.getMessage());
            return result;
        }
    }

    @AuraEnabled
    public static List<Object> searchSell(){
        List<Object> pickListValuesList= new List<Object>();
        Schema.DescribeFieldResult fieldResult = BookedTrade__c.SellCurrency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            Map<String,Object> novaLinha = new Map<String,Object>();
                novaLinha.put('label', pickListVal.getLabel());
                novaLinha.put('value', pickListVal.getValue());
            pickListValuesList.add(novaLinha);
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static List<Object> searchBuy(){
        List<Object> pickListValuesList= new List<Object>();
        Schema.DescribeFieldResult fieldResult = BookedTrade__c.SellCurrency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            Map<String,Object> novaLinha = new Map<String,Object>();
                novaLinha.put('label', pickListVal.getLabel());
                novaLinha.put('value', pickListVal.getValue());
            pickListValuesList.add(novaLinha);
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static Map<String, Object> insertTrade(String sellCurrency, Decimal sellAmount, Decimal rate, String buyCurrency, Decimal buyAmount){
        Map<String, Object> result = new Map<String, Object>();

        try {
            BookedTrade__c trade = new BookedTrade__c();
                trade.BuyAmount__c = buyAmount;
                trade.BuyCurrency__c = buyCurrency;
                trade.DateBooked__c = Datetime.now();
                trade.Rate__c = rate;
                trade.SellAmount__c = sellAmount;
                trade.SellCurrency__c = sellCurrency;
            insert trade;

            String messsageBody =
            '<p>A new trade has been created with the following data:</p>';

            String messageData = 
            '<p>Sell Currency: '+trade.SellCurrency__c+'</p>'+
            '<p>Sell Amount: '+trade.SellAmount__c+'</p>'+
            '<p>Buy Currency: '+trade.BuyCurrency__c+'</p>'+
            '<p>Buy Amount: '+trade.BuyAmount__c+'</p>'+
            '<p>Rate: '+trade.Rate__c+'</p>'+
            '<p>Booked Date: '+trade.DateBooked__c.format()+'</p>'+
            '<p>Link to the trade: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+trade.Id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+trade.Id+'</a></p>';
            

            List<Group> queueGroup = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Group WHERE Type = 'Queue' AND Name = 'Trade reviewers' LIMIT 1];

            if (queueGroup.size() == 0) {
                    result.put('error', true);
                    result.put('message', 'Queue not found');
                return result;
            }

            // List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId, SystemModstamp FROM GroupMember WHERE GroupId = :queueGroup[0].Id LIMIT 1];

            FeedItem post = new FeedItem();
                post.ParentId = trade.Id;
                post.Body = messsageBody+messageData;
                post.IsRichText = true;
            insert post;

            List<CustomNotificationType > template = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notify_Trade'];

            // Set<String> idsUsers = new Set<String>();
            // for (GroupMember member : groupMembers) {
            //     idsUsers.add(member.UserOrGroupId);
            // }

            
            String messageData2 = 
            'Sell Currency: '+trade.SellCurrency__c+'\n'+
            'Sell Amount: '+trade.SellAmount__c+'\n'+
            'Buy Currency: '+trade.BuyCurrency__c+'\n'+
            'Buy Amount: '+trade.BuyAmount__c+'\n'+
            'Rate: '+trade.Rate__c+'\n'+
            'Booked Date: '+trade.DateBooked__c.format()+'';

            Messaging.CustomNotification notif = new Messaging.CustomNotification();
                // Set the contents for the delinking notification
                notif.setTitle('A new trade has been created with the following data:');
                notif.setBody(messageData2);
                
                // Set the notification type and target
                notif.setNotificationTypeId(template[0].Id);
                notif.setTargetId(post.Id);

            // Send the notification
            notif.send(new Set<String>{queueGroup[0].Id});
                result.put('message', 'A new trade has been created and the Chatter message was Posted.');
                result.put('recordId', trade.Id);
                result.put('error', false);
            return result;
        } catch (Exception e) {
            result.put('error', true);
            result.put('message', e.getMessage());
            return result;
        }
    }

}
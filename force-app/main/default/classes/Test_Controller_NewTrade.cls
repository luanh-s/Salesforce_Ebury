@isTest 
private class Test_Controller_NewTrade {

    @TestSetup
    static void makeData(){
        
        Group g1 = new Group(Name='Trade reviewers', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'BookedTrade__c');
        insert q1;

    }

    @isTest 
    public static void Test_Controller_NewTrade() {

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_NewTrade());  

            Map<String,Object> resp = Controller_NewTrade.getCurrencyValue('JPY', 'GBP', 25);
            
            Controller_NewTrade.getTrades();
            Controller_NewTrade.searchSell();
            Controller_NewTrade.searchBuy();
            
            Map<String, Object> result = Controller_NewTrade.insertTrade('JPY', 25, 1.05, 'GBP', 25);
        Test.stopTest();

        System.assertEquals(result.get('error'), false);
        System.assertEquals(result.get('message'), 'A new trade has been created and the Chatter message was Posted.');
    }
}
global class Mock_NewTrade implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"date": "2018-02-22", "historical": "", "info": {"rate": 148.972231, "timestamp": 1519328414 }, "query": {"amount": 25,"from": "GBP","to": "JPY" }, "result": 3724.305775, "success": true}');
            response.setStatusCode(200);
        return response; 
    }
}
import Foundation

let headers = [
    "x-rapidapi-key": "a8244f9b8cmshd0e275d2089f179p179e79jsnac085c65346b",
    "x-rapidapi-host": "apidojo-yahoo-finance-v1.p.rapidapi.com"
]

func fetchStockChartData(stock: String, fromP: String, toP: String, interval: String,  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    
//    print(NSString(format: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-historical-data?period1=%@&period2=%@&symbol=%@&frequency=%@&filter=history", fromP, toP, stock, interval) )
    
    let request = NSMutableURLRequest(
        url: NSURL(
            string: NSString(format: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-historical-data?period1=%@&period2=%@&symbol=%@&frequency=%@&filter=history", fromP, toP, stock, interval) as String)! as URL,
        cachePolicy: .useProtocolCachePolicy,
        timeoutInterval: 10.0
    )
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = headers

    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)

    dataTask.resume()
}

func fetchStockAnalysis(stock: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    let url = NSString(format: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-analysis?symbol=%@&region=US", stock)
    let request = NSMutableURLRequest(
        url: NSURL(string: url as String)! as URL,
        cachePolicy: .useProtocolCachePolicy,
        timeoutInterval: 10.0
    )
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = headers

    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)

    dataTask.resume()
}

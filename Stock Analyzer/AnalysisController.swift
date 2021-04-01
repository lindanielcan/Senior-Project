//
//  AnalysisController.swift
//  Stock Analyzer
//
//  Created by CAN on 2021/2/15.
//

import UIKit

class AnalysisController: UIViewController {
    
    var stockTicker: String? = nil
    
    @IBOutlet weak var regularMarketOpen: UILabel!
    @IBOutlet weak var averageDailyVolume3M: UILabel!
    @IBOutlet weak var regularMarketDayHigh: UILabel!
    @IBOutlet weak var regularMarketDayLow: UILabel!
    @IBOutlet weak var averageDailyVolume10D: UILabel!
    @IBOutlet weak var regularMarketChange: UILabel!
    @IBOutlet weak var regularMarketPreClose: UILabel!
    @IBOutlet weak var preMarketPrice: UILabel!
    @IBOutlet weak var preMarketChange: UILabel!
    @IBOutlet weak var postMarketPrice: UILabel!
    @IBOutlet weak var postMarketChange: UILabel!
    @IBOutlet weak var regularMarketPrice: UILabel!
    @IBOutlet weak var regularMarketVolume: UILabel!
    @IBOutlet weak var peRatio: UILabel!
    @IBOutlet weak var pegRatio: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var targetMedianPrice: UILabel!
    @IBOutlet weak var targetHighPrice: UILabel!
    @IBOutlet weak var ebitdaMargins: UILabel!
    @IBOutlet weak var profitMargins: UILabel!
    @IBOutlet weak var grossMargins: UILabel!
    @IBOutlet weak var operatingCashflow: UILabel!
    @IBOutlet weak var revenueGrowth: UILabel!
    @IBOutlet weak var operatingMargins: UILabel!
    @IBOutlet weak var ebitda: UILabel!
    @IBOutlet weak var recommendationKey: UILabel!
    @IBOutlet weak var grossProfit: UILabel!
    @IBOutlet weak var freeCashflow: UILabel!
    @IBOutlet weak var currentRatio: UILabel!
    @IBOutlet weak var returnOnAssets: UILabel!
    @IBOutlet weak var totalDebt: UILabel!
    @IBOutlet weak var totalCashPerShare: UILabel!
    @IBOutlet weak var revenuePerShare: UILabel!
    @IBOutlet weak var totalRevenue: UILabel!
    @IBOutlet weak var targetLowPrice: UILabel!
    @IBOutlet weak var totalCash: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.stockTicker!;
        self.loadData()
    }
    
    func loadData() {
        fetchStockAnalysis(stock: stockTicker!, completionHandler:  { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    
                    let price = json["price"] as! [String:Any]
                    let indexTrend = json["indexTrend"] as! [String:Any]
                    let financial = json["financialData"] as! [String:Any]
                    
                    DispatchQueue.main.async {
                        // Extract Price Part
                        let regularMarketOpen = (price["regularMarketOpen"] as! [String: Any])["fmt"] as? String
                        self.regularMarketOpen.text = regularMarketOpen ?? " "
                        let averageDailyVolume3M = (price["averageDailyVolume3Month"] as! [String: Any])["fmt"] as? String
                        self.averageDailyVolume3M.text = averageDailyVolume3M ?? " "
                        let regularMarketDayHigh = (price["regularMarketDayHigh"] as! [String: Any])["fmt"] as? String
                        self.regularMarketDayHigh.text = regularMarketDayHigh ?? " "
                        let averageDailyVolume10D = (price["averageDailyVolume10Day"] as! [String: Any])["fmt"] as? String
                        self.averageDailyVolume10D.text = averageDailyVolume10D ?? " "
                        let regularMarketChange = (price["regularMarketChange"] as! [String: Any])["fmt"] as? String
                        self.regularMarketChange.text = regularMarketChange ?? " "
                        let regularMarketPreviousClose = (price["regularMarketPreviousClose"] as! [String: Any])["fmt"] as? String
                        self.regularMarketPreClose.text = regularMarketPreviousClose ?? " "
                        let preMarketPrice = (price["preMarketPrice"] as! [String: Any])["fmt"] as? String
                        self.preMarketPrice.text = preMarketPrice ?? " "
                        let postMarketChange = (price["postMarketChange"] as! [String: Any])["fmt"] as? String
                        self.postMarketChange.text = postMarketChange ?? " "
                        let postMarketPrice = (price["postMarketPrice"] as! [String: Any])["fmt"] as? String
                        self.postMarketPrice.text = postMarketPrice ?? " "
                        let preMarketChange = (price["preMarketChange"] as! [String: Any])["fmt"] as? String
                        self.preMarketChange.text = preMarketChange ?? " "
                        let regularMarketDayLow = (price["regularMarketDayLow"] as! [String: Any])["fmt"] as? String
                        self.regularMarketDayLow.text = regularMarketDayLow ?? " "
                        let regularMarketPrice = (price["regularMarketPrice"] as! [String: Any])["fmt"] as? String
                        self.regularMarketPrice.text = regularMarketPrice ?? " "
                        let regularMarketVolume = (price["regularMarketVolume"] as! [String: Any])["fmt"] as? String
                        self.regularMarketVolume.text = regularMarketVolume ?? " "
                        
                        // Extract Index Trend Part
                        let peRatio = (indexTrend["peRatio"] as! [String: Any])["fmt"] as? String
                        self.peRatio.text = peRatio ?? " "
                        let pegRatio = (indexTrend["pegRatio"] as! [String: Any])["fmt"] as? String
                        self.pegRatio.text = pegRatio ?? " "
                        
                        
                        // Extract Financial Data Part
                        let ebitdaMargins = (financial["ebitdaMargins"] as! [String: Any])["fmt"] as? String
                        self.ebitdaMargins.text = ebitdaMargins ?? " "
                        
                        let profitMargins = (financial["profitMargins"] as! [String: Any])["fmt"] as? String
                        self.profitMargins.text = profitMargins ?? " "
                        
                        let grossMargins = (financial["grossMargins"] as! [String: Any])["fmt"] as? String
                        self.grossMargins.text = grossMargins ?? " "
                        
                        let operatingCashflow = (financial["operatingCashflow"] as! [String: Any])["fmt"] as? String
                        self.operatingCashflow.text = operatingCashflow ?? " "
                        
                        let revenueGrowth = (financial["revenueGrowth"] as! [String: Any])["fmt"] as? String
                        self.revenueGrowth.text = revenueGrowth ?? " "
                        
                        let operatingMargins = (financial["operatingMargins"] as! [String: Any])["fmt"] as? String
                        self.operatingMargins.text = operatingMargins ?? " "
                        
                        let ebitda = (financial["ebitda"] as! [String: Any])["fmt"] as? String
                        self.ebitda.text = ebitda ?? " "
                        
                        let targetLowPrice = (financial["targetLowPrice"] as! [String: Any])["fmt"] as? String
                        self.targetLowPrice.text = targetLowPrice ?? " "
                        
                        self.recommendationKey.text = (financial["recommendationKey"] as? String) ?? " "
                        
                        let grossProfits = (financial["grossProfits"] as! [String: Any])["fmt"] as? String
                        self.grossProfit.text = grossProfits ?? " "
                        
                        let freeCashflow = (financial["freeCashflow"] as! [String: Any])["fmt"] as? String
                        self.freeCashflow.text = freeCashflow ?? " "
                        
                        let targetMedianPrice = (financial["targetMedianPrice"] as! [String: Any])["fmt"] as? String
                        self.targetMedianPrice.text = targetMedianPrice ?? " "
                        
                        let currentPrice = (financial["currentPrice"] as! [String: Any])["fmt"] as? String
                        self.currentPrice.text = currentPrice ?? " "
                        
                        let currentRatio = (financial["currentRatio"] as! [String: Any])["fmt"] as? String
                        self.currentRatio.text = currentRatio ?? " "
                        
                        let returnOnAssets = (financial["returnOnAssets"] as! [String: Any])["fmt"] as? String
                        self.returnOnAssets.text = returnOnAssets ?? " "
                        
                        let targetHighPrice = (financial["targetHighPrice"] as! [String: Any])["fmt"] as? String
                        self.targetHighPrice.text = targetHighPrice ?? " "
                        
                        let totalDebt = (financial["totalDebt"] as! [String: Any])["fmt"] as? String
                        self.totalDebt.text = totalDebt ?? " "
                        
                        let totalCash = (financial["totalCash"] as! [String: Any])["fmt"] as? String
                        self.totalCash.text = totalCash ?? " "
                        
                        let totalRevenue = (financial["totalRevenue"] as! [String: Any])["fmt"] as? String
                        self.totalRevenue.text = totalRevenue ?? " "
                        
                        let totalCashPerShare = (financial["totalCashPerShare"] as! [String: Any])["fmt"] as? String
                        self.totalCashPerShare.text = totalCashPerShare ?? " "
                        
                        let revenuePerShare = (financial["revenuePerShare"] as! [String: Any])["fmt"] as? String
                        self.revenuePerShare.text = revenuePerShare ?? " "
                        
                        
                    }
                } catch _ as NSError {
                    showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
                }
            }
        })
    }
    
}

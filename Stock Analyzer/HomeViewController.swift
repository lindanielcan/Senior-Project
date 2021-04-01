//
//  HomeViewController.swift
//  Stock Analyzer
//
//  Created by CAN on 2021/2/08.
//

import UIKit
//import Charts
import Charts

class HomeViewController: UIViewController {
    
    var stockTicker: String? = nil
    
    @IBOutlet weak var chart: CandleStickChartView!
    
    var nowInterval = "1d"
    var endP = Int(Date().timeIntervalSince1970)
    var startP = Int(Date().timeIntervalSince1970 - 24 * 60 * 60 * 365)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    @IBAction func showAnalysis(_ sender: Any) {
        let analysisView = self.storyboard?.instantiateViewController(withIdentifier: "analysisController") as! AnalysisController
        analysisView.stockTicker = self.stockTicker!
        analysisView.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(analysisView, animated: true)
    }
    
    @IBAction func onChooseDay(_ sender: Any) {
        self.nowInterval = "1d"
        self.endP = Int(Date().timeIntervalSince1970)
        self.startP = Int(Date().timeIntervalSince1970 - 365 * 24 * 60 * 60)
        self.loadData()
    }
    
    @IBAction func onChooseMonth(_ sender: Any) {
        self.nowInterval = "1mo"
        self.endP = Int(Date().timeIntervalSince1970)
        self.startP = Int(Date().timeIntervalSince1970 - 3 * 365 * 24 * 60 * 60 )
        self.loadData()
    }
    
    @IBAction func onChooseWeek(_ sender: Any) {
        self.nowInterval = "1wk"
        self.endP = Int(Date().timeIntervalSince1970)
        self.startP = Int(Date().timeIntervalSince1970 - 2 * 365 * 24 * 60 * 60)
        self.loadData()
    }
    
    
    func loadData() {
        fetchStockChartData(stock: stockTicker!, fromP: String(self.startP), toP: String(self.endP), interval: nowInterval, completionHandler: { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    print(json)
                    //                    let chart = json["chart"] as! [String: Any]
                    let chart = json["prices"] as! [[String: Any]]
                    //                    if (chart["result"] != nil) {
                    // parse data here
                    // print(chart["result"])
                    //                        let result = (chart["result"] as! [[String:Any]])[0]
                    //                        let timestamp = result["timestamp"] as! [Double]
                    var xAxis = [String]()
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = NSTimeZone.local
                    dateFormatter.dateFormat = "YYYY/MM/dd"
                    
                    //                        for i in 0..<timestamp.count {
                    //
                    //                            let date = Date(timeIntervalSince1970: timestamp[i])
                    //                            xAxis.append(dateFormatter.string(from: date))
                    //                        }
                    // print(xAxis)
                    //                        let chartData = ((result["indicators"]  as! [String:Any]) ["quote"] as! [[String:[Any]]])[0]
                    var yAxis = [CandleChartDataEntry]()
                    var counter = 0;
                    for i in (0..<chart.count).reversed() {
                        
                        let high = chart[i]["high"] as? Double
                        if (high is NSNull || high == nil) {
                            continue
                        }
                        let low = chart[i]["low"] as! Double
                        let close = chart[i]["close"] as! Double
                        let open = chart[i]["open"] as! Double
                        let date = chart[i]["date"] as! Double
                        xAxis.append(dateFormatter.string(from: Date(timeIntervalSince1970: date)))
                        yAxis.append(CandleChartDataEntry(x: Double(counter), shadowH: high!, shadowL: low, open: open, close: close))
                        counter += 1
                    }
                    //                        print(xAxis)
                    // high, low, close, open, volume,
                    //                        let high = chartData["high"] as! [Double]
                    //                        let low = chartData["low"] as! [Double]
                    //                        let close = chartData["close"] as! [Double]
                    //                        let open = chartData["open"] as! [Double]
                    
                    //                        let yAxis = (0..<high.count).map {
                    //                            (i) -> CandleChartDataEntry in
                    //                                return CandleChartDataEntry(x: Double(i), shadowH: high[i], shadowL: low[i], open: open[i], close: close[i])
                    //                        }
                    
                    let set1 = CandleChartDataSet(entries:yAxis , label: self.stockTicker!)
                    set1.setColor(UIColor.blue)
                    set1.shadowColor = UIColor ( red: 0.5536, green: 0.5528, blue: 0.0016, alpha: 1.0 )
                    set1.shadowWidth = 0.5
                    set1.decreasingFilled = true
                    set1.increasingFilled = true
                    set1.axisDependency = .left
                    set1.drawIconsEnabled = false
                    
                    set1.decreasingColor = .red
                    set1.increasingColor = .green
                    set1.neutralColor = .blue
                    
                    
                    
                    DispatchQueue.main.async {
                        let x = self.chart.xAxis
                        x.labelPosition = XAxis.LabelPosition.bottom
                        x.valueFormatter = IndexAxisValueFormatter(values: xAxis)
                        x.drawGridLinesEnabled = false;
                        x.setLabelCount(5, force: false)
                        self.chart.borderLineWidth = 0.5
                        self.chart.data = CandleChartData(dataSet: set1)
                        if xAxis.count > 0 {
                            self.chart.setVisibleXRange(minXRange: 10, maxXRange: 15)
                            self.chart.moveViewToX(Double(xAxis.count - 1))
                        } else {
                            self.chart.xAxis.axisMinimum = 0
                            self.chart.xAxis.axisMaximum = 10
                            
                            self.chart.leftAxis.axisMinimum = 0
                            self.chart.leftAxis.axisMaximum = 10
                            self.chart.rightAxis.axisMinimum = 0
                            self.chart.rightAxis.axisMaximum = 10
                        }
                        // self.chart.setVisibleXRangeMaximum(12.0)
                    }
                    //                    } else if (chart["result"] == nil && chart["error"] != nil) {
                    //                        let errorBody = chart["error"] as! [String:String]
                    //                        showConfirmAlert(root: self, msg: errorBody["description"] ?? "Error parse yahoo finance api.")
                    //                    }   else {
                    //                        showConfirmAlert(root: self, msg: "Error parse yahoo finance api.")
                    //                    }
                } catch _ as NSError {
                    showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
                }
            }
        })
    }
    
    
    
    
}

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
    
    @IBOutlet weak var chartContainer: UIView!
    
    var chart: UIView? = nil
    var macdChart: CombinedChartView? = nil;
    
    var isNow5M = false
    var nowInterval = "1d"
    var endP = Int(Date().timeIntervalSince1970)
    var startP = Int(Date().timeIntervalSince1970 - 24 * 60 * 60 * 365)
    var isKLine = true
    var showMacd = false
    @IBOutlet weak var changeChartStyle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        if (self.showMacd) {
            if (self.chart != nil) {
                self.chart?.frame = CGRect(x: 0, y: 0, width: self.chartContainer.frame.width, height: self.chartContainer.frame.height - 160)
            }
            if (self.macdChart != nil) {
                self.macdChart?.frame = CGRect(x: 0, y: self.chartContainer.frame.height - 150, width: self.chartContainer.frame.width, height: 150)
            }
        } else {
            if (self.chart != nil) {
                self.chart?.frame = CGRect(x: 0, y: 0, width: self.chartContainer.frame.width, height: self.chartContainer.frame.height - 160)
            }
        }
    }
    
    @IBAction func onChangeChartStyle(_ sender: Any) {
        if self.isKLine {
            self.changeChartStyle.setTitle("Candle", for: UIControl.State.normal)
            self.isKLine = false
        } else {
            self.changeChartStyle.setTitle("Line", for: UIControl.State.normal)
            self.isKLine = true
        }
        if self.isNow5M {
            self.onChooseFiveMin(sender)
        } else {
            self.refreshStockChart()
        }
    }
    
    @IBAction func onChangeMACD(_ sender: Any) {
        if (self.isNow5M) {
            showConfirmAlert(root: self, msg: "MACD not supported for 5Min mode.")
            return
        }
        if (self.showMacd) {
            self.showMacd = false
            DispatchQueue.main.async {
                if self.macdChart != nil {
                    self.macdChart?.removeFromSuperview()
                }
            }
        } else {
            self.showMacd = true
            self.loadMacd()
        }
    }
    
    func loadMacd() {
        let chart = CombinedChartView(frame: CGRect(x: 0, y:  430, width: 360, height: 150))
        DispatchQueue.main.async {
            if self.macdChart != nil {
                self.macdChart?.removeFromSuperview()
            }
            
            self.macdChart = chart
            self.chartContainer.addSubview(self.macdChart!)
        }
        
        var wrapTime = "";
        if (self.nowInterval == "1d") {
            wrapTime = "1day"
        } else if (self.nowInterval == "1wk") {
            wrapTime = "1week"
        } else {
            wrapTime = "1month"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let startP  = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.startP)))
        let endP = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.endP)))
        
        print(startP, endP)
        fetchMACD(stock: self.stockTicker!, fromP: startP, toP: endP, interval: wrapTime, completionHandler: { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let status = json["status"] as! String
                    if status != "ok" {
                        showConfirmAlert(root: self, msg: "No stock data.")
                    }
                    
                    var xVals = [String]()
                    var macdVals : [ChartDataEntry] = [ChartDataEntry]()
                    var macdSiVals : [ChartDataEntry] = [ChartDataEntry]()
                    var histVals : [BarChartDataEntry] = [BarChartDataEntry]()
                    
                    let d = json["values"] as! [[String: String]]
                    
                    for i in (0..<d.count).reversed() {
                        let v = d[i]
                        let time = v["datetime"]
                        let macd = Double(v["macd"]!) // blue line
                        let macd_signal = Double(v["macd_signal"]!) // red line
                        let macd_hist = Double(v["macd_hist"]!) // grey hist
                        
                        
                        xVals.append(String(time!.suffix(from: time!.index(time!.firstIndex(of: "-")!, offsetBy: 1))))
                        macdVals.append(ChartDataEntry(x: Double(d.count - i - 1), y: macd!))
                        macdSiVals.append(ChartDataEntry(x: Double(d.count - i - 1), y: macd_signal!))
                        histVals.append(BarChartDataEntry(x: Double(d.count - i - 1), y: macd_hist!))
                    }
                    
                    DispatchQueue.main.async {
                        let data = LineChartData()
                        let set1 = LineChartDataSet(entries:macdVals , label: "macd")
                        set1.setColor(UIColor.blue)
                        let set2 = LineChartDataSet(entries:macdSiVals , label: "signal")
                        set2.setColor(UIColor.red)
                        set1.circleRadius = 1.0
                        set2.circleRadius = 1.0
                        data.addDataSet(set1)
                        data.addDataSet(set2)
                        
                        let barData = BarChartData()
                        let set3 = BarChartDataSet(entries: histVals, label: "hist")
                        set3.colors = [UIColor.gray]
                        barData.addDataSet(set3)
                        let combine: CombinedChartData = CombinedChartData()
                        combine.barData = barData
                        combine.lineData = data
                        chart.data = combine
                        
                        
                        let x = chart.xAxis
                        x.labelPosition = XAxis.LabelPosition.bottom
                        x.valueFormatter = IndexAxisValueFormatter(values: xVals)
                        x.drawGridLinesEnabled = false;
                        x.setLabelCount(5, force: false)
                        chart.borderLineWidth = 0.5
                        
                        if xVals.count > 0 {
                            chart.setVisibleXRangeMaximum(14)
                            chart.autoScaleMinMaxEnabled = true
                            
                            chart.moveViewToX(Double(xVals.count - 1))
                        } else {
                            chart.xAxis.axisMinimum = 0
                            chart.xAxis.axisMaximum = 10
                            
                            chart.leftAxis.axisMinimum = 0
                            chart.leftAxis.axisMaximum = 10
                            chart.rightAxis.axisMinimum = 0
                            chart.rightAxis.axisMaximum = 10
                        }
                    }
                    
                } catch _ as NSError {
                    showConfirmAlert(root: self, msg: "Error access finance api.")
                }
            }
        })
        
    }
    
    
    @IBAction func onChooseFiveMin(_ sender: Any) {
        self.isNow5M = true
        let chartView: BarLineChartViewBase
        if self.isKLine {
             chartView = CandleStickChartView(frame: CGRect(x: 0, y: 0, width: 360, height: 420))
        } else {
            chartView = LineChartView(frame: CGRect(x: 0, y: 0, width: 360, height: 420))
        }
        
        
        DispatchQueue.main.async {
            if self.chart != nil {
                self.chart?.removeFromSuperview()
            }
            if self.macdChart != nil {
                self.macdChart?.removeFromSuperview()
            }
            self.chart = chartView
            self.chartContainer.addSubview(chartView)
        }
        fetchRealtime(stock: self.stockTicker!, completionHandler: { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let chart = json["chart"] as! [String: Any]
     

                    if !(chart["error"]! is NSNull) {
                        showConfirmAlert(root: self, msg: "No stock data.")
                        return
                    }
                    let result = (chart["result"] as! [[String: Any]])[0]
                    let ts = result["timestamp"] as! [Int]
                    let indicator = result["indicators"] as! [String: Any]
                    let quote = (indicator["quote"] as! [[String: Any]])[0] as! [String: Any]
                    print("xxx")
                    print(quote)
                    print("aaa")
                    let lowA = quote["low"] as! [Double?]
                    let highA = quote["high"] as! [Double?]
                    let closeA = quote["close"] as! [Double?]
                    let openA = quote["open"]as! [Double?]
            
                    var xAxis = [String]()
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = NSTimeZone.local
                    dateFormatter.dateFormat = "HH:mm"
                    
                    
                    var lowLine = [ChartDataEntry]()
                    var highLine = [ChartDataEntry]()
                    var openLine = [ChartDataEntry]()
                    var closeLine = [ChartDataEntry]()
                    var candleData = [CandleChartDataEntry]()
                    
                    var counter = 0;
                    if highA != nil {
                        for i in (0..<highA.count) {
                            let high = highA[i] ?? 0
                            let low = lowA[i] ?? 0
                            let close = closeA[i] ?? 0
                            let open = openA[i] ?? 0
                            let date = ts[i] ?? 0
                            xAxis.append(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date))))
                            lowLine.append(ChartDataEntry(x: Double(counter), y: low))
                            highLine.append(ChartDataEntry(x: Double(counter), y: high))
                            openLine.append(ChartDataEntry(x: Double(counter), y: open))
                            closeLine.append(ChartDataEntry(x: Double(counter), y: close))
                            
                            candleData.append(CandleChartDataEntry(x: Double(counter), shadowH: high, shadowL: low, open: open, close: close))
                            counter += 1
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if self.isKLine {
                            let set1 = CandleChartDataSet(entries:candleData , label: self.stockTicker!)
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
                            
                            let x = chartView.xAxis
                            x.labelPosition = XAxis.LabelPosition.bottom
                            x.valueFormatter = IndexAxisValueFormatter(values: xAxis)
                            x.drawGridLinesEnabled = false;
                            x.setLabelCount(5, force: false)
                            chartView.borderLineWidth = 0.5
                            chartView.autoScaleMinMaxEnabled = true
                            chartView.data = CandleChartData(dataSet: set1)
                            if xAxis.count > 0 {
                                chartView.autoScaleMinMaxEnabled = true
                                chartView.setVisibleXRange(minXRange: 14, maxXRange: 14)
                                chartView.moveViewToX(Double(xAxis.count - 1))
                            } else {
                            }
                        } else {
                            let data = LineChartData()
                            let set1 = LineChartDataSet(entries:lowLine , label: self.stockTicker! + " Low")
                            set1.setColor(UIColor.red)
                            let set2 = LineChartDataSet(entries:highLine , label: self.stockTicker! + " High")
                            set2.setColor(UIColor.green)
                        
                            set1.circleRadius = 1.0
                            set2.circleRadius = 1.0
                            data.addDataSet(set1)
                            data.addDataSet(set2)

                            chartView.data = data
                        
                            let x = chartView.xAxis
                            x.labelPosition = XAxis.LabelPosition.bottom
                            x.valueFormatter = IndexAxisValueFormatter(values: xAxis)
                            
                            if xAxis.count > 0 {
                                chartView.setVisibleXRangeMaximum(14)
                                chartView.autoScaleMinMaxEnabled=true
                                chartView.moveViewToX(Double(xAxis.count - 1))
                            } else {
                            }
                        }
                    }
                } catch _ as NSError {
                    showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
                }
            }
        })
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
        self.refreshStockChart()
    }
    
    @IBAction func onChooseMonth(_ sender: Any) {
        self.nowInterval = "1mo"
        self.endP = Int(Date().timeIntervalSince1970)
        self.startP = Int(Date().timeIntervalSince1970 - 3 * 365 * 24 * 60 * 60 )
        self.refreshStockChart()
    }
    
    @IBAction func onChooseWeek(_ sender: Any) {
        self.nowInterval = "1wk"
        self.endP = Int(Date().timeIntervalSince1970)
        self.startP = Int(Date().timeIntervalSince1970 - 2 * 365 * 24 * 60 * 60)
        self.refreshStockChart()
    }
    
    func refreshStockChart() {
        self.isNow5M = false
        if self.isKLine {
            self.loadData()
        } else {
            self.loadDataLinear()
        }
        if (self.showMacd) {
            self.loadMacd()
        }
    }
    
    func loadDataLinear() {
        let chartView = LineChartView(frame: CGRect(x: 0, y: 0, width: 360, height: 420))
        
        DispatchQueue.main.async {
            if self.chart != nil {
                self.chart?.removeFromSuperview()
            }
            self.chart = chartView
            self.chartContainer.addSubview(chartView)
        }
        
        fetchStockChartData(stock: stockTicker!, fromP: String(self.startP), toP: String(self.endP), interval: nowInterval, completionHandler: { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let chart = json["prices"] as! [[String: Any]]
                    var xAxis = [String]()
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = NSTimeZone.local
                    dateFormatter.dateFormat = "MM/dd"
                    
                    var lowLine = [ChartDataEntry]()
                    var highLine = [ChartDataEntry]()
                    var openLine = [ChartDataEntry]()
                    var closeLine = [ChartDataEntry]()
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
                        lowLine.append(ChartDataEntry(x: Double(counter), y: low))
                        highLine.append(ChartDataEntry(x: Double(counter), y: high!))
                        openLine.append(ChartDataEntry(x: Double(counter), y: open))
                        closeLine.append(ChartDataEntry(x: Double(counter), y: close))
                        counter += 1
                    }
                    
                    
                    
                    DispatchQueue.main.async {
                        let data = LineChartData()
                        let set1 = LineChartDataSet(entries:lowLine , label: self.stockTicker! + " Low")
                        set1.setColor(UIColor.red)
                        
                        
                        let set2 = LineChartDataSet(entries:highLine , label: self.stockTicker! + " High")
                        set2.setColor(UIColor.green)
                        
                        let set3 = LineChartDataSet(entries:openLine , label: self.stockTicker! + " Open")
                        set3.setColor(UIColor.blue)
                        
                        let set4 = LineChartDataSet(entries:closeLine , label: self.stockTicker! + " Close")
                        set4.setColor(UIColor.gray)
                        
                        set1.circleRadius = 1.0
                        set2.circleRadius = 1.0
                        set3.circleRadius = 1.0
                        set4.circleRadius = 1.0
                        
                        data.addDataSet(set1)
                        data.addDataSet(set2)
                        data.addDataSet(set3)
                        data.addDataSet(set4)
                        
                        
                        chartView.data = data
                        let x = chartView.xAxis
                        x.labelPosition = XAxis.LabelPosition.bottom
                        x.valueFormatter = IndexAxisValueFormatter(values: xAxis)
                        
                        if xAxis.count > 0 {
                            chartView.setVisibleXRangeMaximum(14)
                            chartView.autoScaleMinMaxEnabled = true
                            chartView.setScaleEnabled(true)
                            chartView.moveViewToX(Double(xAxis.count - 1))
                        } else {
                            chartView.xAxis.axisMinimum = 0
                            chartView.xAxis.axisMaximum = 10
                            
                            chartView.leftAxis.axisMinimum = 0
                            chartView.leftAxis.axisMaximum = 10
                            chartView.rightAxis.axisMinimum = 0
                            chartView.rightAxis.axisMaximum = 10
                        }
                    }
                } catch _ as NSError {
                    showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
                }
            }
        })
    }
    
    func loadData() {
        let chartView = CandleStickChartView(frame: CGRect(x: 0, y: 0, width: 360, height: 420))
        DispatchQueue.main.async {
            if self.chart != nil {
                self.chart?.removeFromSuperview()
            }
            self.chart = chartView
            self.chartContainer.addSubview(chartView)
        }
        
        
        
        fetchStockChartData(stock: stockTicker!, fromP: String(self.startP), toP: String(self.endP), interval: nowInterval, completionHandler: { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                showConfirmAlert(root: self, msg: "Error access yahoo finance api.")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    // print(json)
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
                    dateFormatter.dateFormat = "MM/dd"
                    
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
                        let x = chartView.xAxis
                        x.labelPosition = XAxis.LabelPosition.bottom
                        x.valueFormatter = IndexAxisValueFormatter(values: xAxis)
                        x.drawGridLinesEnabled = false;
                        chartView.autoScaleMinMaxEnabled = true
                        chartView.borderLineWidth = 0.5
                        chartView.data = CandleChartData(dataSet: set1)
                        
                        if xAxis.count > 0 {
                            chartView.setVisibleXRangeMaximum(14)
                            chartView.autoScaleMinMaxEnabled = true
                            chartView.moveViewToX(Double(xAxis.count - 1))
                        } else {
                            chartView.xAxis.axisMinimum = 0
                            chartView.xAxis.axisMaximum = 10
                            
                            chartView.leftAxis.axisMinimum = 0
                            chartView.leftAxis.axisMaximum = 10
                            chartView.rightAxis.axisMinimum = 0
                            chartView.rightAxis.axisMaximum = 10
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

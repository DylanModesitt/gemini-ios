//
//  PriceSummaryTableViewCell.swift
//  Gemini
//
//  Created by Dylan Modesitt on 1/8/18.
//  Copyright © 2018 modesitt. All rights reserved.
//

import UIKit
import Charts

class PriceSummaryTableViewCell: UITableViewCell {
    
    enum TimeSelectors {
        case hour, day, week, month, year, all
        private static let allValues = [hour,day,week,month,year,all]
        
        static func getSelector(buttonText: String) -> TimeSelectors {
            switch buttonText {
            case "1H":
                return self.hour
            case "1D":
                return self.day
            case "1W":
                return self.week
            case "1M":
                return self.month
            case "1Y":
                return self.year
            case "All":
                return self.all
            default:
                return self.hour
            }
        }
        
        private var index: Int {
            return TimeSelectors.allValues.index(of: self)!
        }
    
    }
    
    // MARK: properties
    
    var symbol: String?
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet var timeSelectors: [UIButton]!
    
    lazy var selectedTime = TimeSelectors.getSelector(buttonText: timeSelectors[0].titleLabel!.text!)
    lazy var selectedTimeButton = timeSelectors[0]
    var data: [Double] = []
    
    // MARK: methods
    
    @IBAction func timeSelectorDidChange(_ sender: Any) {
        selectedTime = TimeSelectors.getSelector(buttonText: (sender as! UIButton).titleLabel!.text!)
        selectedTimeButton = (sender as! UIButton)
        layoutSubviews()
    }
    
    private func getData() {
        
        guard let smbl = symbol else { return }
        var timestamp = Int64(NSDate().timeIntervalSince1970)
        
        switch selectedTime {
        case .hour:
            timestamp -= Int64(60*60)
        case .day:
            timestamp -= Int64(60*60*24)
        case .week:
            timestamp -= Int64(60*60*24*7)
        case .month:
            timestamp -= Int64(60*60*24*7*4) // good enough ;)
        case .year:
            timestamp -= Int64(60*60*24*7*4*12) // ^^
        case .all:
            timestamp = 0
        }
        
        Api.request(endpoint: .TradeHistory(symbol: smbl, since: timestamp, limit: nil, includeBreaks: nil)) { (json) in
            print(json)
            self.data = []
            json.arrayValue.forEach({ (auction) in
                if let value = Double(auction["price"].stringValue) {
                    self.data.append(value)
                }
            })
        }
        
    }
    
    // MARK: Table View Cell Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        getData()
        
        // set seleced value button
        timeSelectors.forEach { (button) in
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 4
            button.tintColor = UIColor.blue
        }
        
        selectedTimeButton.backgroundColor = UIColor.red
        selectedTimeButton.layer.cornerRadius = 4
        selectedTimeButton.tintColor = UIColor.white
        
        // set chart data
        guard data.count > 0 else { return }
        var entry = [ChartDataEntry]()
        for i in 0..<data.count {
            entry.append(ChartDataEntry(x: Double(i), y: data[i]))
        }
        let line = LineChartDataSet(values: entry, label: symbol!)
        line.colors = [UIColor.red]
        let chardData = LineChartData()
        chardData.addDataSet(line)
        lineChart.data = chardData
    }
    
    
}

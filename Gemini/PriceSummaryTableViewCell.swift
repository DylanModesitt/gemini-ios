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
    var data: [Double] = []
    
    // MARK: methods
    
    @IBAction func timeSelectorDidChange(_ sender: Any) {
        selectedTime = TimeSelectors.getSelector(buttonText: (sender as! UIButton).titleLabel!.text!)
        layoutSubviews()
    }
    
    private func getData() {
        
        guard let smbl = symbol else { return }
        
        var timestamp = Int(NSDate().timeIntervalSince1970)
        
        switch selectedTime {
        case .hour:
            timestamp -= 60*60
        case .day:
            timestamp -= 60*60*24
        case .week:
            timestamp -= 60*60*24*7
        case .month:
            timestamp -= 60*60*24*7*30
        case .year:
            timestamp -= 60*60*24*7*30*365
        case .all:
            timestamp = 0
        }
        
        Api.request(endpoint: .AuctionHistory(symbol: smbl, since: timestamp, limit: nil, indicitave: nil)) { (json) in
            self.data = []
            json.arrayValue.forEach({ (auction) in
                if let value = Double(auction["collar_price"].stringValue) {
                    self.data.append(value)
                }
            })
        }
        
    }
    
    // MARK: Table View Cell Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        getData()
    }
    
    
}

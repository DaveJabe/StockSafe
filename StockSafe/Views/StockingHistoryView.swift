//
//  StockingHistoryView.swift
//  Stocked.
//
//  Created by David Jabech on 6/4/21.
//

import UIKit
import Firebase

class StockingHistory: UIView {
    
    public var history = [StockingInstance]()
    
    public let historyTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.addSubview(historyTable)
        historyTable.frame = self.bounds
        historyTable.delegate = self
        historyTable.dataSource = self
    }
}

extension StockingHistory: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = historyTable.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timestamp = formatter.string(from: history[indexPath.row].time)
        cell.timestampLabel.text = timestamp
        
        cell.casesLabel.text = "Cases: \(history[indexPath.row].cases)"
        
        cell.locationLabel.text = "Location: \(history[indexPath.row].location!)"
        
        cell.destinationLabel.text = "Location: \(history[indexPath.row].destination)"
        
        return cell
    }
    
    
}

//
//  SetLimitsViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/19/21.
//

import UIKit

struct LimitSection {
    let title: String
    let options: [SetLimitsOptionType]
}

enum SetLimitsOptionType {
    case productCell(model: SetLimitsProductOption)
    case limitCell(model: SetLimitsOption)
    case limitSwitchCell(model: LimitSwitchOption)
    case buttonCell
}

struct SetLimitsProductOption {
    let title: String
}

struct SetLimitsOption {
    let title: String
    let textfieldTag: String
    let textfield: UITextField
    let handler: (() -> Void)
}

struct LimitSwitchOption {
    let title: String
    let isOn: Bool
}

class SetLimitsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var productView: UIView!
    @IBOutlet var limitView: UIView!
    
    var textFieldFilet = UITextField()
    var textFieldSpicy = UITextField()
    var textFieldNugget = UITextField()
    var textFieldStrip = UITextField()
    var textFieldGFilet = UITextField()
    var textFieldGNugget = UITextField()
    var textFieldBFilet = UITextField()
    var textFieldFilet2 = UITextField()
    var textFieldSpicy2 = UITextField()
    var textFieldNugget2 = UITextField()
    var textFieldStrip2 = UITextField()
    var textFieldGFilet2 = UITextField()
    var textFieldGNugget2 = UITextField()
    var textFieldBFilet2 = UITextField()
    
    private var productList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.register(LimitSwitchCell.self, forCellReuseIdentifier: LimitSwitchCell.identifier)
        return tableView
    }()
    
    private var limitList: UITableView = {
        let tableView = UITableView(frame: .infinite, style: .grouped)
        tableView.register(LimitCell.self, forCellReuseIdentifier: LimitCell.identifier)
        return tableView
    }()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        productList.contentOffset = limitList.contentOffset
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if tableView == productList {
            let model = sections[section]
            return model.title
        }
        else {
            let model = sectionsForLimitTable[section]
            return model.title
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productList {
            return sections[section].options.count
        }
        else {
            return sectionsForLimitTable[section].options.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == productList {
            return sections.count
        }
        else {
            return sectionsForLimitTable.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == productList {
            let model = sections[indexPath.section].options[indexPath.row]
            switch model.self {
                case .productCell(let model):
                    guard let cell = productList.dequeueReusableCell(withIdentifier: ProductCell.identifier) as? ProductCell else {
                        return UITableViewCell()
                        }
                    cell.configure(with: model)
                    return cell
                case .limitCell(let model):
                    guard let cell = productList.dequeueReusableCell(withIdentifier: LimitCell.identifier) as? LimitCell else {
                        return UITableViewCell()
                        }
                    cell.configure(with: model)
                    return cell
            case .limitSwitchCell(let model):
                guard let cell = productList.dequeueReusableCell(withIdentifier: LimitSwitchCell.identifier) as? LimitSwitchCell else {
                    return UITableViewCell()
                }
                cell.configure(with: model)
                return cell
            default: return UITableViewCell()
            }
        }
        else if tableView == limitList {
            let model = sectionsForLimitTable[indexPath.section].options[indexPath.row]
            switch model.self {
            case .limitCell(let model):
                guard let cell = limitList.dequeueReusableCell(withIdentifier: LimitCell.identifier) as? LimitCell else {
                    return UITableViewCell()
                }
                cell.configure(with: model)
                return cell
            case .productCell(let model):
                guard let cell = limitList.dequeueReusableCell(withIdentifier: ProductCell.identifier) as? ProductCell else {
                    return UITableViewCell()
                }
                cell.configure(with: model)
                return cell
            case .limitSwitchCell(let model):
                guard let cell = limitList.dequeueReusableCell(withIdentifier: LimitSwitchCell.identifier) as? LimitSwitchCell else {
                    return UITableViewCell()
                }
                cell.configure(with: model)
                return cell
            default: return UITableViewCell()
            }
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    var sections = [LimitSection]()
    var sectionsForLimitTable = [LimitSection]()
    
    func configure() {
        sections.append(LimitSection(title: "Thawing Cabinet", options: [
                                        .productCell(model: SetLimitsProductOption(title: "Filet")),
                                        .productCell(model: SetLimitsProductOption(title: "Spicy")),
                                        .productCell(model: SetLimitsProductOption(title: "Nugget")),
                                        .productCell(model: SetLimitsProductOption(title: "Strip")),
                                        .productCell(model: SetLimitsProductOption(title: "Grilled Filet")),
                                        .productCell(model: SetLimitsProductOption(title: "Grilled Nugget")),
                                        .productCell(model: SetLimitsProductOption(title: "Breakfast Filet"))
        ]))
        sections.append(LimitSection(title: "Breading Table", options: [
                                        .productCell(model: SetLimitsProductOption(title: "Filet")),
                                        .productCell(model: SetLimitsProductOption(title: "Spicy")),
                                        .productCell(model: SetLimitsProductOption(title: "Nugget")),
                                        .productCell(model: SetLimitsProductOption(title: "Strip")),
                                        .productCell(model: SetLimitsProductOption(title: "Grilled Filet")),
                                        .productCell(model: SetLimitsProductOption(title: "Grilled Nugget")),
                                        .productCell(model: SetLimitsProductOption(title: "Breakfast Filet"))
        ]))
        
        sections.append(LimitSection(title: "Options", options: [
            .limitSwitchCell(model: LimitSwitchOption(title: "Turn limits on/off", isOn: UserDefaults.standard.bool(forKey: "SetLimitsKey")))
        ]))
        
        sectionsForLimitTable.append(LimitSection(title: "Limits:", options:
                                                    [.limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldFilet", textfield: textFieldFilet, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldSpicy", textfield: textFieldSpicy, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldNugget", textfield: textFieldNugget, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldStrip", textfield: textFieldStrip, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldGFilet", textfield: textFieldGFilet, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldGNugget", textfield: textFieldGNugget, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldBFilet", textfield: textFieldBFilet, handler: { }))]))
        sectionsForLimitTable.append(LimitSection(title: "Limits:", options:
                                                    [.limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldFilet2", textfield: textFieldFilet2, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldSpicy2", textfield: textFieldSpicy2, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldNugget2", textfield: textFieldNugget2, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldStrip2", textfield: textFieldStrip2, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldGFilet2", textfield: textFieldGFilet2, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldGNugget2", textfield: textFieldGNugget2, handler: { })),
                                                     .limitCell(model: SetLimitsOption(title: "Limit", textfieldTag: "textFieldBFilet2", textfield: textFieldBFilet2, handler: { }))]))
    }
    
    func configureLimits() {
        textFieldFilet.text = String(describing: UserDefaults.standard.integer(forKey: "tc_filet"))
        textFieldFilet2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_filet"))
        textFieldSpicy.text = String(describing: UserDefaults.standard.integer(forKey: "tc_spicy"))
        textFieldSpicy2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_spicy"))
        textFieldNugget.text = String(describing: UserDefaults.standard.integer(forKey: "tc_nugget"))
        textFieldNugget2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_nugget"))
        textFieldStrip.text = String(describing: UserDefaults.standard.integer(forKey: "tc_strip"))
        textFieldStrip2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_strip"))
        textFieldGFilet.text = String(describing: UserDefaults.standard.integer(forKey: "tc_gfilet"))
        textFieldGFilet2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_gfilet"))
        textFieldGNugget.text = String(describing: UserDefaults.standard.integer(forKey: "tc_gnugget"))
        textFieldGNugget2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_gnugget"))
        textFieldBFilet.text = String(describing: UserDefaults.standard.integer(forKey: "tc_bfilet"))
        textFieldBFilet2.text = String(describing: UserDefaults.standard.integer(forKey: "bt_bfilet"))
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if
            view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height/2)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        
        productView.addSubview(productList)
        productList.frame = CGRect(x: 0, y: 0, width: productView.frame.size.width, height: productView.frame.size.height)
        productList.delegate = self
        productList.dataSource = self
        
        limitView.addSubview(limitList)
        limitList.frame = CGRect(x: 0, y: 0, width: limitView.frame.size.width, height: limitView.frame.size.height)
        limitList.delegate = self
        limitList.dataSource = self
        
        configureLimits()
        configure()
        
    }

}

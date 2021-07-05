//
//  AccountInfoViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/23/21.
//

import UIKit
import Firebase

struct AccountInfoSection {
    let title: String?
    let options: [AccountInfoOption]
}
enum AccountInfoOption {
    case productCell(model: SetLimitsProductOption)
    case fieldCell(model: AccountInfoFieldOption)
    case titleCell(model: TitleCellOption)
}

struct TitleCellOption {
    let title: String
}
struct AccountInfoFieldOption {
    let title: String
    let tfTag: Int
    let textField: UITextField
    let handler: (()->Void)
}

class AccountInfoViewController: UIViewController {
    
    @IBOutlet var infoTableView: UIView!
    @IBOutlet var fieldTableView: UIView!
    
    private var userNameTF: UITextField = {
        let textfield = UITextField()
        textfield.tag = 1
        return textfield
    }()
    
    private var storeNumberTF: UITextField = {
        let textfield = UITextField()
        textfield.tag = 2
        return textfield
    }()

    
    private var infoTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        table.register(SignOutCell.self, forCellReuseIdentifier: SignOutCell.identifier)
        return table
    }()
    
    private var fieldTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(TitleCell.self, forCellReuseIdentifier: TitleCell.identifier)
        table.register(FieldCell.self, forCellReuseIdentifier: FieldCell.identifier)
        return table
    }()

    private var models = [LimitSection]()
    private var fieldModels = [AccountInfoSection]()
    
    func configure() {
        models.append(LimitSection(title: "Account Info", options: [.productCell(model: SetLimitsProductOption(title: "User Name")),
                                                                    .productCell(model: SetLimitsProductOption(title: "User Email")),
                                                                    .productCell(model: SetLimitsProductOption(title: "Store Number")),
                                                                    .productCell(model: SetLimitsProductOption(title: "Date Joined"))
        ]))
        models.append(LimitSection(title: " ", options: [.buttonCell] ))
        
        fieldModels.append(AccountInfoSection(title: " ", options: [.fieldCell(model: AccountInfoFieldOption(title: "", tfTag: 1, textField: userNameTF, handler: { })),
                                                                    .titleCell(model: TitleCellOption(title: String(UserDefaults.standard.string(forKey: "UserEmailKey") ?? ""))),
                                                                    .fieldCell(model: AccountInfoFieldOption(title: "", tfTag: 2, textField: storeNumberTF, handler: { })),
                                                                    .titleCell(model: TitleCellOption(title: String(UserDefaults.standard.string(forKey: "DateJoinedKey") ?? "")))
        ]))
                                                                    
    }
    
    func configureTextFields() {
        userNameTF.text = UserDefaults.standard.string(forKey: "UserNameKey")
        storeNumberTF.text = UserDefaults.standard.string(forKey: "StoreNumberKey")
    }
    
    func buildTables() {
        infoTableView.addSubview(infoTable)
        fieldTableView.addSubview(fieldTable)
        infoTable.frame = infoTableView.bounds
        
        fieldTable.frame = fieldTableView.bounds
        infoTable.delegate = self
        infoTable.dataSource = self
        fieldTable.delegate = self
        fieldTable.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        infoTable.contentOffset = fieldTable.contentOffset
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardWillShowNotification] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func leaveSettingsToLogin() {
        let loginvc = storyboard?.instantiateViewController(withIdentifier: "login") as? LoginViewController
        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.pushViewController(loginvc!, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        buildTables()
        configureTextFields()
        configure()
    }
}
extension AccountInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == infoTable {
            return models.count
        }
        else {
            return fieldModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userNameTF.resignFirstResponder()
        storeNumberTF.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == infoTable {
            return models[section].title
        }
        else {
            return fieldModels[section].title
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == infoTable {
            return models[section].options.count
        }
        else {
            return fieldModels[section].options.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == infoTable {
            let model = models[indexPath.section].options[indexPath.row]
            switch model.self {
                case .productCell(let model):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
                        return UITableViewCell()
                    }
                    cell.configure(with: model)
                    return cell
                case .buttonCell:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: SignOutCell.identifier, for: indexPath) as? SignOutCell else {
                        return UITableViewCell()
                    }
                    cell.signOutButton.addTarget(self, action: #selector(leaveSettingsToLogin), for: .touchUpInside)
                    return cell
                    
                default: return UITableViewCell()
            }
        }
        else {
            let model = fieldModels[indexPath.section].options[indexPath.row]
            switch model.self {
                case .fieldCell(let model): guard let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.identifier, for: indexPath)    as? FieldCell else {
                        return UITableViewCell()
                    }
                    cell.configure(with: model)
                    return cell
                case .titleCell(let model):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleCell.identifier, for: indexPath) as? TitleCell else {
                        return UITableViewCell()
                }
                    cell.configure(with: model)
                    return cell
                default: return UITableViewCell()
            }
            
        }
    }
}

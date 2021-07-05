//
//  SettingsViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/12/21.
//

import UIKit
import Firebase

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
    case buttonCell
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage?
    let backgroundColor: UIColor
    var isOn: Bool
    let handler: (() -> Void)
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let backgroundColor: UIColor
    let handler: (() -> Void)
}

class settingsCell: UITableViewCell {
    
    static let identifier = "settingsCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(label)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 10, width: size-5, height: size-5)
        iconImageView.frame = CGRect(x: 0.75, y: 0.25, width: iconContainer.frame.size.width-2, height: iconContainer.frame.size.height-2)
        label.frame = CGRect(x: 25+iconContainer.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width-15-iconContainer.frame.size.width,
                             height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
    public func configure(with model: SettingsOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.backgroundColor
    }
}

class settingsSwitchCell: UITableViewCell {
    static let identifier = "settingsSwitchCell"
    
    var db: Firestore!
    
    @objc func switchWasTapped(_ sender: UISwitch!) -> Bool {
        let uid = String(Auth.auth().currentUser!.uid)
        print(uid)
        if mySwitch.isOn {
            db.collection("userInfo").whereField("userID", isEqualTo: uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("error in switchWasTapped: \(err)")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData(["autoArchive" : true])
                        }
                    }
                }
            UserDefaults.standard.setValue(true, forKey: "AutoArchiveKey")
            return true
        }
        else {
            db.collection("userInfo").whereField("userID", isEqualTo: uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("error in switchWasTapped: \(err)")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData(["autoArchive" : false])
                        }
                    }
                }
            UserDefaults.standard.setValue(false, forKey: "AutoArchiveKey")
            return false
        }
    }
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let mySwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.tintColor = .blue
        return mySwitch
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        Firestore.firestore().settings = settings
        // [END setup]
            db = Firestore.firestore()
        
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(label)
        contentView.clipsToBounds = true
        contentView.addSubview(mySwitch)
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 10, width: size-5, height: size-5)
        iconImageView.frame = CGRect(x: 0.75, y: 0.25, width: iconContainer.frame.size.width-2, height: iconContainer.frame.size.height-2)
        label.frame = CGRect(x: 25+iconContainer.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width-15-iconContainer.frame.size.width,
                             height: contentView.frame.size.height)
        mySwitch.sizeToFit()
        mySwitch.frame = CGRect(x: (contentView.frame.size.width-mySwitch.frame.size.width)-15,
                                y: (contentView.frame.size.height-mySwitch.frame.size.height)/2,
                                width: mySwitch.frame.size.width,
                                height: mySwitch.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
        mySwitch.isOn = false
    }
    
    public func configure(with model: SettingsSwitchOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.backgroundColor
        mySwitch.isOn = model.isOn
        mySwitch.addTarget(self, action: #selector(switchWasTapped), for: UIControl.Event.valueChanged)
    }
}
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type {
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        default:
            print("row was selected")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        switch model.self {
        case .staticCell(let model):
            guard let cell = settingsTable.dequeueReusableCell(withIdentifier: settingsCell.identifier, for: indexPath) as? settingsCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = settingsTable.dequeueReusableCell(withIdentifier: settingsSwitchCell.identifier, for: indexPath) as? settingsSwitchCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .buttonCell:
            guard let cell = settingsTable.dequeueReusableCell(withIdentifier: SignOutCell.identifier, for: indexPath) as? SignOutCell else {
                return UITableViewCell()
            }
            return cell
        }
    }
    
    var models = [Section]()
    
    func configure() {
        
        models = []
        
        models.append(Section(title: "General", options: [
                                .switchCell(model: SettingsSwitchOption(title: "AutoArchive", icon: UIImage(systemName: "arrow.triangle.2.circlepath"), backgroundColor: .systemGreen, isOn: UserDefaults.standard.bool(forKey: "AutoArchiveKey") ) { } ),
                                .staticCell(model: SettingsOption(title: "Delete All Cases", icon: UIImage(systemName: "trash"), backgroundColor: .systemRed, handler: { [self] in
                                    let dcvc = storyboard?.instantiateViewController(withIdentifier: "delete") as? DeleteCasesViewController
                                    navigationController?.pushViewController(dcvc!, animated: true)
                                } )),
                                .staticCell(model: SettingsOption(title: "Set Case Limits", icon: UIImage(systemName: "checkmark.rectangle"), backgroundColor: .systemBlue, handler: { [self] in
                                    let slvc = storyboard?.instantiateViewController(withIdentifier: "setLimits") as? SetLimitsViewController
                                    navigationController?.pushViewController(slvc!, animated: true)
                                    
                                } )),
                                .staticCell(model: SettingsOption(title: "Tutorial", icon: UIImage(systemName: "questionmark"), backgroundColor: .systemTeal, handler: { [self] in
                                    let tutorialvc = storyboard?.instantiateViewController(withIdentifier: "tutorial") as? TutorialViewController
                                    navigationController?.pushViewController(tutorialvc!, animated: true)
                                } ))
            ] ))
       
        models.append(Section(title: "Account", options: [
                                .staticCell(model: SettingsOption(title: "Account Info", icon: UIImage(systemName: "person.circle"), backgroundColor: .systemGray2, handler: { [self] in
                                    let accountvc = storyboard?.instantiateViewController(withIdentifier: "accountInfo") as? AccountInfoViewController
                                    navigationController?.pushViewController(accountvc!, animated: true)
                                } )),
                                .staticCell(model: SettingsOption(title: "Subscription", icon: UIImage(systemName: "purchased.circle"), backgroundColor: .orange, handler: { [self] in
                                    let subvc = storyboard?.instantiateViewController(withIdentifier: "subscription") as? SubscriptionViewController
                                    navigationController?.pushViewController(subvc!, animated: true)
                                } ))
        
            ] ))
        
        }

    private let settingsTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(settingsCell.self, forCellReuseIdentifier: settingsCell.identifier)
        table.register(settingsSwitchCell.self, forCellReuseIdentifier: settingsSwitchCell.identifier)
        table.register(SignOutCell.self, forCellReuseIdentifier: SignOutCell.identifier)
        return table
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
        NotificationCenter.default.post(name: Notification.Name(rawValue: vckey), object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        title = "Settings"
        view.addSubview(settingsTable)
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.frame = view.bounds
        
        
        
    }
    
}

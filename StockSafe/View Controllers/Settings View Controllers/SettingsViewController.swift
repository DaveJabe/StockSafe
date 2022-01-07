//
//  SettingsViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/12/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
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

class SettingsViewController: UIViewController {
    
    private var models = [Section]()
    
    private let settingsTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        table.register(SettingsSwitchCell.self, forCellReuseIdentifier: SettingsSwitchCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        title = "Settings"
        view.addSubview(settingsTable)
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.frame = view.bounds
    }
    
    private func configure() {
        models = []
        
        models.append(Section(title: "General", options: [
            .staticCell(model: SettingsOption(title: "About Us", icon: UIImage(systemName: "at"), backgroundColor: .systemOrange, handler: { [self] in
                
            } )),
            .staticCell(model: SettingsOption(title: "Tutorial", icon: UIImage(systemName: "questionmark"), backgroundColor: .systemTeal, handler: { [self] in
                
            } ))
            ] ))
        
        models.append(Section(title: "Customize", options: [
            .staticCell(model: SettingsOption(title: "Alerts", icon: UIImage(systemName: "bell.circle"), backgroundColor: .systemYellow, handler: { [self] in
                
            } )),
            .staticCell(model: SettingsOption(title: "Rename", icon: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), backgroundColor: .systemBlue, handler: { [self] in
                
            } )),
            .staticCell(model: SettingsOption(title: "Change Theme", icon: UIImage(systemName: "paintpalette.fill"), backgroundColor: .magenta, handler: { [self] in
                let tsvc = ThemeSelectViewController()
                if let parent = parent as? MainViewController {
                    tsvc.setMediator(mediator: parent)
                }
                present(tsvc, animated: true)
            } )),
        ]))
                           
        models.append(Section(title: "Account", options: [
            .staticCell(model: SettingsOption(title: "Account Info", icon: UIImage(systemName: "person.circle"), backgroundColor: .systemGray2, handler: { [self] in
                
            } )),
            .staticCell(model: SettingsOption(title: "Reset", icon: UIImage(systemName: "trash"), backgroundColor: .systemRed, handler: { [self] in
                
            } )),
            ] ))
        
        }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
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
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        switch model.self {
        case .staticCell(let model):
            guard let cell = settingsTable.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = settingsTable.dequeueReusableCell(withIdentifier: SettingsSwitchCell.identifier, for: indexPath) as? SettingsSwitchCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
    }
}

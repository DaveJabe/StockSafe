//
//  ThemeSelectViewController.swift
//  StockSafe
//
//  Created by David Jabech on 8/12/21.
//

import UIKit

class ThemeSelectViewController: UIViewController, ColleagueProtocol {
    
    var mediator: MediatorProtocol?
    
    private let themeTable = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        themeTable.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(themeTable)
        themeTable.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.identifier)
        themeTable.delegate = self
        themeTable.dataSource = self
    }
    
    func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }

}

extension ThemeSelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return ColorThemes.themeColors.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else {
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            cell.title.text = "Current Theme"
            cell.button.backgroundColor = ColorThemes.themeColors[indexPath.row]
            cell.button.isEnabled = false
            return cell
        }
        else {
            cell.title.text = ColorThemes.themeTitles[indexPath.row]
            cell.button.backgroundColor = ColorThemes.themeColors[indexPath.row]
            cell.button.addAction( UIAction { [self] _ in
                ColorThemes.loadTheme(themeID: ColorThemes.themeTitles[indexPath.row])
                mediator?.notify(sender: self, event: .newThemeSelection)
                dismiss(animated: true)
            }, for: .touchUpInside)
            return cell
        }
    }
    
    
}

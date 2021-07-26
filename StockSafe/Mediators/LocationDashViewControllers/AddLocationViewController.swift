//
//  AddLocationViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/17/21.
//

import UIKit

class AddLocationViewController: UIViewController {
    
    private var manager = LocationManager()
    
    private var locationName = ""
    
    public var locationColor = "#A93226"
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var addNewLocationLabel: UILabel!
    
    @IBOutlet var addLocationTable: UITableView!
    
    @IBOutlet var addLocationButton: UIButton!
    
    @IBAction func addLocation(_ sender: UIButton) {
        let ldvc = presentingViewController?.children.first(where: { $0.restorationIdentifier == "locationDashboard" }) as? LocationDashboardViewController
        manager.addNewLocation(name: locationName, color: locationColor) {
            manager.configureLocations()
            ldvc!.locationCollection.reloadData()
        }
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        VD.addShadow(view: backgroundView)
        VD.addShadow(view: addLocationButton)
        VD.addSubtleShadow(view: addNewLocationLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLocationTable.delegate = self
        addLocationTable.dataSource = self
        addLocationTable.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.identifier)
        addLocationTable.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.identifier)
        addLocationTable.allowsSelection = false
    }
    
    @objc private func goToColorSelect(_ sender: UIButton) {
        let csvc = storyboard?.instantiateViewController(withIdentifier: "colorSelect") as? ColorSelectViewController
        csvc!.modalPresentationStyle = .overCurrentContext
        present(csvc!, animated: true)
    }
}

extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        
        case 0:
            guard let cell = addLocationTable.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            cell.title.text = "Name"
            cell.textField.placeholder = "Cooler"
            cell.setDelegate(delegate: self)
            return cell
            
        case 1:
            guard let cell = addLocationTable.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else {
                return UITableViewCell()
            }
            cell.title.text = "Color"
            cell.button.backgroundColor = HexColor(locationColor)
            cell.button.addTarget(self, action: #selector(goToColorSelect(_:)), for: .touchUpInside)
            return cell
            
        default:
            print("Error in cellForRowAt in AddLocationViewController")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }
}

extension AddLocationViewController: TextFieldCellDelegate {
    func returnText(senderTag: Int, text: String) {
        locationName = text
    }
}

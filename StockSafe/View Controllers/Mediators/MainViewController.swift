//
//  MainViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/27/21.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
    
    private var casePage = CasesViewController()
    
    private var productPage = ProductsViewController()
    
    private var locationPage = LocationsViewController()
    
    private var settingsPage = SettingsViewController()
    
    private let containerView = UIView()
    
    private let popUpMenu = PopUpMenuView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
    private let circleView = UIView()
    
    private let darkenView = UIView()
    
    private lazy var casesOption: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = #imageLiteral(resourceName: "CasesMenuOptionFiltered")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var productsOption: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = #imageLiteral(resourceName: "StockSafeProductsOption")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var locationsOption: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = #imageLiteral(resourceName: "StockSafeLocationsOption")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var settingsOption: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = #imageLiteral(resourceName: "StockSafeSettingsOption")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    @IBOutlet var header: UIView!
    
    @IBOutlet var childVCLabel: UILabel!
    
    @IBOutlet var historyButton: UIButton!
    
    @IBOutlet var signOutButton: UIButton!
    
    @IBOutlet var childView: UIView!
    
    @IBOutlet var tabBar: UIView!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBAction func signOut(_ sender: UIButton) {
        do { try Auth.auth().signOut()
            Constants.userID = ""
            guard let sceneDel = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            guard let mainVC = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.loginVC) as? LoginViewController else { return }
            sceneDel.window?.setRootViewController(viewController: mainVC)
            print("Sign Out Successful")
            print("UserID = \(Constants.userID)")
        }
        catch let error {
            print("Error signing out: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add(casePage, viewForChild: childView)
        add(productPage, viewForChild: childView)
        add(locationPage, viewForChild: childView)
        add(settingsPage, viewForChild: childView)
        
        productPage.view.isHidden = true
        locationPage.view.isHidden = true
        settingsPage.view.isHidden = true
        
        dateLabel.getDate()
        timeLabel.getTime()
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                                    dateLabel.getDate()
                                    timeLabel.getTime()
        }
        popUpMenu.frame = CGRect(x: UIScreen.main.bounds.midX-25,
                                y: 25,
                                width: 20,
                                height: tabBar.frame.size.height)
        tabBar.addSubview(circleView)
        tabBar.addSubview(popUpMenu)
        view.isUserInteractionEnabled = true
        
        view.addSubview(darkenView)
        view.addSubview(casesOption)
        view.addSubview(productsOption)
        view.addSubview(locationsOption)
        view.addSubview(settingsOption)
        
        let menuGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLoadingBox(_:)))
        let casesTap = UITapGestureRecognizer(target: self, action: #selector(switchToCases(_:)))
        let productsTap = UITapGestureRecognizer(target: self, action: #selector(switchToProducts(_:)))
        let locationsTap = UITapGestureRecognizer(target: self, action: #selector(switchToLocations(_:)))
        let settingsTap = UITapGestureRecognizer(target: self, action: #selector(switchToSettings(_:)))
        
        tabBar.addGestureRecognizer(menuGesture)
        casesOption.addGestureRecognizer(casesTap)
        productsOption.addGestureRecognizer(productsTap)
        locationsOption.addGestureRecognizer(locationsTap)
        settingsOption.addGestureRecognizer(settingsTap)
    }
    
    @objc public func didTapLoadingBox(_ sender: UITapGestureRecognizer) {
        popUpMenu.boxAnimation.play()
        toggleMenu()
    }
    
    private func configureLayout() {
        view.backgroundColor = ColorThemes.backgroundColor
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.cornerRadius = 40
        tabBar.backgroundColor = ColorThemes.foregroundColor2
                
        circleView.backgroundColor = .systemGray6
        circleView.frame = CGRect(x: tabBar.center.x-45,
                                  y: 5,
                                  width: 90,
                                  height: 90)
        circleView.asCircle()
        circleView.addShadow()
        
        dateLabel.textColor = .systemGray6
        timeLabel.textColor = .systemGray6
        
        tabBar.addShadow()
        view.addSubview(tabBar)
        
        
        header.backgroundColor = ColorThemes.foregroundColor1
        header.addBorder(side: .bottom, thickness: 1, color: .black)
        childVCLabel.textColor = .systemGray6
        childVCLabel.addSubtleShadow()
        historyButton.tintColor = .systemGray6
        historyButton.addSubtlerShadow()
        signOutButton.titleLabel?.textColor = .systemGray6
        signOutButton.addSubtlerShadow()
        
        view.bringSubviewToFront(popUpMenu)
        
        casesOption.frame = CGRect(x: 0,
                                   y: view.frame.size.height,
                                   width: view.frame.size.width/2,
                                   height: 200)
        casesOption.center.x = view.center.x
        
        productsOption.frame = CGRect(x: 0,
                                   y: view.frame.size.height,
                                   width: view.frame.size.width/3,
                                   height: 180)
        productsOption.center.x = view.center.x
        
        locationsOption.frame = CGRect(x: 0,
                                   y: view.frame.size.height,
                                   width: view.frame.size.width/5,
                                   height: 140)
        locationsOption.center.x = view.center.x
        
        settingsOption.frame = CGRect(x: 0,
                                   y: view.frame.size.height,
                                   width: view.frame.size.width/7,
                                   height: 110)
        settingsOption.center.x = view.center.x
        
        darkenView.frame = view.bounds
        darkenView.backgroundColor = .darkGray
        darkenView.alpha = 0
    }
    
    @objc private func resignViews(_ sender: UITapGestureRecognizer) {
        casePage.submenu.ptfOne!.resignFirstResponder()
        casePage.submenu.ptfTwo!.resignFirstResponder()
        casePage.tuckAwaySelectionViews()
        toggleMenu()
    }
    
    public func toggleMenu() {
        tabBar.gestureRecognizers?[0].isEnabled = false
        if casesOption.frame.origin.y == view.frame.size.height {
            UIView.animate(withDuration: 0.15) { [self] in
                darkenView.alpha = 0.45
                casesOption.frame.origin.y = 650
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.15) {
                    self.productsOption.frame.origin.y = 730
                }
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIView.animate(withDuration: 0.15) {
                        self.locationsOption.frame.origin.y = 810
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UIView.animate(withDuration: 0.15) {
                            self.settingsOption.frame.origin.y = 880
                            }
                        }
                    }
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.3) { [self] in
                darkenView.alpha = 0
                casesOption.frame.origin.y = view.frame.size.height
                productsOption.frame.origin.y = view.frame.size.height
                locationsOption.frame.origin.y = view.frame.size.height
                settingsOption.frame.origin.y = view.frame.size.height
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tabBar.gestureRecognizers?[0].isEnabled = true
        }
    }
    
    // This func will switch the childVC to the cases page
    @objc private func switchToCases(_ sender: UITapGestureRecognizer) {
        productPage.view.isHidden = true
        locationPage.view.isHidden = true
        settingsPage.view.isHidden = true
        casePage.view.isHidden = false
        
        childVCLabel.text = "Cases"
        toggleMenu()
    }
    
    // This func will switch the childVC to the products page
    @objc private func switchToProducts(_ sender: UITapGestureRecognizer) {
        casePage.view.isHidden = true
        locationPage.view.isHidden = true
        settingsPage.view.isHidden = true
        productPage.view.isHidden = false
        
        childVCLabel.text = "Products"
        toggleMenu()
    }
    
    // This func will switch the childVC to the locations page
    @objc private func switchToLocations(_ sender: UITapGestureRecognizer) {
        productPage.view.isHidden = true
        casePage.view.isHidden = true
        settingsPage.view.isHidden = true
        locationPage.view.isHidden = false
        
        childVCLabel.text = "Locations"
        toggleMenu()
    }
    
    @objc private func switchToSettings(_ sender: UITapGestureRecognizer) {
        productPage.view.isHidden = true
        casePage.view.isHidden = true
        locationPage.view.isHidden = true
        settingsPage.view.isHidden = false
        
        childVCLabel.text = "Settings"
        toggleMenu()
    }
}

extension MainViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .newThemeSelection:
            casePage = CasesViewController()
            productPage = ProductsViewController()
            locationPage = LocationsViewController()
            settingsPage = SettingsViewController()

            viewDidLoad()
            casePage.view.isHidden = true
            settingsPage.view.isHidden = false
            
        default:
            print("Error in func notify() - MainViewController")
        }
    }
}

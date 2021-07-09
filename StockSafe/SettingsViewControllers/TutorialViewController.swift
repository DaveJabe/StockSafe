//
//  TutorialViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/30/21.
//

import UIKit

class TutorialViewController: UIViewController {
    
    private let pageControl: UIPageControl = {
        let pagecontrol = UIPageControl()
        pagecontrol.backgroundColor = .systemGray5
        pagecontrol.numberOfPages = 2
        return pagecontrol
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(named: "StockedColors")
        return scrollView
    }()
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: current * Int(view.frame.size.width), y: 0), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageControl)
        view.addSubview(scrollView)
        pageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        scrollView.delegate = self
        self.navigationItem.title = "Tutorial"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - 100, width: view.frame.size.width, height: 70)
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - pageControl.frame.size.height - 20)
        
        configureScrollView()
    }
    
    private func configureScrollView() {
        scrollView.contentSize = CGSize(width: view.frame.size.width*2, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        let labelFont = UIFont(name: "Avenir Heavy", size: 30)
        let textViewFont = UIFont(name: "Avenir", size: 20)
        
        let pageOne = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: scrollView.frame.size.height))
        pageOne.backgroundColor = UIColor(named: "StockedColors")
        
        let pageTwo = UIView(frame: CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: scrollView.frame.size.height))
        pageTwo.backgroundColor = UIColor(named: "StockedColors")
        
        let initialLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        initialLabel.center  = CGPoint(x: 120, y: 100)
        initialLabel.text = "Initial Setup"
        initialLabel.textColor = .black
        initialLabel.font = labelFont
        
        let boxOne = UIView(frame: CGRect(x: 50, y: 120, width: pageOne.frame.size.width - 100, height: 200))
        boxOne.backgroundColor = .white
        boxOne.layer.borderWidth = 1
        boxOne.layer.masksToBounds = true
        boxOne.layer.cornerRadius = 10
        
        let textViewOne = UITextView(frame: CGRect(x: 0, y: 0, width: pageOne.frame.size.width - 100, height: 200))
        textViewOne.isEditable = false
        textViewOne.font = textViewFont
        textViewOne.text = "Welcome to Stocked.! To get started, ensure that you have completed the following: 1. purchase a Stocked. subscription to access features (you can do this in Settings under 'Subscription'), 2. ensure that you have a secure internet connection and 3. ensure that all of the cases you will be tracking are numbered beginning at 1 (but never exceeding 100), for each product. For example: Filet 1, Filet 2, and so forth."
        boxOne.addSubview(textViewOne)
        
        let newCasesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        newCasesLabel.center = CGPoint(x: 170, y: 350)
        newCasesLabel.text = "Entering New Cases"
        newCasesLabel.textColor = .black
        newCasesLabel.font = labelFont
        
        let boxTwo = UIView(frame: CGRect(x: 50, y: 370, width: pageOne.frame.size.width - 100, height: 200))
        boxTwo.backgroundColor = .white
        boxTwo.layer.borderWidth = 1
        boxTwo.layer.masksToBounds = true
        boxTwo.layer.cornerRadius = 10
        
        let textViewTwo = UITextView(frame: CGRect(x: 0, y: 0, width: pageOne.frame.size.width - 100, height: 200))
        textViewTwo.isEditable = false
        textViewTwo.font = textViewFont
        textViewTwo.text = "To enter new cases, 1. select the 'New Cases' button on the home screen, which will take you to the New Cases Dashboard, 2. select the product you are stocking, and enter it's corresponding case number. To enter multiple cases at a time, toggle the 'Multiple Cases Switch', where you may then enter a range of case numbers. No two cases may have the same number (see 'Archiving Cases' for info on removing cases). The table to the right will display all of the current cases of your selected product in the Freezer."
        boxTwo.addSubview(textViewTwo)
        
        let limitsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        limitsLabel.center = CGPoint(x: 170, y: 600)
        limitsLabel.text = "Setting Limits"
        limitsLabel.textColor = .black
        limitsLabel.font = labelFont
        
        let boxThree = UIView(frame: CGRect(x: 50, y: 620, width: pageOne.frame.size.width - 100, height: 200))
        boxThree.backgroundColor = .white
        boxThree.layer.borderWidth = 1
        boxThree.layer.masksToBounds = true
        boxThree.layer.cornerRadius = 10
        
        let textViewThree = UITextView(frame: CGRect(x: 0, y: 0, width: pageOne.frame.size.width - 100, height: 200))
        textViewThree.isEditable = false
        textViewThree.font = textViewFont
        textViewThree.text = "To track cases more precisely, you might want to set limits for how much of a given product can be stocked to the Thawing Cabinet and Breading Table. In Settings, 1. select 'Set Case Limits', 2. toggle the switch at the bottom to turn limits on, and 3. set limits for each product corresponding to the capacity for each in the Thawing Cabinet and Breading Table."
        boxThree.addSubview(textViewThree)
        
        let stockLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        stockLabel.center  = CGPoint(x: 170, y: 100)
        stockLabel.text = "Stocking Cases"
        stockLabel.textColor = .black
        stockLabel.font = labelFont
        
        let boxFour = UIView(frame: CGRect(x: 50, y: 120, width: pageOne.frame.size.width - 100, height: 200))
        boxFour.backgroundColor = .white
        boxFour.layer.borderWidth = 1
        boxFour.layer.masksToBounds = true
        boxFour.layer.cornerRadius = 10
        
        let textViewFour = UITextView(frame: CGRect(x: 0, y: 0, width: pageOne.frame.size.width - 100, height: 200))
        textViewFour.isEditable = false
        textViewFour.font = textViewFont
        textViewFour.text = "To stock cases, 1. select the 'Stock Cases' button on the home screen, which will take you to the Stock Cases Dashboard, 2. select the product you would like to stock, its location, and its destination, 3. from the table to the right, select the cases you would like to stock and press the 'Stock!' button."
        boxFour.addSubview(textViewFour)
        
        let archiveLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        archiveLabel.center = CGPoint(x: 170, y: 350)
        archiveLabel.text = "Archiving Cases"
        archiveLabel.textColor = .black
        archiveLabel.font = labelFont
        
        let boxFive = UIView(frame: CGRect(x: 50, y: 370, width: pageOne.frame.size.width - 100, height: 200))
        boxFive.backgroundColor = .white
        boxFive.layer.borderWidth = 1
        boxFive.layer.masksToBounds = true
        boxFive.layer.cornerRadius = 10
        
        let textViewFive = UITextView(frame: CGRect(x: 0, y: 0, width: pageOne.frame.size.width - 100, height: 200))
        textViewFive.isEditable = false
        textViewFive.font = textViewFont
        textViewFive.text = "After a case in the breading table has been used, its final destination is the Archive. To archive a case, simply stock cases to the Archive destination- this will delete the case from the app, which will allow you to enter a new case with that same number."
        boxFive.addSubview(textViewFive)
        
        let helpLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        helpLabel.center = CGPoint(x: 170, y: 600)
        helpLabel.text = "Help"
        helpLabel.textColor = .black
        helpLabel.font = labelFont
        
        let boxSix = UIView(frame: CGRect(x: 50, y: 620, width: pageOne.frame.size.width - 100, height: 200))
        boxSix.backgroundColor = .white
        boxSix.layer.borderWidth = 1
        boxSix.layer.masksToBounds = true
        boxSix.layer.cornerRadius = 10
        
        let textViewSix = UITextView(frame: CGRect(x: 0, y: 0, width: pageOne.frame.size.width - 100, height: 200))
        textViewSix.isEditable = false
        textViewSix.font = textViewFont
        textViewSix.text = "For any issues or questions regarding this application, feel free to send an email describing your concern to david.jabech@sagacity.ink."
        boxSix.addSubview(textViewSix)
       
        pageOne.addSubview(initialLabel)
        pageOne.addSubview(boxOne)
        pageOne.addSubview(newCasesLabel)
        pageOne.addSubview(boxTwo)
        pageOne.addSubview(limitsLabel)
        pageOne.addSubview(boxThree)
        
        pageTwo.addSubview(stockLabel)
        pageTwo.addSubview(boxFour)
        pageTwo.addSubview(archiveLabel)
        pageTwo.addSubview(boxFive)
        pageTwo.addSubview(helpLabel)
        pageTwo.addSubview(boxSix)
        
        scrollView.addSubview(pageOne)
        scrollView.addSubview(pageTwo)
        
    }
}

extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x / scrollView.frame.size.width)))
    }
}

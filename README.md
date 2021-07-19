# StockSafe
>The cutting-edge, effortless solution for tracking cases of perishable products. StockSafe's unique approach to product management makes cost-efficacy, guest-safety and employee productivity remarkably simple.

## Development Guidelines
* The Email/Password combination for logging into StockSafe on test devices/simulators is: dj96202013@gmail.com/Dj1999dj.
* Consult the ViewDesigner class for basic functions for enhancing views (shadows, gradients, and StockSafe fonts).
* StockSafe follows the "Mediator Design Pattern": mediators (UIViewControllers) mediate the communication and functionality between Colleagues (CaseTables, SelectionViews, managers). This is accomplished with via the ColleagueProtocol and the MediatorProtocol.
* Colleagues fall into 2 categories:
  * ViewViewModels (VVMs) - VVMs merge the functionality of Views and ViewModels by not only configuring, but also presenting the View.
  * Managers - Managers query Firestore for information about Locations, Products, and Cases. Managers also manage the majority of logic involved in passing and changing the data it querys.
* We aim to continue to revise and add comments to code where necessary.
* Quality assurance is to be handled by the developer who has not committed the code (i.e. If David commits changes to the code, Jose reviews them for quality assurance).
* Quality assurance must be completed for ALL kanbans.
* If we fail to find aggreement on some aspect of the project's code (readability, efficiency etc.), we'll consult StackOverflow, Apple Documentation, Angela Yu's Udemy videos, Harsh and/or Faiz for guidance.
* The timeline (found below this section) will be updated weekly with 2-4 broadly defined tasks.
* Kanbans will be under 1 of 4 possible categories: Refactoring, Feature Implementation, Design, or Bugs
* The overarching objective is to be in the process of submitting StockSafe to the app store 10 weeks from the date of this repository's creation (which will be 9/13/2021).
* Let's do this thing.

## Timeline
Week 3 (7/19 - 7/25)
* Fix bugs in NewCasesViewController and in StockCasesViewController
* Add restrictions for product or location adding
* Create ProductInfoViewController and LocationInfoViewController

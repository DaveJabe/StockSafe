# StockSafe
> An effortless solution for tracking cases of perishable products. StockSafe's unique approach to product management prioritizes cost-efficacy, guest-safety and employee productivity.

## Development Guidelines
* The Email/Password combination for logging into StockSafe on test devices/simulators is: dj96202013@gmail.com/Dj1999dj.
* The ViewDesigner class is responsible for basic functions to enhance views (shadows, gradients, and StockSafe fonts).
* StockSafe follows the "Mediator Design Pattern": mediators (UIViewControllers) mediate the communication and functionality between Colleagues (CaseTables, SelectionViews, managers). This is accomplished via the ColleagueProtocol and the MediatorProtocol.
* Colleagues fall into 2 categories:
  * ViewViewModels (VVMs) - VVMs merge the functionality of Views and ViewModels by not only configuring, but also presenting the View.
  * Managers - Managers query Firestore for information about Locations, Products, and Cases. Managers also manage the majority of logic involved in passing and changing the data it querys.

## Application Previews
> Account Creation and Signing In

![CreateAccount](https://user-images.githubusercontent.com/54407429/165979966-f347bd1d-f5f1-4bc9-abe4-1be0d4e8772f.gif)

This video demonstrates account creation in StockSafe (secure text entries are hidden in screen recording).

Here we can see the sign-in process.

> Adding Cases

> Stocking Cases

> Adding a Product

> Adding a Location

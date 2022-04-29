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
https://user-images.githubusercontent.com/54407429/165966948-c0efbaab-7d44-4890-a589-7dce5761c645.mov
This video demonstrates account creation in StockSafe (secure text entries are hidden in screen recording).
https://user-images.githubusercontent.com/54407429/165966990-e6b3a9ed-44cf-4a49-ab6c-9a3c9a39acf8.mov
Here we can see the sign-in process.

> Adding Cases

> Stocking Cases

> Adding a Product

> Adding a Location

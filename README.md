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

![create_account](https://user-images.githubusercontent.com/54407429/165985156-29064b6e-d699-4657-8450-f10f6cb753e4.gif)
* This video demonstrates account creation in StockSafe (secure text entries are hidden in screen recording).

![sign-in](https://user-images.githubusercontent.com/54407429/165985202-10e89706-2632-4356-aee2-6ab40e60a245.gif)
* Here we can see the sign-in process.

> Adding Cases

![add_cases](https://user-images.githubusercontent.com/54407429/165985287-b463f40a-29e5-463c-a74f-e4031f5c9992.gif)

> Stocking Cases

![stock_cases](https://user-images.githubusercontent.com/54407429/165985338-f2cda3a2-8d15-42fa-ab81-858c5d03fd7b.gif)

> Undo/Redo Functions

![undo_redo](https://user-images.githubusercontent.com/54407429/165985419-8cc4563e-57e4-43cb-82b6-a0173289d392.gif)

> Archiving and Replaceing Preexisting Cases

![archive-replace](https://user-images.githubusercontent.com/54407429/165985506-1bacaf3d-e3ea-4dca-9a51-11a08356486b.gif)

> Reseting Shelf-Life

![erase-sl](https://user-images.githubusercontent.com/54407429/165985625-152ead4f-9e07-4bca-b7a9-83bc5623a655.gif)




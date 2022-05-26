# StockSafe
> An alternative solution for tracking cases of perishable products. StockSafe's unique approach to product management prioritizes cost-efficacy, guest-safety and employee productivity. The app idea was validated in a local Chick-Fil-A, replacing the preceding pen-paper log system during its trial. 
> Features: 
* User account creation/sign in
* Add custom products and locations 
* Add and stock cases of products to different locations
* Track shelf lives of cases 
* Bold and effortless UI 
* Notifies users when cases of product expires

## Development Guidelines
* The Email/Password combination for logging into StockSafe on test devices/simulators is: dj96202013@gmail.com/Dj1999dj.
* StockSafe follows the "Mediator Design Pattern": mediators (UIViewControllers) mediate the communication and functionality between Colleagues (CaseTables, SelectionViews, managers). This is accomplished via the ColleagueProtocol and the MediatorProtocol.
* Colleagues fall into 2 categories:
  * UI Elements - These classes both configure and present the view.
  * Managers - Managers query Firestore for information about Locations, Products, and Cases. Managers also manage the majority of logic involved in passing and changing the data it querys.

* The ViewDesigner class is responsible for basic functions to enhance views (shadows, gradients, and StockSafe fonts).

## Application Previews
 
### Account Creation and Signing In

![create_account](https://user-images.githubusercontent.com/54407429/165985156-29064b6e-d699-4657-8450-f10f6cb753e4.gif)
* This video demonstrates account creation in StockSafe (secure text entries are hidden in screen recording). The Firebase Authentication SDK is used for storing users and facilitating the sign-in process.

![sign-in](https://user-images.githubusercontent.com/54407429/165985202-10e89706-2632-4356-aee2-6ab40e60a245.gif)
* The simple email/password sign-in process.


### Adding Cases

![add_cases](https://user-images.githubusercontent.com/54407429/165985287-b463f40a-29e5-463c-a74f-e4031f5c9992.gif)
* In this video, "Strawberries" are selected as the product to be added and "Prep Table" is selected as the location to which cases of the selected product will be added to. Note that a shelf life is automatically assigned to each case upon creation, indicated to the user as days until expiry ("Expires in 4 days"). When cases are added, a unique user ID is generated for a  Firebase Firestore document with attributes corresponding to the case information (i.e. product = "Strawberries", caseNumber = 1, etc.).


### Stocking Cases

![stock_cases](https://user-images.githubusercontent.com/54407429/165985338-f2cda3a2-8d15-42fa-ab81-858c5d03fd7b.gif)
* Here we watch the user move from the "add cases" option (signified by the plus sign at the top left corner) to the "stock cases" option (signified by the two opposing arrows at the top right corner). Cases 23 and 24 of "Blueberries" are selected from the "Cooler" and stocked to the "Prep Table" destination.


### Undo/Redo Functions

![undo_redo](https://user-images.githubusercontent.com/54407429/165985419-8cc4563e-57e4-43cb-82b6-a0173289d392.gif)
* A simple demonstration of the undo and redo functions; the action undone (and then redone) is the addition of a case of "Romaine Lettuce."


### Archiving and Replaceing Preexisting Cases

![archive-replace](https://user-images.githubusercontent.com/54407429/165985506-1bacaf3d-e3ea-4dca-9a51-11a08356486b.gif)
* StockSafe offers the option to archive and replace cases when the user attempts to add cases with preexisting numbers. In this case, we see cases 1, 2 and 3 replaced and given new shelf lives.


### Reseting Shelf-Life

![erase-sl](https://user-images.githubusercontent.com/54407429/165985625-152ead4f-9e07-4bca-b7a9-83bc5623a655.gif)
* StockSafe also offers the option to erase the shelf life of a case (or group of cases). Here we see cases 1, 2 and 3- which were added in the previous video- stocked to what is typically their initial location ("Cooler"). Because the shelf life for the product "Blueberries" has been set by the user to begin at the "Prep Table" location, an alert is presented asking the user whether they would like to erase, not erase, or not stock the cases.


### Menu Options

![menu_options](https://user-images.githubusercontent.com/54407429/166000533-81d61d13-7ccd-43ae-8a4e-8b1bba55b31f.gif)
* A brief video showing the menu pop-up animation along with the other menu options (Note: most of the settings options are not yet functional).


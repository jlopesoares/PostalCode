# WTest

## WTest the Postal Code Explorer

Simple app develop to download and search Portuguese Postal Codes.

## To Run

 1. Open PostalCode.xcodeproj
 2. Wait for the download of Swift Package Dependencies and files processing stage
 3. Run the project on simulator or device

## Notes

 - MVVM Architecture
 - CoreData to persistable data.
 - It was used keyboard observers to handle the tableView margin, however it could be used the tableView property: `keyboardDismissMode` with `onDrag`. I decided to use the observers to make sure the goal to keep all results visible is fullfilled.
 - Some approached would be used on a production project, like:
     - Programmatically developing the UI
     - More realistic network layer
     - The viewModel / repository was built with this approach to allow more flexibility for unit tests. However the dependencies would be changed, to avoid to affect database values while performing the unit tests

# On the Map

#### Description: IOS app that allows a user to post locations containing a url. As well as view other postings within a MKMapView

---

## ViewControllers

Button names and functionality changes throughout the app allowing for a simpler UI. Network request are present, activity Indicators are used to help display the app is currently active.


### LoginViewController

Allows a user to login through a post request with user data from two text fields. Session ID and key is returned from the post request and stored.

Contains:
1. Two text fields allowing users to enter user credentials to Udacity's login API.
2. A single button allows execute the POST request sending credentials to the server.

<img src="readmePic/loginScreen.png" alt="LoginViewController"  width="240">

### MapViewController

Contains:
1. Navigational bar with three buttons logout, refresh and add a pin.
2. Tool bar with a single button that switches to a tableView.
3. MKMapView with clickable annotations (Pins) being displayed with user information.

Users can view locations on the MKMapView, each location is represented by a pin (annotation). When a pin is selected location and url will be displayed with a disclosure button. When pressed again alert will be presented asking if the url should be opened in Safari.

Logout button will preform a delete request with Session data stored from login and taken back to LoginViewController. This button is also used to cancel creating a pin by changing the button title and tag.

#### getPins function

getPins function is used within the view did load and the refresh button. Responsible for preforming a get request for the last 100 student locations and populating the StudentLocation array and MKMapView.


<img src="readmePic/pinsOnMap.png" alt="MapViewController"  width="240">

<img src="readmePic/selectPinOnMap.png" alt="MapViewController"  width="240">

<img src="readmePic/addPins.png" alt="addaPin"  width="240">

### AddPinViewController

Contains:
1. Two text fields allowing user to enter a Location and url.
2. Single button executing a delegate to mapView with location and url data.
3. Navigational bar with a single button canceling creating a pin.

When location and url have been entered and button is pressed. Geocoding of the location will return coordinates of the location, if successful a delegate is triggered passing coordinates, location and url to MapViewController. Cancel button allows a user to go back to the MapViewController.
When delegate is triggered coordinates are used on the map to display the location allowing the user to verify its the correct location

<img src="readmePic/addPin.png" alt="AddPinViewController"  width="240">

### TableViewController

Contains:
1. Navigational bar with a single back button
2. 100 table cells of user locations

Table view will allow a user to find a location faster than using the MapView. A simple segue is used from the MapViewController to enter TableViewController. Each cell contains two labels stacked, one to display the location other to display the url. When a cell is selected a alert will be presented; asking if the url should be opened in Safari.

<img src="readmePic/listView.png" alt="TableViewController"  width="240">

<img src="readmePic/selectPinInTable.png" alt="MapViewController"  width="240">

---

## ErrorHandling

Contains:
1. Custom errors kept in enums
2. Extension alert function
3. Guard throwable functions


Custom errors allow for friendlier messages. Code is kept clean by errors separate from the viewControllers, single alert function displays the error to the user. Throwable functions with guard statements allow for reuse between views.

<img src="readmePic/errorOne.png" alt="Error"  width="240">
<img src="readmePic/nologin.png" alt="Error"  width="240">

```js
enum loginError: Error {
    case empty
    case invalidJson
    case invalidJsonFromUser
    case invalidAccount
    case invalidServer
    case invalidConnection
}

extension loginError: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty: return "Empty Email or Password"
        case .invalidJsonFromUser: return "Internal Error"
        case .invalidJson: return "Unable to read message from server."
        case .invalidAccount: return "Invalid Email or Password"
        case .invalidServer: return "Server offline"
        case .invalidConnection: return "Unable to connect to server"
        }
    }
}

```

---

## Request

All JSON encodings are done through codable structs.

### Endpoints

Endpoints are constructed using a struct to store strings and URLComponents to build a URL. This system allows for query to be added and kept separate from the viewController.

```js
struct onTheMapEndpoint {
    static let scheme = "https"
    static let host = "onthemap-api.udacity.com"
    static let path = "/v1/session"
    static let pathTolocations = "/v1/StudentLocation"
}

var onthemapComponents:URLComponents{
    var components = URLComponents()
    components.scheme = onTheMapEndpoint.scheme
    components.host = onTheMapEndpoint.host
    components.path = onTheMapEndpoint.path
    return components
}

```



### Request functions

Post, Get and Delete request functions are all fairly similar. The idea is to make flexible functions that allow for easy reuse. Set time out interval is added to prevent hanging requests. If a request hangs longer than the set time out interval nil values will be returned. Post request takes two inputs url and json data while get and delete just url. Url param is the endpoint and json data is the payload. Three optional values are returned data, response and error, optional allow for nils to be returned. No error handling is done in the request.   

Example POST request
```js
public func postRequest(url:URL,jsonRequest:String,completionBlock:  @escaping  (Data?,URLResponse?,Error?)  -> Void) -> Void{
    var request = URLRequest(url:url,timeoutInterval: 5.0)
    request.httpMethod = "POST"
    request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(restApiKey,forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonRequest.data(using: .utf8)
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
            DispatchQueue.main.async  {
                completionBlock(data,response ,error)
            }
    }
    task.resume()
}
```

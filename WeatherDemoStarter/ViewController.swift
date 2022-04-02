//
//  ViewController.swift
//  WeatherDemoStarter
//
//  Created by Dumidu Sumanasekara on 2022-04-01.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var conditionText: UILabel!
    
    
    let locationManager = CLLocationManager()
    let mf = MeasurementFormatter()
    
    var weatherCode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mf.locale = Locale(identifier: "en_GB")

        // this is to set up if user wants to use return key to search first we conform to UITextFieldDelegate
        searchText.delegate = self
                
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemMint, .systemYellow, .systemMint])
        weatherImage.preferredSymbolConfiguration = config
        let imageName = returnImageName(code: weatherCode)
        print(imageName)
        weatherImage.image = UIImage(systemName: imageName)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print(textField.text ?? "")
        textField.endEditing(true)
        getWeather(search: textField.text)
        return true
    }
    
    // check the code and return the image
    func returnImageName(code: Int) -> String {
        
        switch code {
            
        case 1000:
            return "sun.max.fill"
        case 1003:
            return "cloud.sun.fill"
        case 1006:
            return "cloud.sun.fill"
        case 1009:
            return "cloud.fill"
        case 1030:
            return "smoke.fill"
        case 1063:
            return "cloud.sun.rain.fill"
        case 1066:
            return "cloud.sleet.fill"
        case 1069:
            return "cloud.sleet.fill"
        case 1072:
            return "cloud.snow.fill"
        case 1087:
            return "cloud.bolt.fill"
        case 1114:
            return "wind.snow.fill"
        case 1117:
            return "tornado"
        case 1135:
            return "cloud.fog.fill"
        case 1147:
            return "cloud.snow.fill"
        case 1150:
            return "cloud.drizzle.fill"
        case 1153:
            return "cloud.drizzle.fill"
        case 1168:
            return "cloud.sleet.fill"
        case 1171:
            return "cloud.snow.fill"
        case 1180:
            return "cloud.sun.rain.fill"
        case 1183:
            return "cloud.sun.rain.fill"
        case 1186:
            return "cloud.sun.rain.fill"
        case 1189:
            return "cloud.sun.rain.fill"
        case 1192:
            return "cloud.heavyrain.fill"
        case 1195:
            return "cloud.heavyrain.fill"
        case 1198:
            return "cloud.sleet.fill"
        case 1201:
            return "cloud.sleet.fill"
        case 1204:
            return "cloud.sleet.fill"
        case 1207:
            return "cloud.sleet.fill"
        case 1210:
            return "cloud.sleet.fill"
        case 1213:
            return "cloud.sleet.fill"
        case 1216:
            return "cloud.snow.fill"
        case 1219:
            return "cloud.snow.fill"
        case 1222:
            return "cloud.snow.fill"
        case 1225:
            return "snowflake"
        case 1237:
            return "snowflake"
        case 1240:
            return "cloud.sun.rain.fill"
        case 1243:
            return "cloud.rain.fill"
        case 1246:
            return "cloud.heavyrain.fill"
        case 1249:
            return "cloud.sleet.fill"
        case 1252:
            return "cloud.sleet.fill"
        case 1255:
            return "cloud.snow.fill"
        case 1258:
            return "cloud.snow.fill"
        case 1261:
            return "cloud.snow.fill"
        case 1264:
            return "cloud.snow.fill"
        case 1273:
            return "cloud.bolt.rain.fill"
        case 1276:
            return "cloud.bolt.rain.fill"
        case 1279:
            return "cloud.snow.fill"
        case 1282:
            return "cloud.snow.fill"
        default:
            return "sun.max.fill"
        }
        
    }
    
    // weather list
    var weatherList = [123:"pisse"]
    
    

    @IBAction func onSearchTapped(_ sender: UIButton) {

        // better way is to handle the optional inside the getWeather func
//        if let typedText = searchText.text {
//            getWeather(search: typedText)
//        } else {
//            print("text search is empty")
//        }
        searchText.endEditing(true)
        getWeather(search: searchText.text)
        
    }
    
    
    @IBAction func onMyLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    // better arrpoach is to let the func handle the optional this way
    private func getWeather(search: String?) {
        
        guard let searchText = search else {
            return
        }

        // step 1: getting the url
        let url = getUrl(searchKey: searchText)
        
        guard let url = url else {
            print("could not get the URL")
            return
        }
        
        // step 2: create URL session
        let session = URLSession.shared
        
        // step 3: create task session
        let dataTask = session.dataTask(with: url) { data, response, error in
            
            print("network call complete")
            // network call finished
            
            guard error == nil else {
                print("received error")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
        
            print("No error")
            
            if let weather = self.parseJson(data: data){
                print(weather.location.name)
                print(weather.current.temp_c)
                
                self.weatherCode = weather.current.condition.code
                print("code: \(self.weatherCode)")
                //print(self.weatherCode)
                
                // set to labels to display
                
                // need to change the thread because ui elements are in the main thread. and we are doing this network call in a different thread.
                
                DispatchQueue.main.async {
                    
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemMint, .systemYellow, .white])
                    self.weatherImage.preferredSymbolConfiguration = config
                    let imageName = self.returnImageName(code: self.weatherCode)
                    print(imageName)
                    self.weatherImage.image = UIImage(systemName: imageName)
                    self.locationLabel.text = weather.location.name
                    let temp = Measurement(value: Double(weather.current.temp_c), unit: UnitTemperature.celsius)
                    //self.tempLabel.text = "\(weather.current.temp_c)C"
                    self.tempLabel.text = self.mf.string(from: temp)
                    self.conditionText.text = weather.current.condition.text
                    
                }
                
                
            }
            
        }
        
        // step 4: start the task
        dataTask.resume()
    }
    
    
    private func parseJson(data: Data) -> WeatherResponse? {
        
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        
        // error could throw while decoding
        do {
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error parsing weather")
            print(error)
        }
        
        return weatherResponse
        
    }
    
    
    private func getUrl(searchKey: String) -> URL? {
        
        // usually do not expose key in production
        let apiKey = "4cb59ae950a04f59b2e204322220104"
        
        // good idea to stick to https rather than http
        let baseUrl = "https://api.weatherapi.com/v1/"
        
        let currentEndPoint = "current.json"
        
        let url = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(searchKey)"
 
        return URL(string: url)
        
    }
    
    
}


struct WeatherResponse: Decodable{
    let location: Location
    let current: CurrentWeather
}


struct Location: Decodable{
    let name:String
}

struct CurrentWeather: Decodable{
    let temp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable{
    let text: String
    let icon: String
    let code: Int
}






extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got locations")
        
        if let location = locations.last {
            let lattitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            //displayLocation(location: "LatLng: (\(lattitude), \(longitude))")
            print("LatLng: (\(lattitude), \(longitude))")
            let currentLocation: String = "\(lattitude),\(longitude)"
            getWeather(search: currentLocation)

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


/*
 
 [

 {
 "code": 1150,
 "day": "Patchy light drizzle",
 "night": "Patchy light drizzle",
 "icon": 263
 "symbol": "cloud.drizzle.fill"
 },
 {
 "code": 1153,
 "day": "Light drizzle",
 "night": "Light drizzle",
 "icon": 266
 "symbol": "cloud.drizzle.fill"
 },
 {
 "code": 1168,
 "day": "Freezing drizzle",
 "night": "Freezing drizzle",
 "icon": 281
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1171,
 "day": "Heavy freezing drizzle",
 "night": "Heavy freezing drizzle",
 "icon": 284
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1180,
 "day": "Patchy light rain",
 "night": "Patchy light rain",
 "icon": 293
 "symbol": "cloud.sun.rain.fill"
 },
 {
 "code": 1183,
 "day": "Light rain",
 "night": "Light rain",
 "icon": 296
 "symbol": "cloud.sun.rain.fill"
 },
 {
 "code": 1186,
 "day": "Moderate rain at times",
 "night": "Moderate rain at times",
 "icon": 299
 "symbol": "cloud.sun.rain.fill"
 },
 {
 "code": 1189,
 "day": "Moderate rain",
 "night": "Moderate rain",
 "icon": 302
 "symbol": "cloud.sun.rain.fill"
 },
 {
 "code": 1192,
 "day": "Heavy rain at times",
 "night": "Heavy rain at times",
 "icon": 305
 "symbol": "cloud.heavyrain.fill"
 },
 {
 "code": 1195,
 "day": "Heavy rain",
 "night": "Heavy rain",
 "icon": 308
 "symbol": "cloud.heavyrain.fill"
 },
 {
 "code": 1198,
 "day": "Light freezing rain",
 "night": "Light freezing rain",
 "icon": 311
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1201,
 "day": "Moderate or heavy freezing rain",
 "night": "Moderate or heavy freezing rain",
 "icon": 314
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1204,
 "day": "Light sleet",
 "night": "Light sleet",
 "icon": 317
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1207,
 "day": "Moderate or heavy sleet",
 "night": "Moderate or heavy sleet",
 "icon": 320
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1210,
 "day": "Patchy light snow",
 "night": "Patchy light snow",
 "icon": 323
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1213,
 "day": "Light snow",
 "night": "Light snow",
 "icon": 326
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1216,
 "day": "Patchy moderate snow",
 "night": "Patchy moderate snow",
 "icon": 329
 },
 {
 "code": 1219,
 "day": "Moderate snow",
 "night": "Moderate snow",
 "icon": 332
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1222,
 "day": "Patchy heavy snow",
 "night": "Patchy heavy snow",
 "icon": 335
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1225,
 "day": "Heavy snow",
 "night": "Heavy snow",
 "icon": 338
 "symbol": "snowflake"
 },
 {
 "code": 1237,
 "day": "Ice pellets",
 "night": "Ice pellets",
 "icon": 350
 "symbol": "snowflake"
 },
 {
 "code": 1240,
 "day": "Light rain shower",
 "night": "Light rain shower",
 "icon": 353
 "symbol": "cloud.sun.rain.fill"
 },
 {
 "code": 1243,
 "day": "Moderate or heavy rain shower",
 "night": "Moderate or heavy rain shower",
 "icon": 356
 "symbol": "cloud.rain.fill"
 },
 {
 "code": 1246,
 "day": "Torrential rain shower",
 "night": "Torrential rain shower",
 "icon": 359
 "symbol": "cloud.heavyrain.fill"
 },
 {
 "code": 1249,
 "day": "Light sleet showers",
 "night": "Light sleet showers",
 "icon": 362
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1252,
 "day": "Moderate or heavy sleet showers",
 "night": "Moderate or heavy sleet showers",
 "icon": 365
 "symbol": "cloud.sleet.fill"
 },
 {
 "code": 1255,
 "day": "Light snow showers",
 "night": "Light snow showers",
 "icon": 368
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1258,
 "day": "Moderate or heavy snow showers",
 "night": "Moderate or heavy snow showers",
 "icon": 371
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1261,
 "day": "Light showers of ice pellets",
 "night": "Light showers of ice pellets",
 "icon": 374
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1264,
 "day": "Moderate or heavy showers of ice pellets",
 "night": "Moderate or heavy showers of ice pellets",
 "icon": 377
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1273,
 "day": "Patchy light rain with thunder",
 "night": "Patchy light rain with thunder",
 "icon": 386
 "symbol": "cloud.bolt.rain.fill"
 },
 {
 "code": 1276,
 "day": "Moderate or heavy rain with thunder",
 "night": "Moderate or heavy rain with thunder",
 "icon": 389
 "symbol": "cloud.bolt.rain.fill"
 },
 {
 "code": 1279,
 "day": "Patchy light snow with thunder",
 "night": "Patchy light snow with thunder",
 "icon": 392
 "symbol": "cloud.snow.fill"
 },
 {
 "code": 1282,
 "day": "Moderate or heavy snow with thunder",
 "night": "Moderate or heavy snow with thunder",
 "icon": 395
 "symbol": "cloud.snow.fill"
 }
 ]
 
 
 */

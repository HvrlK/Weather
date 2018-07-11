import Foundation

//MARK: - Protocols

protocol OpenWeatherMapDelegate: class {
    func fetched(_ controller: OpenWeatherMapController)
}

//MARK: - Classes

class OpenWeatherMapController {
    
    //MARK: - Properties
    
    var weather: Weather?
    var weatherList: [Weather]?
    var currentTask: URLSessionTask?
    weak var delegate: OpenWeatherMapDelegate?
    
    //MARK: - Methods
    
    func search(longitude: Double, latitude: Double) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&lon=\(longitude)&lat=\(latitude)&units=metric") else {
            print("Couldn't create URL")
            return
        }
        let session = URLSession(configuration: .default)
        currentTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard let weather = try? JSONDecoder().decode(Weather.self, from: responseData) else {
                print("Couldn't decode data into Weather")
                return
            }
            self.weather = weather
            self.delegate?.fetched(self)
        }
        currentTask?.resume()
    }
    
    func search(cityIds: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/group?&id=\(cityIds)&APPID=\(API.key)&units=metric") else {
            print("Couldn't create URL")
            return
        }
        let session = URLSession(configuration: .default)
        currentTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard let weather = try? JSONDecoder().decode(List.self, from: responseData) else {
                print("Couldn't decode data into Weather")
                return
            }
            self.weatherList = weather.list
            self.delegate?.fetched(self)
        }
        currentTask?.resume()
    }

}

//MARK: - Enums

private enum API {
    static let key = "9b082b6bbd7a77d48d3c8092ae107cd8"
}

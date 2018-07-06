import Foundation

protocol OpenWeatherMapDelegate: class {
    func fetched(_ controller: OpenWeatherMapController)
}

class OpenWeatherMapController {
    
    var weather: [Weather]?
    var currentTask: URLSessionTask?
    weak var delegate: OpenWeatherMapDelegate?
    
    func searchByCity(city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&q=\(city)&units=metric") else {
            print("Couldn't create URL")
            return
        }
        fetchData(url: url)
    }
    
    func searchByLocation(longitude: Double, latitude: Double) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&lon=\(longitude)&lat=\(latitude)&units=metric") else {
            print("Couldn't create URL")
            return
        }
        fetchData(url: url)
    }
    
    func searchBySeveralCities(cityIds: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/group?&id=\(cityIds)&APPID=\(API.key)&units=metric") else {
            print("Couldn't create URL")
            return
        }
        fetchData(url: url)
    }
    
    func fetchData(url: URL) {
        currentTask?.cancel()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        currentTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
//            print(responseData)
//            guard let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {return}
//            print(json)
            if let weather = try? JSONDecoder().decode(List.self, from: responseData) {
                self.weather = weather.list
            } else {
                if let weather = try? JSONDecoder().decode(Weather.self, from: responseData) {
                    self.weather = [weather]
                } else {
                    print("Couldn't decode data into Weather")
                    return
                }
            }
            self.delegate?.fetched(self)
        }
        currentTask?.resume()
    }

}

private enum API {
    static let key = "9b082b6bbd7a77d48d3c8092ae107cd8"
}

import Foundation

//MARK: - Protocols

protocol OpenWeatherMapDelegate: class {
    func fetched(_ controller: OpenWeatherMapController)
}

//MARK: - Classes

class OpenWeatherMapController {
    
    //MARK: - Properties
    
    var weather: [Weather]?
    var currentTask: URLSessionTask?
    weak var delegate: OpenWeatherMapDelegate?
    
    //MARK: - Methods
    
    func search(city: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&q=\(city)&units=metric")
        fetchData(url: url)
    }
    
    func search(longitude: Double, latitude: Double) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&lon=\(longitude)&lat=\(latitude)&units=metric")
        fetchData(url: url)
    }
    
    func search(cityIds: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/group?&id=\(cityIds)&APPID=\(API.key)&units=metric")
        fetchData(url: url)
    }
    
    func fetchData(url: URL?) {
        guard let url = url else {
            print("Couldn't create URL")
            return
        }
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

//MARK: - Enums

private enum API {
    static let key = "9b082b6bbd7a77d48d3c8092ae107cd8"
}

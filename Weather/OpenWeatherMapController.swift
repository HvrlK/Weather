import Foundation

protocol OpenWeatherMapDelegate: class {
    func fetched(_ controller: OpenWeatherMapController)
}

class OpenWeatherMapController {
    
    var weather: Weather?
    
    weak var delegate: OpenWeatherMapDelegate?
    
    func fetchData() {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&\(API.key)&q=Kiev&units=metric")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url!) { (data, response, error) in
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
        task.resume()
    }

}

private enum API {
    static let key = "id=524901&APPID=9b082b6bbd7a77d48d3c8092ae107cd8"
}

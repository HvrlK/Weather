import Foundation

//MARK: - Protocols

protocol OpenWeatherMapDelegate: class {
    func fetchedWeather(_ controller: OpenWeatherMapController)
    func fetchedCities(_ controller: OpenWeatherMapController)
    func fetchedNewCity(_ controller: OpenWeatherMapController)
    func fetchedForecast(_ controller: OpenWeatherMapController)
}

//MARK: - Extensions

extension OpenWeatherMapDelegate {
    func fetchedWeather(_ controller: OpenWeatherMapController) {}
    func fetchedCities(_ controller: OpenWeatherMapController) {}
    func fetchedNewCity(_ controller: OpenWeatherMapController) {}
    func fetchedForecast(_ controller: OpenWeatherMapController) {}
}

//MARK: - Classes

class OpenWeatherMapController {
    
    //MARK: - Properties
    
    weak var delegate: OpenWeatherMapDelegate?
    var weather: Weather?
    var weatherList: [Weather]?
    var currentTask: URLSessionTask?
    var newCityId: String?
    private var searchType: SearchType = .none
    
    //MARK: - Methods
    
    func search(longitude: Double, latitude: Double) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&lon=\(longitude)&lat=\(latitude)&units=metric")
        searchType = .coordinate
        fetchData(url: url)
    }
    
    func search(cityIds: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/group?&id=\(cityIds)&APPID=\(API.key)&units=metric")
        searchType = .ids
        fetchData(url: url)
    }
    
    func search(zip: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?&APPID=\(API.key)&zip=\(zip)&units=metric")
        searchType = .zip
        fetchData(url: url)
    }
    
    func fetchData(url: URL?) {
        guard let url = url else {
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
            switch self.searchType {
            case .coordinate, .zip:
                guard let weather = try? JSONDecoder().decode(Weather.self, from: responseData) else {
                    print("Couldn't decode data into Weather")
                    return
                }
                if self.searchType == .coordinate {
                    self.weather = weather
                    self.delegate?.fetchedWeather(self)
                } else {
                    self.newCityId = weather.id.description
                    self.delegate?.fetchedNewCity(self)
                }
            case .ids:
                guard let weather = try? JSONDecoder().decode(List.self, from: responseData) else {
                    print("Couldn't decode data into List of Weather")
                    return
                }
                self.weatherList = weather.list
                self.delegate?.fetchedCities(self)
            case .none:
                return
            }
//            self.delegate?.fetched(self)
            self.searchType = .none
        }
        currentTask?.resume()
    }

}

//MARK: - Enums

private enum API {
    static let key = "9b082b6bbd7a77d48d3c8092ae107cd8"
}

private enum SearchType {
    case none
    case coordinate
    case ids
    case zip
}

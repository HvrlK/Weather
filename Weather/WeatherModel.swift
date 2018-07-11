import Foundation

//MARK: - Structures

struct List: Codable {
    let list: [Weather]
}

struct Weather: Codable {
    let name: String
    let main: MainInfo
    let coord: Coordinate
    let wind: Wind
    let id: Int
    let sys: System
}

struct MainInfo: Codable {
    let temp: Double
    let pressure: Int
    let humidity: Double
}

struct Coordinate: Codable {
    let lon: Double
    let lat: Double
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct System: Codable {
    let country: String
}


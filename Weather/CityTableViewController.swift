//
//  CityTableViewController.swift
//  Weather
//
//  Created by Vitalii Havryliuk on 7/6/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit
import CoreLocation

class CityTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    var weatherInCurrentLocation: Weather?
    let weatherController = OpenWeatherMapController()
    var weatherList: [Weather]?
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherController.search(cityIds: "524901,703448,2172797")
        weatherController.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let weatherList = weatherList {
            return weatherList.count
        }
        return 0
    }

    @IBAction func showWeatherInCurrentLocation(_ sender: UIBarButtonItem) {
        locationManager.startUpdatingLocation()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        if let weatherList = weatherList {
            cell.textLabel?.text = weatherList[indexPath.row].name + ", " + weatherList[indexPath.row].sys.country
            cell.detailTextLabel?.text = Int(weatherList[indexPath.row].main.temp).description + "°C"
        }
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let detailWeather = segue.destination as? DetailWeatherViewController, let indexPath = tableView.indexPathForSelectedRow, let weatherList = weatherList {
                let weather = weatherList[indexPath.row]
                detailWeather.weatherController.search(longitude: weather.coord.lon, latitude: weather.coord.lat)
            }
        }
        if segue.identifier == "CurrentWeather" {
            if let detailWeatherViewController = segue.destination as? DetailWeatherViewController {
                detailWeatherViewController.weatherForCurrentLocation()
            }
        }
    }

}

//MARK: - Extensions

extension CityTableViewController: OpenWeatherMapDelegate {
    
    func fetched(_ controller: OpenWeatherMapController) {
        guard let weatherList = controller.weatherList else { return }
        self.weatherList = weatherList
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}



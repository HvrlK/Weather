//
//  ViewController.swift
//  Weather
//
//  Created by Vitalii Havryliuk on 7/5/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit
import CoreLocation

//MARK: - Classes

class DetailWeatherViewController: UIViewController {
    
    //MARK: - Properties
    
    var weather: Weather?
    let locationManager = CLLocationManager()
    let weatherController = OpenWeatherMapController()
    
    //MARK: - Outlets
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
//
    @IBAction func startButtonTapped() {
        weatherController.search(city: "Rivne")
    }
//
    
    //MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        weatherController.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        weatherController.currentTask?.cancel()
    }
    
    func updateUI() {
        if let weather = weather {
            cityLabel.text = weather.name
            humidityLabel.text = weather.main.humidity.description + "%"
            temperatureLabel.text = Int(weather.main.temp).description + "°C"
            pressureLabel.text = weather.main.pressure.description + "hPa"
            windLabel.text = weather.wind.speed.description + "m/sec" 
        } else {
            cityLabel.text = "--"
            humidityLabel.text = "--"
            temperatureLabel.text = "--"
            pressureLabel.text = "--"
            windLabel.text = "--"
        }
    }
    
    func weatherForCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }


}

//MARK: - Extensions

extension DetailWeatherViewController: OpenWeatherMapDelegate {
    
    func fetched(_ controller: OpenWeatherMapController) {
        if let weather = controller.weather {
            self.weather = weather[0]
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }
    
}

extension DetailWeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        weatherController.search(longitude: locationValue.longitude, latitude: locationValue.latitude)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//
        print("Error with location")
//        
    }
}



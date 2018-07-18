//
//  CityTableViewController.swift
//  Weather
//
//  Created by Vitalii Havryliuk on 7/6/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CityTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    var weatherInCurrentLocation: Weather?
    let weatherController = OpenWeatherMapController()
    var weatherList: [Weather]?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherController.delegate = self
        createStringWithId()
    }
    
    func createStringWithId() {
        let cities = fetchSavedCity()
        guard !cities.isEmpty else { return }
        var idString = cities[0].id
        if cities.count > 1 {
            for cityIndex in 1..<cities.count {
                idString += ",\(cities[cityIndex].id)"
            }
        }
        weatherController.search(cityIds: idString)
    }
    
    func fetchSavedCity() -> [Cities] {
        let fetchRequest = NSFetchRequest<Cities>(entityName: "Cities")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            return try appDelegate.managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("Fetch data error: \(error)")
        }
    }
    
    func createZip(text: String) -> String {
        return text.split(separator: " ").joined(separator: ",")
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        if let weatherList = weatherList {
            cell.textLabel?.text = weatherList[indexPath.row].name + ", " + weatherList[indexPath.row].sys.country
            cell.detailTextLabel?.text = Int(weatherList[indexPath.row].main.temp).description + "°C"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            appDelegate.managedObjectContext.delete(fetchSavedCity()[indexPath.row])
            do {
                try appDelegate.managedObjectContext.save()
            } catch {
                fatalError("Can't save data")
            }
            weatherList?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
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
    
    //MARK: - Actions
    
    @IBAction func showWeatherInCurrentLocation(_ sender: UIBarButtonItem) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func addCityButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Please, enter zip and country codes", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let textFields = alert.textFields, let text = textFields[0].text else { return }
            self.weatherController.search(zip: self.createZip(text: text))
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "Example: 94040 us"
        }
        present(alert, animated: true)
    }
    
}

//MARK: - Extensions

extension CityTableViewController: OpenWeatherMapDelegate {
    
    func fetchedNewCity(_ controller: OpenWeatherMapController) {
        guard let newCityId = controller.newCityId else { return }
        let newCity = Cities(context: appDelegate.managedObjectContext)
        newCity.id = newCityId
        do {
            try appDelegate.managedObjectContext.save()
        } catch {
            fatalError("Can't save new city")
        }
        DispatchQueue.main.async {
            self.createStringWithId()
        }
    }
    
    func fetchedCities(_ controller: OpenWeatherMapController) {
        guard let weatherList = controller.weatherList else { return }
        self.weatherList = weatherList
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}



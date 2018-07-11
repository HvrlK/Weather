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
    
    let locationManager = CLLocationManager()
    
    var weatherInCurrentLocation: Weather?

    let weatherController = OpenWeatherMapController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    @IBAction func showWeatherInCurrentLocation(_ sender: UIBarButtonItem) {
        locationManager.startUpdatingLocation()
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailWeatherViewController = segue.destination as? DetailWeatherViewController {
            detailWeatherViewController.weatherForCurrentLocation()
        }
    }
 

}



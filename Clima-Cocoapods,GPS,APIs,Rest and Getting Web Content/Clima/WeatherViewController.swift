//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation     //not open source
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate ,ChangeCityDelegate{
    
    var count:Int = 0
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "c09226363f88eceda92bb77d1ccfa445"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()       //一個小寫 一個大寫

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self     //讓自己成為處理loaction資訊的代表
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //取得精準度
        locationManager.requestWhenInUseAuthorization() //要求授權
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking    連結到server
    /***************************************************************/
    //Write the getWeatherData method here:
    func getWeatherData(url:String , parameters:[String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Got the weather Data")
                let weatherJSON:JSON = JSON(response.result.value!)
                self.updateWeatherData(json:weatherJSON)
                if self.count == 0 {
                     print(weatherJSON)
                     self.count += 1
                }
            }
            else{   //if have error
                print("Error\(response.error)")
                self.cityLabel.text = "connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing  取得server回傳的數值
    /***************************************************************/
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        if let tempResult = json["main"]["temp"].double{
             //原先tempResult要用! unroll ,但是若有錯(e.g.id打錯)程式就會當掉,造成使用者體驗不良,因此使用if let判斷是否有出錯
            weatherDataModel.temperature = Int(tempResult - 273.150)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue  //數值不能加""
            weatherDataModel.weatherIconName =  weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
            UIUpdate()  //更新數值後記得更新介面
        }
        else{
            cityLabel.text = "weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates    更新數值
    /***************************************************************/
    func UIUpdate(){
        //Label中的text一直都只吃String
        cityLabel.text = String(weatherDataModel.city)      //String()與\()意思一樣
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named:weatherDataModel.weatherIconName)
        
       // print(weatherDataModel.condition)
    }
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy>0 {
            locationManager.stopUpdatingLocation()
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            //建立字典
            let params:[String:String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city:String){
        
        let params : [String:String] = ["q" : city , "appid" : APP_ID]  //經由openweathermap.org網頁得知q是代表cityname
        print(city)
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
}



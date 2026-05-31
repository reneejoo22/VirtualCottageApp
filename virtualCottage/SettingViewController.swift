//
//  SettingViewController.swift
//  virtualCottage
//
//  Created by 주희연 on 5/25/26.
//

import UIKit
import AVFoundation
import UserNotifications
import CoreLocation

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var rainSlider: UISlider!
    @IBOutlet weak var fireSlider: UISlider!
    @IBOutlet weak var keyboardSlider: UISlider!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var cityPicker: UIPickerView!
    
    let cities = ["📍 현재 위치", "🌧 런던", "🌧 체라푼지", "🌧 마나우스",  "❄️ 무르만스크","❄️ 야쿠츠크", "❄️ 헬싱키", "☀️ 두바이", "🌫 샌프란시스코", "🌤 서울"]
    let cityKeys = ["current", "London","Cherrapunji","Manaus", "Murmansk","Yakutsk","Helsinki", "Dubai", "San Francisco", "Seoul"]
    let displayName = ["현재 위치", "런던", "체라푼지", "마나우스","무르만스크", "야쿠츠크","헬싱키", "두바이", "샌프란시스코", "서울"]
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedValues()
        
        
        cityPicker.delegate = self
        cityPicker.dataSource = self
        
        // 저장된 도시 선택 복원
        let saved = UserDefaults.standard.string(forKey: "selectedCity") ?? "current"
        let index = cityKeys.firstIndex(of: saved) ?? 0
        cityPicker.selectRow(index, inComponent: 0, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncSlidersWithHomeSound()
    }

    func syncSlidersWithHomeSound() {
        guard let homeVC = getHomeVC() else { return }
        
        // 홈 VC의 실제 플레이어 볼륨을 슬라이더에 반영
        rainSlider.value = homeVC.rainPlayer?.volume ?? UserDefaults.standard.float(forKey: "rainVolume")
        fireSlider.value = homeVC.firePlayer?.volume ?? UserDefaults.standard.float(forKey: "fireVolume")
        keyboardSlider.value = homeVC.keyboardPlayer?.volume ?? UserDefaults.standard.float(forKey: "keyboardVolume")
    }

    func getHomeVC() -> HomeViewController? {
        return tabBarController?.viewControllers?.first as? HomeViewController
    }
    
    // ✅ 피커뷰 DataSource
        func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return cities.count
        }
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return cities[row]
        }
        
        // ✅ 도시 선택 시 동작
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedKey = cityKeys[row]
            UserDefaults.standard.set(selectedKey, forKey: "selectedCity")
            
            if selectedKey == "current" {
                // 현재 위치 사용
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestLocation()
            } else {
                // 선택한 도시로 날씨 갱신
                notifyHomeToUpdateWeather(city: selectedKey)
            }
        }
        
        // ✅ 현재 위치 받으면 홈에 전달
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let loc = locations.first else { return }
            notifyHomeToUpdateWeatherByCoord(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            notifyHomeToUpdateWeather(city: "Seoul")
        }
        
        // ✅ 홈화면에 날씨 업데이트 요청
        func notifyHomeToUpdateWeather(city: String) {
            NotificationCenter.default.post(
                name: Notification.Name("updateWeatherByCity"),
                object: nil,
                userInfo: ["city": city, "displayName": displayName]
            )
        }
        func notifyHomeToUpdateWeatherByCoord(lat: Double, lon: Double) {
            NotificationCenter.default.post(
                name: Notification.Name("updateWeatherByCoord"),
                object: nil,
                userInfo: ["lat": lat, "lon": lon]
            )
        }
    
    // MARK: - 저장된 값 불러오기
    func loadSavedValues() {
        // 저장된 값 있으면 불러오기, 없으면 기본값
        if UserDefaults.standard.object(forKey: "rainVolume") != nil {
            rainSlider.value = UserDefaults.standard.float(forKey: "rainVolume")
            fireSlider.value = UserDefaults.standard.float(forKey: "fireVolume")
            keyboardSlider.value = UserDefaults.standard.float(forKey: "keyboardVolume")
        } else {
            // 처음 실행 기본값
            rainSlider.value = 0.5
            fireSlider.value = 0.3
            keyboardSlider.value = 0.3
            
            // 기본값 저장
            UserDefaults.standard.set(Float(0.5), forKey: "rainVolume")
            UserDefaults.standard.set(Float(0.3), forKey: "fireVolume")
            UserDefaults.standard.set(Float(0.3), forKey: "keyboardVolume")
        }
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationOn")
        updateHomeSound()
    }
    // MARK: - IBActions
    @IBAction func rainSliderChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "rainVolume")
        updateHomeSound()
    }
    
    @IBAction func fireSliderChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "fireVolume")
        updateHomeSound()
    }
    
    @IBAction func keyboardSliderChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "keyboardVolume")
        updateHomeSound()
    }
    
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        
        UserDefaults.standard.set(sender.isOn, forKey: "notificationOn")
        if sender.isOn {
            requestNotificationPermission()
        }
    }
    

    
    // MARK: - 홈화면 소리 업데이트
    func updateHomeSound() {
        guard let homeVC = getHomeVC() else { return }
        homeVC.playBackgroundSound(
            rain: rainSlider.value,
            fire: fireSlider.value,
            keyboard: keyboardSlider.value
        )
    }
//    func updateHomeSound() {
//        guard let tabBar = tabBarController,
//              let homeNav = tabBar.viewControllers?.first,
//              let homeVC = (homeNav as? UINavigationController)?.topViewController as? HomeViewController
//                ?? tabBar.viewControllers?.first as? HomeViewController
//        else { return }
//        
//        homeVC.playBackgroundSound(
//            rain: rainSlider.value,
//            fire: fireSlider.value,
//            keyboard: keyboardSlider.value
//        )
//    }
    
    // MARK: - 알림 권한 요청
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    self.notificationSwitch.isOn = false
                    UserDefaults.standard.set(false, forKey: "notificationOn")
                }
            }
        }
    }
}

//
//  ViewController.swift
//  virtualCottage
//
//  Created by 주희연 on 5/19/26.
//
import UIKit
import AVFoundation
import CoreLocation
import WebKit

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var aiLabel: UILabel!
    @IBOutlet weak var focusTimeField: UITextField!
    @IBOutlet weak var restTimeField: UITextField!
    @IBOutlet weak var sessionCountField: UITextField!
    
    // MARK: - Timer UI (코드로 생성)
    var timerContainerView = UIView()
    var timerLabel = UILabel()
    var sessionLabel = UILabel()
    var pauseButton = UIButton(type: .system)
    var stopButton = UIButton(type: .system)
    var circleLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    var todoToggleButton = UIButton(type: .system)
    var collapsedTodoView = UIView()
    
    
    // weather
    var locationManager = CLLocationManager()
    
    // 소리
    var rainPlayer: AVAudioPlayer?
    var firePlayer: AVAudioPlayer?
    var keyboardPlayer: AVAudioPlayer?
    
    
    // MARK: - Properties
    //    var todos: [String] = []
    // 더미값
    struct TodoItem {
        var text: String
        var isChecked: Bool
        var createdAt: Date
        
        var timeString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d HH:mm"
            return formatter.string(from: createdAt)
        }
    }

    // todos 변경
    var todos: [TodoItem] = [
        TodoItem(text: "ios프로그래밍 보고서 작성", isChecked: false, createdAt: Date()),
        TodoItem(text: "커피 테이크아웃", isChecked: false, createdAt: Date()),
        TodoItem(text: "소설책 읽기", isChecked: false, createdAt: Date())
    ]
    var isTodoExpanded = true
    var focusMinutes = 5
    var restMinutes = 1
    var sessionCount = 1
    var currentSession = 1
    var isFocusing = false
    var timer: Timer?
    var remainingSeconds = 0
    var totalSeconds = 0
    var circleDidSetup = false
    var audioPlayer: AVAudioPlayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupTimerUI()
        setupLocation()
        preloadSounds()
        //fetchWeather()
        
        
        weatherLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        weatherLabel.layer.cornerRadius = 12
        weatherLabel.clipsToBounds = true
        weatherLabel.textColor = .white
        weatherLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        weatherLabel.text = "  🌤 날씨 로딩중  "
        
        // 1. 최대 줄 수 제한 없애기 (0으로 설정하면 글자 길이에 맞춰 무한 줄바꿈)
        aiLabel.numberOfLines = 0
        aiLabel.lineBreakMode = .byWordWrapping
        aiLabel.textAlignment = .center // 글자 가운데 정렬
        
        
        popupView.addSubview(aiLabel)
        aiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 💡 여기에 제약조건 코드를 넣어줍니다!
        NSLayoutConstraint.activate([
            aiLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            aiLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            aiLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 80)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCityWeather(_:)),
            name: Notification.Name("updateWeatherByCity"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCoordWeather(_:)),
            name: Notification.Name("updateWeatherByCoord"), object: nil)
    }
    
    
    
    @objc func handleCityWeather(_ notification: Notification) {
        guard let city = notification.userInfo?["city"] as? String else { return }
        let apiKey = "100de131c8fd83b78baa33db251d3344"
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric&lang=kr"
        guard let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let weather = (json["weather"] as? [[String: Any]])?.first,
                  let main = weather["main"] as? String,
                  let desc = weather["description"] as? String,
                  let temp = (json["main"] as? [String: Any])?["temp"] as? Double
            else { return }
            DispatchQueue.main.async {
                // city 파라미터로 받은 영어 키로 인덱스 찾기
                let displayName = notification.userInfo?["displayName"] as? String ?? city
                self.weatherLabel.text = "  🌤 \(displayName) \(Int(temp))°C · \(desc)  "
                self.updateBackground(weather: main)
            }
        }.resume()
    }

    @objc func handleCoordWeather(_ notification: Notification) {
        guard let lat = notification.userInfo?["lat"] as? Double,
              let lon = notification.userInfo?["lon"] as? Double else { return }
        fetchWeather(lat: lat, lon: lon)
    }
    
    func preloadSounds() {
        let rain = UserDefaults.standard.object(forKey: "rainVolume") != nil
            ? UserDefaults.standard.float(forKey: "rainVolume") : Float(0.5)
        let fire = UserDefaults.standard.object(forKey: "fireVolume") != nil
            ? UserDefaults.standard.float(forKey: "fireVolume") : Float(0.3)
        let keyboard = UserDefaults.standard.object(forKey: "keyboardVolume") != nil
            ? UserDefaults.standard.float(forKey: "keyboardVolume") : Float(0.3)
        
        playSound(player: &rainPlayer, name: "rain_sound", volume: rain)
        playSound(player: &firePlayer, name: "fire_sound", volume: fire)
        playSound(player: &keyboardPlayer, name: "keyboard_sound", volume: keyboard)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !circleDidSetup && view.frame.width > 0 {
            setupCircleTimer()
            circleDidSetup = true
        }
    }
    
    
    
    // MARK: - Setup
    func setupUI() {
        popupView.isHidden = true
        popupView.layer.cornerRadius = 16
        popupView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "cottage_home.png")
        backgroundImageView.clipsToBounds = true
        
        focusTimeField.text = "5"
        restTimeField.text = "1"
        sessionCountField.text = "1"
        focusTimeField.keyboardType = .numberPad
        restTimeField.keyboardType = .numberPad
        sessionCountField.keyboardType = .numberPad
        
        todoTableView.layer.cornerRadius = 16
        todoTableView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
    }
    
    func playBackgroundSound(rain: Float, fire: Float, keyboard: Float) {
        playSound(player: &rainPlayer, name: "rainSound", volume: rain)
        playSound(player: &firePlayer, name: "fireplaceSound", volume: fire)
        playSound(player: &keyboardPlayer, name: "keyboardSound", volume: keyboard)
    }

    func playSound(player: inout AVAudioPlayer?, name: String, volume: Float) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        if player == nil {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // 무한반복
            player?.prepareToPlay()
        }
        player?.volume = volume
        if volume > 0 { player?.play() }
        else { player?.pause() }
    }
    
    func setupTableView() {
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }
    


    @objc func minusTapped() {
        remainingSeconds = max(0, remainingSeconds - 60)  // ✅ 0 아래로 안 내려감
        totalSeconds = max(0, totalSeconds - 60)
        updateTimerUI()
    }

    @objc func minusLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
                self.remainingSeconds = max(0, self.remainingSeconds - 60)
                self.totalSeconds = max(0, self.totalSeconds - 60)
                self.updateTimerUI()
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            longPressTimer?.invalidate()
            longPressTimer = nil
        }
    }

    @objc func plusTapped() {
        remainingSeconds += 60
        totalSeconds += 60
        updateTimerUI()
    }
    var longPressTimer: Timer?


    @objc func plusLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
                self.remainingSeconds += 60
                self.totalSeconds += 60
                self.updateTimerUI()
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            longPressTimer?.invalidate()
            longPressTimer = nil
        }
    }
    
    func setupTimerUI() {
        // 컨테이너 (배경 투명!)
        timerContainerView.translatesAutoresizingMaskIntoConstraints = false
        timerContainerView.isUserInteractionEnabled = true
        timerContainerView.backgroundColor = .clear
        timerContainerView.isHidden = true
        view.addSubview(timerContainerView)
        
        // 타이머 라벨
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "25:00"
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 52, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.layer.shadowColor = UIColor.black.cgColor
        timerLabel.layer.shadowOpacity = 0.5
        timerLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        timerContainerView.addSubview(timerLabel)
        
        // 세션 라벨
        sessionLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionLabel.text = "🔥 1번째 세션"
        sessionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sessionLabel.textColor = .white
        sessionLabel.textAlignment = .center
        sessionLabel.layer.shadowColor = UIColor.black.cgColor
        sessionLabel.layer.shadowOpacity = 0.5
        sessionLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        timerContainerView.addSubview(sessionLabel)
        
        
        
        // - 버튼
        let minusButton = UIButton(type: .system)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        minusButton.setTitleColor(.white, for: .normal)
        minusButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        minusButton.layer.cornerRadius = 20
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        timerContainerView.addSubview(minusButton)
        
        // + 버튼
        let plusButton = UIButton(type: .system)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        plusButton.layer.cornerRadius = 20
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        timerContainerView.addSubview(plusButton)
        // 롱프레스 추가
        let minusLong = UILongPressGestureRecognizer(target: self, action: #selector(minusLongPress(_:)))
        minusLong.minimumPressDuration = 0.4
        minusButton.addGestureRecognizer(minusLong)

        let plusLong = UILongPressGestureRecognizer(target: self, action: #selector(plusLongPress(_:)))
        plusLong.minimumPressDuration = 0.4
        plusButton.addGestureRecognizer(plusLong)

        // 제약 — 타이머 원형 바로 아래 중앙
        NSLayoutConstraint.activate([
            minusButton.widthAnchor.constraint(equalToConstant: 40),
            minusButton.heightAnchor.constraint(equalToConstant: 40),
            minusButton.centerYAnchor.constraint(equalTo: timerLabel.centerYAnchor),
            minusButton.centerYAnchor.constraint(equalTo: timerLabel.centerYAnchor),
            minusButton.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -40),
            
            plusButton.widthAnchor.constraint(equalToConstant: 40),
            plusButton.heightAnchor.constraint(equalToConstant: 40),
            plusButton.centerYAnchor.constraint(equalTo: timerLabel.centerYAnchor),
            plusButton.leadingAnchor.constraint(equalTo: timerLabel.trailingAnchor, constant: 40),
        ])
        
        // 일시정지 버튼
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.setTitle("일시정지", for: .normal)
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        pauseButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        pauseButton.layer.cornerRadius = 12
        pauseButton.layer.borderWidth = 1
        pauseButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        timerContainerView.addSubview(pauseButton)
        
        // 종료 버튼
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.setTitle("종료", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        stopButton.backgroundColor = UIColor(red: 91/255, green: 138/255, blue: 111/255, alpha: 0.9)
        stopButton.layer.cornerRadius = 12
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        timerContainerView.addSubview(stopButton)
        
        // 제약
        NSLayoutConstraint.activate([
            timerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            timerContainerView.bottomAnchor.constraint(equalTo: todoTableView.topAnchor),
            //timerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            timerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timerContainerView.centerYAnchor, constant: -20),
            
            sessionLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            sessionLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8),
            
            pauseButton.leadingAnchor.constraint(equalTo: timerContainerView.leadingAnchor, constant: 24),
            pauseButton.bottomAnchor.constraint(equalTo: timerContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pauseButton.heightAnchor.constraint(equalToConstant: 52),
            pauseButton.widthAnchor.constraint(equalTo: timerContainerView.widthAnchor, multiplier: 0.44),
            
            stopButton.trailingAnchor.constraint(equalTo: timerContainerView.trailingAnchor, constant: -24),
            stopButton.bottomAnchor.constraint(equalTo: timerContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stopButton.heightAnchor.constraint(equalToConstant: 52),
            stopButton.widthAnchor.constraint(equalTo: timerContainerView.widthAnchor, multiplier: 0.44),
        ])
    }
    
    
    
    func setupCircleTimer() {
        let centerX = view.frame.width / 2
        let centerY = view.frame.height / 4 // 2 - 20
        let center = CGPoint(x: centerX, y: centerY)
        let radius: CGFloat = 110
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: -CGFloat.pi / 2,
                                endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
                                clockwise: true)
        circleLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        circleLayer.lineWidth = 10
        timerContainerView.layer.addSublayer(circleLayer)
        
        progressLayer.path = path.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(red: 91/255, green: 138/255, blue: 111/255, alpha: 1).cgColor
        progressLayer.lineWidth = 10
        progressLayer.strokeEnd = 1.0
        progressLayer.lineCap = .round
        timerContainerView.layer.addSublayer(progressLayer)
    }


    func updateBackground(weather: String) {
        switch weather.lowercased() {
        case "rain", "drizzle", "haze", "thunderstorm":
            backgroundImageView.image = UIImage(named: "rainy.png")
            playBackgroundSound(rain: 0.7, fire: 0.0, keyboard: 0.0)
        case "snow":
            backgroundImageView.image = UIImage(named: "snowy.png")
            playBackgroundSound(rain: 0.0, fire: 0.5, keyboard: 0.0)
        case "clouds", "mist", "fog", "smoke", "dust", "sand", "ash":
            backgroundImageView.image = UIImage(named: "foggy.png")
            playBackgroundSound(rain: 0.0, fire: 0.0, keyboard: 0.5)
        default:
            backgroundImageView.image = UIImage(named: "cottage_home.png")
            playBackgroundSound(rain: 0.0, fire: 0.3, keyboard: 0.0)
        }
    }
    
    // MARK: - Gemini AI
    func callGeminiAI() {
        // ⚠️ 1. 실제 발급받은 올바른 API 키인지 확인하세요!
        let apiKey = "AIzaSyB-slMK5zmoz-9UIsp9yZsmpiz9CVzDJq0"
        
        // ⚠️ 2. 모델명을 gemini-1.5-flash로 업데이트하는 것을 권장합니다.
//        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=\(apiKey)") else { return }
        
        // 💡 가볍고 널널한 2.5-flash-lite 모델로 변경!
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=\(apiKey)") else { return }
        
        let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR") // 한국어 설정
            formatter.dateFormat = "a h시 m분" // 오전 1시 5분 형식
            let currentTimeString = formatter.string(from: Date()) // 현재 시간 글자로 변환
        //let todoText = todos.isEmpty ? "할일 없음" : todos.joined(separator: ", ")
        let todoText = todos
            .filter { !$0.isChecked }  // 체크 안 된 것만
            .map { $0.text }
            .joined(separator: ", ")
        let todoText2 = todoText.isEmpty ? "할일 없음" : todoText
        
        let prompt = "현재 시간: \(currentTimeString). 할일 목록: \(todoText). 가장 오래 걸릴 작업과 추천 집중 시간을 딱 한 줄로 한국어로 말해줘. / persona: 당신은 어느 숲속의 코티지 주인이며 이곳에 할일을 하러 오는 인간 방문자들을 늘 반갑게 맞이하는 역할입니다./ 말투: 현재 시간에 맞춰서 센스 있게 인사하기(예: 새벽이면 새벽 인사를, 낮이면 낮 인사를), 친절 친근, 동기부여, 웃는 이모티콘 사용하거나 꽃이나 식물 등 관련된 이모티콘 붙이기. 100자 이내로./ 예시: 졸린 새벽 1시네요! ㅇㅇ작업이 오래 걸릴거예요, 1시간 집중 어때요? / 인삿말 참고: 밤 인사 드려요 방문자님 or 나른한 오후 3시네요 or 아침, 점심, 저녁 시간이면 밥 먹었는지 묻기"
        
        // / persona: 당신은 어느 숲속의 코티지 주인이며 이곳에 할일을 하러 오는 인간 방문자들을 반갑게 맞이하는 역할입니다.
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "contents": [["parts": [["text": prompt]]]]
        ])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러가 발생했는지 먼저 확인
            if let error = error {
                print("네트워크 에러 발생:", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("데이터가 비어있습니다.")
                return
            }
            
            // 디버깅용: 서버에서 실제로 준 전체 응답을 글자로 출력해봅니다.
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Gemini Response String:\n", jsonString)
            }
            
            // JSON 파싱 순차적 진행
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("JSON 변환 실패")
                    return
                }
                
                guard let candidates = json["candidates"] as? [[String: Any]],
                      let content = candidates.first?["content"] as? [String: Any],
                      let parts = content["parts"] as? [[String: Any]],
                      let text = parts.first?["text"] as? String else {
                    print("Gemini가 에러를 반환했거나 JSON 구조가 다릅니다. 위 Response String을 확인하세요.")
                    return
                }
                
                // UI 업데이트는 메인 스레드에서
                DispatchQueue.main.async {
                    let cleanText = text.replacingOccurrences(of: "**", with: "")
                    self.aiLabel.text = cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
            } catch {
                print("파싱 에러:", error)
            }
        }.resume()
    }

    // MARK: - 타이머
    func startTimer() {
        focusMinutes = Int(focusTimeField.text ?? "5") ?? 5
        restMinutes  = Int(restTimeField.text  ?? "1")  ?? 1
        sessionCount = Int(sessionCountField.text ?? "1") ?? 1
        currentSession = 1
        isFocusing = true
        remainingSeconds = focusMinutes * 60
        totalSeconds = focusMinutes * 60
        updateTimerUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.remainingSeconds -= 1
            self.updateTimerUI()
            if self.remainingSeconds <= 0 { self.switchSession() }
        }
    }

    func playBell() {
        guard let url = Bundle.main.url(forResource: "bell_sound", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("벨소리 에러:", error)
        }
    }
    
    func switchSession() {
        sendNotification() 
        playBell()
        if isFocusing {
            isFocusing = false
            remainingSeconds = restMinutes * 60
            totalSeconds = restMinutes * 60
        } else {
            currentSession += 1
            if currentSession > sessionCount {
                timer?.invalidate()
                showCompletionAlert()
                return
            }
            isFocusing = true
            remainingSeconds = focusMinutes * 60
            totalSeconds = focusMinutes * 60
        }
    }
    
    func sendNotification() {
        guard UserDefaults.standard.bool(forKey: "notificationOn") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🏡 Smart Virtual Cottage"
        content.body = isFocusing ? "집중 세션 완료! 잠깐 쉬어가요 ☕" : "휴식 끝! 다시 집중해봐요 🔥"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func updateTimerUI() {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", m, s)
        sessionLabel.text = isFocusing ? "🔥 \(currentSession)번째 세션" : "☕ 휴식 중"
        let progress = totalSeconds > 0 ? CGFloat(remainingSeconds) / CGFloat(totalSeconds) : 0
        progressLayer.strokeEnd = progress
    }
    

    
    func showCompletionAlert() {
        let checkedTodos = todos.filter { $0.isChecked }.map { $0.text }
        let elapsedSeconds = totalSeconds - remainingSeconds
        var elapsedMinutes = elapsedSeconds / 60
        
        
        if elapsedMinutes == 0 {
                elapsedMinutes = 1
        }
        
        if checkedTodos.isEmpty {
            // 체크한 게 없으면 그냥 팝업
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "완료! 🎉", message: "모든 세션을 완료했어요!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in self.endFocus() })
                self.present(alert, animated: true)
            }
        } else {
            // 체크한 게 있으면 Gemini 칭찬 호출
            //let totalFocusedMinutes = focusDurationPerSession * currentSession
            callGeminiCompletion(checkedTodos: checkedTodos, durationMinutes: elapsedMinutes)
        }
    }

    func callGeminiCompletion(checkedTodos: [String], durationMinutes: Int) {
        let apiKey = "AIzaSyB-slMK5zmoz-9UIsp9yZsmpiz9CVzDJq0"
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=\(apiKey)") else { return }
        
        let doneText = checkedTodos.joined(separator: ", ")
        let timeText: String
            if durationMinutes >= 60 {
                let hours = durationMinutes / 60
                let minutes = durationMinutes % 60
                timeText = minutes > 0 ? "\(hours)시간 \(minutes)분" : "\(hours)시간"
            } else {
                timeText = "\(durationMinutes)분"
            }
            
        let prompt = "사용자가 무려 \(timeText) 동안 엄청나게 집중해서 '\(doneText)' 할일을 끝냈어. 코티지 주인 페르소나로 우와 \(timeText) 동안 n가지 일들을 해내다니 대단해요! 같은 뉘앙스로 60자 이내로 짧고 다정하게 칭찬해줘. 이모티콘 포함. 한국어로. 예시: 2시간동안 집중해서 보고서 작성을 마쳤어요 수고했어요!"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "contents": [["parts": [["text": prompt]]]]
        ])
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "완료! 🎉", message: "모든 세션을 완료했어요!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in self.endFocus() })
                    self.present(alert, animated: true)
                }
                return
            }
            DispatchQueue.main.async {
                let clean = text.replacingOccurrences(of: "**", with: "")
                let alert = UIAlertController(title: "완료! 🎉", message: clean, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in self.endFocus() })
                self.present(alert, animated: true)
            }
        }.resume()
    }
    
    func saveSessionToday(minutes: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "focus_\(Int(today.timeIntervalSince1970))"
        let existing = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(existing + minutes, forKey: key)
        print("✅ 저장: \(existing + minutes)분") // 콘솔 확인용
    }
    func endFocus() {
        saveSessionToday(minutes: focusMinutes)
        timer?.invalidate()
        timer = nil
        timerContainerView.isHidden = true
        startButton.isHidden = false
        todoTableView.isHidden = false
        weatherLabel.isHidden = false
        backgroundImageView.image = UIImage(named: "cottage_home.png")
        currentSession = 1
        sessionLabel.text = "🔥 1번째 세션"
        pauseButton.setTitle("일시정지", for: .normal)
        progressLayer.strokeEnd = 1.0
        
    }
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        callGeminiAI()
        popupView.isHidden = false
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        popupView.isHidden = true
    }
    
    @IBAction func confirmTapped(_ sender: UIButton) {
        popupView.isHidden = true
        backgroundImageView.image = UIImage(named: "cottage_home2.jpg")
        startButton.isHidden = true
        weatherLabel.isHidden = true
        timerContainerView.isHidden = false
        
        startTimer()
//        popupView.isHidden = true
//        backgroundImageView.image = UIImage(named: "cottage_home2.jpg")
//        startButton.isHidden = true
//        //todoTableView.isHidden = true
//        weatherLabel.isHidden = true
//        //timerContainerView.isHidden = false
//        // timerContainerView bottom을 todoTableView top으로
//        timerContainerView.bottomAnchor.constraint(equalTo: todoTableView.topAnchor)
//        startTimer()
    }
    
    @IBAction func toggleTodo(_ sender: UIButton) {
        isTodoExpanded.toggle()
        todoTableView.isHidden = !isTodoExpanded
    }
    
    @objc func pauseTapped() {
        if timer?.isValid == true {
            timer?.invalidate()
            pauseButton.setTitle("계속하기", for: .normal)
        } else {
            pauseButton.setTitle("일시정지", for: .normal)
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.remainingSeconds -= 1
                self.updateTimerUI()
                if self.remainingSeconds <= 0 { self.switchSession() }
            }
        }
    }
    
    @objc func stopTapped() {
        let alert = UIAlertController(title: "조기 종료", message: "집중을 종료하시겠습니까?", preferredStyle: .alert)
        
        // ⭐️ [수정된 부분] "종료"를 누르면 타이머만 무효화하고 제미나이 칭찬 팝업을 띄웁니다!
        alert.addAction(UIAlertAction(title: "종료", style: .destructive) { _ in
            //self.saveSessionToday(minutes: self.focusMinutes)
            // 1. 타이머를 먼저 멈춥니다.
            self.timer?.invalidate()
            self.timer = nil
            
            // 2. 제미나이 칭찬 및 완료 팝업을 호출합니다.
            // (이 팝업에서 '확인'을 누르면 알아서 내부적으로 self.endFocus()를 호출하게 연동되어 있습니다!)
            self.showCompletionAlert()
        })
        
        alert.addAction(UIAlertAction(title: "계속하기", style: .cancel))
        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todos.isEmpty {
                return 2 // + 추가 버튼 + Empty State 셀
            }
            return todos.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 0번째 = + 추가 버튼
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell")
                ?? UITableViewCell(style: .default, reuseIdentifier: "AddCell")
            cell.textLabel?.text = "+ 할일 추가"
            cell.textLabel?.textColor = .gray
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        if todos.isEmpty && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell")
                ?? UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
            cell.textLabel?.text = "🌿 할일을 추가하고 집중을 시작해 보세요!"
            cell.textLabel?.textColor = UIColor.systemGray2
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }

        
        // 나머지 = 투두 셀
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as? TodoCell
            ?? TodoCell(style: .default, reuseIdentifier: "TodoCell")
        let todo = todos[indexPath.row - 1]
        cell.todoLabel.text = todo.text
        cell.timeLabel.text = todo.timeString
        cell.isChecked = todo.isChecked
        cell.todoLabel.attributedText = nil
        cell.todoLabel.text = todo.text
        cell.todoLabel.textColor = todo.isChecked ? .lightGray : .darkText
        cell.checkButton.isSelected = todo.isChecked

        // 체크된 거면 줄긋기
        if todo.isChecked {
            cell.todoLabel.attributedText = NSAttributedString(
                string: todo.text,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                             .foregroundColor: UIColor.lightGray])
        }
        
        cell.onCheck = {
            self.todos[indexPath.row - 1].isChecked = cell.isChecked
        }
        cell.onDelete = {
            self.todos.remove(at: indexPath.row - 1)
            tableView.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "할일 추가", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "할일을 입력하세요" }
            alert.addAction(UIAlertAction(title: "추가", style: .default) { _ in
                if let text = alert.textFields?.first?.text, !text.isEmpty {
                    self.todos.append(TodoItem(text: text, isChecked: false, createdAt: Date()))
                    self.todoTableView.reloadData()
                }
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    
    // viewDidLoad에 추가
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // 위치 받으면 자동 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        fetchWeather(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 위치 실패시 서울로 기본값
        fetchWeather(lat: 37.5665, lon: 126.9780)
    }
    
    // fetchWeather 수정
    func fetchWeather(lat: Double, lon: Double) {
        let apiKey = "100de131c8fd83b78baa33db251d3344"
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=kr"
        guard let url = URL(string: urlStr) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let weather = (json["weather"] as? [[String: Any]])?.first,
                  let desc = weather["description"] as? String,
                  let main = weather["main"] as? String,
                  let temp = (json["main"] as? [String: Any])?["temp"] as? Double
            else { return }
            DispatchQueue.main.async {
                //self.weatherLabel.text = "  🌤 \(Int(temp))°C · \(desc)  "
                self.weatherLabel.text = "  🌤 내 위치 \(Int(temp))°C · \(desc)  "
                self.updateBackground(weather: main)
                print(weather)
            }
        }.resume()
    }
    
}


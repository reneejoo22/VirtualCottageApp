//
//  StatsViewController.swift
//  virtualCottage
//
//  Created by renee on 6/1/26.
//

import UIKit

class StatsViewController: UIViewController {
    
    let days = ["월", "화", "수", "목", "금", "토", "일"]
    var weekMinutes: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "cottage_home") ?? .systemBackground
        weekMinutes = loadWeekData()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 오늘 데이터 초기화
//        let today = Calendar.current.startOfDay(for: Date())
//        let key = "focus_\(Int(today.timeIntervalSince1970))"
//        UserDefaults.standard.removeObject(forKey: key)
        
        weekMinutes = loadWeekData()
        view.subviews.forEach { $0.removeFromSuperview() }
        setupUI()
    }
    func callGeminiStats(label: UILabel) {
        let total = weekMinutes.reduce(0, +)
        //let avg = total / 7
        //let maxDay = ["월","화","수","목","금","토","일"][weekMinutes.firstIndex(of: weekMinutes.max() ?? 0) ?? 0]
        //let streak = weekMinutes.filter { $0 > 0 }.count
        
        let randomSeed = Int.random(in: 1...9999)
        let prompt = "(\(randomSeed)). 이 어플은 뽀모도로 Virtual Cottage 라는 앱이야. 사용자가 이번 주 총 \(total)분 집중했어. 너는 코티지 주인 페르소나로 20자 이내로 짧게 따뜻하게 칭찬해줘. 이모티콘 포함. 한국어로. 존댓말. 사용자를 방문자님으로 부르기. 이번 주 열심히 공부한 방문자님께 따뜻하고 유쾌하게 한마디 건네줘./예시: 이번주 공부를 열심히 하셨어요! 이대로만 쭉 가봐요!"
        
        //let apiKey = ""
//        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=\(apiKey)") else { return }
//
        guard let url = URL(string: "https://gemini-proxy.reneejoo22.workers.dev") else { return }
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
                  let text = parts.first?["text"] as? String else { return }
            DispatchQueue.main.async {
                label.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }.resume()
    }
    
    
    func loadWeekData() -> [Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday == 1) ? -6 : -(weekday - 2)
        
        // 더미 기본값 (월~일)
        let todayIndex = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        var dummyData = [45, 90, 30, 120, 60, 5, 25]
        dummyData[todayIndex] = 0
        
        return (0..<7).map { i in
            guard let day = calendar.date(byAdding: .day, value: mondayOffset + i, to: today) else { return dummyData[i] }
            let key = "focus_\(Int(day.timeIntervalSince1970))"
            let saved = UserDefaults.standard.integer(forKey: key)
            
            // 오늘인지 확인
            let isToday = calendar.isDateInToday(day)
            
            if isToday {
                return dummyData[i] + saved  // ✅ 오늘은 더미 + 실제 누적
            } else {
                return dummyData[i]  // 나머지는 더미 그대로
            }
        }
    }
    
    func setupUI() {
        // 배경
        let bg = UIImageView(image: UIImage(named: "cottage_home"))
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 카드 뷰
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        // 제목
        let title = UILabel()
        title.text = "이번 주 집중 기록 🔥"
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(title)
        
        // 총 집중시간
        let total = weekMinutes.reduce(0, +)
        let totalHour = total / 60
        let totalMin = total % 60
        let totalLabel = UILabel()
        totalLabel.text = "총 \(totalHour)시간 \(totalMin)분 집중했어요 ✨"
        totalLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        totalLabel.textColor = UIColor(red: 91/255, green: 138/255, blue: 111/255, alpha: 1)
        totalLabel.textAlignment = .center
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(totalLabel)
        
        // 막대그래프 스택
        let barStack = UIStackView()
        barStack.axis = .horizontal
        barStack.distribution = .fillEqually
        barStack.alignment = .bottom
        barStack.spacing = 8
        barStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(barStack)
        
        // 분석 라벨
        let avgMinutes = weekMinutes.reduce(0, +) / 7
        let maxDay = days[weekMinutes.firstIndex(of: weekMinutes.max() ?? 0) ?? 0]
        let streak = weekMinutes.filter { $0 > 0 }.count

        let analysisLabel = UILabel()
        analysisLabel.numberOfLines = 0
        analysisLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        analysisLabel.textColor = .darkGray
        analysisLabel.translatesAutoresizingMaskIntoConstraints = false

        let text = """
        📈 하루 평균 집중시간: \(avgMinutes)분
        🏆 최고 집중 요일: \(maxDay)요일 (\(weekMinutes.max() ?? 0)분)
        🔥 이번 주 \(streak)일 집중 달성!
        """
        analysisLabel.text = text
        card.addSubview(analysisLabel)

        NSLayoutConstraint.activate([
            analysisLabel.topAnchor.constraint(equalTo: barStack.bottomAnchor, constant: 16),
            analysisLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            analysisLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            //analysisLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        
        let maxMinutes = weekMinutes.max() ?? 1
        let maxBarHeight: CGFloat = 120
        
        for (i, min) in weekMinutes.enumerated() {
            let todayIndex = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
                
            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 4
            
            // 시간 라벨
            let minLabel = UILabel()
            minLabel.text = min > 0 ? "\(min)m" : ""
            minLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            minLabel.textColor = .darkGray
            col.addArrangedSubview(minLabel)
            
            // 막대
            let bar = UIView()
            let height = min == 0 ? 4 : CGFloat(min) / CGFloat(maxMinutes) * maxBarHeight
            bar.backgroundColor = UIColor(red: 91/255, green: 138/255, blue: 111/255, alpha: min == 0 ? 0.2 : 0.85)
            bar.layer.cornerRadius = 6
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: height).isActive = true
            bar.widthAnchor.constraint(equalToConstant: 28).isActive = true
            col.addArrangedSubview(bar)
            
            // 요일
            let dayLabel = UILabel()
            dayLabel.text = days[i]
            dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            dayLabel.textColor = .darkGray
            col.addArrangedSubview(dayLabel)
            
            barStack.addArrangedSubview(col)
            
            
            dayLabel.font = (i == todayIndex)
                    ? UIFont.systemFont(ofSize: 12, weight: .bold)
                    : UIFont.systemFont(ofSize: 12, weight: .medium)
                dayLabel.textColor = (i == todayIndex)
                    ? UIColor(red: 91/255, green: 138/255, blue: 111/255, alpha: 1)
                    : .darkGray
        }
        
        
        // Gemini 한줄평 라벨
        let geminiLabel = UILabel()
        geminiLabel.numberOfLines = 0
        geminiLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        geminiLabel.textColor = .darkGray
        geminiLabel.textAlignment = .center
        geminiLabel.text = "✨ 코티지 주인 기록 읽는 중..."
        geminiLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(geminiLabel)

        NSLayoutConstraint.activate([
            geminiLabel.topAnchor.constraint(equalTo: analysisLabel.bottomAnchor, constant: 12),
            geminiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            geminiLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            geminiLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        // analysisLabel bottom 제약 삭제하고 이걸로 교체
        // analysisLabel.bottomAnchor ~ 이 줄 제거!

        callGeminiStats(label: geminiLabel)
        
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            title.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            totalLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            totalLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            barStack.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 24),
            barStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            barStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            //barStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            barStack.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
}

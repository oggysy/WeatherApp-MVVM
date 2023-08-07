//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by 小木曽 佑介 on 2023/08/04.
//

import WidgetKit
import SwiftUI
import Intents
import Alamofire

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), iconImage: UIImage(named: "sample") ?? UIImage(), weatherData: sampleWidget)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(date: Date(), iconImage: UIImage(named: "sample") ?? UIImage(), weatherData: sampleWidget)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // UserDefaultsから位置情報を取得
        let sharedDefaults = UserDefaults(suiteName: "group.com.yuusuke.ogiso.WeatherApp-MVVM")
        let latitude = sharedDefaults?.string(forKey: "latitude")
        let longitude = sharedDefaults?.string(forKey: "longitude")
        
        guard let latitude = latitude, let longitude = longitude else {
            return
        }
        
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&lang=ja&appid=5dfc577c1d7d94e9e23a00431582f1ac"
        Task {
            do {
                let decodedData = try await WidgetAPICaller.fetchWeatherData(from: url)
                let iconURL = "https://openweathermap.org/img/wn/\(decodedData.weather[0].icon)@2x.png"
                let iconImage = try await WidgetAPICaller.fetchIconImage(from: iconURL)
                let entry = WeatherEntry(date: Date(), iconImage: iconImage, weatherData: decodedData)
                // 30分後にスケジューリング
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } catch {
                print("Error: \(error)")
                let entry = WeatherEntry(date: Date(), iconImage: UIImage(), weatherData: sampleWidget)
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))) // 1時間後に再試行
                completion(timeline)
            }
        }
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let iconImage: UIImage
    let weatherData: WidgetWeatherData
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(entry.weatherData.dt.changeTimeString() + "現在").font(.caption2)
                        Text(entry.weatherData.name).font(.caption2)
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(String(format: "%.1f", entry.weatherData.main.temp)) .font(.title2)
                            Text("℃").font(.caption2).padding(.bottom, 2)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "drop").font(.caption2)
                            Text(String(entry.weatherData.main.humidity) + "%").font(.caption2)
                        }
                        HStack(spacing: 5){
                            Image(systemName: "barometer").font(.caption2)
                            Text(String(entry.weatherData.main.pressure) + "hPa").font(.caption2)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "wind").font(.caption2)
                            Text(String(entry.weatherData.wind.speed) + "/ms").font(.caption2)
                        }
                    }
                    Spacer()
                }
                .frame(width: (geo.size.width - 30) * 0.6)
                VStack {
                    Image(uiImage: entry.iconImage)
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }
                .frame(width: (geo.size.width - 30) * 0.4)
            }
            .padding(15)
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("WeatherApp-MVVM")
        .description("現在の天気情報を表示します")
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: WeatherEntry(date: Date(), iconImage: UIImage(named: "sample") ?? UIImage(), weatherData: sampleWidget))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

import Foundation

struct WeatherDetailViewModel {
    let cityName: String
    let temperature: String
    let forecasts: [WeatherDetailForecastViewModel]
}

struct WeatherDetailForecastViewModel {
    let day: String
    let temp: String
}

protocol WeatherDetailPresenter: class {
    func loadContent()
}

class WeatherDetailDefaultPresenter: WeatherDetailPresenter {
    
    let interactor: WeatherDetailInteractor
    weak var view: WeatherDetailView?
    
    required init(interactor: WeatherDetailInteractor, view: WeatherDetailView) {
        self.interactor = interactor
        self.view = view
    }
    
    // MARK: - WeatherDetailPresenter
    
    func loadContent() {
        self.view?.displayLoading()
        self.interactor.fetchWeather {(result) in
            switch result {
            case .Success(let weather):
                let vm = self.buildViewModel(weather)
                self.view?.displayWeatherDetail(vm)
                break
            case .Failure(let reason):
                self.view?.displayError(reason.localizedDescription)
            }
        }
    }
    
    private func buildViewModel(data: Weather) -> WeatherDetailViewModel {
        var forecasts = [WeatherDetailForecastViewModel]()
        
        let df = NSDateFormatter()
        df.dateFormat = "EEEE"
        var date = NSDate()
        
        for temp in data.forecastInDays {
            let day = df.stringFromDate(date)
            
            let forecast = WeatherDetailForecastViewModel(day: day, temp: temp + data.temperatureUnit)
            forecasts.append(forecast)
            
            date = date.dateByAddingTimeInterval(24 * 60 * 60)
        }
        
        return WeatherDetailViewModel(cityName: data.locationName,
                                      temperature: data.temperature + data.temperatureUnit,
                                      forecasts: forecasts)
    }
    
}

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(_ CoinManager: CoinManager, coin: CoinModel)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8F0A7A1C-9A3B-498D-816A-8EF1FDD3BE2A"
    
    let currencyArray = ["TRY", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR","AUD"]
    
    var delegate : CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        guard let url = URL(string: "https://rest.coinapi.io/v1/exchangerate/BTC/\(currency)?apikey=\(apiKey)") else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data,response,error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            if let safeData = data {
                if let coin = self.parseJSON(safeData) {
                    delegate?.didUpdateCurrency(self, coin: coin)
                }
            }
            
        }
        task.resume()
    }
    
    func parseJSON(_ data:Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let currencyName = decodedData.asset_id_quote
            let coin = CoinModel(currency: lastPrice, currencyName: currencyName)
            return coin
        }catch{
            print(error.localizedDescription)
            return nil
        }
        
    }
    
}

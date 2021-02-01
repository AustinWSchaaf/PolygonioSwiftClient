//
//  PolygonioSwiftClient.swift
//
//  Created by Austin Schaaf on 1/22/21.
//  Copyright © 2021 Austin Schaaf. All rights reserved.
//

import Foundation

//Http wrapper
public class Request{
    private static let session = URLSession.shared
    
    public static func http(url: URL, completion: @escaping (Data?,URLResponse?,Error?)->()){
        session.invalidateAndCancel()

        session.dataTask(with: url) { (data, response, error) in
            completion(data, response, error)
        }.resume()
    }
}

//Helper stuff
public protocol PolygonJSON {}

public enum Sort: String{
    case asc = "asc"
    case desc = "desc"
}

public enum Timespan: String{
    case minute = "minute"
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
}

public enum QueryType{
    case aggregateBars
    case previousClose
    case groupedBars
    case dailyOpenClose
}

public struct QueryDate{
    public let year: String
    public let month: String
    public let day: String
    
    public init(year: Int, month: Int, day: Int){
        self.year = String(year)
        self.month = month < 10 ? "0\(month)" : String(month)
        self.day = day < 10 ? "0\(day)" : String(day)
    }
    
    public var date: String{
        return "\(year)-\(month)-\(day)"
    }
}

public enum FinancialsTOR: String{
    case Y = "Y"
    case YA = "YA"
    case Q = "Q"
    case QA = "QA"
    case T = "T"
    case TA = "TA"
}

public enum Direction: String{
    case gainers = "gainers"
    case losers = "losers"
}

//Checks if you are using a valid ticker symbol
public enum Ticker{
    case stock(String)
    case forex(String)
    case crypto(String)
    
    public func ticker()->String{
        switch self {
        case .stock(let ticker):
            return ticker
        case .forex(let ticker):
            return ticker
        case .crypto(let ticker):
            return ticker
        }
    }
}

public enum Market: String{
    case stock = "STOCKS"
    case forex = "FOREX"
    case crypto = "CRYPTO"
    case any = ""
}

public enum FinancialsSort:String{
    case ascReportPeriod = "reportPeriod"
    case descReportPeriod = "-reportPeriod"
    case ascCalendarDate = "calendarDate"
    case descCalendarDate = "-calendarDate"
}

public enum TickerType: String{
    case trades = "trades"
    case quotes = "quotes"
}

public protocol PolygonioQuery{
    var address: String { get }
}


//Reference rest api

fileprivate struct TickersQuery: PolygonioQuery {
    private let sort: String
    private let type: String
    private let market: String
    private let locale: String
    private let search: String
    private let perpage: String
    private let page: String
    private let active: String
    
    public init(sort: String = "", type: String = "", market: Market = .stock, locale: String = "", search: String = "", perpage: Int = 50, page: Int = 1, active: Bool = true){
        self.sort = sort
        self.type = type
        self.market = market.rawValue
        self.locale = locale
        self.search = search
        self.perpage = String(perpage)
        self.page = String(page)
        self.active = String(active)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/reference/tickers?sort=\(sort)&type=\(type)&market=\(market)&locale=\(locale)&search=\(search)&perpage=\(perpage)&page=\(page)&active=\(active)&apiKey="
    }
}

fileprivate struct TickerTypes: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v2/reference/types?apiKey="
    }
}

fileprivate struct TickerDetails: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v1/meta/symbols/\(ticker)/company?apiKey="
    }
}

fileprivate struct TickerNews: PolygonioQuery{
    
    private let ticker: String
    private let perPage: String
    private let page: String
    
    public init(ticker: String, perPage: Int, page: Int){
        self.ticker = ticker
        self.perPage = String(perPage)
        self.page = String(page)
    }
    
    public var address: String{
        "https://api.polygon.io/v1/meta/symbols/\(ticker)/news?perpage=\(perPage)&page=\(page)&apiKey="
    }
}

fileprivate struct Markets: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v2/reference/markets?apiKey="
    }
}

fileprivate struct Locales: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v2/reference/locales?apiKey="
    }
}

fileprivate struct StockSplits: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v2/reference/splits/\(ticker)?apiKey="
    }
}

fileprivate struct StockDividends: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v2/reference/dividends/\(ticker)?apiKey="
    }
}

fileprivate struct StockFinancials: PolygonioQuery{
    private let ticker: String
    private let limit: String
    private let type: String
    private let sort: String
    
    public init(ticker: String, limit: Int = 5, type: FinancialsTOR = .Y, sort: FinancialsSort = .ascReportPeriod){
        self.ticker = ticker
        self.limit = String(limit)
        self.type = type.rawValue
        self.sort = sort.rawValue
    }
    
    public var address: String{
        "https://api.polygon.io/v2/reference/financials/\(ticker)?limit=\(limit)&type=\(type)&sort=\(sort)&apiKey="
    }
}

fileprivate struct MarketHolidays: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v1/marketstatus/upcoming?apiKey="
    }
}

fileprivate struct MarketStatus: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v1/marketstatus/now?apiKey="
    }
}

fileprivate struct StockExchanges: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v1/meta/exchanges?apiKey="
    }
}

fileprivate struct ConditionMappings: PolygonioQuery{
    private let tickerType: String
    
    public init(tickerType: TickerType){
        self.tickerType = tickerType.rawValue
    }
    
    public var address: String{
        "https://api.polygon.io/v1/meta/conditions/\(tickerType)?apiKey="
    }
}

fileprivate struct CryptoExchanges: PolygonioQuery{
    public var address: String{
        "https://api.polygon.io/v1/meta/crypto-exchanges?apiKey="
    }
}

//Stock rest api

fileprivate struct StockTradesQuery: PolygonioQuery{
    private let ticker: String
    private let date: String
    private let timestamp: String
    private let timestampLimit: String
    private let reverse: String
    private let limit: String
    
    public init(ticker: String, date: QueryDate, timestamp: Double?, timestampLimit: Int?, reverse: Bool = true, limit: Int = 10){
        self.ticker = ticker
        self.date = date.date
        self.timestamp = timestamp == nil ? "" : String(timestamp!)
        self.timestampLimit = timestampLimit == nil ? "" : String(timestampLimit!)
        self.reverse = String(reverse)
        self.limit = String(limit)
    }
    
    public var address: String{    "https://api.polygon.io/v2/ticks/stocks/trades/\(ticker)/\(date)?timestamp=\(timestamp)&timestampLimit=\(timestampLimit)&reverse=\(reverse)&limit=\(limit)&apiKey="
    }
}

fileprivate struct StockQuotesQuery: PolygonioQuery{
    private let ticker: String
    private let date: String
    private let timestamp: String
    private let timestampLimit: String
    private let reverse: String
    private let limit: String
    
    public init(ticker: String, date: QueryDate, timestamp: Double?, timestampLimit: Int?, reverse: Bool = true, limit: Int = 10){
        self.ticker = ticker
        self.date = date.date
        self.timestamp = timestamp == nil ? "" : String(timestamp!)
        self.timestampLimit = timestampLimit == nil ? "" : String(timestampLimit!)
        self.reverse = String(reverse)
        self.limit = String(limit)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/ticks/stocks/nbbo/\(ticker)/\(date)?timestamp=\(timestamp)&timestampLimit=\(timestampLimit)&reverse=\(reverse)&limit=\(limit)&apiKey="
    }
}

fileprivate struct StockLastTradeQuery: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v1/last/stocks/\(ticker)?apiKey="
    }
}

fileprivate struct StockLastQuoteQuery: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v1/last_quote/stocks/\(ticker)?apiKey="
    }
}

fileprivate struct StockDailyOpenCloseQuery: PolygonioQuery{
    private let ticker: String
    private let date: String
    
    public init(ticker: String, date: QueryDate){
        self.ticker = ticker
        self.date = date.date
    }
    
    public var address: String{
        "https://api.polygon.io/v1/open-close/\(ticker)/\(date)?apiKey="
    }
}

fileprivate struct StockGroupedDailyBarsQuery: PolygonioQuery{
    private let date: String
    private let unadjusted: String
    
    public init(date: QueryDate, unadjusted: Bool = true){
        self.date = date.date
        self.unadjusted = String(unadjusted)
    }
    public var address: String{
        "https://api.polygon.io/v2/aggs/grouped/locale/us/market/stocks/\(date)?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct StockPreviousCloseQuery: PolygonioQuery{
    private let ticker: String
    private let unadjusted: String
    
    public init(ticker: String, unadjusted: Bool = true){
        self.ticker = ticker
        self.unadjusted = String(unadjusted)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/prev?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct StockAggregateBarsQuery: PolygonioQuery{
    private let ticker: String
    private let multiplier: String
    private let timespan: String
    private let from: String
    private let to: String
    private let unadjusted: String
    private let sort: String
    private let limit: String
    
    public init(ticker: String, multiplier: Int, timespan: Timespan, from: QueryDate, to: QueryDate, unadjusted: Bool = true, sort: Sort = .asc, limit: Int = 120){
        self.ticker = ticker
        self.multiplier = String(multiplier)
        self.timespan = timespan.rawValue
        self.from = from.date
        self.to = to.date
        self.unadjusted = String(unadjusted)
        self.sort = sort.rawValue
        self.limit = String(limit)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/range/\(multiplier)/\(timespan)/\(from)/\(to)?unadjusted=\(unadjusted)&sort=\(sort)&limit=\(limit)&apiKey="
    }
}

fileprivate struct StockSnapshotAllTickersQuery: PolygonioQuery{
    private let tickers: String
    
    public init(tickers: [String] = []){
        self.tickers = tickers.joined(separator: ",")
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers?tickers=\(tickers)&apiKey="
    }
}

fileprivate struct StockSnapshotTickerQuery: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers/\(ticker)?apiKey="
    }
}

fileprivate struct StockSnapshotGainersLosersQuery: PolygonioQuery{
    private let direction: String
    
    public init(direction: Direction){
        self.direction = direction.rawValue
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/\(direction)?apiKey="
    }
}

//Forex rest api
fileprivate struct HistoricForexTicksQuery: PolygonioQuery{
    private let pair: String
    private let date: String
    private let offset: String
    private let limit: String
    
    public init(pair: String, date: QueryDate, offset: Double?, limit: Int = 120){
        self.pair = pair
        self.date = date.date
        self.offset = offset == nil ? "" : String(offset!)
        self.limit = String(limit)
    }
    
    public var address: String{
        "https://api.polygon.io/v1/historic/forex/\(pair)/\(date)?offset=\(offset)&limit=\(limit)&apiKey="
    }
}

fileprivate struct RealTimeCurrencyConversionQuery: PolygonioQuery{
    private let pair: String
    private let amount: String
    private let precision: String
    
    public init(pair: String, amount: Int = 100, precision: Int = 2){
        self.pair = pair
        self.amount = String(amount)
        self.precision = String(precision)
    }
    
    public var address: String{
        "https://api.polygon.io/v1/conversion/\(pair)?amount=\(amount)&precision=\(precision)&apiKey="
    }
}

fileprivate struct LastQuoteCurrencyPairQuery: PolygonioQuery{
    private let pair: String
    
    public init(pair: String){
        self.pair = pair
    }
    
    public var address: String{
        "https://api.polygon.io/v1/last_quote/currencies/\(pair)?&apiKey="
    }
}

fileprivate struct ForexGroupedDailyBarsQuery: PolygonioQuery{
    private let date: String
    private let unadjusted: String
    
    public init(date: QueryDate, unadjusted: Bool = true){
        self.date = date.date
        self.unadjusted = String(unadjusted)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/grouped/locale/global/market/fx/\(date)?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct ForexPreviousCloseQuery: PolygonioQuery{
    private let ticker: String
    private let unadjusted: String
    
    public init(ticker: String, unadjusted: Bool = true){
        self.ticker = ticker
        self.unadjusted = String(unadjusted)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/prev?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct ForexAggregateBarsQuery: PolygonioQuery{
    private let ticker: String
    private let multiplier: String
    private let timespan: String
    private let from: String
    private let to: String
    private let unadjusted: String
    private let sort: String
    private let limit: String
    
    public init(ticker: String, multiplier: Int, timespan: Timespan, from: QueryDate, to: QueryDate, unadjusted: Bool = true, sort: Sort = .asc, limit: Int = 120){
        self.ticker = ticker
        self.multiplier = String(multiplier)
        self.timespan = timespan.rawValue
        self.from = from.date
        self.to = to.date
        self.unadjusted = String(unadjusted)
        self.sort = sort.rawValue
        self.limit = String(limit)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/range/\(multiplier)/\(timespan)/\(from)/\(to)?unadjusted=\(unadjusted)&sort=\(sort)&limit=\(sort)&apiKey="
    }
}

fileprivate struct ForexSnapshotTickerQuery: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/forex/tickers/\(ticker)?&apiKey="
    }
}

fileprivate struct ForexSnapshotAllTickersQuery: PolygonioQuery{
    private let tickers: String
    
    public init(tickers: [String] = []){
        self.tickers = tickers.joined(separator: ",")
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/forex/tickers?tickers=\(tickers)&apiKey="
    }
}

fileprivate struct ForexSnapshotGainersLosersQuery: PolygonioQuery{
    private let direction: String
    
    public init(direction: Direction = .gainers){
        self.direction = direction.rawValue
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/forex/\(direction)?&apiKey="
    }
}

//Crypto rest api

fileprivate struct CryptoDailyOpenCloseQuery: PolygonioQuery{
    private let from: String
    private let to: String
    private let date: String
    private let unadjusted: String
    
    public init(from: String, to: String, date: QueryDate, unadjusted: Bool = true){
        self.from = from
        self.to = to
        self.date = date.date
        self.unadjusted = String(unadjusted)
    }
    
    public var address: String{
        "https://api.polygon.io/v1/open-close/crypto/\(from)/\(to)/\(date)?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct CryptoHistoricTradesQuery: PolygonioQuery{
    private let from: String
    private let to: String
    private let date: String
    private let offset: String
    private let limit: String
    
    public init(from: String, to: String, date: QueryDate, offset: Double?, limit: Int = 100){
        self.from = from
        self.to = to
        self.date = date.date
        self.offset = offset == nil ? "" : String(offset!)
        self.limit = String(limit)
    }
    
    public var address: String{
        "https://api.polygon.io/v1/historic/crypto/\(from)/\(to)/\(date)?offset=\(offset)&limit=\(limit)&apiKey="
    }
}

fileprivate struct CryptoGroupedDailyBarsQuery: PolygonioQuery{
    private let date: String
    private let unadjusted: String
    
    public init(date: String, unadjusted: Bool = true){
        self.date = date
        self.unadjusted = String(unadjusted)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/grouped/locale/global/market/crypto/\(date)?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct CryptoPreviousCloseQuery: PolygonioQuery{
    private let ticker: String
    private let unadjusted: String
    
    public init(ticker: String, unadjusted: Bool = true){
        self.ticker = ticker
        self.unadjusted = String(unadjusted)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/prev?unadjusted=\(unadjusted)&apiKey="
    }
}

fileprivate struct CryptoAggregateBarsQuery: PolygonioQuery{
    private let ticker: String
    private let multiplier: String
    private let timespan: String
    private let from: String
    private let to: String
    private let unadjusted: String
    private let sort: String
    private let limit: String
    
    public init(ticker: String, multiplier: Int, timespan: Timespan, from: QueryDate, to: QueryDate, unadjusted: Bool = true, sort: Sort = .asc, limit: Int = 120){
        self.ticker = ticker
        self.multiplier = String(multiplier)
        self.timespan = timespan.rawValue
        self.from = from.date
        self.to = to.date
        self.unadjusted = String(unadjusted)
        self.sort = sort.rawValue
        self.limit = String(limit)
    }
    
    public var address: String{
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/range/\(multiplier)/\(timespan)/\(from)/\(to)?unadjusted=\(unadjusted)&sort=\(sort)&limit=\(limit)&apiKey="
    }
}

fileprivate struct CryptoSnapshotAllTickersQuery: PolygonioQuery{
    private let tickers: String
    
    public init(tickers: [String] = []){
        self.tickers = tickers.joined(separator: ",")
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/crypto/tickers?tickers=\(tickers)&apiKey="
    }
}

fileprivate struct CryptoSnapshotTickerQuery: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/crypto/tickers/\(ticker)?&apiKey="
    }
}

public struct CryptoSnapshotTickerFullBookQuery: PolygonioQuery{
    private let ticker: String
    
    public init(ticker: String){
        self.ticker = ticker
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/crypto/tickers/\(ticker)/book?&apiKey="
    }
}

fileprivate struct CryptoSnapshotGainersLosersQuery: PolygonioQuery{
    private let direction: String
    
    public init(direction: Direction){
        self.direction = direction.rawValue
    }
    
    public var address: String{
        "https://api.polygon.io/v2/snapshot/locale/global/markets/crypto/\(direction)?&apiKey="
    }
}

fileprivate struct CyrptoLastTradeQuery: PolygonioQuery{
    private let from: String
    private let to: String
    
    public init(from: String, to: String){
        self.from = from
        self.to = to
    }
    
    public var address: String{
        "https://api.polygon.io/v1/last/crypto/\(from)/\(to)?&apiKey="
    }
}

public class Reference{
    
    public func tickers(sort: String = "", type: String = "", market: Market = .stock, locale: String = "", search: String = "", perpage: Int = 50, page: Int = 1, active: Bool = true)->PolygonioQuery{
        return TickersQuery(sort: sort, type: type, market: market, locale: locale, search: search, perpage: perpage, page: page, active: active)
    }
    
    public func tickerTypes()->PolygonioQuery{
        return TickerTypes()
    }
    
    public func tickerDetails(ticker: String)->PolygonioQuery{
        return TickerDetails(ticker: ticker)
    }
    
    public func tickerNews(ticker: String, perPage: Int, page: Int)->PolygonioQuery{
        return TickerNews(ticker: ticker, perPage: perPage, page: page)
    }
    
    public func markets()->PolygonioQuery{
        return Markets()
    }
    
    public func locales()->PolygonioQuery{
        return Locales()
    }
    
    public func stockSplits(ticker: String)->PolygonioQuery{
        return StockSplits(ticker: ticker)
    }
    
    public func stockDividends(ticker: String)->PolygonioQuery{
        return StockDividends(ticker: ticker)
    }
    
    public func stockFinancials(ticker: String, limit: Int = 5, type: FinancialsTOR = .Y, sort: FinancialsSort = .ascReportPeriod)->PolygonioQuery{
        return StockFinancials(ticker: ticker, limit: limit, type: type, sort: sort)
    }
    
    public func marketHolidays()->PolygonioQuery{
        return MarketHolidays()
    }
    
    public func marketStatus()->PolygonioQuery{
        return MarketStatus()
    }
    
    public func stockExchanges()->PolygonioQuery{
        return StockExchanges()
    }
    
    public func conditionMappings(tickerType: TickerType)->PolygonioQuery{
        return ConditionMappings(tickerType: tickerType)
    }
    
    public func cryptoExchanges()->PolygonioQuery{
        return CryptoExchanges()
    }
}

public class Stock{
    
    public func trades(ticker: String, date: QueryDate, timestamp: Double?, timestampLimit: Int?, reverse: Bool = true, limit: Int = 10)->PolygonioQuery{
        return StockTradesQuery(ticker: ticker, date: date, timestamp: timestamp, timestampLimit: timestampLimit, reverse: reverse, limit: limit)
    }
    
    public func quotes(ticker: String, date: QueryDate, timestamp: Double?, timestampLimit: Int?, reverse: Bool = true, limit: Int = 10)->PolygonioQuery{
        return StockQuotesQuery(ticker: ticker, date: date, timestamp: timestamp, timestampLimit: timestampLimit, reverse: reverse, limit: limit)
    }
    
    public func lastTrade(ticker: String)->PolygonioQuery{
        return StockLastTradeQuery(ticker: ticker)
    }
    
    public func lastQuote(ticker: String)->PolygonioQuery{
        return StockLastQuoteQuery(ticker: ticker)
    }
    
    public func dailyOpenClose(ticker: String, date: QueryDate)->PolygonioQuery{
        return StockDailyOpenCloseQuery(ticker: ticker, date: date)
    }
    
    public func groupedDailyBars(date: QueryDate, unadjusted: Bool = true)->PolygonioQuery{
        return StockGroupedDailyBarsQuery(date: date, unadjusted: unadjusted)
    }
    
    public func previousClose(ticker: String, unadjusted: Bool = true)->PolygonioQuery{
        return StockPreviousCloseQuery(ticker: ticker, unadjusted: unadjusted)
    }
    
    public func aggregateBars(ticker: String, multiplier: Int, timespan: Timespan, from: QueryDate, to: QueryDate, unadjusted: Bool = true, sort: Sort = .asc, limit: Int = 120)->PolygonioQuery{
        return StockAggregateBarsQuery(ticker: ticker, multiplier: multiplier, timespan: timespan, from: from, to: to, unadjusted: unadjusted, sort: sort, limit: limit)
    }
    
    public func snapshotAllTickers(tickers: [String] = [])->PolygonioQuery{
        return StockSnapshotAllTickersQuery(tickers: tickers)
    }
    
    public func snapshotTicker(ticker: String)->PolygonioQuery{
        return StockSnapshotTickerQuery(ticker: ticker)
    }
    
    public func snapshotGainersLoser(direction: Direction)->PolygonioQuery{
        return StockSnapshotGainersLosersQuery(direction: direction)
    }
}

public class Forex{
    
    public func historicTicks(pair: String, date: QueryDate, offset: Double?, limit: Int = 120)->PolygonioQuery{
        return HistoricForexTicksQuery(pair: pair, date: date, offset: offset, limit: limit)
    }
    
    public func realtimeCurrenyConversion(pair: String, amount: Int = 100, precision: Int = 2)->PolygonioQuery{
        return RealTimeCurrencyConversionQuery(pair: pair, amount: amount, precision: precision)
    }
    
    public func lastQuote(pair: String)->PolygonioQuery{
        return LastQuoteCurrencyPairQuery(pair: pair)
    }
    
    public func groupedDailyBars(date: QueryDate, unadjusted: Bool = true)->PolygonioQuery{
        return ForexGroupedDailyBarsQuery(date: date, unadjusted: unadjusted)
    }
    
    public func previousClose(ticker: String, unadjusted: Bool = true)->PolygonioQuery{
        return ForexPreviousCloseQuery(ticker: ticker, unadjusted: unadjusted)
    }
    
    public func aggregateBars(ticker: String, multiplier: Int, timespan: Timespan, from: QueryDate, to: QueryDate, unadjusted: Bool = true, sort: Sort = .asc, limit: Int = 120)->PolygonioQuery{
        return ForexAggregateBarsQuery(ticker: ticker, multiplier: multiplier, timespan: timespan, from: from, to: to, unadjusted: unadjusted, sort: sort, limit: limit)
    }
    
    public func snapshotTicker(ticker: String)->PolygonioQuery{
        return ForexSnapshotTickerQuery(ticker: ticker)
    }
    
    public func snapshotAlltickers(tickers: [String] = [])->PolygonioQuery{
        return ForexSnapshotAllTickersQuery(tickers: tickers)
    }
    
    public func snapshotGainersLosers(direction: Direction)->PolygonioQuery{
        return ForexSnapshotGainersLosersQuery(direction: direction)
    }
}

public class Crypto{
    
    public func dailyOpenClose(from: String, to: String, date: QueryDate, unadjusted: Bool = true)->PolygonioQuery{
        return CryptoDailyOpenCloseQuery(from: from, to: to, date: date, unadjusted: unadjusted)
    }
    
    public func historicTrade(from: String, to: String, date: QueryDate, offset: Double?, limit: Int = 100)->PolygonioQuery{
        return CryptoHistoricTradesQuery(from: from, to: to, date: date, offset: offset, limit: limit)
    }
    
    public func groupedDailyBars(date: String, unadjusted: Bool = true)->PolygonioQuery{
        return CryptoGroupedDailyBarsQuery(date: date, unadjusted: unadjusted)
    }
    
    public func previousClose(ticker: String, unadjusted: Bool = true)->PolygonioQuery{
        return CryptoPreviousCloseQuery(ticker: ticker, unadjusted: unadjusted)
    }
    
    public func aggregateBars(ticker: String, multiplier: Int, timespan: Timespan, from: QueryDate, to: QueryDate, unadjusted: Bool = true, sort: Sort = .asc, limit: Int = 120)->PolygonioQuery{
        return CryptoAggregateBarsQuery(ticker: ticker, multiplier: multiplier, timespan: timespan, from: from, to: to, unadjusted: unadjusted, sort: sort, limit: limit)
    }
    
    public func snapshotAllTickers(tickers: [String] = [])->PolygonioQuery{
        return CryptoSnapshotAllTickersQuery(tickers: tickers)
    }
    
    public func snapshotTicker(ticker: String)->PolygonioQuery{
        return CryptoSnapshotTickerQuery(ticker: ticker)
    }
    
    public func snapshotGainersLosers(direction: Direction)->PolygonioQuery{
        return CryptoSnapshotGainersLosersQuery(direction: direction)
    }
    
    public func lastTrade(from: String, to: String)->PolygonioQuery{
        return CyrptoLastTradeQuery(from: from, to: to)
    }
}

//Call all queries through this class
public class Query{
    public static let reference = Reference()
    public static let stock = Stock()
    public static let forex = Forex()
    public static let crypto = Crypto()
}

//client

public class PolygonioClient{
    
    private let key: String
        
    public init(apiKey: String) {
        self.key = apiKey
    }
    
    public func get(query: PolygonioQuery, completion: @escaping (Data?,URLResponse?,Error?)->()){
        guard let url = getURL(query: query) else{
            return
        }
            
        Request.http(url: url) { (data, response, error) in
            if let error = error{
                print(error.localizedDescription)
                completion(nil,response,error)
            }
            
            if let response = response as? HTTPURLResponse{
                if (400...499).contains(response.statusCode){
                    print(response.description)
                }else if (500...599).contains(response.statusCode){
                    print(response.description)
                }
            }
            
            if let data = data{
                completion(data,response,error)
            }
        }
    }
        
    private func getURL(query: PolygonioQuery)->URL?{
        return URL(string: query.address+key)
    }
}



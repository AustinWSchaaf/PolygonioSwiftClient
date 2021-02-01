# PolygonioSwiftClient
Make calls to Polygonio's rest api in swift 

## usage

Consuming [Polygon.io](https://polygon.io/) with PolygonioSwiftClient

````swift
//first import the package
import PolygonioSwiftClient

//pass your api key to a newly instatiated Polygon object
let client = PolygonioClient(apiKey: apiKey)

//create your desired PolygonQuery - in this case we call the stock aggregate bars query
let query = Query.stock.aggregateBars(ticker: "AAPL",
                                      multiplier: 1,
                                      timespan: .minute,
                                      from: QueryDate(year: 2021, month: 1, day: 28),
                                      to: QueryDate(year: 2021, month: 1, day: 28))

//pass your query to the client object 
client.get(query: query) { (data, res, err) in
    if let err = err{
        print(err.localizedDescription)
    }
    if let data = data{
        do{
            if let results = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]{
                //do something with your data
            }
        }catch let e{
            print(e.localizedDescription)
        }
    }
}
````


  - [Interacting with Crypto API](#interacting-with-crypto-api)
  - [Requirements](#requirements)
  - [Functions to Interact with API](#functions-to-interact-with-api)
      - [`getExchange`](#getexchange)
      - [`getDailyMarket`](#getdailymarket)
      - [`getAggregates`](#getaggregates)
  - [Data Exploration](#data-exploration)
      - [Bitcoin Trading Volume](#bitcoin-trading-volume)

# Interacting with Crypto API

# Requirements

The following packages are required to use the API function:

  - `tidyverse`: Useful data tools for transforming and visualizing data
  - `jsonlite`: Interact and download data with API
  - `knitr`: Display well-formatted tables
  - `lubridate`: Useful date functions such as quarter

You will also need an API key to be able to interact with the API.
Please go to [polygon.io](https://polygon.io/) to register for a free
API key. You will need to assign the key to the variable `APIkey`, as
follows:

``` r
APIkey = "insert_key_here"
```

# Functions to Interact with API

## `getExchange`

**Description:** Function to get Crypto Exchanges Data

**Input:** None

**Output:** Returns a table of exchange data information

``` r
getExchange <- function(){
  
   # Build the URL  
   baseURL <- "https://api.polygon.io/v1/meta/crypto-exchanges/"
   key <- paste0("?apiKey=", APIkey)
   URL <- paste0(baseURL, key)
   
   # Use the URL to retrieve data from API
   exchangeData <- fromJSON(URL)
   
   return(exchangeData)
}

# Sample Function Call
kable(getExchange())
```

| id | market | name     | url                             | tier   | locale |
| -: | :----- | :------- | :------------------------------ | :----- | :----- |
|  1 | crypto | Coinbase | <https://www.coinbase.com>      | crypto | G      |
|  2 | crypto | BITFINEX | <https://www.bitfinex.com/>     | crypto | G      |
|  6 | crypto | Bitstamp | <https://www.bitstamp.net/>’    | crypto | G      |
| 10 | crypto | HitBTC   | <https://hitbtc.com/>           | crypto | G      |
| 23 | crypto | Kraken   | <https://www.kraken.com/en-us/> | crypto | G      |

## `getDailyMarket`

**Description:** Function to get the daily grouped data for the entire
Crypto market

**Input:** Date in “YYYY-MM-DD” format

**Output:** Returns a table of containing crypto market information for
the input date

``` r
getDailyMarket <- function(date=Sys.Date()){

   # Build the URL
   baseURL <- "https://api.polygon.io/v2/aggs/grouped/locale/global/market/crypto/"
   key <- paste0("?apiKey=", APIkey)
   day <- date
   URL <- paste0(baseURL, day, key)
   
   # Use the URL to retrieve data from API
   rawList <- fromJSON(URL)
   rawData <- rawList$results
   
   marketData <- rawData %>% select(ticker = T, volume = v, price = c)
   
   return(marketData)
}

# Sample Function Call

dailyMarket <- getDailyMarket("2021-09-30")
kable(head(dailyMarket))
```

| ticker    |       volume |       price |
| :-------- | -----------: | ----------: |
| X:ICPUSD  |    539819.67 |    45.08400 |
| X:LTCEUR  |     54319.85 |   132.23000 |
| X:MANAUSD |   6227804.05 |     0.68900 |
| X:IOTXUSD | 109464846.00 |     0.06036 |
| X:BTCUSD  |     28947.92 | 43770.97000 |
| X:RLYUSD  |   4297315.00 |     0.54050 |

## `getAggregates`

**Description:** Function to get 1-year aggregate data for a
cryptocurrency pair ending at a given date

**Input:** Date in “YYYY-MM-DD” format

**Output:** Returns a table of containing crypto market information such
as daily volume and price

``` r
getAggregates <- function(date=Sys.Date(), name="", abbr){

   # Retrieve the date 1 year prior to the input date
   dayEnd <- as.Date(date)
   dayStart <- dayEnd - 364
   
   reference <- cbind(c("BTCUSD", "ETHUSD", "ADAUSD", "XRPUSD"),
                      c("BITCOIN", "ETHEREUM", "CARDANO", "XRP")
                     )
   
   # Allow user to specify either the crypto currency name or the ticker name
   if (name != ""){
   symbol <- switch(toupper(name),
                    BITCOIN = "BTCUSD",
                    ETHEREUM = "ETHUSD",
                    CARDANO = "ADAUSD",
                    XRP = "XRPUSD",
                    SOLANA = "SOLUSD",
                    POLKADOT = "DOTUSD",
                    DOGECOIN = "DOGEUSD",
                    UNISWAP = "UNIUSD",
                    CHAINLINK = "LINKUSD",
                    LITECOIN = "LTCUSD",
                    )
   } else if (abbr != ""){
     symbol <- toupper(abbr)
   } 
   
   if (symbol == ""){
      message <- paste("ERROR: Only the top 10 cryptocurrencies by market cap are supported,", 
                       "please input another name, or use the `abbr` parameter to input the symbol")
      stop(message)
      
   }else if (!(paste0("X:", symbol) %in% dailyMarket$ticker)){
      message <- "ERROR: Symbol not supported. Please input a valid symbol"
      
      stop(message)
   }
   
   
   # Build the URL
   baseURL <- "https://api.polygon.io/v2/aggs/ticker/"
   ticker <- paste0("X:", symbol, "/")
   range <- "range/1/day/"
   otherSettings <- "?adjusted=true&sort=asc&limit=365"
   key <- paste0("&apiKey=", APIkey)
   URL <- paste0(baseURL, ticker, range, dayStart, "/", dayEnd, otherSettings, key)
   

   # Use the URL to retrieve data from API
   rawList <- fromJSON(URL)
   rawData <- rawList$results
   
   # Select Variables for the output dataset
   date_range <- as.Date(c(dayStart:dayEnd), origin = "1970-01-01")
   
   # Get the Quarter of the date
   qtr <- paste0(year(date_range), " Q", quarter(date_range))
   
   cryptoData <- data.frame(qtr, date_range, rawData$v, rawData$o, rawData$c)
   colnames(cryptoData) <- c("quarter", "date", "volume", "priceOpen", "priceClose")
   
   return(cryptoData)
}

bitcoinData <- getAggregates("2021-09-30", name="bitcoin")

kable(head(bitcoinData))
```

| quarter | date       |   volume | priceOpen | priceClose |
| :------ | :--------- | -------: | --------: | ---------: |
| 2020 Q4 | 2020-10-01 | 58731.65 |  10797.00 |   10616.10 |
| 2020 Q4 | 2020-10-02 | 61021.60 |  10616.35 |   10573.12 |
| 2020 Q4 | 2020-10-03 | 27705.14 |  10586.00 |   10551.65 |
| 2020 Q4 | 2020-10-04 | 23021.75 |  10550.32 |   10671.11 |
| 2020 Q4 | 2020-10-05 | 37483.09 |  10669.00 |   10799.00 |
| 2020 Q4 | 2020-10-06 | 41179.06 |  10796.97 |   10601.49 |

# Data Exploration

``` r
# Calculate percent change
price <- bitcoinData$`Closing Price`

change1Day <- (price[366] - price[365]) / price[365]
change7Day <- (price[366] - price[359]) / price[359]
change30Day <-(price[366] - price[336]) / price[336]
change365Day <- (price[366] - price[1]) / price[1]

kable(cbind(price[366], change1Day, change7Day, change30Day, change365Day), nrow=1)
```

|  | change1Day | change7Day | change30Day | change365Day |
| -: | ---------: | ---------: | ----------: | -----------: |

``` r
plot(x=bitcoinData$date, y= bitcoinData$priceClose)
```

![](C:\\Users\\joeyc\\Desktop\\MR%20Statistics\\ST%20558\\repos\\Vignette\\README_files/figure-gfm/pctchg-1.png)<!-- -->

## Bitcoin Trading Volume

We can examine the Bitcoin trading Volume by looking at the Box plot.

``` r
ggplot(bitcoinData, aes(quarter, volume)) +
   geom_boxplot(size=1) +
   geom_jitter(aes(y=volume, fill=quarter, color=quarter), size=2) +
   labs(title="Boxplot for Bitcoin Trading Volume by Quarter") +
   theme(text=element_text(size=16), 
         panel.grid.major = element_line(size=1.5),
         axis.ticks = element_line(size=1.4),
         axis.ticks.length = unit(0.20, 'cm'))
```

![](C:\\Users\\joeyc\\Desktop\\MR%20Statistics\\ST%20558\\repos\\Vignette\\README_files/figure-gfm/Boxplot-1.png)<!-- -->

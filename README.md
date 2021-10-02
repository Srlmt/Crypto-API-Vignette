
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

``` r
library(tidyverse)
library(jsonlite)
library(knitr)
library(lubridate)
APIkey="r87x5acIqxjYxZWZ31xO3dxUjQGVlja6"
```

# Functions to Interact with API

## `getExchange`

Description: Function to get Crypto Exchanges Data

Input: None

Output: Returns a table of exchange data information

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

Description: Function to get the daily grouped data for the entire
Crypto market

Input: Date in “YYYY-MM-DD” format

Output: Returns a table of containing crypto market information for the
input date

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

return(rawData)
}

# Sample Function Call
kable(head(getDailyMarket("2021-09-30")))
```

| T         |           v |         vw |           o |           c |           h |          l |            t |      n |
| :-------- | ----------: | ---------: | ----------: | ----------: | ----------: | ---------: | -----------: | -----: |
| X:ICPUSD  |   450593.05 |    44.6230 |    44.40000 |    44.86300 |    45.61900 |    43.4200 | 1.633046e+12 |  37416 |
| X:LTCEUR  |    41612.44 |   130.2602 |   124.85000 |   131.28000 |   133.41000 |   124.0400 | 1.633046e+12 |  11202 |
| X:MANAUSD |  4859310.43 |     0.6716 |     0.64500 |     0.69700 |     0.69800 |     0.6410 | 1.633046e+12 |   6598 |
| X:IOTXUSD | 95415671.00 |     0.0625 |     0.06025 |     0.06088 |     0.06529 |     0.0594 | 1.633046e+12 |  18722 |
| X:BTCUSD  |    21919.73 | 43123.0966 | 41519.11000 | 43383.40000 | 43859.98503 | 41409.6700 | 1.633046e+12 | 395656 |
| X:RLYUSD  |  3385452.00 |     0.5490 |     0.52530 |     0.54480 |     0.58790 |     0.5233 | 1.633046e+12 |  10669 |

``` r
dailyMarket <- getDailyMarket("2021-09-30")
```

## `getAggregates`

Description: Function to get 1-year aggregate data for a cryptocurrency
pair ending at a given date

Input: Date in “YYYY-MM-DD” format

Output: Returns a table of containing crypto market information such as
daily volume and price

``` r
# Retrieve the date 1 year prior to the input date
date = "2021-09-29"
dayEnd <- as.Date(date)
dayStart <- dayEnd - 365

reference <- cbind(c("BTCUSD", "ETHUSD", "ADAUSD"),
                   c("BITCOIN", "ETHEREUM", "CARDANO")
                  )

# Build the URL
baseURL <- "https://api.polygon.io/v2/aggs/ticker/"
ticker <- paste0("X:", "BTCUSD", "/")
range <- "range/1/day/"
otherSettings <- "?adjusted=true&sort=asc&limit=366"
key <- paste0("&apiKey=", APIkey)
URL <- paste0(baseURL, ticker, range, dayStart, "/", dayEnd, otherSettings, key)

# Use the URL to retrieve data from API
rawList <- fromJSON(URL)
rawData <- rawList$results

# Select Variables for the output dataset
date_range <- as.Date(c(dayStart:dayEnd), origin = "1970-01-01")

# Get the Quarter of the date
qtr <- paste0(year(cryptoData$Date), " Q", quarter(cryptoData$Date))

cryptoData <- data.frame(qtr, date_range, rawData$v, rawData$c)
colnames(cryptoData) <- c("Quarter", "Date", "Volume", "Closing Price")
```

# Data Exploration

``` r
# Calculate percent change
price <- cryptoData$`Closing Price`

change1Day <- (price[366] - price[365]) / price[365]
change7Day <- (price[366] - price[359]) / price[359]
change30Day <-(price[366] - price[336]) / price[336]
change365Day <- (price[366] - price[1]) / price[1]

kable(cbind(price[366], change1Day, change7Day, change30Day, change365Day), nrow=1)
```

|          | change1Day |  change7Day | change30Day | change365Day |
| -------: | ---------: | ----------: | ----------: | -----------: |
| 41522.16 |  0.0120921 | \-0.0474281 | \-0.1164315 |      2.82968 |

``` r
plot(x=cryptoData$Date, y= cryptoData$`Closing Price`)
```

![](../images/unnamed-chunk-3-1.png)<!-- -->

## Bitcoin Trading Volume

We can examine the Bitcoin trading Volume by looking at the Box plot.

``` r
ggplot(cryptoData, aes(Quarter, Volume)) +
   geom_boxplot(size=1) +
   geom_jitter(aes(y=Volume, fill=Quarter, color=Quarter), size=2) +
   labs(title="Boxplot for Bitcoin Trading Volume by Quarter") +
   theme(text=element_text(size=16), 
         panel.grid.major = element_line(size=1.5),
         axis.ticks = element_line(size=1.4),
         axis.ticks.length = unit(0.20, 'cm'))
```

![](../images/Boxplot-1.png)<!-- -->

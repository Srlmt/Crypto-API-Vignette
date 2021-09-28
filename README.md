
# Interacting with Crypto API

# Requirements

``` r
library(tidyverse)
library(jsonlite)
library(knitr)
APIkey="r87x5acIqxjYxZWZ31xO3dxUjQGVlja6"
```

# Functions to Interact with API

## `getExchange`

Description: Function to get Crypto Exchanges Data Input: None Output:
Returns a table of exchange data information

``` r
getExchange <- function(){
baseURL <- "https://api.polygon.io/v1/meta/crypto-exchanges/"
key <- paste0("?apiKey=", APIkey)
URL <- paste0(baseURL, key)

exchangeData <- fromJSON(URL)

return(exchangeData)
}

kable(getExchange())
```

| id | market | name     | url                             | tier   | locale |
| -: | :----- | :------- | :------------------------------ | :----- | :----- |
|  1 | crypto | Coinbase | <https://www.coinbase.com>      | crypto | G      |
|  2 | crypto | BITFINEX | <https://www.bitfinex.com/>     | crypto | G      |
|  6 | crypto | Bitstamp | <https://www.bitstamp.net/>’    | crypto | G      |
| 10 | crypto | HitBTC   | <https://hitbtc.com/>           | crypto | G      |
| 23 | crypto | Kraken   | <https://www.kraken.com/en-us/> | crypto | G      |

``` r
## -----------------------------------------
baseURL <- "https://api.polygon.io/v2/aggs/ticker/"
ticker <- paste0("X:", "BTCUSD", "/")
range <- "range/1/day/"
day1 <- "2021-01-01/"
day2 <- "2021-09-20"
otherSettings <- "?adjusted=true&sort=asc&limit=365"
key <- "&apikey=r87x5acIqxjYxZWZ31xO3dxUjQGVlja6"
URL <- paste0(baseURL, ticker, range, day1, day2, otherSettings, key)

rawData <- fromJSON(URL)

dayStart <- as.Date(day1)
dayEnd <- as.Date(day2)
numDays <- dayEnd - dayStart + 1


cryptoData <- as.data.frame(rawData["results"])
change1Day <- (cryptoData$results.c[263] - cryptoData$results.c[262]) / cryptoData$results.c[262]
change7Day <- (cryptoData$results.c[263] - cryptoData$results.c[256]) / cryptoData$results.c[256]
change30Day <-(cryptoData$results.c[263] - cryptoData$results.c[233]) / cryptoData$results.c[233]

kable(c(cryptoData$results.c[263], change1Day, change7Day, change30Day))
```

|             x |
| ------------: |
| 43012.9700000 |
|   \-0.0897866 |
|   \-0.0430445 |
|   \-0.1192545 |

``` r
plot(x=dayStart:dayEnd, y=cryptoData$results.c)
```

![](../images/unnamed-chunk-2-1.png)<!-- -->

``` r
# cryptoData %>%
```

# Data Exploration

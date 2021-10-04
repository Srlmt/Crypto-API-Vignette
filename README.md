Using R to Interact with Cryptocurrency API
================
Joey Chen
10/5/2021

  - [Introduction](#introduction)
  - [Requirements](#requirements)
      - [R Packages](#r-packages)
      - [API Key](#api-key)
  - [Functions to Interact with API](#functions-to-interact-with-api)
      - [(1) `getExchange`](#getexchange)
      - [(2) `getNews`](#getnews)
      - [(3) `getDailyMarket`](#getdailymarket)
      - [(4) `getTickerDetails`](#gettickerdetails)
      - [(5) `getPreviousClose`](#getpreviousclose)
      - [(6) `getAggregates`](#getaggregates)
      - [(7)\[Wrapper\] `cryptoAPI`](#wrapper-cryptoapi)
  - [Data Exploration](#data-exploration)
      - [Top Cryptocurrencies](#top-cryptocurrencies)
      - [Bitcoin vs Ethereum](#bitcoin-vs-ethereum)
  - [Conclusion](#conclusion)

<img src="images/crypto.jpg" width="527" />

# Introduction

Cryptocurrencies have gained traction over the past couple or years. As
the trend continues, some may want to perform data exploration or
analysis.

This document will go over the processes of using R to interact with the
cryptocurrency [Application Programming Interface
(API)](https://www.mulesoft.com/resources/api/what-is-an-api). It will
go over the requirements and useful functions, followed by data
exploration examples and conclusion.

# Requirements

<img src="images/packages.png" width="1031" />

### R Packages

The following packages are required to use the API function:

  - [`tidyverse`](https://www.tidyverse.org/): Useful data tools for
    transforming and visualizing data
  - [`jsonlite`](https://cran.r-project.org/web/packages/jsonlite/vignettes/json-aaquickstart.html):
    Interact and download data with API
  - [`knitr`](https://cran.r-project.org/web/packages/knitr/index.html):
    Display well-formatted tables
  - [`lubridate`](https://lubridate.tidyverse.org/): Useful date
    functions (part of `tidyverse`)

### API Key

You will also need an API key to be able to interact with the API.
Please go to [polygon.io](https://polygon.io/) to register for a free
API key. You will need to assign the key to the variable `APIkey`, as
follows:

``` r
APIkey = "insert_key_here"
```

# Functions to Interact with API

I have created 6 useful functions and a separate wrapper function to
conveniently call any of the 6 functions. Each of the functions would
return an R data frame that can be readily used. The functions modify
URLs to call the API and retrieve data from different parts of the API.

Please keep in mind that this API is limited to **5 API Calls /
Minute**. R would return an error if that is exceeded.

We will now go over the functions:

## (1) `getExchange`

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

## (2) `getNews`

**Description:** Function to get Bitcoin news. It currently does not
work for any other cryptocurrencies.

**Input:** None

**Output:** Returns a table of Bitcoin news such as title, author, and
link.

``` r
getNews <- function(){
  
   # Build the URL  
   baseURL <- "https://api.polygon.io/v2/reference/news?limit=20&order=descending&sort=published_utc&ticker=BTC"
   key <- paste0("&apiKey=", APIkey)
   URL <- paste0(baseURL, key)
   
   # Use the URL to retrieve data from API
   newsList <- fromJSON(URL)
   
   # Select meaningful variables from the `results` table
   newsData <- newsList$results %>% select(publisher, title, author, published_utc, article_url)
   
   return(newsData)
}

# Sample Function Call
kable(head(getNews(), n=3))
```

| publisher | title                                                                                   | author            | published\_utc       | article\_url                                                                                                                                            |
| :-------- | :-------------------------------------------------------------------------------------- | :---------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Benzinga  | Why You Shouldn’t Invest In Cryptocurrency, According To This Analyst                   | Adrian Zmudzinski | 2021-06-15T22:10:55Z | <https://www.benzinga.com/markets/cryptocurrency/21/06/21562733/why-you-shouldnt-invest-in-cryptocurrency-according-to-this-analyst>                    |
| Benzinga  | Billionaire Investor Tim Draper Still Believes Bitcoin Will Hit $250,000 By End Of 2022 | Adrian Zmudzinski | 2021-06-15T19:56:59Z | <https://www.benzinga.com/markets/cryptocurrency/21/06/21563347/billionaire-investor-tim-draper-still-believes-bitcoin-will-hit-250-000-by-end-of-2022> |
| Benzinga  | Two Former PayPal Execs Launch Crypto Payments Platform To Fight SWIFT Banking System   | Adrian Zmudzinski | 2021-06-15T16:56:30Z | <https://www.benzinga.com/markets/cryptocurrency/21/06/21570582/two-former-paypal-execs-launch-crypto-payments-platform-to-fight-swift-banking-system>  |

## (3) `getDailyMarket`

**Description:** Function to get the daily grouped data for the entire
Crypto market

**Input:** Date in “YYYY-MM-DD” format

**Output:** Returns a table of containing crypto market information on
the input date

``` r
getDailyMarket <- function(date=Sys.Date()){

   # Build the URL
   baseURL <- "https://api.polygon.io/v2/aggs/grouped/locale/global/market/crypto/"
   key <- paste0("?apiKey=", APIkey)
   day <- date
   URL <- paste0(baseURL, day, key)
   
   # Use the URL to retrieve data from API
   dailyMarketList <- fromJSON(URL)
   
    # Select meaningful variables from the `results` table
   dailyMarketData <- dailyMarketList$results %>% select(ticker = T, volume = v, priceOpen = o, priceClose = c)
   
   return(dailyMarketData)
}

# Sample Function Call
kable(head(getDailyMarket("2021-09-30"), n=5))
```

| ticker    |       volume |   priceOpen |  priceClose |
| :-------- | -----------: | ----------: | ----------: |
| X:ICPUSD  |    539819.67 |    44.40000 |    45.08400 |
| X:LTCEUR  |     54319.85 |   124.85000 |   132.23000 |
| X:MANAUSD |   6227804.05 |     0.64500 |     0.68900 |
| X:IOTXUSD | 109464846.00 |     0.06025 |     0.06036 |
| X:BTCUSD  |     28947.92 | 41519.11000 | 43770.97000 |

## (4) `getTickerDetails`

**Description:** Function to get more information about the input ticker

**Input:** Ticker name. Examples: “BTCUSD” or “ETHUSD”

**Output:** Returns a table of ticker information such as currency
symbol and name

``` r
getTickerDetails <- function(ticker){

   # Build the URL  
   baseURL <- "https://api.polygon.io/vX/reference/tickers/"
   symbol <- paste0("X:", ticker)
   key <- paste0("?apiKey=", APIkey)
   URL <- paste0(baseURL, symbol, key)
   
   # Use the URL to retrieve data from API
   tickerList <- fromJSON(URL)
   
   # Select meaningful variables from the `results` table
   tickerData <- as.data.frame(tickerList$results) %>% select(ticker, name, market, locale, currency_name, base_currency_symbol, base_currency_name)
   
   return(tickerData)
}

# Sample Function Call
kable(getTickerDetails("ETHUSD"))
```

| ticker   | name                            | market | locale | currency\_name       | base\_currency\_symbol | base\_currency\_name |
| :------- | :------------------------------ | :----- | :----- | :------------------- | :--------------------- | :------------------- |
| X:ETHUSD | Ethereum - United States Dollar | crypto | global | United States Dollar | ETH                    | Ethereum             |

## (5) `getPreviousClose`

**Description:** Function to get the previous day’s open, high, low, and
close for the input cryptocurrency

**Input:** Cryptocurrency pair ticker. Example: “BTCUSD” or “ETHUSD”

**Output:** Returns a table of containing previous day’s data

``` r
getPreviousClose <- function(ticker){
      
   baseURL <- "https://api.polygon.io/v2/aggs/ticker/"
   symbol <- paste0("X:", ticker, "/")
   otherSettings <- "prev?adjusted=true"
   key <- paste0("&apiKey=", APIkey)
   URL <- paste0(baseURL, symbol, otherSettings, key)
   
   # Use the URL to retrieve data from API
   prevCloseList <- fromJSON(URL)
   
   # Select meaningful variables from the `results` table
   prevCloseData <- prevCloseList$results %>% select(ticker = T, volume = v, priceOpen = o, priceClose = c, priceLowest = l, priceHighest = h)

   return(prevCloseData)   
}

#Sample Function Call
kable(getPreviousClose("ETHUSD"))
```

| ticker   |   volume | priceOpen | priceClose | priceLowest | priceHighest |
| :------- | -------: | --------: | ---------: | ----------: | -----------: |
| X:ETHUSD | 183444.4 |   3388.67 |    3418.94 |     3342.52 |         3490 |

## (6) `getAggregates`

**Description:** Function to get 1-year aggregate data for a
cryptocurrency pair ending at a given date

**Input:** Date in “YYYY-MM-DD” format

**Output:** Returns a table of containing crypto market information such
as daily volume and price

``` r
getAggregates <- function(date=Sys.Date(), ticker){

   # Retrieve the date 1 year prior to the input date
   dayEnd <- as.Date(date)
   dayStart <- dayEnd - 364
   
   # Build the URL
   baseURL <- "https://api.polygon.io/v2/aggs/ticker/"
   symbol <- paste0("X:", ticker, "/")
   range <- "range/1/day/"
   otherSettings <- "?adjusted=true&sort=asc&limit=365"
   key <- paste0("&apiKey=", APIkey)
   URL <- paste0(baseURL, symbol, range, dayStart, "/", dayEnd, otherSettings, key)
   
   # Use the URL to retrieve data from API
   aggregateList <- fromJSON(URL)
   aggregateData <- aggregateList$results
   
   # The table from API does not have the date, so we will create it
   date_range <- as.Date(c(dayStart:dayEnd), origin = "1970-01-01")
   
   # Get the Quarter of the date (from lubridate package)
   qtr <- paste0(year(date_range), " Q", quarter(date_range))
   
   cryptoData <- data.frame(qtr, date_range, aggregateData$v, aggregateData$o, aggregateData$c)
   colnames(cryptoData) <- c("quarter", "date", "volume", "priceOpen", "priceClose")
   
   return(cryptoData)
}

kable(head(getAggregates("2021-09-30", ticker="BTCUSD"), n=5))
```

| quarter | date       |   volume | priceOpen | priceClose |
| :------ | :--------- | -------: | --------: | ---------: |
| 2020 Q4 | 2020-10-01 | 58731.65 |  10797.00 |   10616.10 |
| 2020 Q4 | 2020-10-02 | 61021.60 |  10616.35 |   10573.12 |
| 2020 Q4 | 2020-10-03 | 27705.14 |  10586.00 |   10551.65 |
| 2020 Q4 | 2020-10-04 | 23021.75 |  10550.32 |   10671.11 |
| 2020 Q4 | 2020-10-05 | 37483.09 |  10669.00 |   10799.00 |

## (7)\[Wrapper\] `cryptoAPI`

**Description:** Wrapper function to call any of the 6 functions above.

**Input:** The `func` parameter can take either the function id (1-6) or
the function name (in quotes).

For functions that need the `ticker` variable, you can supply either the
`name` or the `ticker` argument. Examples of `name` are “bitcoin” or
“ETHEREUM”, and examples of `ticker` are “btcusd” “ethUSD”. The letter
case do not matter since they will be converted and mapped correctly
within the function.

**Output:** Returns the output from the specific function called

``` r
cryptoAPI <- function(func, name="", ticker="", date=Sys.Date()){
   
   # Check if `func` is numeric (1-6)
   # If it is outside of (1-6), return an error message
   # If it is within 1 to 6, map to the corresponding function
   if (is.numeric(func)){
      if (!between(func, 1, 6)){
         stop("ERROR: There are only 6 functions. Please input a valid function ID (1 to 6)")
      } else{
        func <- switch(func,
                    "getExchange",
                    "getNews",
                    "getDailyMarket",
                    "getTickerDetails",
                    "getPreviousClose",
                    "getAggregates")
      } 
   }
   
   # Check to see if either `name` or `ticker` is provided
   # Some functions do not require these arguments
   if (name != "" | ticker != ""){
   
      # Allow user to specify either the crypto currency name or the ticker name
      # Map the name to the corresponding ticker
      # Only the top 10 cryptocurrencies (by market cap) are supported
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
      } else if (ticker != ""){
        symbol <- toupper(ticker)
      } 
      
      # Check to see if the ticker is mapped correctly
      if (symbol == ""){
         message <- paste("ERROR: Only the top 10 cryptocurrencies by market cap are supported,", 
                          "please input another name, or use the `ticker` and input a valid Crypto ticker")
         stop(message)
         
      # Use function 3 `getDailyMarket` to check for valid ticker names
      }
      
   
   # For functions that require the input, check to see if the ticker is mapped correctly      
   }else if(name == "" & ticker == "" & func %in% c("getTickerDetails", "getPreviousClose", "getAggregates")){
      stop("ERROR: Missing cryptocurrency name or ticker input required for this function")
   }   
   
   
   # Function 1
   if (func == "getExchange"){
      output <- getExchange()
   
   # Function 2      
   }else if (func == "getNews"){
      output <- getNews()
      
   # Function 3   
   }else if (func == "getDailyMarket"){
      output <- getDailyMarket(date)
   
   # Function 4      
   }else if (func == "getTickerDetails"){
      output <- getTickerDetails(symbol)
   
   # Function 5   
   }else if (func == "getPreviousClose"){
      output <- getPreviousClose(symbol)
   
   # Function 6      
   }else if (func == "getAggregates"){
      output <- getAggregates(date, symbol)
   
   # Return error message if the function name is not mapped correctly   
   }else{
      stop("ERROR: The `func` argument is not valid")
   }
   
   return(output)
}
```

The following are examples of valid functions calls:

``` r
cryptoAPI(1)
cryptoAPI("getNews")
cryptoAPI(3)
cryptoAPI("getTickerDetails", name="cardano")
cryptoAPI(5, ticker="ethusd")
cryptoAPI(6, name="eThErEuM")
```

# Data Exploration

We will now use some of the above functions to retrieve data from the
API and perform some data exploration.

## Top Cryptocurrencies

<img src="images/crypto.jpg" width="400px" />

We can first look at 6 of the top cryptocurrencies by market cap. We
will calculate the YTD price change by using “2021-01-01” as the
baseline date and “2021-09-30” as the comparison date. We can use the
`cryptoAPI` wrapper function to call the `getDailyMarket` function using
the two dates. Then we can merge the two datasets and calculate the YTD
change.

Now we can visualize the data by creating a bar plot of the YTD change.

``` r
ggplot(marketData, aes(x=cryptoCurrency, y=pctChange, fill=cryptoCurrency)) +
   geom_bar(stat="identity") +
   scale_y_continuous(labels = scales::percent) +
   labs(title="YTD Price Change as of 2021-09-30 in 6 Top Cryptocurrencies", 
        y="YTD % Change") +
   theme(text=element_text(size=14),
         legend.position = "none")
```

![](README_files/figure-gfm/barplot-1.png)<!-- --> From the graph we can
see that Dogecoin has the highest YTD change by far, with approximately
+3500% increase. Cardano also has a large YTD change with over 1000%
increase. In contrast, Bitcoin and Litecoin has the lowest YTD change.

## Bitcoin vs Ethereum

<img src="images/bitcoin_vs_ethereum.jpg" width="848" />

Ethereum, the second largest cryptocurrency by market cap, is often
compared to Bitcoin. As of 2021-10-02, Bitcoin has a market cap of $900
million, while Ethereum has a market cap of $400 million. We can first
look at the performance of the two cryptocurrencies over the past year.
We will grab the 1 year data ending on “2021-09-30” from the API, since
that would give us 4 complete quarters.

``` r
bitcoinData <- cryptoAPI("getAggregates", name="Bitcoin", date="2021-09-30")
ethereumData <- cryptoAPI(6, name="Ethereum", date="2021-09-30")

calcPerformance <- function(price){

   change1Day <- scales::percent((price[365] - price[364]) / price[364], accuracy=0.1)
   change7Day <- scales::percent((price[365] - price[358]) / price[358], accuracy=0.1)
   change30Day <-scales::percent((price[365] - price[335]) / price[335], accuracy=0.1)
   changeYear <- scales::percent((price[365] - price[1]) / price[1], accuracy=0.1)
   
   scales::label_percent(c(change1Day, change7Day))
   
   performanceData <- cbind(price = price[365], '24h %' = change1Day, '7d %' = change7Day, '30d %' = change30Day, 'yr %' = changeYear)
   
   return(performanceData)
}

bitcoinPerformance <- cbind(cryptocurrency = "Bitcoin", calcPerformance(bitcoinData$priceClose))
ethereumPerformance <- cbind(cryptocurrency = "Ethereum", calcPerformance(ethereumData$priceClose))

kable(rbind(bitcoinPerformance, ethereumPerformance))
```

| cryptocurrency | price    | 24h % | 7d %   | 30d %   | yr %   |
| :------------- | :------- | :---- | :----- | :------ | :----- |
| Bitcoin        | 43770.97 | 5.4%  | \-2.5% | \-7.1%  | 312.3% |
| Ethereum       | 3000.28  | 5.3%  | \-4.9% | \-12.5% | 749.9% |

``` r
bitcoinData$cryptoCurrency <- "Bitcoin"
ethereumData$cryptoCurrency <- "Ethereum"

combinedData <- rbind(bitcoinData, ethereumData)
combinedData$dayPerformance <- ifelse(combinedData$priceClose - combinedData$priceOpen >= 0, "Gain", "Loss")
combinedData$dayChange <- scales::percent((combinedData$priceClose - combinedData$priceOpen) / combinedData$priceOpen, accuracy=0.01)


table(combinedData$quarter, combinedData$dayPerformance, combinedData$cryptoCurrency)
```

    ## , ,  = Bitcoin
    ## 
    ##          
    ##           Gain Loss
    ##   2020 Q4   60   32
    ##   2021 Q1   51   39
    ##   2021 Q2   41   50
    ##   2021 Q3   48   44
    ## 
    ## , ,  = Ethereum
    ## 
    ##          
    ##           Gain Loss
    ##   2020 Q4   55   37
    ##   2021 Q1   53   37
    ##   2021 Q2   52   39
    ##   2021 Q3   52   40

``` r
ggplot(filter(combinedData, cryptoCurrency=="Bitcoin"), aes(quarter, volume)) +
   geom_boxplot(size=1) +
   geom_jitter(aes(y=volume, fill=dayPerformance, color=dayPerformance), size=2) +
   labs(title="Boxplot for Bitcoin Trading Volume by Quarter") +
   theme(text=element_text(size=16), 
         panel.grid.major = element_line(size=1.5),
         axis.ticks = element_line(size=1.4),
         axis.ticks.length = unit(0.20, 'cm')) +
   scale_color_manual(values = c("Gain" = "lightgreen", "Loss" = "red"))
```

![](README_files/figure-gfm/boxplots-1.png)<!-- -->

``` r
ggplot(filter(combinedData, cryptoCurrency=="Ethereum"), aes(quarter, volume)) +
   geom_boxplot(size=1) +
   geom_jitter(aes(y=volume, fill=dayPerformance, color=dayPerformance), size=2) +
   labs(title="Boxplot for Ethereum Trading Volume by Quarter") +
   theme(text=element_text(size=16), 
         panel.grid.major = element_line(size=1.5),
         axis.ticks = element_line(size=1.4),
         axis.ticks.length = unit(0.20, 'cm')) +
   scale_color_manual(values = c("Gain" = "lightgreen", "Loss" = "red"))
```

![](README_files/figure-gfm/boxplots-2.png)<!-- -->

``` r
scatterData <- data.frame(quarter = bitcoinData$quarter, bitcoin = bitcoinData$priceClose, ethereum = ethereumData$priceClose)

ggplot(scatterData, aes(x=ethereum, y=bitcoin)) +
   geom_point(aes(col=quarter)) + 
   geom_smooth(method=lm)
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/correlation-1.png)<!-- -->

``` r
R <- cor(x=scatterData$bitcoin, y=scatterData$ethereum)
R2 <- R^2

correlation <- data.frame(R=R, R2=R2)
kable(correlation, digits=4)
```

|      R |    R2 |
| -----: | ----: |
| 0.7443 | 0.554 |

``` r
ggplot(filter(combinedData, cryptoCurrency=="Bitcoin")) +   
   geom_line(aes(x=date, y=priceClose, stat="identity")) +
   geom_bar(aes(x=date, y=volume/8, fill=dayPerformance), stat="identity") +
   scale_y_continuous(sec.axis = sec_axis(~ .*8, name="Volume")) +
   scale_fill_manual(values = c("Gain" = "lightgreen", "Loss" = "red"))
```

    ## Warning: Ignoring unknown aesthetics: stat

![](README_files/figure-gfm/price%20by%20volume%20plot-1.png)<!-- -->

# Conclusion

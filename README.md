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
      - [YTD Performance of Top
        Cryptocurrencies](#ytd-performance-of-top-cryptocurrencies)
      - [Bitcoin Performance](#bitcoin-performance)
      - [Bitcoin vs Ethereum](#bitcoin-vs-ethereum)
  - [Conclusion](#conclusion)

<img src="images/crypto.jpg" width="527" />

# Introduction

Cryptocurrencies have gained traction over the past couple of years. As
the trend continues, some may be interested in performing data
exploration or analysis. To start, we will need data to work with.
[polygon.io](https://polygon.io/) provides free access to financial
data, which includes Cryptocurrency data. We can access these data by
interacting with the [Application Programming Interface
(API)](https://www.mulesoft.com/resources/api/what-is-an-api).

This document will go over the processes of using R to interact with the
cryptocurrency API. It will go over the requirements and useful
functions, followed by data exploration examples and conclusion.

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

**Input:** Date in “YYYY-MM-DD” format. The default is the day before
system date.

**Output:** Returns a table of containing crypto market information on
the input date

``` r
getDailyMarket <- function(date=Sys.Date()-1){

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

| ticker    |      volume |  priceOpen | priceClose |
| :-------- | ----------: | ---------: | ---------: |
| X:ICPUSD  |    539819.7 |  44.400000 |  45.084000 |
| X:XLMUSD  | 127436391.1 |   0.269729 |   0.278615 |
| X:COMPUSD |    120354.6 | 307.380000 | 318.200000 |
| X:MANAUSD |   6227804.0 |   0.645000 |   0.689000 |
| X:IOTXUSD | 109464846.0 |   0.060250 |   0.060360 |

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
| X:ETHUSD | 241097.7 |  3419.666 |     3387.2 |      3268.4 |       3441.3 |

## (6) `getAggregates`

**Description:** Function to get 1-year aggregate data for a
cryptocurrency pair ending at a given date

**Input:** Date in “YYYY-MM-DD” format

**Output:** Returns a table of containing crypto market information such
as daily volume and price

``` r
getAggregates <- function(date=Sys.Date()-1, ticker){

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
“ETHEREUM”, and examples of `ticker` are “btcusd” or “ethUSD”. The
letter case do not matter since they will be converted and mapped
correctly within the function.

**Output:** Returns the output from the specific function called

``` r
cryptoAPI <- function(func, name="", ticker="", date=Sys.Date()-1){
   
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

## YTD Performance of Top Cryptocurrencies

<img src="images/cryptocurrency-market.jpg" width="500px" />

We can first look at 6 of the top cryptocurrencies by market cap. We
will calculate the YTD price change by using “2021-01-01” as the
baseline date and “2021-09-30” as the comparison date. We can use the
`cryptoAPI` wrapper function to call the `getDailyMarket` function using
the two dates. Then we can merge the two datasets and calculate the YTD
change.

``` r
# Call the wrapper function and specify the desired function name 
marketBaseline <- cryptoAPI("getDailyMarket", date="2021-01-01") 

# Alternative way to call the API using the function ID
marketCurrent <- cryptoAPI(3, date="2021-09-30")

# Merge the two datasets from API
# Only get the 6 Top cryptocurrencies
# Calculate percent change and map the tickers to their respective cryptocurrency names
marketData <- merge(marketBaseline, marketCurrent, by="ticker") %>%
                  filter(ticker %in% c("X:BTCUSD", "X:ETHUSD", "X:ADAUSD", "X:XRPUSD", "X:DOGEUSD", "X:LTCUSD")) %>%
                  select(ticker, priceBase = priceClose.x, priceCurrent = priceClose.y) %>%
                  mutate(pctChange = (priceCurrent - priceBase) / priceBase,
                         cryptoCurrency = ifelse(ticker=="X:BTCUSD", "Bitcoin",
                                ifelse(ticker=="X:ETHUSD", "Ethereum",
                                ifelse(ticker=="X:ADAUSD", "Cardano",
                                ifelse(ticker=="X:XRPUSD", "XRP",
                                ifelse(ticker=="X:DOGEUSD", "Dogecoin",
                                ifelse(ticker=="X:LTCUSD", "Litecoin", "Check Ticker")))))))
# Show data
kable(marketData)
```

| ticker    |    priceBase | priceCurrent |  pctChange | cryptoCurrency |
| :-------- | -----------: | -----------: | ---------: | :------------- |
| X:ADAUSD  | 1.751540e-01 |      2.11370 | 11.0676662 | Cardano        |
| X:BTCUSD  | 2.941284e+04 |  43770.97000 |  0.4881586 | Bitcoin        |
| X:DOGEUSD | 5.707900e-03 |      0.20420 | 34.7749785 | Dogecoin       |
| X:ETHUSD  | 7.308500e+02 |   3000.28000 |  3.1051926 | Ethereum       |
| X:LTCUSD  | 1.265300e+02 |    153.19000 |  0.2107010 | Litecoin       |
| X:XRPUSD  | 2.376500e-01 |      0.95254 |  3.0081633 | XRP            |

Now we can visualize the data by creating a bar plot of the YTD change.

``` r
ggplot(marketData, aes(x=cryptoCurrency, y=pctChange, fill=cryptoCurrency)) +
   geom_bar(stat="identity") +
   scale_y_continuous(labels = scales::percent) +
   theme(text=element_text(size=12),
         legend.position = "none") +
   labs(title="YTD Price Change as of 2021-09-30 in 6 Top Cryptocurrencies", 
        y="YTD % Change")
```

![](README_files/figure-gfm/market%20barplot-1.png)<!-- -->

From the graph we can see that Dogecoin has the highest YTD change by
far, with approximately 3500% increase. Cardano also has a large YTD
change with over 1000% increase. In contrast, Bitcoin and Litecoin have
the lowest YTD change.

## Bitcoin Performance

Next, we can focus on the Bitcoin data. We can get daily volume and
price data using the `getAggregates` function. We will get the 1 year
data ending on “2021-09-30” since that would give us 4 complete
quarters. We can then derive variables and generate figures.

``` r
# Use the cryptoAPI function to get the 1 year data for Bitcoin
bitcoinData <- cryptoAPI("getAggregates", name="Bitcoin", date="2021-09-30")

# Categorize each day as "Gain" or "Loss" and calculate the percent change 
bitcoinData$dayPerformance <- ifelse(bitcoinData$priceClose - bitcoinData$priceOpen >= 0, "Gain", "Loss")
bitcoinData$dayChange <- (bitcoinData$priceClose - bitcoinData$priceOpen) / bitcoinData$priceOpen
```

### Volume by Quarter

Now that we have calculated the day performance (Gain or Loss), we can
can create a boxplot of the volume by quarter, with day gain and losses
as different colors.

``` r
ggplot(bitcoinData, aes(quarter, volume/1000)) +
   geom_boxplot(size=1) +
   geom_jitter(aes(y=volume/1000, col=dayPerformance), size=2) +
   theme(text=element_text(size=14), 
         panel.grid.major = element_line(size=1.5),
         axis.ticks = element_line(size=1.4),
         axis.ticks.length = unit(0.20, 'cm')) +
   scale_color_manual(values = c("Gain" = "lightgreen", "Loss" = "red")) +
   labs(title = "Bitcoin Trading Volume by Quarter",
        x="Quarter", y="Volume (Thousands)", 
        color="Day Performance")
```

![](README_files/figure-gfm/Bitcoin%20boxplots-1.png)<!-- -->

From the boxplot we can see that the average volume is the highest in Q1
of 2021, with Q3 of 2021 having the least volume. The day performance of
gains and losses are fairly spread out. We can see that there are some
outliers in each quarter.

### Price with Volume

Next, we can look at how the Bitcoin price and volume behave together.

``` r
ggplot(bitcoinData) +   
   geom_line(aes(x=date, y=priceClose, stat="identity")) +
   geom_bar(aes(x=date, y=volume/8, fill=dayPerformance), stat="identity") +
   scale_y_continuous(sec.axis = sec_axis(~ .*.008, name="Volume (Thousands)")) +
   scale_fill_manual(values = c("Gain" = "lightgreen", "Loss" = "red")) +
   labs(title="Bitcoin Price and Volume Chart",
        y="Price ($)", 
        fill="Day Performance")
```

    ## Warning: Ignoring unknown aesthetics: stat

![](README_files/figure-gfm/Bitcoin%20price%20by%20volume%20plot-1.png)<!-- -->

From the chart we can see that from Oct 2020 to Jan 2021, as the volume
was increasing, the price was also increasing. We can also see the two
tallest red ticks, one in Jan 2021 and another in May 2021. These were
followed by big price drop.

### Daily Price Change

We can examine the distribution of the daily % gains and losses. One way
to visualize this is to create a histogram.

``` r
ggplot(bitcoinData, aes(x=dayChange, fill=..x..)) + 
   geom_histogram(binwidth=0.01) +
   scale_x_continuous(labels = scales::percent) +
   scale_fill_gradient(low="red", high="green", labels = scales::percent) +
   labs(title="Histogram of Daily Price Change (%)", 
        x="Day Change",
        y="Count",
        fill="")
```

![](README_files/figure-gfm/Bitcoin%20Histogram-1.png)<!-- -->

From the histogram we can see that the distribution looks approximately
normal, centered at 0%. With the Bitcoin price going from $10,000 to
over $40,000 in a year, we might expect more Day Change to be positive,
but the distribution looks quite balanced.

## Bitcoin vs Ethereum

<img src="images/bitcoin_vs_ethereum.jpg" width="848" />

Ethereum, the second largest cryptocurrency by market cap, is often
compared to Bitcoin. As of 2021-10-02, Bitcoin has a market cap of $900
million, while Ethereum has a market cap of $400 million. We can first
look at the performance of the two cryptocurrencies over the past year.
Again, we will grab the 1 year data ending on “2021-09-30” from the API,
since that would give us 4 complete quarters.

``` r
# Use the cryptoAPI function to obtain Ethereum data
ethereumData <- cryptoAPI(6, name="Ethereum", date="2021-09-30")

# Categorize each day as "Gain" or "Loss" and calculate the percent change 
ethereumData$dayPerformance <- ifelse(ethereumData$priceClose - ethereumData$priceOpen >= 0, "Gain", "Loss")
ethereumData$dayChange <- (ethereumData$priceClose - ethereumData$priceOpen) / ethereumData$priceOpen
```

### 1-Year Performance

We can compare the performance of Bitcoin and Ethereum by calculating
the price change of 1, 7, 30 days and 1 year.

``` r
# Function to calculate the 1, 7, 30 day and the 1 year price change
calcPerformance <- function(price){
   
   # Calculate change and present in percentages
   change1Day <- scales::percent((price[365] - price[364]) / price[364], accuracy=0.1)
   change7Day <- scales::percent((price[365] - price[358]) / price[358], accuracy=0.1)
   change30Day <-scales::percent((price[365] - price[335]) / price[335], accuracy=0.1)
   changeYear <- scales::percent((price[365] - price[1]) / price[1], accuracy=0.1)
   
   # Name the columns
   performanceData <- cbind(price = price[365], '24h %' = change1Day, '7d %' = change7Day, '30d %' = change30Day, 'yr %' = changeYear)
   
   return(performanceData)
}

# Call the function and present the combined table
bitcoinPerformance <- cbind(cryptocurrency = "Bitcoin", calcPerformance(bitcoinData$priceClose))
ethereumPerformance <- cbind(cryptocurrency = "Ethereum", calcPerformance(ethereumData$priceClose))

kable(rbind(bitcoinPerformance, ethereumPerformance))
```

| cryptocurrency | price    | 24h % | 7d %   | 30d %   | yr %   |
| :------------- | :------- | :---- | :----- | :------ | :----- |
| Bitcoin        | 43770.97 | 5.4%  | \-2.5% | \-7.1%  | 312.3% |
| Ethereum       | 3000.28  | 5.3%  | \-4.9% | \-12.5% | 749.9% |

### Number of Days of Gains vs Losses

We can also calculate the number of days of gains and losses by quarter.
We can do that by creating a contingency table.

``` r
bitcoinData$cryptoCurrency <- "Bitcoin"
ethereumData$cryptoCurrency <- "Ethereum"

combinedData <- rbind(bitcoinData, ethereumData)

# Create a 3 way contingency table
dayPerformance <- table(combinedData$quarter, combinedData$dayPerformance, combinedData$cryptoCurrency)

# Present the tables
kable(dayPerformance[, , 1], caption = "Bitcoin: Days of Gains and Losses by Quarter")
```

|         | Gain | Loss |
| :------ | ---: | ---: |
| 2020 Q4 |   60 |   32 |
| 2021 Q1 |   51 |   39 |
| 2021 Q2 |   41 |   50 |
| 2021 Q3 |   48 |   44 |

Bitcoin: Days of Gains and Losses by Quarter

``` r
kable(dayPerformance[, , 2], caption = "Ethereum: Days of Gains and Losses by Quarter")
```

|         | Gain | Loss |
| :------ | ---: | ---: |
| 2020 Q4 |   55 |   37 |
| 2021 Q1 |   53 |   37 |
| 2021 Q2 |   52 |   39 |
| 2021 Q3 |   52 |   40 |

Ethereum: Days of Gains and Losses by Quarter

Now we have seen the data in the contingency table, we could also
visualize it with bar plots.

``` r
ggplot(combinedData, aes(x=quarter, fill=dayPerformance)) +
   geom_bar(stat="count", position="dodge") +
   scale_fill_manual(values = c("Gain" = "lightgreen", "Loss" = "red")) +
   theme(text=element_text(size=12)) +
   labs(title="Number of Days of Gains and Losses by Quarter", 
        x = "Quarter",
        y="Number of Days",
        fill="Day Performance") +
   facet_grid(~ cryptoCurrency) 
```

![](README_files/figure-gfm/BTC%20ETH%20Barplot-1.png)<!-- -->

From the bar plot, we can see that Bitcoin has much more days of gains
than losses in 2020 Q4, but there are more days of losses than gains in
2021 Q2. For Ethereum, the pattern is pretty much the same, with more
days of gains than losses.

### Correlation

The price of cryptocurrencies often move together as a market. We can
analyze the correlation between Bitcoin and Ethereum. First, we will
generate a scatterplot.

``` r
# Build data used for scatterplot 
scatterData <- data.frame(quarter = bitcoinData$quarter, bitcoin = bitcoinData$priceClose, ethereum = ethereumData$priceClose)

ggplot(scatterData, aes(x=ethereum, y=bitcoin)) +
   geom_point(aes(col=quarter)) + 
   geom_smooth(method=lm) + 
   labs(title="Scatterplot of Bitcoin vs Ethereum from 2020-10-01 to 2021-09-30", 
        x="Ethereum Price ($)", 
        y="Bitcoin Price ($)",
        col="Quarter")
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/correlation%20plot-1.png)<!-- -->

From the scatterplot, we can see that for many of the quarters, the
points are in clusters. This suggests that the price move closely
together at least within the quarter. We do see a positive correlation.

``` r
# Calculate correlation coefficient
r <- cor(x=scatterData$bitcoin, y=scatterData$ethereum)
r2 <- R^2

# Format and present the table
correlation <- data.frame(r=r, r2=r2)
kable(correlation, digits=4)
```

|      r |    r2 |
| -----: | ----: |
| 0.7443 | 0.554 |

We can calculate the correlation coefficient (r). With r=0.7443, we can
say that the price of Bitcoin and Ethereum have a fairly strong positive
linear relationship within the year.

# Conclusion

We have gone through different functions to help you retrieve data from
calling the crypto API. We also looked at how these functions and data
can be used in data exploration and analysis. Hopefully you have learned
how to use the API functions and use them as tools to play around with
crypto data\!

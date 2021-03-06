#' ---	
#' title: "Forecasting Heirarchical Time Series"	
#' 	
#' 	
#' output:	
#'   html_document:	
#'     css: style.css	
#' 	
#' 	
#' ---	
#' ![](logo.gif)	
#' 	
#' 	
require(plotly)	
require(fpp)	
require(ggplot2)	
library(hts)	
knitr::opts_chunk$set(echo = TRUE)	
#' 	
#' 	
#' ### Context	
#' 	
#' 	
#' 	
#' 	
#' This article is about a technique which can come quite handy when one wants to build multiple time series models for the time series which have inherently heirarchical structure.	
#' 	
#' 	
#' Time series can often be naturally disaggregated in a hierarchical structure using attributes such as geographical location, product type, etc. For example, the total number of Member of Parliaments(MPs) in a given election can  come from different States and in turn given a particular State ,from different cities,districts and so forth.Such disaggregation imposes a hierarchical structure. We refer to these as hierarchical time series.	
#' 	
#' Another possibility is that series can be naturally grouped together based on attributes without necessarily imposing a hierarchical structure. For example the MPs in the above context can be filtered down also on the basic of Sex viz.Male ,Female and Others. Grouped time series can be thought of as hierarchical time series that do not impose a unique hierarchical structure in the sense that the order by which the series can be grouped is not unique.	
#' 	
#' Though in this blog we will talk solely about heirarchical time series though grouped time series can also be handled symmetrically.	
#' 	
#' I will try and focus more on the intuition rather than the mathematical details here but if one is interested in the same please refer [here](https://robjhyndman.com/papers/Hierarchical6.pdf)	
#' 	
#' 	
#' Let's plot some heirarchical  time series below.**This one pertains to Total quarterly visitor nights from 1998-2011 for eight regions of Australia**:	
#' 	
#' ### Data Description	
#' 	
#' I will show below some  graphs and tables pertaining to the Data at hand so as to expose it better.	
#' 	
#' Time Series Title  | Description	
#' ------------- | -------------	
#' Sydney  | The Sydney metropolitan area.	
#' NSW  | New South Wales other than Sydney	
#' Melbourne|The Melbourne metropolitan area.	
#' VIC      |Victoria other than Melbourne.	
#' BrisbaneGC|The Brisbane and Gold Coast area.	
#' QLD|Queensland other than Brisbane and the Gold Coast.	
#' Capitals          |The other five capital cities: Adelaide, Hobart, Perth, Darwin and Canberra.	
#' Other|All other areas of Australia.	
#' 	
#' 	
#' 	
#' ![](heirarchy.png)	
#' ---	
#' <center> **Fig:Australia Vistor Nights Heirarchy** </center>	
#' ---	
#' 	
#' ---	
#' ---	
#' ---	
#' 	
#' <center> **Glimpse of the Data at Hand** </center>	
#' 	
#' 	
#' 	
	
	
knitr::kable(head(data.frame(vn,row.names = time(vn))))	
ggplotly(autoplot(vn,ylab='No of vistor Nights',title='a'))	
#' 	
#' <left> **Fig:Time Series Tourists at City Level** </left>	
#' 	
#' ### Intuition	
#' 	
#' 	
#' 	
#' I will try to keep the focus more on the intuitive part relative to the theory but more advanced/curious folks can refer [here](https://robjhyndman.com/papers/Hierarchical6.pdf)	
#' 	
#' Summary of the 3 methods broadly which can be used to forecast(The optimal combination approach we are skipping as its outside the scope but interested folks can refer [here](https://robjhyndman.com/papers/Hierarchical6.pdf)) **hierarchical and grouped time series**.	
#' 	
#' **Summary Forecast Methods**	
#' 	
#' Forecast Method  | Description | 	
#' ------------- | -------------	
#' bottom-up approach  | This approach involves first generating base independent forecasts for each series at the bottom level of the hierarchy and then aggregating these upwards.	
#' top-down approach  | Top-down approaches involve first generating base forecasts for the “Total” series  top of the hierarchy and then disaggregating  downwards. 	
#' Middle-out approach|A hybrid of the above two approaches.	
#' 	
#' 	
#' 	
#' *Briefly wiill go try and explain the above methods in our context in laymanish terms.*	
#' 	
#' * **bottom-up approach**: Here this means we will forecast lower most level of the Heirarchy i.e cities and then aggregate the results up the heirarchy.	
#' 	
#' * **top-down approach**: Here this means that we will forecast at the highest level heirarchy i.e	
#' pan Australia level and then disaggregate the results down the heirarchy.This disaggregation can happen via 	
#'     + computing relative proportions historically and using that for future periods.	
#'     + forecasting the proportions in isolation,normalising it and then using that to disaggregate. 	
#' 	
#' * **Middle-out approach**:It's a hybrid approach.Basially in this:	
#'     + A middle level is chosen let's say the state level which has 4 series/nodes within it.	
#'     + 4 time series models at this level will be made.	
#'     + For the top mode level bottom up approach would be used to aggregate the results.	
#'     + For the bottom level middle level results would be disaggregated downwards.	
#' 	
#' <centre> Pretty simple right!. </centre>	
#' 	
#' Now implementing this is even simpler.I will demostrate a working example via one of the above techniques and rest you can carch up via the documentaion  of ***hts*** package in **R** language.	
#' 	
#' 	
#' ---	
#' 	
#' ### Application	
#' 	
#' 	
#' 	
	
y <- hts(vn, nodes=list(4,c(2,2,2,2)))	
	
#' 	
#' The  above command creates a heirarchical time series with 3 levels(top most level one does not have to specify) with 4 nodes in the middle and 8 nodes in bottom most level.(basically the argument 'nodes' does the trick for you here.)	
#' 	
#' 	
#' 	
allf <- forecast(y, h=8,method = 'tdfp',fmethod = 'ets')	
names(allf$labels)=c('Pan Australia level Forecast','State Level Forecast',	
                           'City Level Forecast')#here tdfp means top-down forecast #proportions	
plot(allf)	
 	
	
#' 	
#' <center> **Forecasts across all the Heirarchies** </center>	
#' ---	
#' 	
#' The above command will give you forecasts(dotted lines in respective colours are the forecasts) across all levels in the heirarchy using top-down forecast proportions approach discussed above for 8 periods(quarters in our case) ahead.	
#' 	
#' Just to reiterate:	
#' 	
#' * **Level 0**--pan Australia level	
#' * **Level 1**--State level	
#' * **Level 2**--City Level	
#' 	
#' One can go futher deep in the documentation [here](https://cran.r-project.org/web/packages/hts/hts.pdf) and try out different techniques with different parameter combinations.	
#' &nbsp;	
#' 	
#' Below animation captures forecast by  various(some) combinations of parameters/methods.	
#' 	
#' ![](filtering-slow.gif)	
#' 	
#' ### Concluding Remarks	
#' 	
#' In this post we have  been able to learn from scratch(atleast at an applied and intuitive) level	
#' how open source tools like **R** and **hts** package can be levergaed to build time series models quite simple in complicated heirarchical structural data for forecasting purposes.	
#' &nbsp;	
#' 	
#' Also many things have been missed out courtesy paucity of space and time but in the above framework in lieu of Arima or classical statistical models one can **user defined function**	
#' as well for prediction purposed which suits the context.	
#' There are many other great things once can explore in this amazing package/module.	
#' &nbsp;	
#' 	
#' Hope this blog was helpful.See you soon then.	
#' &nbsp;	
#' 	
#' Peace...	
#' 	
#' 	
#' 	
#' 	
#' 	

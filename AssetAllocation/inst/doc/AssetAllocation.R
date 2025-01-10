## ----include=FALSE------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width=7, fig.height=5
)

## ----setup--------------------------------------------------------------------
library(AssetAllocation)
library(PerformanceAnalytics)
names(asset_allocations$static)

## ----all weather 1------------------------------------------------------------
asset_allocations$static$all_weather

## ----all weather 2------------------------------------------------------------
# define strategy 
all_weather <- asset_allocations$static$all_weather

# backtest strategy
bt_all_weather <- backtest_allocation(all_weather, ETFs$Prices, ETFs$Returns, ETFs$risk_free)

## ----all weather 3------------------------------------------------------------
# plot cumulative returns
charts.PerformanceSummary(bt_all_weather$returns, 
                          main = all_weather$strat$name)

## ----all weather 4------------------------------------------------------------
# table with performance metrics
bt_all_weather$table_performance

## ----all weather 5------------------------------------------------------------
chart.StackedBar(bt_all_weather$rebalance_weights,
                 date.format = "%Y",
                 main = paste0("Allocations, ", all_weather$name))

## ----factors EW setup---------------------------------------------------------
factors_EW  <- list(name = "EW Factors",
                      tickers = c("MTUM", "VLUE", "USMV", "QUAL"),
                      default_weights = c(0.25, 0.25, 0.25, 0.25),
                      rebalance_frequency = "month",
                      portfolio_rule_fn = "constant_weights")

## ----factors EW data, message=FALSE, warning=FALSE----------------------------
factor_ETFs_data <- get_data_from_tickers(factors_EW$tickers,
                                      starting_date = "2013-08-01")


## ----factors EW bt------------------------------------------------------------
# backtest the strategy
bt_factors_EW <- backtest_allocation(factors_EW,factor_ETFs_data$P, factor_ETFs_data$R)

# plot returns
charts.PerformanceSummary(bt_factors_EW$returns,
                          main = bt_factors_EW$strat$name,
                               )

# table with performance metrics
bt_factors_EW$table_performance

## ----tactical setup-----------------------------------------------------------
# define strategies
ivy <- asset_allocations$tactical$ivy
raa <- asset_allocations$tactical$raa
dual_mo <- asset_allocations$tactical$dual_mo
aaa <- asset_allocations$tactical$aaa

# run backtests
bt_ivy <- backtest_allocation(ivy, ETFs$Prices,ETFs$Returns, ETFs$risk_free)
bt_raa <- backtest_allocation(raa, ETFs$Prices,ETFs$Returns, ETFs$risk_free)
bt_dual_mo <- backtest_allocation(dual_mo, ETFs$Prices,ETFs$Returns, ETFs$risk_free)
bt_aaa <- backtest_allocation(aaa, ETFs$Prices,ETFs$Returns, ETFs$risk_free)

ret_strats <- merge.xts(bt_ivy$returns, bt_raa$returns, bt_dual_mo$returns, bt_aaa$returns)

# find index from which all strats are available
min_ind <- which.max(!is.na(rowSums(ret_strats)))

charts.PerformanceSummary(ret_strats[min_ind:nrow(ret_strats)])

cbind(bt_ivy$table_performance,
      bt_raa$table_performance,
      bt_dual_mo$table_performance,
      bt_aaa$table_performance)


## ----tactical allocations-----------------------------------------------------
chart.StackedBar(bt_ivy$rebalance_weights,
                 date.format = "%Y",
                 main = paste0("Allocations, ", bt_ivy$strat$name))

chart.StackedBar(bt_raa$rebalance_weights,
                 date.format = "%Y",
                 main = paste0("Allocations, ", bt_raa$strat$name))

chart.StackedBar(bt_dual_mo$rebalance_weights,
                 date.format = "%Y",
                 main = paste0("Allocations, ", bt_dual_mo$strat$name))

chart.StackedBar(bt_aaa$rebalance_weights,
                 date.format = "%Y",
                 main = paste0("Allocations, ", bt_aaa$strat$name))


## ----mvp, message=FALSE, warning=FALSE----------------------------------------
# Minimum variance portfolio
us_mvp  <- list(name = "US MinVar",
               tickers = c("VTI",
                           "BND"),
               default_weights = c(0.5,
                                   0.5),
               rebalance_frequency = "month",
               portfolio_rule_fn = min_variance)

bt_us_mvp <- backtest_allocation(us_mvp,
                                ETFs$Prices,
                                ETFs$Returns,
                                ETFs$risk_free)

charts.PerformanceSummary(bt_us_mvp$returns)

bt_us_mvp$table_performance

## ----mvp plot-----------------------------------------------------------------
chart.StackedBar(bt_us_mvp$rebalance_weights,
                 date.format = "%Y",
                 main = paste0("Allocations, ", us_mvp$name))

## ----risk parity setup--------------------------------------------------------
rp  <- list(name = "US Risk Parity",
             tickers = c("TIP",
                         "VTI", "EFA", "EEM",
                         "DBC", "GLD",
                         "IEF"),
             default_weights = c(0.25,
                                 0.25/3, 0.25/3, 0.25/3,
                                 0.25/2, 0.25/2,
                                 0.25),
             rebalance_frequency = "month",
             portfolio_rule_fn = "risk_parity")
             
bt_rp <- backtest_allocation(rp,
                                 ETFs$Prices,
                                 ETFs$Returns,
                                 ETFs$risk_free)

## ----risk parity perf---------------------------------------------------------
charts.PerformanceSummary(bt_rp$returns)
bt_rp$table_performance

## ----risk parity compare, message=FALSE, warning=FALSE------------------------
rpar <- get_data_from_tickers("RPAR")
rp_compare <- merge.xts(bt_rp$returns, rpar$R, join = "right")
rp_compare <- na.omit(rp_compare)
cor(rp_compare)

## ----risk parity stats--------------------------------------------------------
table.AnnualizedReturns(rp_compare)

## ----risk parity rescale------------------------------------------------------
rp_rescale_factor <- table.AnnualizedReturns(rp_compare)[2,2]/table.AnnualizedReturns(rp_compare)[2,1]

rp_compare[, 1] <- rp_compare[, 1] * rp_rescale_factor

charts.PerformanceSummary(rp_compare)


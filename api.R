.libPaths(c("/usr/local/lib/R/site-library", .libPaths()))

library(plumber)
library(seasonal)

#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  plumber::forward()
}

#* Health check
#* @get /health
function() {
  list(status = "ok", message = "Seasonal adjustment API is running")
}

#* Seasonally adjust a monthly time series using X-13ARIMA-SEATS
#* @post /seasonally_adjust
#* @serializer json
function(req) {
  body <- tryCatch(
    jsonlite::fromJSON(req$postBody),
    error = function(e) NULL
  )

  if (is.null(body)) {
    return(list(status = "error", message = "Invalid JSON in request body"))
  }

  values      <- body$values
  start_year  <- body$start_year
  start_month <- body$start_month

  if (is.null(values) || is.null(start_year) || is.null(start_month)) {
    return(list(status = "error", message = "Missing required fields: values, start_year, start_month"))
  }

  if (length(values) < 36) {
    return(list(status = "error", message = "At least 3 years (36 months) of data required for seasonal adjustment"))
  }

  ts_data <- ts(as.numeric(values), start = c(start_year, start_month), frequency = 12)

  result <- tryCatch({
    fit    <- seas(ts_data)
    sa     <- as.numeric(final(fit))
    tr     <- as.numeric(trend(fit))
    list(
      status              = "ok",
      seasonally_adjusted = sa,
      trend               = tr,
      start_year          = start_year,
      start_month         = start_month,
      n                   = length(sa)
    )
  }, error = function(e) {
    list(status = "error", message = conditionMessage(e))
  })

  result
}

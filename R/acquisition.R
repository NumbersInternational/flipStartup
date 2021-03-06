#' \code{Acquisition}
#'
#' @description Computes acquisition, by cohort.
#' @param data A \code{data.frame} that has the same variables as a \code{RevenueData} object.
#' @param remove.last Remove the final period (as usually is incomplete).
#' @param volume Weights the results by volume.
#' @param number.periods The number of periods of data that are treated as being 'acquisitions'. By default, this is 1, 
#' which means that only sales in the initial period are counted as acquisitions. If set to 12, for example, it would
#' means that the first 12 periods are treated as acquisitions (e.g., the first year, if the data has been setup as monthly).
#' @details Where subscribers suspends their purchasing for a period, but purchases again later, the subscriber
#' is asusmed to have been retained during the period where the account was suspended.
#' @return A \code{\link{list}} containing the following elements:
#'   \item{id}{The \code{id} values of subscribers to churn.}
#'   \item{base}{The number of subscribers to renew or churn in the time period.}
#'   \item{counts}{Number of acquisitions by period (or in $ if \code{volume} is \code{TRUE}}.
#'   \item{rates}{The percentage to churn (weighted if the counts are weighted)}.
#'
#' @importFrom flipStatistics Table
#' @export
Acquisition <- function(data, remove.last = TRUE, volume = FALSE, number.periods = 1)
{
    subscription.length <- attr(data, "subscription.length")
    if (remove.last)
        data <- removeLast(data)
    data <- data[data$observation <= number.periods, ]
    idag <- aggregate(id ~ subscriber.from.period, data = data, FUN = unique)
    id <- idag[, 2]
    names(id) <- idag[, 1]
    counts <- if (volume)
        Table(value ~ subscriber.from.period, data = data, FUN = sum)
    else
        Table( ~ subscriber.from.period, data = data)
    result <-list(volume = volume, id = id, counts = counts, subscription.length = subscription.length)
    class(result) <- c("Acquisition", class(result))
    result
}

#' @importFrom flipStandardCharts Chart
#' @export
plot.Acquisition <- function(x, ...)
{
    rates <- x$counts
    period.names <- names(rates)
    title <- if(x$volume) "Acquisition (% volume)" else "Acquisition (subscribers)"
    p <- Chart(rates,  x.tick.angle=0,
         y.title = title, fit.type = "Smooth", fit.ignore.last = TRUE,
         fit.line.type = "solid", fit.line.width = 2, fit.line.colors="Custom color", 
         fit.line.colors.custom.color="#ED7D31")
    print(p)
}


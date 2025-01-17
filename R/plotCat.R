#' Plot Categories
#'
#' Plot a summary of stock status categories by year: underfished (green), fully
#' fished (yellow), or overfished (red).
#'
#' @param dat data frame of stock time series, containing columns named
#'        \code{bbmsy} and \code{ffmsy}, as well as method-specific
#'        \code{bbmsy.*} and \code{ffmsy.*}.
#' @param method string indicating which method was used to estimate B/Bmsy and
#'        F/Fmsy.
#' @param cats either \code{3} or \code{4}, indicating whether to plot the stock
#'        status based on biomass only (3 categories) or based on biomass and
#'        fishing mortality (4 categories).
#' @param type string indicating the type of plot, either \code{"count"} or
#'        \code{"stock"}.
#'
#' @details
#' The first two columns in \code{dat} are treated as \code{'stock'} and
#' \code{'year'}, regardless of the actual column names.
#'
#' The last column names in \code{dat} should contain the \code{method} name as
#' a suffix. For example, if \code{method = "effEdepP"}, then this function will
#' look for columns called \code{bbmsy.effEdepP} and \code{ffmsy.effEdepP}.
#'
#' The \code{type} argument supports legacy synonyms, where \code{"prop"} is the
#' same as \code{"count"}, and \code{"all"} is the same as \code{"stock"}.
#'
#' @return A \code{ggplot} object.
#'
#' @author Rishi Sharma and Arni Magnusson.
#'
#' @seealso
#' \code{\link{ggplot}} is the underlying function used to produce the plot.
#'
#' \code{\link{calcCat}} calculates stock status categories.
#'
#' \code{\link{SOFIA-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' plotCat(stock.timeseries, method="effEdepP", cats=3, type="count")
#' plotCat(stock.timeseries, method="effEdepP", cats=3, type="stock")
#' }
#'
#' @aliases plotProp
#'
#' @importFrom ggplot2 aes_string geom_bar geom_raster ggplot theme_minimal
#'                     scale_fill_manual
#'
#' @export

plotCat <- function(dat, method="cmsy.naive", cats=4, type="count")
{
  names(dat)[1:2] <- c("stock", "year")  # convert Stock->stock, yr->year

  txt3 <- c("b>1.2", "0.8<b<1.2", "b<0.8")
  txt4 <- c("b>1,f<1", "b>1,f>1", "b<1,f<1", "b<1,f>1")

  ## Create a new data frame with the categories
  tDat <- calcCat(dat, method=method)
  tDat <- tDat[, c("stock", "year", "estCat3", "estCat4")]

  if(cats == 3)
  {
    tDat$estCat <- factor(txt3[tDat$estCat3], levels=txt3)
    cols <- c("darkgreen", "yellow", "red")
  }
  else
  {
    tDat$estCat <- factor(txt4[tDat$estCat4], levels=txt4)
    cols <- c("darkgreen", "orange", "yellow", "red")
  }

  ## Plot
  ## (use aes_string to avoid R CMD check notes)
  if(type == "count" || type == "prop")
  {
    ggplot(data=tDat, aes_string(x="year", color="estCat")) +
      geom_bar(aes_string(fill="estCat"), width=0.5) +
      theme_minimal() +
      scale_fill_manual(values=cols)
  }
  else if(type == "stock" || type == "all")
  {
    ggplot(tDat, aes_string(x="year", y="stock", fill="estCat")) +
      geom_raster() +
      theme_minimal() +
      scale_fill_manual(values=cols)
  }
}

#' @export

## plotProp() was an older name for plotCat() that was used in earlier SOFIA
## scripts, so we provide historical support.

plotProp <- function(...)
{
  ## .Deprecated("plotCat")
  plotCat(...)
}

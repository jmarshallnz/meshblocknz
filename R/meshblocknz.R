#' Urban/Rural concordance data for meshblocks in NZ from 2006
#'
#' A dataset containing the meshblock 2006 identifier and urban/rural status
#' for all meshblocks in New Zealand.
#'
#' @format A data frame with 41392 rows and 4 variables:
#' \describe{
#'   \item{Meshblock06}{Meshblock identifier}
#'   \item{UR_cat}{Urban/Rural categorisation of the meshblock with 7 levels}
#'   \item{UR_num}{Numeric scale of urban/rural status from -3 (most rural) to 3 (most urban)}
#'   \item{UR_bool}{Urban/Rural categorisation with 2 levels ("Rural" and "Urban")}
#' }
#' @source \url{http://www.stats.govt.nz/Census/2006CensusHomePage/MeshblockDataset.aspx}
"mb_2006_ur"
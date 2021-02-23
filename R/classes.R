#' is_ONDRI_df
#'
#' Tests if the \code{x} object is of class type "ONDRI_df"
#'
#' @param x object to test
#' @return boolean. \code{TRUE} if the object is of class "ONDRI_df", \code{FALSE} otherwise.
#'
#' @seealso \code{\link{inherits}}
#'
#' @export
is_ONDRI_df <- function(x){
  inherits(x, "ONDRI_df")
}

#' is_ONDRI_df_missing
#'
#' Tests if the \code{x} object is of class type "ONDRI_df_missing"
#'
#' @description Not in use yet.
#'
#' @param x object to test
#' @return boolean. \code{TRUE} if the object is of class "ONDRI_df_missing", \code{FALSE} otherwise.
#'
#' @seealso \code{\link{inherits}}
#'
#' @export
is_ONDRI_df_missing <- function(x){
  inherits(x, "ONDRI_df_missing")
}

## TO DO
# print.ONDRI_df_missing <- function(x, ...) {
#
# }


#' @export
print.ONDRI_df <- function(x, ..., nrows_to_show = 6) {

  if(!is_ONDRI_df(x)){
    stop("print.ONDRI_df: Not a recognized class")
  }

  nr <- nrow(x)
  if(nrows_to_show > nr){
    nrows_to_show <- nr
  }


  header_df <- data.frame(
    names(x),
    get_ondridf_column_data_types(x),
    unlist(lapply(lapply(x, class),function(x) x[2])),
    rep("",length(names(x)))
  )

  x_to_show <- as.matrix(x)
  if( (nrows_to_show < 24 & nrows_to_show > 4) & !is.na(nrows_to_show) ){

    head_locs <- seq(1,ceiling(nrows_to_show/2), 1)
    tail_locs <- seq((nr - floor(nrows_to_show/2))+1, nr, 1)
    x_to_show <-rbind(
      x_to_show[head_locs,,drop=F],
      rep("...",ncol(x_to_show)),
      x_to_show[tail_locs,,drop=F]
    )

    y <- as.data.frame(rbind(t(header_df), x_to_show))
    rownames(y) <- c('Variable names: ', 'ONDRI data types: ', 'R class: ', ' ', head_locs, "...", tail_locs)
    total_rows <- nrow(x_to_show)-1
  }else{

    y <- as.data.frame(rbind(t(header_df), x_to_show))
    rownames(y) <- c('Variable names: ', 'ONDRI data types: ', 'R class: ', ' ', 1:nr)
    total_rows <- nrow(x_to_show)
  }
  names(y) <- NULL

  # CVD_style <- make_style(ondricolors::ondri_palettes$all_colors["CVD"])
  # FTD_style <- make_style(ondricolors::ondri_palettes$all_colors["FTD"])
  # ADMCI_style <- make_style(ondricolors::ondri_palettes$all_colors["ADMCI"])
  # PD_style <- make_style(ondricolors::ondri_palettes$all_colors["PD"])
  # ALS_style <- make_style(ondricolors::ondri_palettes$all_colors["ALS"])
  # dark_style <- make_style(ondricolors::ondri_palettes$all_colors["dark"])
  # light_style <- make_style(ondricolors::ondri_palettes$all_colors["light"])

  # ONDRI_df_text <- CVD_style("O") %+% FTD_style("N") %+% ADMCI_style("D") %+% PD_style("R") %+% ALS_style("I") %+% dark_style("_df")

  # a cat call here to intro the info
  cat("ONDRI_df", "has", nrow(x),"rows and", ncol(x),"columns.\n")
  # cat("\t", bold(green("Showing")), total_rows, bold(green("rows out of")), nrow(x))
  cat("\tShowing", total_rows, "rows out of", nrow(x))
  print(y, ...)

  if(sum(is.na(x)) > 0){
    cat("\n\nONDRI_df contains ", sum(is.na(x)), " missing values. Those missing values are:\n")
    print(find_missing(x)) ### this has its own class, so I can do some fancier printing with it
  }else{
    # cat("\n\n",bold(ONDRI_df_text), magenta(" contains no missing values. "),"\n")
    cat("\n\nONDRI_df contains no missing values. \n")
  }
  # a cat call on number of MISSING
  # another DF print of row, col, MISSING

}



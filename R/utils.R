# imports from other packages
#' @import haven
#' @importFrom purrr map
#' @import sticky
#' @import ondricolors
#' @importFrom utils read.csv read.table
#' @importFrom stats df
NULL


# other utils

#' @title equal_sets_setdiff
#'
#' @description checks equality of two vectors
#'
#' @param vector_one a vector
#' @param vector_two another vector
#' @noRd
equal_sets_setdiff <- function(vector_one, vector_two){

  setdiff_12 <- setdiff(vector_one, vector_two)
  setdiff_21 <- setdiff(vector_two, vector_one)

  identical(setdiff_12, character(0)) & identical(setdiff_21, character(0))

}



#' @title \code{tag_nas_with_ondri_missing_codes} tags \code{NA}s with an internal mapping
#'
#' @description Maps specific NA tags (via \code{haven}) to \code{NA}s found in the data. Meant for internal use
#'
#' @param column_from_ondri_data a column from the data with NAs
#' @param column_from_ondri_data_missing_codes a (matched) column (to the above) with the missing codes intact
#' @noRd
tag_nas_with_ondri_missing_codes <- function(column_from_ondri_data, column_from_ondri_data_missing_codes){


  na_from_data <- is.na(column_from_ondri_data)
  M_code_from_missing_data <- grepl(valid_missing_codes_grep_patterns(), column_from_ondri_data_missing_codes)

  ## exit if both are all false
    ## actually I can use > because I know that na_from_data >= M_code_from_missing_data

  primary_condition <- na_from_data >= M_code_from_missing_data
  find_mismatches <- na_from_data != M_code_from_missing_data

  if( all(primary_condition) ){

    column_from_ondri_data[which(M_code_from_missing_data)] <- haven::tagged_na(tagged_na_map()[column_from_ondri_data_missing_codes[which(M_code_from_missing_data)],"TAGS"])

    if(any(find_mismatches)){
      column_from_ondri_data[which(find_mismatches)] <- haven::tagged_na(tagged_na_map()["M_UNIDENTIFIED","TAGS"])
    }

  }else{
    stop("Mismatch of missingness between matched columns of 'ondri_data' and 'ondri_data_missing_codes'.")
  }

  column_from_ondri_data
}



### well let's steal some code!
# https://stackoverflow.com/questions/62712843/add-tag-label-attr-attribute-to-dataframe-columns-variables


# Subsetters

#' @export
#'
#' @title Get columns names by data type
#'
#' @description Get all the column names of a particular ONDRI data type
#'
#' @param ondridf the ONDRI_df data frame
#' @param data_type one of the allowable ONDRI data types (see \code{data_types()})
#'
get_ondridf_column_names_by_data_type <- function(ondridf, data_type){
  sapply(ondridf, function(x) attr(x, "data_type") == data_type)
}

#' @export
#'
#' @title Get subset ONDRI_df by data type
#'
#' @description Get the ONDRI_df of strictly the particular ONDRI data type
#'
#' @param ondridf the ONDRI_df data frame
#' @param data_type one of the allowable ONDRI data types (see \code{data_types()})
#'
get_ondridf_by_data_type <- function(ondridf, data_type){
  found_columns_by_type <- get_ondridf_column_names_by_data_type(ondridf, data_type)

  if(all(!found_columns_by_type)){
    stop("No data available of that type")
  }else{
    return(ondridf[,found_columns_by_type,drop=F])
  }
}


#' @export
#'
#' @title Get columns names by TEXT
#'
#' @description Get all the column names of type TEXT
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_TEXT <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "TEXT")
}

#' @export
#'
#' @title Get subset ONDRI_df by TEXT
#'
#' @description Get the ONDRI_df susbet of only type TEXT
#'
#' @param ondridf the ONDRI_df data frame
get_ondridf_by_TEXT <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "TEXT")
}



#' @export
#'
#' @title Get columns names by CATEGORICAL
#'
#' @description Get all the column names of type CATEGORICAL
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_CATEGORICAL <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "CATEGORICAL")
}

#' @export
#'
#' @title Get subset ONDRI_df by CATEGORICAL
#'
#' @description Get the ONDRI_df susbet of only type CATEGORICAL
#'
#' @param ondridf the ONDRI_df data frame
get_ondridf_by_CATEGORICAL <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "CATEGORICAL")
}






#' @export
#'
#' @title Get subset ONDRI_df by DATE
#'
#' @description Get the ONDRI_df susbet of only type DATE
#'
#' @param ondridf the ONDRI_df data frame
get_ondridf_by_DATE <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "DATE")
}

#' @export
#'
#' @title Get columns names by DATE
#'
#' @description Get all the column names of type DATE
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_DATE <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "DATE")
}

#' @export
#'
#' @title Get subset ONDRI_df by NUMERIC
#'
#' @description Get the ONDRI_df susbet of only type NUMERIC
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_by_NUMERIC <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "NUMERIC")
}

#' @export
#'
#' @title Get columns names by NUMERIC
#'
#' @description Get all the column names of type NUMERIC
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_NUMERIC <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "NUMERIC")
}

#' @export
#'
#' @title Get subset ONDRI_df by ORDINAL
#'
#' @description Get the ONDRI_df susbet of only type ORDINAL
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_by_ORDINAL <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "ORDINAL")
}

#' @export
#'
#' @title Get columns names by ORDINAL
#'
#' @description Get all the column names of type ORDINAL
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_ORDINAL <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "ORDINAL")
}


#' @export
#'
#' @title Get subset ONDRI_df by MIXED
#'
#' @description Get the ONDRI_df susbet of only type MIXED
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_by_MIXED <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "MIXED")
}

#' @export
#'
#' @title Get columns names by MIXED
#'
#' @description Get all the column names of type MIXED
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_MIXED <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "MIXED")
}

#' @export
#'
#' @title Get subset ONDRI_df by TIME
#'
#' @description Get the ONDRI_df susbet of only type TIME
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_by_TIME <- function(ondridf){
  get_ondridf_by_data_type(ondridf, "TIME")
}

#' @export
#'
#' @title Get columns names by TIME
#'
#' @description Get all the column names of type TIME
#'
#' @param ondridf the ONDRI_df data frame
#'
get_ondridf_column_names_by_TIME <- function(ondridf){
  get_ondridf_column_names_by_data_type(ondridf, "TIME")
}

#' @export
#'
#' @title Get ONDRI_df column types
#'
#' @description Gets the attributes of a ONDRI_df data.frame
#'
#' @param ondridf a ONDRI_df
get_ondridf_column_data_types <- function(ondridf){
  sapply(ondridf, attr, "data_type")
}

# Sets attributes to columns from a single vector
#' @title Set ONDRI_df column types
#'
#' @description Sets the attributes of a ONDRI_df data.frame. For internal use.
#'
#' @param ondridf a ONDRI_df
#' @param columns_data_type a vector of length \code{ncol(ondridf)} with an ONDRI data type for each element
#' @noRd
set_ondridf_columns_data_type <- function(ondridf, columns_data_type){

  if(!all(columns_data_type %in% data_types())){
    stop("set_ondridf_columns_data_type: unrecognized data type in 'columns_data_type'.")
  }

  as.data.frame(
    mapply(
      function(this_col, this_type) {
        attr(this_col, "data_type") <- this_type
        this_col
      },
      ondridf, columns_data_type, SIMPLIFY = FALSE),
    stringsAsFactors = F
  )
}


##
# convert_ondri_dates_to_iso_dates <- function(ondridf){
#
#   datedf <- ondridf[get_ondridf_column_names_by_DATE(ondridf)]
#   if(length(datedf)<1){
#     stop("convert_ondri_dates_to_iso_dates: No 'DATE' columns available.")
#   }
#
#   datedf <- as.data.frame(lapply(datedf, function(x){ as.Date(x, "%Y%B%d") }))
#   class(datedf) <-  c("ONDRI_df", "data.frame")
#   datedf
# }

#' @export
#'
#' @title A date converter
#'
#' @description Convert an ONDRI date column to standard via \code{as.Date}
#'
#' @param date_column a vector presumed to be of type DATE from an ONDRI_df
#'
convert_ondri_dates_to_iso_dates <- function(date_column){

  if(attr(date_column, "data_type") == "DATE"){

    return( as.Date(date_column, "%Y%B%d") )

  }else{
    stop("convert_ondri_dates_to_iso_dates: 'attributes$date_column' does not equal 'DATE'")
  }

}



### need a bunch of find missings here...
  ## maybe these are just subsets of the grand find_missing()
# find_CB <- function(){
#
# }
#
# find_ART <- function(){
#
# }


#' @export
#'
#' @title Find and map missing data from a ONDRI_df
#'
#' @description Given an ONDRI_df, this returns a data.frame (of class \code{ONDRI_df_missing}) that contains a mapping of missing values by row, column, subject (if available), and variable. Also includes the text M-code and the \code{haven} tagged NA for reference.
#' @param ondridf an ONDRI_df
find_missing <- function(ondridf){


  total_missings <- sum(is.na(ondridf))

  if(total_missings > 0){


    rcm <- function(ondri_df_column, index){
      rows <- which(is.na(ondri_df_column))
      if(length(rows) > 0){
        cols <- rep(index, length(rows))
        haven_na <- ondri_df_column[rows]
        missings <- tagged_na_map()$MISSING_CODE[match(haven::na_tag(ondri_df_column[rows]), tagged_na_map()$TAGS)]
        return(
          data.frame(ROWS = rows, COLUMNS = cols, HAVEN_NA = haven_na, M_CODES = missings,
                     stringsAsFactors = F)
        )
      }else{
        return(NULL)
      }

    }

    if(ncol(ondridf)>1){



      missing_table <- do.call("rbind",mapply(rcm, ondridf, seq_along(ondridf), SIMPLIFY = F))
      rownames(missing_table) <- NULL
      missing_table$VARIABLE_NAMES <- colnames(ondridf)[missing_table$COLUMNS]

      missing_table <- missing_table[c("ROWS","COLUMNS","VARIABLE_NAMES","M_CODES","HAVEN_NA")]
      if("SUBJECT" %in% colnames(ondridf)){
        missing_table$SUBJECT <- ondridf$SUBJECT[missing_table$ROWS]
        missing_table <- missing_table[c("ROWS","COLUMNS","SUBJECT","VARIABLE_NAMES","M_CODES","HAVEN_NA")]
      }
    }else if(ncol(ondridf)==1){

      rows <- which(is.na(ondridf))
      missing_table <- data.frame(
        ROWS = rows,
        # COLUMNS = rep(1, length(rows)),
        HAVEN_NA = ondridf[rows,1],
        M_CODES = tagged_na_map()$MISSING_CODE[match(haven::na_tag(ondridf[rows,1]), tagged_na_map()$TAGS)],
        VARIABLE_NAMES = rep(names(ondridf),length(rows)),
        stringsAsFactors = F)
      rownames(missing_table) <- NULL
      missing_table <- missing_table[c("ROWS","VARIABLE_NAMES","M_CODES","HAVEN_NA")]

    }else{
      stop("find_missing: a ONDRI_df with zero columns was provided.")
    }




  }else{
    ## make an empty one here.
    missing_table <- data.frame(
      ROWS = integer(),
      COLUMNS = integer(),
      VARIABLE_NAMES = character(),
      M_CODES = character(),
      stringsAsFactors = FALSE)
  }
  class(missing_table) <- c("ONDRI_df_missing", "data.frame")
  missing_table
}


#' ONDRIdf
#'
#' @description ONDRIdf is designed for one general purpose: to read in and (more) easily handle ONDRI data, which has multiple types of missing data and a paired dictionary file.
#' @details As of now, ONDRIdf provides one primary function: \code{ONDRI_df} and multiple helpers (see the index of the help for the package).
#' The helpers include, for example, ways to get the indices and types of missing data, and to get the names or subset an ONDRI_df based on ONDRI data types.
#'
#' @aliases ondridf ONDRIDF ONDRIdf
#'
#' @keywords internal
#'
"_PACKAGE"


#' @export
#'
#' @title ONDRI data frame
#'
#' @description Provide paths to the DATA and DICT file pair and a new ONDRI_df object is returned. It is of type data.frame with some additional features including specialized NAs and printing.
#'
#' @param DATA_file a character/string that is the path to an ONDRI DATA.csv file
#' @param DICTIONARY_file a character/string that is the path to an ONDRI DICT.csv file
#'

ONDRI_df <- function(DATA_file, DICTIONARY_file){



  MISSING_CODES <- missing_codes() #paste0("M_",c("CB","PI","VR","AE","DNA","TE","NP","ART","OTHER"))
  DATA_TYPES <- data_types() #c("TEXT","CATEGORICAL","DATE","NUMERIC","ORDINAL","MIXED","TIME")

  for_header <- toupper(read.csv(DATA_file, header = F, nrows=1, stringsAsFactors =  F))
  ## send everything toupper and check for duplicates
    ## exit if any duplicates
  if(anyDuplicated(for_header)){
    stop("Duplicated variables in header of DATA.")
  }

  DICTIONARY <- read.csv(DICTIONARY_file, header = T, stringsAsFactors = F)
  if(ncol(DICTIONARY) > 4){
    stop("Unrecognized DICTIONARY format")
  }

  colnames(DICTIONARY) <- toupper(colnames(DICTIONARY))

  if( !equal_sets_setdiff(colnames(DICTIONARY), c("COLUMN_LABEL","DESCRIPTION","TYPE","VALUES")) ){
    stop("Unrecognized DICTIONARY format")
  }

  ## now toupper DICT content
  DICTIONARY[,"TYPE"] <- toupper(DICTIONARY[,"TYPE"])
  if(!all(DICTIONARY[,"TYPE"] %in% DATA_TYPES)){
    stop("Unrecognized TYPE in DICTIONARY file")
  }

  if(nrow(DICTIONARY) != length(for_header)){
    stop("COLUMN_LABEL items not the same length as DATA header")
  }

  ## now toupper DICT content
  DICTIONARY[,"COLUMN_LABEL"] <- toupper(DICTIONARY[,"COLUMN_LABEL"])

  if( !equal_sets_setdiff(for_header, DICTIONARY[,"COLUMN_LABEL"]) ){
    stop("DATA header and DICTIONARY:COLUMN_LABEL do not contain the same items")
  }

  if( !all.equal(for_header, DICTIONARY[,"COLUMN_LABEL"]) ){
    warning("DATA header and DICTIONARY:COLUMN_LABEL items are not in the same order. Changing order of the DICTIONARY file.")
    DICTIONARY <- DICTIONARY[match(for_header, DICTIONARY[,"COLUMN_LABEL"]),]
  }


  ## find SUBJECT & VISIT in DATA
  ## grep for _SITE$ and _DATE$ in DATA
  DATA_SITES <- grep("\\_SITE$", for_header)
  if(identical(DATA_SITES,integer(0))){
    stop("No SITE variables found in DATA header")
  }
  DATA_DATES <- grep("\\_DATE$", for_header)
  if(identical(DATA_DATES,integer(0))){
    stop("No DATE variables found in DATA header")
  }

  SUBJECT_index <- which(for_header == "SUBJECT")
  if(length(SUBJECT_index)!=1){
    stop("Zero or many SUBJECT columns found. There can be only one.")
  }
  if(SUBJECT_index!=1){
    warning("SUBJECT is not the first column")
  }

  VISIT_index <- which(for_header == "VISIT")
  if(length(VISIT_index)!=1){
    stop("Zero or many VISIT columns found. There can be only one.")
  }
  if(VISIT_index!=2){
    warning("VISIT is not the second column")
  }


  ## find all DATE variables in the DICT
    # DATE_variables and DATA_DATES provide the upper bound of indices
  DATE_variables <- which(DICTIONARY[,"TYPE"]=="DATE")

  ## aggregate all these indices in a vector
  all_indices <- unique(c(SUBJECT_index, VISIT_index, DATA_SITES, DATA_DATES, DATE_variables))


  enforced_character_column_classes <- rep("character",length(all_indices))
  names(enforced_character_column_classes) <- as.character(for_header[all_indices])


  ## read here twice
    ### once to get the data with NAs
  ondri_data <- read.csv(DATA_file, na.strings = MISSING_CODES, colClasses = enforced_character_column_classes, stringsAsFactors =  F, header = T)
  if(any(is.na(ondri_data$SUBJECT))){
    stop("SUBJECT cannot be missing.")
  }
  colnames(ondri_data) <- toupper(colnames(ondri_data))

    ### once again just to retrieve the M_* codes (there has to be a better way for this...)
  ondri_data_missing_codes <- read.csv(DATA_file, colClasses = "character", stringsAsFactors =  F, header = T)



  tagged_ondri_data <- as.data.frame(purrr::map2(ondri_data, ondri_data_missing_codes, tag_nas_with_ondri_missing_codes),
                                     stringsAsFactors = F)
  if(all.equal(tagged_ondri_data, ondri_data)){

    ondri_data <- tagged_ondri_data
    rm(tagged_ondri_data)
    rm(ondri_data_missing_codes)

    TYPE_vector <- DICTIONARY[,"TYPE"]
    names(TYPE_vector) <- DICTIONARY[,"COLUMN_LABEL"]

    ondri_data <- sticky::sticky_all(set_ondridf_columns_data_type(ondri_data, TYPE_vector))

  }else{
    stop("ondridf: 'tagged_ondri_data' and 'ondri_data' not equal.")
  }

  ### can probably optimize this a bit, but will return to it once I have the mapping of tagged_na


  # ### this will end up as additional attributes (probably as comments)
  # if(keep_dictionary_description | keep_dictionary_values){
  #
  #   meta_information <- data.frame(matrix(ncol=ncol(ondri_data),nrow=0,
  #                                  dimnames=list(NULL,colnames(ondri_data))))
  #
  #   if(keep_dictionary_description){
  #     DESCRIPTION <- DICTIONARY[,"DESCRIPTION"]
  #     meta_information[1,] <- DESCRIPTION
  #     rownames(meta_information)[1] <- "DESCRIPTION"
  #   }
  #
  #   if(keep_dictionary_values){
  #     VALUES <- DICTIONARY[,"VALUES"]
  #     if(nrow(meta_information)==0){
  #       meta_information[1,] <- VALUES
  #       rownames(meta_information)[1] <- "VALUES"
  #     }else{
  #       meta_information[2,] <- VALUES
  #       rownames(meta_information)[2] <- "VALUES"
  #     }
  #   }
  #
  # }

  class(ondri_data) <- c("ONDRI_df", "data.frame")
  ondri_data
}



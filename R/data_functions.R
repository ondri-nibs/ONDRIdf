
#' @title data types map
#'
#' @description a function that produces a vector of the valid ONDRI data types
#' @noRd
data_types <- function(){
  c("TEXT","CATEGORICAL","DATE","NUMERIC","ORDINAL","MIXED","TIME")
}

#' @title missing codes
#'
#' @description a function that produces a vector of the valid ONDRI missing codes
#' @noRd
missing_codes <- function(){
  x <- paste0("M_",c("CB","PI","VR","AE","DNA","TE","NP","ART","OTHER"))
  names(x) <- x
  x
}

#' @title grep-able missing codes
#'
#' @description a function that produces a vector of the valid ONDRI missing codes in a grep-able format
#' @noRd
valid_missing_codes_grep_patterns <- function(){
  paste(paste0("^",missing_codes(),"$"), collapse = "|")
}

#' @export
#' @title Mapping of MISSING codes to \code{haven} tags and descriptors
#'
#' @description a function that produces a data.frame that is the set of ONDRI missing codes with all needed information
tagged_na_map <- function(){

  data.frame(
    MISSING_CODE = c(
      "M_CB",
      "M_PI",
      "M_VR",
      "M_AE",
      "M_DNA",
      "M_TE",
      "M_NP",
      "M_ART",
      "M_TBC",
      "M_OTHER",
      "M_UNIDENTIFIED"),

    MEANING = c(
      "Cognitive/behavioural impairment",
      "Physical impairment",
      "Verbal refusal",
      "Administrative/administration error",
      "Did not apply",
      "Technical/equipment error",
      "Not part of protocol",
      "Artifacts",
      "To be completed",
      "Other",
      "Unidentified type of missing (NA)"),

    DESCRIPTION = c(
      "The participant could not participate in the assessment or task because of cognitive impairment (it is assumed as a result of the disease).",
      "The participant could not participate in the assessment or task because of a physical impairment that prevented the participant from completing that task. ",
      "The participant chose not to participate in the assessment or task.",
      "The administrator of the assessment or task made a mistake that caused the participant's score to be invalid or otherwise unobtainable.",
      "The task or assessment was not performed, or a value could not be derived because it did not apply to the participant.",
      "The instruments or tools (hardware or software) used for data acquisition, collection, or processing failed.",
      "Data did not exist for a participant because the assessment or task was not part of protocol.",
      "Data are not usable due to artifacts.",
      "Data are currently unavailable but will eventually be added. The only circumstance under which this should occur is when a release is required but data have not yet been processed, curated, or subjected to outlier analyses.",
      "When missing data are not covered by previous categories *and* when none of the existing missing codes apply.",
      "A 'NA' was present in the data and is not a recognized missing code."),

    TAGS = c(
      M_CB = "a",
      M_PI = "b",
      M_VR = "c",
      M_AE = "d",
      M_DNA = "e",
      M_TE = "f",
      M_NP = "g",
      M_ART = "h",
      M_TBC = "i",
      M_OTHER = "j",
      M_UNIDENTIFIED = "Z"
    ),

    TAGGED_NAs = c(
      haven::tagged_na("a"),
      haven::tagged_na("b"),
      haven::tagged_na("c"),
      haven::tagged_na("d"),
      haven::tagged_na("e"),
      haven::tagged_na("f"),
      haven::tagged_na("g"),
      haven::tagged_na("h"),
      haven::tagged_na("i"),
      haven::tagged_na("j"),
      haven::tagged_na("Z")),
    stringsAsFactors = F
  )

}

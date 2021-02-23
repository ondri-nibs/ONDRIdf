ONDRIdf: A package made just for ONDRI’s data (and dictionary) files
================

# ONDRIdf <img src='etc/ONDRIdf.png' align="right" height="139" />

Before installing, you’ll need a few other packages:

``` r
devtools::install_github(repo = "ondri-nibs/ondricolors")
install.packages('sticky')
install.packages('haven')
install.packages('purrr')
```

Get the package from this ONDRI-NIBS github repository

``` r
devtools::install_github(repo = "ondri-nibs/ONDRIdf")
# or
# remotes::install_github(repo = "ondri-nibs/ONDRIdf")
```

# An introduction to ONDRI data

ONDRI’s data adhere to standards that we developed in order to harmonize
across *very* diverse data types, data sets, and various backgrounds and
expertise. The core of the data standards are that data sets require:

-   A ‘DATA’ file with participants along the rows and variables along
    the columns. More details below.

-   A ‘DICT’ (dictionary) file with variables down the rows (so
    transposed from its respective DATA file), and four columns to
    describe each variable: COLUMN\_LABEL, DESCRIPTION, TYPE, and
    VALUES.

-   Some additional files to help supplement the package, such as
    describing any participants that are *entirely* missing (a ‘MISSING’
    file), details on how the data were collected, curated, and prepared
    for release (a ‘METHODS’ file). See the ONDRI compendium for details

For ONDRI data, there are two specific standards that are conceptually
important (even critical), but can be inconvenient to handle when
reading the data. These are:

-   ONDRI defined data *TYPES*, which generally conform to established
    typologies, and quickly convey information about how the data could
    or should be analyzed. The types include: TEXT, CATEGORICAL,
    NUMERIC, ORDINAL, DATE, TIME, and MIXED. See the ONDRI compendium
    for details on the definitions of each. However, it is important for
    many analyses that we are able to track these data types (as defined
    by ONDRI curators). Often, when reading in data to your preferred
    environment, these data types are converted to whatever the
    environment decides (e.g., in `R` TEXT or CATEGORICAL are often read
    as `character` or `factor`).

-   ONDRI also specifies 10 types of MISSING data that are standard
    across the project. For the complete list see either the ONDRI
    compendium or a function in this package:
    `ONDRIdf::tagged_na_map()`. These codes for missing data are
    crucial: data are missing for very different reasons. For
    examples: (1) sometimes data cannot be obtained because impairment
    is so severe that certain tasks cannot be completed (“M\_CB” which
    stands for “Missing: Cognitive/Behavioral”), and (2) sometimes data
    were not correctly or accurately collected which could have been due
    to administration error (“M\_AE” which stands for “Missing:
    Administration error”) or because of technical issues with equipment
    (“M\_TE” which stands for “Missing: Technical error”). With
    different types of missing data, we want to be able to handle them
    in different ways. These types of missing will inform us on
    imputation strategies, whether or not to include or exclude certain
    participants, cohorts, or variables from analyses, and even provide
    for us key information on how and why data are “missing” throughout
    the entirety of the project.

# Ain’t so easy though

Many environments—including and especially `R`—were not designed to read
in and naturally handle data with some of these particularities. `R` has
one type of missing called `NA` and has its own definitions of data
types (which correspond to types in other environments and languages)
including `numeric` (which itself includes `integer` and `double`).

So how can we keep track of 10 kinds of missing data, and keep track of
more general terms for data types? We could (and at this time probably
are) reading in multiple files, and maybe creating additional
`data.frames` or `lists` to help us track all of this information. The
**major** drawback there is that any update to the core DATA
`data.frame` will not automatically update any additional information
(such as missingess, data types, and so on). Fortunately, with some help
from other `R` packages, the `ONDRIdf` package will do all this for us.

# `ONDRIdf` makes it easy(ier?)

The `ONDRIdf` package generally has one goal: preserve the specifities
of ONDRI’s standards and handle them in `R`’s `data.frame` (the most
common data structure for data manipulation and analyses in `R`).

The `ONDRIdf` package has a primary function called `ONDRI_df()` which
reads in a ‘DATA’ and ‘DICT’ pair. From there, `ONDRI_df()` creates a
special subclass of a `data.frame` called `ONDRI_df`. This helps us
track features that are (somewhat) hidden in the `data.frame`. The
important features are that: (1) tag each column with it’s ONDRI data
type and (2) uniquely identifies different types of `NA`. Both of these
features are (somewhat) hidden with the help of the `haven` and `sticky`
packages. The ONDRI types are tracked for you so you can always refer
back to them within the `ONDRI_df` `data.frame`. More importantly, the
types of `NA`s are not obvious in the `data.frame`, and even behave
(almost) exactly like regular `NA`s. Instead, they become obvious
through the `print` method or specifically asking for missing data via
`ONDRIdf::find_missing()`.

# An example

Let’s see `ONDRIdf` in action. We’re going to read the `toy_data`
directly from the ONDRI-NIBS Github page. Feel free to explore those
data on your own, and see how we use data types and missing codes (find
all the “M\_” characters in the data).

``` r
DATA_FILE <- "https://raw.githubusercontent.com/ondri-nibs/toy_data/master/OND01_ALL_01_NIBS_SYNTHDATA_TABULAR_2020JUL26_DATAPKG/OND01_ALL_01_NIBS_SYNTHDATA_TABULAR_2020JUL26_DATA.csv"

DICTIONARY_FILE <- "https://raw.githubusercontent.com/ondri-nibs/toy_data/master/OND01_ALL_01_NIBS_SYNTHDATA_TABULAR_2020JUL26_DATAPKG/OND01_ALL_01_NIBS_SYNTHDATA_TABULAR_2020JUL26_DICT.csv"
```

And now we’ll call the one function we need to maintain all the key
information about data columns and magically handle the missingness.

``` r
library(ONDRIdf)
my_ondri_df <- ONDRI_df(DATA_FILE, DICTIONARY_FILE)
```

Let’s see how this `print`s

``` r
my_ondri_df
```

    ## ONDRI_df has 147 rows and 17 columns.
    ##  Showing 6 rows out of 147                                                                 
    ## Variable names:           SUBJECT       VISIT NIBS_SYNTHDATA_SITE
    ## ONDRI data types:            TEXT CATEGORICAL         CATEGORICAL
    ## R class:                character   character           character
    ##                                                                  
    ## 1                  OND01_SYN_0001          01                 SYN
    ## 2                  OND01_SYN_0002          01                 SYN
    ## 3                  OND01_SYN_0003          01                 SYN
    ## ...                           ...         ...                 ...
    ## 145                OND01_SYN_0145          01                 SYN
    ## 146                OND01_SYN_0146          01                 SYN
    ## 147                OND01_SYN_0147          01                 SYN
    ##                                                                   
    ## Variable names:    NIBS_SYNTHDATA_DATE     AGE         SEX   NIHSS
    ## ONDRI data types:                 DATE NUMERIC CATEGORICAL NUMERIC
    ## R class:                     character numeric   character numeric
    ##                                                                   
    ## 1                            2020MAY30   64.41        male       0
    ## 2                            2020MAY30   59.64        male       0
    ## 3                            2020MAY30   84.54        male       1
    ## ...                                ...     ...         ...     ...
    ## 145                          2020MAY30   58.80        male       0
    ## 146                          2020MAY30   71.44        male       0
    ## 147                          2020MAY30   75.89        male       0
    ##                                                                    
    ## Variable names:    APOE_GENOTYPE MAPT_DIPLOTYPE TMT_A_SEC TMT_B_SEC
    ## ONDRI data types:    CATEGORICAL    CATEGORICAL   NUMERIC   NUMERIC
    ## R class:               character      character   numeric   numeric
    ##                                                                    
    ## 1                            E44           H2H2      39.2      96.2
    ## 2                            E33           H1H1      29.9      <NA>
    ## 3                            E33           H1H1      72.0     124.7
    ## ...                          ...            ...       ...       ...
    ## 145                          E33           H1H1      44.2      83.1
    ## 146                          E32           H1H1      46.5     186.3
    ## 147                          E32           H1H2      51.6     207.8
    ##                                                                       
    ## Variable names:    STROOP_COLOR_SEC STROOP_WORD_SEC STROOP_INHIBIT_SEC
    ## ONDRI data types:           NUMERIC         NUMERIC            NUMERIC
    ## R class:                    numeric         numeric            numeric
    ##                                                                       
    ## 1                              38.4            32.8               50.6
    ## 2                              36.0            23.5               75.7
    ## 3                              29.6            33.0               51.2
    ## ...                             ...             ...                ...
    ## 145                            29.7            28.6               52.8
    ## 146                            38.4            33.1               84.9
    ## 147                            40.4            28.8               75.2
    ##                                                               
    ## Variable names:    STROOP_SWITCH_SEC NAGM_PERCENT NAWM_PERCENT
    ## ONDRI data types:            NUMERIC      NUMERIC      NUMERIC
    ## R class:                     numeric      numeric      numeric
    ##                                                               
    ## 1                               71.1         43.0         32.9
    ## 2                               60.1         43.6         34.0
    ## 3                               64.5         41.9         31.0
    ## ...                              ...          ...          ...
    ## 145                            136.3         42.6         35.3
    ## 146                             72.4         42.0         30.4
    ## 147                             73.3         <NA>         <NA>
    ## 
    ## 
    ## ONDRI_df contains  10  missing values. Those missing values are:
    ##    ROWS COLUMNS        SUBJECT    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1    70      10 OND01_SYN_0070         TMT_A_SEC    M_AE       NA
    ## 2    97      10 OND01_SYN_0097         TMT_A_SEC    M_AE       NA
    ## 3     2      11 OND01_SYN_0002         TMT_B_SEC    M_TE       NA
    ## 4    66      15 OND01_SYN_0066 STROOP_SWITCH_SEC    M_CB       NA
    ## 5    91      15 OND01_SYN_0091 STROOP_SWITCH_SEC    M_CB       NA
    ## 6   114      15 OND01_SYN_0114 STROOP_SWITCH_SEC    M_CB       NA
    ## 7   133      15 OND01_SYN_0133 STROOP_SWITCH_SEC    M_CB       NA
    ## 8   140      15 OND01_SYN_0140 STROOP_SWITCH_SEC    M_CB       NA
    ## 9   147      16 OND01_SYN_0147      NAGM_PERCENT   M_ART       NA
    ## 10  147      17 OND01_SYN_0147      NAWM_PERCENT   M_ART       NA

You can see that there are some major differences from, say, if we were
to just simply cast the data back to a standard data.frame with
`as.data.frame(my_ondri_df)`. Here, we are showing a snapshot of the
first few rows and the last few rows (this can be customized!). More
importantly, we provide additional information. First you can see some
introductory text telling us about the size & shape of the data. Next
you can see that there are three new column headers. These tell us the
variable name, ONDRI’s data type, and how `R` treats the data (`R`s
primitive types). Note that you can see the standard `<NA>` displayed in
the data table. However, if you look to the bottom of the printed
output, we see a new and smaller table with some introductory text. This
bottom table tells us where we have missing data and which *types* they
are. These behaviors are preserved just as they would be for
data.frames, e.g.,

``` r
my_ondri_df[,c(1,15:17)]
```

    ## ONDRI_df has 147 rows and 4 columns.
    ##  Showing 6 rows out of 147                                                                             
    ## Variable names:           SUBJECT STROOP_SWITCH_SEC NAGM_PERCENT NAWM_PERCENT
    ## ONDRI data types:            TEXT           NUMERIC      NUMERIC      NUMERIC
    ## R class:                character           numeric      numeric      numeric
    ##                                                                              
    ## 1                  OND01_SYN_0001              71.1         43.0         32.9
    ## 2                  OND01_SYN_0002              60.1         43.6         34.0
    ## 3                  OND01_SYN_0003              64.5         41.9         31.0
    ## ...                           ...               ...          ...          ...
    ## 145                OND01_SYN_0145             136.3         42.6         35.3
    ## 146                OND01_SYN_0146              72.4         42.0         30.4
    ## 147                OND01_SYN_0147              73.3         <NA>         <NA>
    ## 
    ## 
    ## ONDRI_df contains  7  missing values. Those missing values are:
    ##   ROWS COLUMNS        SUBJECT    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1   66       2 OND01_SYN_0066 STROOP_SWITCH_SEC    M_CB       NA
    ## 2   91       2 OND01_SYN_0091 STROOP_SWITCH_SEC    M_CB       NA
    ## 3  114       2 OND01_SYN_0114 STROOP_SWITCH_SEC    M_CB       NA
    ## 4  133       2 OND01_SYN_0133 STROOP_SWITCH_SEC    M_CB       NA
    ## 5  140       2 OND01_SYN_0140 STROOP_SWITCH_SEC    M_CB       NA
    ## 6  147       3 OND01_SYN_0147      NAGM_PERCENT   M_ART       NA
    ## 7  147       4 OND01_SYN_0147      NAWM_PERCENT   M_ART       NA

Note how we’re now only showing a subset of variables, and that the
missingness subtable reflects what we’ve chosen to focus on rather than
the full table.

A feature that is disappointingly missing in this markdown file is that
some of the information is color coded when printed to the terminal
(this is still an “aesthetic in progress”).

# What else you got?

There are some helper functions in this package however they may change,
be replaced, or disappear entirely at any time. These should be regarded
as convenience functions that are, effectively, shortcuts for things
you’d do on your own. If they ever cause problems or can be done simpler
in other ways, they are likely to disappear in order to preserve the
core functionality of `ONDRIdf` (which is pretty much one thing: keep
all the important parts in one place).

Here are some examples of these helpers.

## DATES

In ONDRI, we specifically use the ‘%Y%b%d’ date format which produces,
e.g., 2021FEB23. We do this because it creates a contract between ONDRI
data curators and ONDRI data consumers. From the curation perspective we
are definitively providing a date with no ambiguity. As a data consumer,
you might prefer a more ambiguous albeit standard format. In the ONDRI
data, dates look like

``` r
my_ondri_df$NIBS_SYNTHDATA_DATE
```

    ##   [1] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##   [7] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [13] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [19] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [25] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [31] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [37] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [43] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [49] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [55] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [61] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [67] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [73] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [79] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [85] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [91] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ##  [97] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [103] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [109] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [115] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [121] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [127] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [133] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [139] "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30" "2020MAY30"
    ## [145] "2020MAY30" "2020MAY30" "2020MAY30"
    ## attr(,"data_type")
    ## [1] "DATE"
    ## attr(,"class")
    ## [1] "sticky"    "character"

But with a helper, we can get the more standard format:

``` r
convert_ondri_dates_to_iso_dates(my_ondri_df$NIBS_SYNTHDATA_DATE)
```

    ##   [1] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##   [6] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [11] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [16] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [21] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [26] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [31] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [36] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [41] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [46] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [51] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [56] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [61] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [66] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [71] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [76] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [81] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [86] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [91] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ##  [96] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [101] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [106] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [111] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [116] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [121] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [126] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [131] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [136] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [141] "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30" "2020-05-30"
    ## [146] "2020-05-30" "2020-05-30"

## Subsets of data

Generally there are two ways that `ONDRIdf` helps you get specific data
types. The first is by retrieving the indices (and names) as `logical`s
via `get_ondridf_column_data_types`. We need two parameters: the
`ONDRIdf` and the text of the type. Let’s get all the ‘NUMERIC’

``` r
get_ondridf_column_names_by_data_type(my_ondri_df, "NUMERIC")
```

    ##             SUBJECT               VISIT NIBS_SYNTHDATA_SITE NIBS_SYNTHDATA_DATE 
    ##               FALSE               FALSE               FALSE               FALSE 
    ##                 AGE                 SEX               NIHSS       APOE_GENOTYPE 
    ##                TRUE               FALSE                TRUE               FALSE 
    ##      MAPT_DIPLOTYPE           TMT_A_SEC           TMT_B_SEC    STROOP_COLOR_SEC 
    ##               FALSE                TRUE                TRUE                TRUE 
    ##     STROOP_WORD_SEC  STROOP_INHIBIT_SEC   STROOP_SWITCH_SEC        NAGM_PERCENT 
    ##                TRUE                TRUE                TRUE                TRUE 
    ##        NAWM_PERCENT 
    ##                TRUE

Fortunately, I’ve created a (barely) lazier way to do that

``` r
get_ondridf_column_names_by_NUMERIC(my_ondri_df)
```

    ##             SUBJECT               VISIT NIBS_SYNTHDATA_SITE NIBS_SYNTHDATA_DATE 
    ##               FALSE               FALSE               FALSE               FALSE 
    ##                 AGE                 SEX               NIHSS       APOE_GENOTYPE 
    ##                TRUE               FALSE                TRUE               FALSE 
    ##      MAPT_DIPLOTYPE           TMT_A_SEC           TMT_B_SEC    STROOP_COLOR_SEC 
    ##               FALSE                TRUE                TRUE                TRUE 
    ##     STROOP_WORD_SEC  STROOP_INHIBIT_SEC   STROOP_SWITCH_SEC        NAGM_PERCENT 
    ##                TRUE                TRUE                TRUE                TRUE 
    ##        NAWM_PERCENT 
    ##                TRUE

An alternate to this is to retrieve the actual (sub) data.frame, as so:

``` r
get_ondridf_by_data_type(my_ondri_df, "NUMERIC")
```

    ## ONDRI_df has 147 rows and 10 columns.
    ##  Showing 6 rows out of 147                                                                       
    ## Variable names:        AGE   NIHSS TMT_A_SEC TMT_B_SEC STROOP_COLOR_SEC
    ## ONDRI data types:  NUMERIC NUMERIC   NUMERIC   NUMERIC          NUMERIC
    ## R class:           numeric numeric   numeric   numeric          numeric
    ##                                                                        
    ## 1                    64.41       0      39.2      96.2             38.4
    ## 2                    59.64       0      29.9      <NA>               36
    ## 3                    84.54       1        72     124.7             29.6
    ## ...                    ...     ...       ...       ...              ...
    ## 145                   58.8       0      44.2      83.1             29.7
    ## 146                  71.44       0      46.5     186.3             38.4
    ## 147                  75.89       0      51.6     207.8             40.4
    ##                                                                        
    ## Variable names:    STROOP_WORD_SEC STROOP_INHIBIT_SEC STROOP_SWITCH_SEC
    ## ONDRI data types:          NUMERIC            NUMERIC           NUMERIC
    ## R class:                   numeric            numeric           numeric
    ##                                                                        
    ## 1                             32.8               50.6              71.1
    ## 2                             23.5               75.7              60.1
    ## 3                               33               51.2              64.5
    ## ...                            ...                ...               ...
    ## 145                           28.6               52.8             136.3
    ## 146                           33.1               84.9              72.4
    ## 147                           28.8               75.2              73.3
    ##                                             
    ## Variable names:    NAGM_PERCENT NAWM_PERCENT
    ## ONDRI data types:       NUMERIC      NUMERIC
    ## R class:                numeric      numeric
    ##                                             
    ## 1                            43         32.9
    ## 2                          43.6           34
    ## 3                          41.9           31
    ## ...                         ...          ...
    ## 145                        42.6         35.3
    ## 146                          42         30.4
    ## 147                        <NA>         <NA>
    ## 
    ## 
    ## ONDRI_df contains  10  missing values. Those missing values are:
    ##    ROWS COLUMNS    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1    70       3         TMT_A_SEC    M_AE       NA
    ## 2    97       3         TMT_A_SEC    M_AE       NA
    ## 3     2       4         TMT_B_SEC    M_TE       NA
    ## 4    66       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 5    91       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 6   114       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 7   133       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 8   140       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 9   147       9      NAGM_PERCENT   M_ART       NA
    ## 10  147      10      NAWM_PERCENT   M_ART       NA

And another (barely) lazier way to do that

``` r
get_ondridf_by_NUMERIC(my_ondri_df)
```

    ## ONDRI_df has 147 rows and 10 columns.
    ##  Showing 6 rows out of 147                                                                       
    ## Variable names:        AGE   NIHSS TMT_A_SEC TMT_B_SEC STROOP_COLOR_SEC
    ## ONDRI data types:  NUMERIC NUMERIC   NUMERIC   NUMERIC          NUMERIC
    ## R class:           numeric numeric   numeric   numeric          numeric
    ##                                                                        
    ## 1                    64.41       0      39.2      96.2             38.4
    ## 2                    59.64       0      29.9      <NA>               36
    ## 3                    84.54       1        72     124.7             29.6
    ## ...                    ...     ...       ...       ...              ...
    ## 145                   58.8       0      44.2      83.1             29.7
    ## 146                  71.44       0      46.5     186.3             38.4
    ## 147                  75.89       0      51.6     207.8             40.4
    ##                                                                        
    ## Variable names:    STROOP_WORD_SEC STROOP_INHIBIT_SEC STROOP_SWITCH_SEC
    ## ONDRI data types:          NUMERIC            NUMERIC           NUMERIC
    ## R class:                   numeric            numeric           numeric
    ##                                                                        
    ## 1                             32.8               50.6              71.1
    ## 2                             23.5               75.7              60.1
    ## 3                               33               51.2              64.5
    ## ...                            ...                ...               ...
    ## 145                           28.6               52.8             136.3
    ## 146                           33.1               84.9              72.4
    ## 147                           28.8               75.2              73.3
    ##                                             
    ## Variable names:    NAGM_PERCENT NAWM_PERCENT
    ## ONDRI data types:       NUMERIC      NUMERIC
    ## R class:                numeric      numeric
    ##                                             
    ## 1                            43         32.9
    ## 2                          43.6           34
    ## 3                          41.9           31
    ## ...                         ...          ...
    ## 145                        42.6         35.3
    ## 146                          42         30.4
    ## 147                        <NA>         <NA>
    ## 
    ## 
    ## ONDRI_df contains  10  missing values. Those missing values are:
    ##    ROWS COLUMNS    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1    70       3         TMT_A_SEC    M_AE       NA
    ## 2    97       3         TMT_A_SEC    M_AE       NA
    ## 3     2       4         TMT_B_SEC    M_TE       NA
    ## 4    66       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 5    91       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 6   114       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 7   133       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 8   140       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 9   147       9      NAGM_PERCENT   M_ART       NA
    ## 10  147      10      NAWM_PERCENT   M_ART       NA

These above `get`ters exist for all the data types (if you’ve forgotten,
see `ONDRIdf:::data_types()`, which is a hidden function)

And if ever you need to know all the types across all the columns:

``` r
get_ondridf_column_data_types(my_ondri_df)
```

    ##             SUBJECT               VISIT NIBS_SYNTHDATA_SITE NIBS_SYNTHDATA_DATE 
    ##              "TEXT"       "CATEGORICAL"       "CATEGORICAL"              "DATE" 
    ##                 AGE                 SEX               NIHSS       APOE_GENOTYPE 
    ##           "NUMERIC"       "CATEGORICAL"           "NUMERIC"       "CATEGORICAL" 
    ##      MAPT_DIPLOTYPE           TMT_A_SEC           TMT_B_SEC    STROOP_COLOR_SEC 
    ##       "CATEGORICAL"           "NUMERIC"           "NUMERIC"           "NUMERIC" 
    ##     STROOP_WORD_SEC  STROOP_INHIBIT_SEC   STROOP_SWITCH_SEC        NAGM_PERCENT 
    ##           "NUMERIC"           "NUMERIC"           "NUMERIC"           "NUMERIC" 
    ##        NAWM_PERCENT 
    ##           "NUMERIC"

## Just the missing, please

Finally, a lot of the time we want to just focus on the missing data. So
there’s a function for that, too. And it simply retrieves a small
`data.frame` for you that contains the indices (rows, columns), names
(variables, and subjects if available), missing types ("M\_\*"), and
special types of `NA`s provided by `haven` (we’ll see how this works a
bit at the end).

To get the missing data for an `ONDRIdf`:

``` r
find_missing(my_ondri_df)
```

    ##    ROWS COLUMNS        SUBJECT    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1    70      10 OND01_SYN_0070         TMT_A_SEC    M_AE       NA
    ## 2    97      10 OND01_SYN_0097         TMT_A_SEC    M_AE       NA
    ## 3     2      11 OND01_SYN_0002         TMT_B_SEC    M_TE       NA
    ## 4    66      15 OND01_SYN_0066 STROOP_SWITCH_SEC    M_CB       NA
    ## 5    91      15 OND01_SYN_0091 STROOP_SWITCH_SEC    M_CB       NA
    ## 6   114      15 OND01_SYN_0114 STROOP_SWITCH_SEC    M_CB       NA
    ## 7   133      15 OND01_SYN_0133 STROOP_SWITCH_SEC    M_CB       NA
    ## 8   140      15 OND01_SYN_0140 STROOP_SWITCH_SEC    M_CB       NA
    ## 9   147      16 OND01_SYN_0147      NAGM_PERCENT   M_ART       NA
    ## 10  147      17 OND01_SYN_0147      NAWM_PERCENT   M_ART       NA

And we can do this for any arbitrary subset, such as:

``` r
find_missing(my_ondri_df[,c(1,15:17)])
```

    ##   ROWS COLUMNS        SUBJECT    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1   66       2 OND01_SYN_0066 STROOP_SWITCH_SEC    M_CB       NA
    ## 2   91       2 OND01_SYN_0091 STROOP_SWITCH_SEC    M_CB       NA
    ## 3  114       2 OND01_SYN_0114 STROOP_SWITCH_SEC    M_CB       NA
    ## 4  133       2 OND01_SYN_0133 STROOP_SWITCH_SEC    M_CB       NA
    ## 5  140       2 OND01_SYN_0140 STROOP_SWITCH_SEC    M_CB       NA
    ## 6  147       3 OND01_SYN_0147      NAGM_PERCENT   M_ART       NA
    ## 7  147       4 OND01_SYN_0147      NAWM_PERCENT   M_ART       NA

Or we can get more specific and less arbitrary:

``` r
find_missing(get_ondridf_by_NUMERIC(my_ondri_df))
```

    ##    ROWS COLUMNS    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1    70       3         TMT_A_SEC    M_AE       NA
    ## 2    97       3         TMT_A_SEC    M_AE       NA
    ## 3     2       4         TMT_B_SEC    M_TE       NA
    ## 4    66       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 5    91       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 6   114       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 7   133       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 8   140       8 STROOP_SWITCH_SEC    M_CB       NA
    ## 9   147       9      NAGM_PERCENT   M_ART       NA
    ## 10  147      10      NAWM_PERCENT   M_ART       NA

### The `NA`s

The `NA`s we see in the `HAVEN_NA` column all *look* the same, but they
aren’t! They are how we can map *types* of `NA`s in `R` to ONDRI’s
missing codes.

``` r
numeric_missing <- find_missing(get_ondridf_by_NUMERIC(my_ondri_df))

haven::na_tag(numeric_missing$HAVEN_NA)
```

    ##  [1] "d" "d" "f" "a" "a" "a" "a" "a" "h" "h"

We can see extra letters after the `NA`. These are actually stored in a
special byte hidden deep down in some `C` code we don’t want to know
more about. But we do have flexibility to add up to 26 (or possibly 52,
maybe more?) types of missing with the use of single characters. The
drawback is we have to handle the mapping ourselves. For that mapping,
see `tagged_na_map()`

# Some examples

The way in which missingness and types are tracked can help us set up
easier rules for data manipulation and especially imputation. Let’s
start with a relatively “straight forward” problem: numeric data and
imputation. Let’s get the data we need, first:

``` r
library(tidyverse)
```

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.0 --

    ## v ggplot2 3.3.3     v purrr   0.3.4
    ## v tibble  3.0.6     v dplyr   1.0.4
    ## v tidyr   1.1.2     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(magrittr)
```

    ## 
    ## Attaching package: 'magrittr'

    ## The following object is masked from 'package:purrr':
    ## 
    ##     set_names

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

``` r
which_numeric_columns <- which(get_ondridf_column_names_by_NUMERIC(my_ondri_df))

my_ondri_df %>%
  select(SUBJECT, which_numeric_columns) ->
  my_ondri_df_numeric_subset
```

    ## Note: Using an external vector in selections is ambiguous.
    ## i Use `all_of(which_numeric_columns)` instead of `which_numeric_columns` to silence this message.
    ## i See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This message is displayed once per session.

Now, let’s explore the missingness.

``` r
my_ondri_df_numeric_subset %>%
  find_missing()
```

    ##    ROWS COLUMNS        SUBJECT    VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1    70       4 OND01_SYN_0070         TMT_A_SEC    M_AE       NA
    ## 2    97       4 OND01_SYN_0097         TMT_A_SEC    M_AE       NA
    ## 3     2       5 OND01_SYN_0002         TMT_B_SEC    M_TE       NA
    ## 4    66       9 OND01_SYN_0066 STROOP_SWITCH_SEC    M_CB       NA
    ## 5    91       9 OND01_SYN_0091 STROOP_SWITCH_SEC    M_CB       NA
    ## 6   114       9 OND01_SYN_0114 STROOP_SWITCH_SEC    M_CB       NA
    ## 7   133       9 OND01_SYN_0133 STROOP_SWITCH_SEC    M_CB       NA
    ## 8   140       9 OND01_SYN_0140 STROOP_SWITCH_SEC    M_CB       NA
    ## 9   147      10 OND01_SYN_0147      NAGM_PERCENT   M_ART       NA
    ## 10  147      11 OND01_SYN_0147      NAWM_PERCENT   M_ART       NA

We can see three different missing codes: “M\_AE” which is
administrative error, “M\_CB” which is cognitive/behavioral, and
“M\_ART” which is due to artifacts (in this case in the neuroimaging
data). We usually consider “M\_CB” very different from most other
missing types, and in some cases impute these values to a maximum or
minimum (whichever is the worst for the instrument). Note that these max
or min values could be one of several options, such as a hypothetical
max or min, the upper or lower bound on the instrument, or we can use
the min or max from the sample. For now, let’s set up some code to
impute the “M\_CB” values to the worst performance for their measures,
and do so with the *observed sample*. Here we can see that all “M\_CB”
are in one of the timed tasks, so we want to impute to the maximum
observed value.

``` r
my_ondri_df_numeric_subset %>%
  find_missing() %>%
  filter(M_CODES == "M_CB") -> 
  current_cb_missing
```

Let’s now set up our values for replacement

``` r
my_ondri_df_numeric_subset %>%
    select(unique(current_cb_missing$VARIABLE_NAMES)) %>% purrr::map(., max, na.rm=T) -> column_wise_maxes

my_ondri_df_numeric_subset %>% 
  replace_na(as.list(column_wise_maxes)) ->
  my_ondri_df_numeric_subset_no_cb
```

And now we’re left with just the other missing types:

``` r
# either look at the whole thing
# my_ondri_df_numeric_subset_no_missing
# or just the missingness:
my_ondri_df_numeric_subset_no_cb %>%
  find_missing()
```

    ##   ROWS COLUMNS        SUBJECT VARIABLE_NAMES M_CODES HAVEN_NA
    ## 1   70       4 OND01_SYN_0070      TMT_A_SEC    M_AE       NA
    ## 2   97       4 OND01_SYN_0097      TMT_A_SEC    M_AE       NA
    ## 3    2       5 OND01_SYN_0002      TMT_B_SEC    M_TE       NA
    ## 4  147      10 OND01_SYN_0147   NAGM_PERCENT   M_ART       NA
    ## 5  147      11 OND01_SYN_0147   NAWM_PERCENT   M_ART       NA

Per usual, these are the kinds of missing where we usually feel
comfortable with `missMDA` doing the work for us. Note that by moving
over to `missMDA` we’re going to need to analyze and end up with a
`matrix`, not a `data.frame` and, more importantly, we do now lose all
of the nice features of `ONDRIdf`. However, given that our goal with
this step is to eliminate the remaining `NA`s, we’re OK with that.

``` r
my_ondri_df_numeric_subset_no_cb %>%
  select(-SUBJECT) %>%
  missMDA::imputePCA(.) %>%
  purrr::pluck("completeObs") ->
  my_ondri_df_no_missing


rownames(my_ondri_df_no_missing) <- my_ondri_df_numeric_subset_no_cb$SUBJECT
```

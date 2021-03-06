##########################################################################
# Functions to download mortality data from the Human Mortality Database #
##########################################################################

#############################################################################
# Functions to automate the download of mortality from the HMD, which
#  requires prior (free) registration at https://www.mortality.org/mp/auth.pl.
# These functions are hopefully helpful but provided as a courtesy only as
#  model calculation should work fine using other mortality data, provided that
#  these data are formatted as required.
#############################################################################

# Load packages -----------------------------------------------------------
library("RCurl")


#  Function to download mortality data ------------------------------------
table_gen <- function(str_Country_Code, str_Country, sex, parent_dir) {
  if (sex == "M") {
    url_name <- paste("http://www.mortality.org/hmd",
      str_Country_Code, "STATS/mltper_1x1.txt",
      sep = "/"
    )
  } else {
    url_name <- paste("http://www.mortality.org/hmd",
      str_Country_Code, "STATS/fltper_1x1.txt",
      sep = "/"
    )
  }

  # Generate an authentication file, replace 'your@email.com:password' with
  #  the email and password used to register your account at the HMD
  aut_data <- getURL(url_name, userpwd = "your@email.com:password")
  fdata <- "data/mortality/app_aut.txt"
  write(aut_data, file = "data/mortality/app_aut.txt")

  # Open connection
  con  <- file(fdata, open = "r")
  line <- readLines(con)
  long <- length(line)

  entries <- unlist(strsplit(line[3], " "))
  entry_names_id <- which(entries != "")
  entry_names <- entries[entry_names_id]

  # Initialize an empty data-frame
  aut_frame <- data.frame(t(rep(NA, length(entry_names_id))))
  names(aut_frame) <- entry_names
  aut_frame <- aut_frame[-1, ]

  for (i in 4:long) {
    entries <- unlist(strsplit(line[i], " "))
    ids <- which(entries != "")

    if (length(ids) > 0) {
      entry_values <- entries[ids]
      for (j in 1:length(ids)) {
        aut_frame[i - 3, entry_names[j]] <- entry_values[j]
      }
    }
  }

  # Close connection
  close(con)

  # Write dataframes for women and men
  if (sex == "M") {
    write.csv(aut_frame,
      file = paste(parent_dir, str_Country,
        "Male", "Mortality.csv",
        sep = "/"
      ),
      sep = ","
    )
  } else {
    write.csv(aut_frame,
      file = paste(parent_dir, str_Country,
        "Female", "Mortality.csv",
        sep = "/"
      ),
      sep = ","
    )
  }
}

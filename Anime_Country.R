

rm(list=ls())


library(httr)
library(jsonlite)

# API endpoint URL
url <- "https://restcountries.com/v3.1/name/japan"

# Send GET request to the API endpoint
response <- GET(url)

# Extract and parse the response content
response_content <- content(response, "text")
response_json <- jsonlite::fromJSON(response_content, simplifyDataFrame = TRUE)

# Extract the relevant columns into a new dataframe
country_df <- data.frame(
  Name = response_json$name$common,
  Capital = ifelse(length(response_json$capital) > 0, response_json$capital[[1]], NA),
  Population = response_json$population,
  Region = response_json$region,
  Subregion = response_json$subregion,
  Languages = paste(response_json$languages, collapse = ", "),
  Area = ifelse("area" %in% names(response_json), response_json$area, NA),
  Currency = response_json$currencies$JPY$name
)

# Print the resulting dataframe
country_df

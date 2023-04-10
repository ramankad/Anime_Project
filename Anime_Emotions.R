
rm(list=ls())

library(httr)
library(jsonlite)

# Set the API endpoint and categories
endpoint <- "https://api.waifu.pics/sfw"
categories <- c("cry", "hug", "pat", "smug", "smile", "wave", "highfive", "slap", "kick", "happy", "dance")

# Initialize an empty data frame to store the results
results <- data.frame(category = character(), url = character(), stringsAsFactors = FALSE)

# Loop over the categories and retrieve an image URL for each
for (category in categories) {
  # Build the URL for the current category
  url <- paste0(endpoint, "/", category)
  
  # Make the GET request
  response <- GET(url)
  
  # Extract the response content as JSON
  content <- content(response, "text")
  json <- fromJSON(content)
  
  # Extract the image URL from the JSON and add it to the results data frame
  results <- rbind(results, data.frame(category = category, url = json$url, stringsAsFactors = FALSE))
  
  # Download the image to your working directory
  filename <- paste0(category, ".gif")
  download.file(json$url, destfile = filename, mode = "wb")
  
}

# Print the results
print(results)


rm(list=ls())

library(httr)
library(jsonlite)

# Set the GraphQL query and any variables needed
query <- '
  query ($perPage: Int, $page: Int) {
    Page (perPage: $perPage, page: $page) {
      pageInfo {
        total
        perPage
        currentPage
        lastPage
        hasNextPage
      }
      media (type: ANIME, sort: POPULARITY_DESC) {
        id
        title {
          romaji
          english
        }
        episodes
        description
      }
    }
  }
'

variables <- list(perPage = 100, page = 1)

# Set the POST request options
url <- "https://graphql.anilist.co"
body <- list(query = query, variables = variables)
options <- list(content_type_json())

# Send the POST request
response <- POST(url, body = body, encode = "json", verbose(), config = add_headers("Accept-Encoding"="gzip"), options = options)

# Extract the response content as text and parse it as JSON
response_content <- content(response, "text")
response_json <- jsonlite::fromJSON(response_content)

# Extract and print title and number of episodes for each anime
anime_list <- response_json$data$Page$media

for (anime in anime_list) {
  paste("Title (romaji):", anime_list$id)
  paste("Title (romaji):", anime_list$title$romaji)
  paste("Title (english):", anime_list$title$english)
  paste("Episodes:", anime_list$episodes)
  paste("Description:", anime_list$description)
  cat("\n")
}

# Sort anime_list by ID in ascending order
anime_list_sorted <- anime_list[order(anime_list$id), ]


# Print the dataframe

head(anime_list_sorted, 3)


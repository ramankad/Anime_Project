rm(list=ls())


library(rvest)
library(purrr)

# Read the HTML content of the Wikipedia page
anime_url <- "https://en.wikipedia.org/wiki/Anime"
anime_html <- read_html(anime_url)

# Extract the headings and paragraphs
section_headings <- anime_html %>% html_nodes("h2, h3") %>% html_text()
section_paragraphs <- anime_html %>% html_nodes("h2, h3") %>% 
  map(~html_text(html_nodes(.x, xpath = "following-sibling::p"))) %>% 
  map_chr(~if(length(.x) > 0) paste(.x, collapse = "\n") else NA)

# Combine the headings and paragraphs into a data frame
anime_data <- data.frame(Section = section_headings, Content = section_paragraphs)

# Clean the paragraphs
anime_data$Content <- gsub("\\[[0-9]+\\]", "", anime_data$Content) # Remove references/footnotes
anime_data$Content <- gsub("[\r\n]+", " ", anime_data$Content) # Remove newline characters
anime_data$Content <- gsub("\\s+", " ", anime_data$Content) # Remove excess whitespace
anime_data$Content <- trimws(anime_data$Content) # Trim leading/trailing whitespace

# Subset the data frame for desired sections
selective_anime_sections <- c("History", "Modern era", "Globalization and cultural impact")
subset_anime_data <- anime_data[anime_data$Section %in% selective_anime_sections, ]

# Print the cleaned data
subset_anime_data

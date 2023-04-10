rm(list=ls())

library(rvest)
library(purrr)

# Read the HTML content of the Wikipedia page
manga_url <- "https://en.wikipedia.org/wiki/Manga"
manga_html <- read_html(manga_url)

# Extract the headings and paragraphs
section_headings <- manga_html %>% html_nodes("h2, h3") %>% html_text()
section_paragraphs <- manga_html %>% html_nodes("h2, h3") %>% 
  map(~html_text(html_nodes(.x, xpath = "following-sibling::p"))) %>% 
  map_chr(~if(length(.x) > 0) paste(.x, collapse = "\n") else NA)

# Combine the headings and paragraphs into a data frame
manga_data <- data.frame(Section = section_headings, Content = section_paragraphs)

# Clean the paragraphs
manga_data$Content <- gsub("\\[[0-9]+\\]", "", manga_data$Content) # Remove references/footnotes
manga_data$Content <- gsub("[\r\n]+", " ", manga_data$Content) # Remove newline characters
manga_data$Content <- gsub("\\s+", " ", manga_data$Content) # Remove excess whitespace
manga_data$Content <- trimws(manga_data$Content) # Trim leading/trailing whitespace

# Subset the data frame for desired sections
selective_manga_sections <- c("History and characteristics", "International markets")
subset_manga_data <- manga_data[manga_data$Section %in% selective_manga_sections, ]

# Print the cleaned data
subset_manga_data
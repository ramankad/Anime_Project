rm(list=ls())

library(rvest)

# Read in the HTML tables
anime_tables <- read_html("https://en.wikipedia.org/wiki/List_of_highest-grossing_anime_films")
anime_tables <- html_table(anime_tables)

# Keep only the relevant tables
anime_tables <- anime_tables[1:3]
names(anime_tables) <- c("highest_grossing_worldwide", "highest_grossing_japan", "japanese_films_by_admissions")

# Rename the columns for the japanese_films_by_admissions table
colnames(anime_tables[["highest_grossing_worldwide"]]) <- c("Title", "Worldwide gross", "Year", "Format", "Ref.")
colnames(anime_tables[["highest_grossing_japan"]]) <- c("Title", "Japan Gross", "Year", "Format", "Ref.")
colnames(anime_tables[["japanese_films_by_admissions"]]) <- c("Year", "Title", "Rentals", "Gross receipts", "Admissions", "Ref.", "Format")

# Create data frames from the tables
highest_grossing_worldwide_df <- as.data.frame(anime_tables[["highest_grossing_worldwide"]])
highest_grossing_japan_df <- as.data.frame(anime_tables[["highest_grossing_japan"]])
japanese_films_by_admissions_df <- as.data.frame(anime_tables[["japanese_films_by_admissions"]])

head(highest_grossing_worldwide_df, 3)

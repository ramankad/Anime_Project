rm(list=ls())

# Load the required packages
library(rvest)
library(dplyr)
library(ggplot2)
library(cluster)
library(reshape2)
library(ggdendro)
library(tidyr)

# Initialize an empty data frame to store the data
anime_characters <- data.frame()

# Specify the base URL and the number of pages to iterate through
base_url <- "https://anidb.net/character/?noalias=1&orderby.name=1.1&orderby.rating=0.2"
num_pages <- 20

# Loop through each page and extract the data
for (page_num in 1:num_pages) {
  # Construct the URL for the current page
  page_url <- paste0(base_url, "&page=", page_num, "&view=list")
  
  # Read the HTML content from the URL
  page_html <- read_html(page_url)
  
  # Extract the data we want and store it in a data frame
  page_data <- page_html %>%
    html_nodes("table") %>%
    html_table() %>%
    .[[1]]
  
  # Add a column to indicate the page number
  page_data$page_num <- page_num
  
  # Combine the data frame for the current page with the previous data frames
  anime_characters <- rbind(anime_characters, page_data)
}

# Print column names
colnames(anime_characters)

# Remove duplicates and missing values
anime_characters <- unique(anime_characters)

# Convert Rating column to numeric
anime_characters$Rating <- as.numeric(gsub("\\(.*?\\)", "", anime_characters$Rating))

# Convert Age column to numeric and replace missing values with median
anime_characters$Age <- as.numeric(anime_characters$Age)
median_age <- median(anime_characters$Age, na.rm = TRUE)
anime_characters$Age[is.na(anime_characters$Age)] <- median_age

# Create density plot for gender identity and rating
ggplot(anime_characters, aes(x = Rating, fill = `Gender Identity`)) +
  geom_density(alpha = 0.5) +
  labs(x = "Rating", fill = "Gender Identity") +
  labs(fill = "Gender Identity", title = "Density Plot of Rating by Gender Identity") +
  theme_classic() +
  scale_fill_discrete(name = "Gender Identity") +
  xlim(7.5, 10) +
  ggtitle("Density Plot of Rating by Gender Identity") +
  theme(plot.title = element_text(hjust = 0.5), legend.title = element_text(size = 12))

# Select variables for clustering
anime_cluster <- anime_characters[,c("Rating", "Gender Identity", "Age")]

# Convert Gender Identity to numeric
anime_cluster$`Gender Identity` <- ifelse(anime_cluster$`Gender Identity` == "male", 1, 2)
anime_cluster$`Gender Identity` <- as.numeric(anime_cluster$`Gender Identity`)

# Normalize the data
anime_cluster_norm <- scale(anime_cluster)

# Hierarchical clustering
anime_cluster_hclust <- hclust(dist(anime_cluster_norm))

# Create a dendrogram using ggplot2
ggdendrogram(anime_cluster_hclust, rotate = TRUE, theme_dendro = FALSE) +
  labs(title = "Dendrogram of Anime Character Clustering", x = "Number of Observations in Cluster", y = "Cluster Height") +
  theme(axis.text.x = element_text(size = 12), axis.text.y = element_text(size = 12))


# Silhouette analysis
sil <- numeric(num_pages)
for (k in 2:num_pages) {
  anime_cluster_kmeans <- kmeans(anime_cluster_norm, centers = k, nstart = 25)
  sil[k] <- mean(silhouette(anime_cluster_kmeans$cluster, dist(anime_cluster_norm)))
}

plot(2:num_pages, sil[2:num_pages], type = "b", xlab = "Number of Clusters", ylab = "Average Silhouette Coefficient", main = "Silhouette Analysis of Anime Character Clustering", cex.lab = 1.5, cex.main = 1.5, cex.axis = 1.2) +
  abline(h = mean(sil), col = "red", lty = 2) +
  geom_point(aes(x = which.max(sil), y = max(sil)), col = "blue", size = 4)

summary(sil)

# K-means clustering
anime_cluster_kmeans <- kmeans(anime_cluster_norm, centers = 3, nstart = 25)

# Add cluster information to the data frame
anime_cluster$cluster <- as.factor(anime_cluster_kmeans$cluster)

# Generate table of counts by cluster and gender identity
print(table(anime_cluster$cluster, anime_characters$`Gender Identity`))

# Generate table of counts by cluster and age
print(table(anime_cluster$cluster, anime_characters$Age))

# Summarize data by cluster
anime_cluster_summary <- anime_cluster %>%
  group_by(cluster) %>%
  summarize(mean_age = mean(Age),
            mean_rating = mean(Rating))

print(anime_cluster_summary)

# Bar chart of Gender Identity by cluster
ggplot(anime_cluster, aes(x = factor(anime_cluster_kmeans$cluster), fill = factor(`Gender Identity`))) +
  geom_bar(position = "dodge") +
  labs(title = "Bar Chart of Gender Identity by Cluster (k = 3)", subtitle = "Based on Anime Character Ratings and Age", x = "Cluster", y = "Count of Characters", fill = "Gender Identity") +
  scale_fill_brewer(palette = "Dark2") +
  geom_text(stat='count', aes(label=..count..), position=position_dodge(0.9), vjust=-0.5, size = 4) +
  theme_minimal() +
  theme(legend.position="top", legend.direction="horizontal", legend.text = element_text(size = 12), axis.text.x = element_text(size = 12), axis.text.y = element_text(size = 12), plot.title = element_text(size = 18, face = "bold"), plot.subtitle = element_text(size = 16))

# Perform K-means clustering
set.seed(123)
anime_cluster_kmeans <- kmeans(anime_cluster_norm, centers = 3)

# Check number of clusters
nlevels(factor(anime_cluster_kmeans$cluster))

# Create scatterplot of Age and Rating by cluster
ggplot(anime_cluster, aes(x = Age, y = Rating, color = factor(anime_cluster_kmeans$cluster))) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  labs(title = "Scatterplot of Age and Rating by Cluster", x = "Age", y = "Rating", color = "Cluster") +
  scale_color_brewer(palette = "Set1") +
  theme(legend.position = "right") +
  xlim(0, 100) + ylim(7.5, 10)

# Order rows and columns by clustering results
anime_cluster_ordered <- anime_cluster_norm[order(anime_cluster_kmeans$cluster), ]

# Create heatmap of normalized data by cluster
ggplot(data = melt(anime_cluster_ordered), 
       aes(x = Var2, y = Var1, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "red", 
                       mid = "lightyellow", 
                       high = "blue", 
                       midpoint = 0, 
                       na.value ="green",
                       guide = "colourbar",
                       aesthetics = "fill") +
  labs(title = "Heatmap of Normalized Data by Cluster") +
  theme_minimal()


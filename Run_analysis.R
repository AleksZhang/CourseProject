##Loading packages
library(dplyr)
library(tidyr)
library(reshape2)

##Loading data
test_subj <- read.table("subject_test.txt")
test_data <- read.table("X_test.txt")
test_names <- read.table("y_test.txt")
train_subj <- read.table("subject_train.txt")
train_data <- read.table("X_train.txt")
train_names <- read.table("y_train.txt")
act_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

##Loading datasets
test_df <- cbind.data.frame(test_subj, c(rep("test", nrow(test_subj))), test_names, test_data) 
colnames(test_df) <- 1:ncol(test_df)
train_df <- cbind.data.frame(train_subj, c(rep("train", nrow(train_subj))), train_names, train_data) 
colnames(train_df) <- 1:ncol(train_df)

##Merging dataset
merged_df <- rbind.data.frame(test_df, train_df)

##Giving colnames
colnames(merged_df) <- c("id", "dataset", "activity", as.character(features$V2)) 
valid_column_names <- make.names(names=names(merged_df), unique=TRUE, allow_ = TRUE)
names(merged_df) <- valid_column_names

##Extracting mean and std columns
extr_data <- select(merged_df, id, activity, dataset, matches("mean"), matches("std")) %>%
  select(-matches("freq"))

##Giving activity names
extr_data$activity <- factor(extr_data$activity, 
      levels = 1:6,
      labels = as.character(act_labels$V2))

##Reshaping data
molten <- melt(extr_data, id = c("id", "activity", "dataset"))
fin_data <- dcast(molten, formula = id + dataset + activity ~ variable, fun = mean)

##Cleaning column names
names(fin_data) <-  gsub("\\.", "", names(fin_data)) 
names(fin_data) <- tolower(names(fin_data))
names(fin_data) <-  gsub("bodybody", "body", names(fin_data)) 

##Saving the data on HD
write.table(fin_data, "Samsung_data.txt", row.names = FALSE)

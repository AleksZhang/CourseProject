##Loading packages
library(dplyr)
library(tidyr)

##Loading data
test_subj <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\test\\subject_test.txt")
test_data <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\test\\X_test.txt")
test_names <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\test\\y_test.txt")
train_subj <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\train\\subject_train.txt")
train_data <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\train\\X_train.txt")
train_names <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\train\\y_train.txt")
act_labels <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\activity_labels.txt")
features <- read.table("D:\\R\\assignment4\\UCI HAR Dataset\\features.txt")

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

##Saving the data on HD
write.csv(extr_data, "extr_data.csv")

##Loading packages
library(reshape2)

##Loading data
extr_data <- read.csv("extr_data.csv") %>%
  select(-X)

##Reshaping data
molten <- melt(extr_data, id = c("id", "activity", "dataset"))
fin_data <- dcast(molten, formula = id + dataset + activity ~ variable, fun = mean)

##Saving the data on HD
write.csv(fin_data, "fin_data.csv")


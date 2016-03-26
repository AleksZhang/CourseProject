# CourseProject

The Course Project contains:

1. **Run_analysis.R**, the R script of processing the raw data
2. **CodeBook.md**, the file with description of the final array
3. **Samsung_data.txt**, the final array at .txt format
4. **README.md**, the file with description of the repo and comments on how the **Run_analysis.R** script works


##Run_analysis.R code description

**1) At the very begininning we need to load all the packages and data needed for making and cleaning the array.**

Packages are:
```
library(dplyr)
library(tidyr)
library(reshape2)
```

Data include the following files from the ZIP-archive (presume, we unzip all the files to our working directory):
```
test_subj <- read.table("subject_test.txt")
test_data <- read.table("X_test.txt")
test_names <- read.table("y_test.txt")
train_subj <- read.table("subject_train.txt")
train_data <- read.table("X_train.txt")
train_names <- read.table("y_train.txt")
act_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")
```
**2) Then we bind different files to get two arrays, test and train respectively.**
```
test_df <- cbind.data.frame(test_subj, c(rep("test", nrow(test_subj))), test_names, test_data) 
colnames(test_df) <- 1:ncol(test_df)
train_df <- cbind.data.frame(train_subj, c(rep("train", nrow(train_subj))), train_names, train_data) 
colnames(train_df) <- 1:ncol(train_df)
```

Please, pay attention to the argument `c(rep("test/train", nrow(test/train_subj)))`. 
We create a variable which will later let us know, if the value was a part of "train" or "test" dataset. 
So, we'll be able to call these datasets at any moment.
It's very important not to loose any information from the original data, 
and belonging to a corresponding dataset is a part of information.

`colnames(test/train_df) <- 1:ncol(test/train_df)` is needed to unify column nmes for the following binding.

**3) The following step is creating the merged dataset.**
```
merged_df <- rbind.data.frame(test_df, train_df)
colnames(merged_df) <- c("id", "dataset", "activity", as.character(features$V2)) 
valid_column_names <- make.names(names=names(merged_df), unique=TRUE, allow_ = TRUE)
names(merged_df) <- valid_column_names
```

Column names for merged_df are:
* id - for the previous "test/train_subj"
* dataset - making a factor variable for our test/train vectors
* activity - for the previous "test/train_names"
* following columns borrow names from the "features" file.
- as names containing in "features" file are not of appropriate format, we need to use `make.names()`

**4) Extracting the variables needed.**
```
extr_data <- select(merged_df, id, activity, dataset, matches("mean"), matches("std")) %>%
  select(-matches("freq"))
  ```
  
We need only mean and standard deviation columns, not mean frequency.
  
**5) Giving names to activities.**
```
extr_data$activity <- factor(extr_data$activity, 
      levels = 1:6,
      labels = as.character(act_labels$V2))
      ```
      
**6) Reshaping data.**
```
molten <- melt(extr_data, id = c("id", "activity", "dataset"))
fin_data <- dcast(molten, formula = id + dataset + activity ~ variable, fun = mean)
```

We want to leave as ID columns the following data:
* ID of the experiment subject
* Type of the sample the subject belongs to (test or train)
* activity performed by the subject.

As we want to get mean values for every measurement for every activity, we use `mean()` as a function for `dcast()`.

**7) Cleaning column names of the final data**
```
names(fin_data) <-  gsub("\\.", "", names(fin_data)) 
names(fin_data) <- tolower(names(fin_data))
names(fin_data) <-  gsub("bodybody", "body", names(fin_data)) 
```

* remove all the dots
* lower the register for all characters
* remove repeating words from the column names

**8) And owr final step is saving the data on the hard drive.**
```
write.table(fin_data, "Samsung_data.txt", row.names = FALSE)
```

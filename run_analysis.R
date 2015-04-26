##PROJECT ASSIGNMENT GETTING AND CLEANING DATA

## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(data.table)
library(dplyr)

# Read activity labels and features txt into R
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

# Read test data into R from x_test, y_test and subject_test
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# Extract mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

# Create the labels with Activity ID and Labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Combine data tables into test table
test_dataset <- cbind(as.data.table(subject_test), y_test, X_test)

# Read test data into R from x_train, y_train and subject_train
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

# Create the labels with Activity ID and Labels
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"


# Combine data tables into test table
train_dataset <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train datasets into combo_dataset
combo_data = rbind(test_dataset, train_dataset)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(combo_data), id_labels)
melted_data = melt(combo_data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_dataset = dcast(melted_data, subject + Activity_Label ~ variable, mean)
#Output tidy dataset to txt file in working directory
write.table(tidy_dataset, file = "./tidy_data.txt")

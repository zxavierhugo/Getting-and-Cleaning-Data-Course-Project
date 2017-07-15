# First download the reshape2 library. If not, install it
library(reshape2)

# Obtain the filename
filename <- "getdata_dataset.zip"


if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

#1 Load activity and merge labels + features from the file.
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
feat <- read.table("UCI HAR Dataset/features.txt")
feat[,2] <- as.character(feat[,2])

features <- grep(".*mean.*|.*std.*", feat[,2])
features.names <- feat[features,2]
features.names = gsub('-mean', 'Mean', features.names)
features.names = gsub('-std', 'Std', features.names)
features.names <- gsub('[-()]', '', features.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features]
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train <- cbind(train_subjects, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features]
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test <- cbind(test_subjects, test_activities, test)

#2: Extracts only the measurements on the mean and standard deviation for each measurement.
all_data <- rbind(train, test)
colnames(all_data) <- c("subject", "activity", features.names)

# turn activities & subjects into factors
all_data$activity <- factor(all_data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
all_data$subject <- as.factor(all_data$subject)

all_data.melted <- melt(all_data, id = c("subject", "activity"))
all_data.mean <- dcast(all_data.melted, subject + activity ~ variable, mean)

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
write.table(all_data.mean, "cleaned_up.txt", row.names = FALSE, quote = FALSE)
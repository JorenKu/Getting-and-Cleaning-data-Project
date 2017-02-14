library(dplyr)

## Download the zip file, with the several files included
temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp, mode = "wb")
unz(temp, "getdata_dataset.zip")

## Read in necessary files for tidy dataset, columnnames used from Features dataset
Features <- read.table(unz(temp,"UCI HAR Dataset/features.txt")) ; colnames <- Features$V2
Activity <- read.table(unz(temp,"UCI HAR Dataset/activity_labels.txt"))
TestX <- read.table(unz(temp, "UCI HAR Dataset/test/X_test.txt"), col.names = colnames)
TestID <- read.table(unz(temp, "UCI HAR Dataset/test/subject_test.txt"), col.names = "ID")
TestY <- read.table(unz(temp, "UCI HAR Dataset/test/y_test.txt"), col.names = "Activity")
TrainX <- read.table(unz(temp, "UCI HAR Dataset/train/X_train.txt"), col.names = colnames)
TrainID <- read.table(unz(temp, "UCI HAR Dataset/train/subject_train.txt"), col.names = "ID")
TrainY <- read.table(unz(temp, "UCI HAR Dataset/train/y_train.txt"), col.names = "Activity")

# Put the id columns and activity labels in the datasets
Test <- cbind(TestID, TestY, TestX)
Train <- cbind(TrainID, TrainY, TrainX)

##1. Merge the training and the test sets to create one data set.
UCIHAR <- rbind(Test, Train)

##2. Extract only the measurements on the mean and standard deviation for each measurement.
  ## MeanFreq is removed in secondstep due to the partial match in first selection
UCIHAR <- UCIHAR %>% select(matches("mean|Std|ID|Activity")) %>% select(-matches("meanFreq"))

##3.Use descriptive activity names to name the activities in the data set
UCIHAR$Activity <- factor(UCIHAR$Activity, levels = Activity[,1], labels = Activity[,2])

##4.Appropriately label the data set with descriptive variable names.
names(UCIHAR) <- gsub("[.]", "", names(UCIHAR))

##5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
UCIGroup <- UCIHAR %>% group_by(ID, Activity) %>% summarise_each(funs("mean"), vars = -c(ID:Activity))

## Export the last data set
write.table(UCIGroup, "UCIGroup.txt", sep="\t", row.names = FALSE)

unlink(temp)
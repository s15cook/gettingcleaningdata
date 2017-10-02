## Download of zip file, extract train and test data and combine into one table
## Peform the following:
## 1. Merge the training and the test sets to create one data set.
## 2. Extract only the measurements on the mean and standard deviation for 
##    each measurement. 
## 3. Use descriptive activity names to name the activities in the data set
## 4. Appropriately label the data set with descriptive variable names. 
## 5. From the data set in step 4, create a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.

## Extract data from URL and unzip
setwd("./data")
if(!file.exists("./data")) {dir.create("./data")}
fileURL1="http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL1, destfile="./data/dataset.zip")
unzip("dataset.zip", files=NULL, list=FALSE, unzip="internal",setTimes=FALSE)

## Read 3 x training text data from the unzipped folder
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt", header=FALSE)
x_train<-read.table("./UCI HAR Dataset/train/X_train.txt", header=FALSE)
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt", header=FALSE)


## Read 3 x test text data from the unzipped folder
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE)
x_test<-read.table("./UCI HAR Dataset/test/X_test.txt", header=FALSE)
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt", header=FALSE)

## Read in related metadata
features<-read.table("./UCI HAR Dataset/features.txt", header=FALSE, colClasses = c("character"))
activity_label<-read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE, 
                           colClasses = c("character"), col.names = c("ActivityId", "Activity"))

## Combine the related train and test data tables
training_sensor<-(cbind(cbind(x_train, subject_train), y_train))
test_sensor<-(cbind(cbind(x_test, subject_test), y_test))
tt_data <- rbind(training_sensor, test_sensor)

# Label columns from features list
labels <- rbind(rbind(features, c(562, "SubjectId")), c(563, "ActivityId"))[,2]
names(tt_data) <- labels

## Extract the measurements on the mean and standard deviation 
extract_mean_std <- tt_data[,grepl("mean|std|SubjectId|ActivityId", names(tt_data))]

## Apply descriptive names to activities in the data set
extract_mean_std <- join(extract_mean_std, activity_label, by="ActivityId")
extract_mean_std$ActivityId = NULL

## Label the data set with appropriate descriptive variable names. 
names(extract_mean_std) <- gsub('Acc',"Acceleration",names(extract_mean_std))
names(extract_mean_std) <- gsub('Gyro',"AngularSpeed",names(extract_mean_std))
names(extract_mean_std) <- gsub('BodyBody',"Body",names(extract_mean_std))
names(extract_mean_std) <- gsub('Mag',"Magnitude",names(extract_mean_std))
names(extract_mean_std) <- gsub('^t',"Time.",names(extract_mean_std))
names(extract_mean_std) <- gsub('^f',"Frequency.",names(extract_mean_std))
names(extract_mean_std) <- gsub('-mean()',".Mean",names(extract_mean_std))
names(extract_mean_std) <- gsub('-std()',".StandardDeviation",names(extract_mean_std))
names(extract_mean_std) <- gsub('-meanFreq()',".MeanFrequency.",names(extract_mean_std))
names(extract_mean_std) <- gsub('Freq$',"Frequency",names(extract_mean_std))
names(extract_mean_std) <- gsub('\\(|\\)',"",names(extract_mean_std))
##names(extract_mean_std) <- gsub('()',"",names(extract_mean_std))


## Create independent tidy data set with average of each variable for each activity and subject
tidydata <- ddply(extract_mean_std, c("SubjectId","Activity"), numcolwise(mean))
write.table(tidydata, file = "tidyphonedata.txt", row.names=FALSE)


              



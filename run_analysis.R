# provide the directory in which the UCI HAR Dataset is stored here:
data.dir <- 'UCI HAR Dataset/'


##############################
## Do not change code below ##
##############################

# set working directory to where the unzipped files are
old.dir <- getwd()
setwd(data.dir)


# 1. Merges the training and the test sets to create one data set.
library(data.table)
X.train <- fread('train/X_train.txt')
X.test <- fread('test/X_test.txt')
X <- rbind(X.train, X.test)
rm(X.train, X.test)


# 2. Extracts only the measurements on the mean and standard deviation for each 
# measurement.
variable.names <- read.table('features.txt', header = FALSE)
extract <- grep('.*(mean\\(\\)|std\\(\\)).*', variable.names$V2)
X <- X[, extract, with=FALSE]


# 3. Uses descriptive activity names to name the activities in the data set
y.train <- fread('train/y_train.txt')
y.test <- fread('test/y_test.txt')
y <- rbind(y.train, y.test)
rm(y.train, y.test)

activities <- fread('activity_labels.txt')
y$V1 <- factor(y$V1, levels=activities$V1, labels=activities$V2)
names(y) <- 'activity'
rm(activities)


# 4. Appropriately labels the data set with descriptive variable names.
names(X) <- as.character(variable.names[extract, 2])
rm(variable.names, extract)


# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
subject.train <- fread('train/subject_train.txt')
subject.test <- fread('test/subject_test.txt')
subject <- rbind(subject.train, subject.test)
rm(subject.train, subject.test)
names(subject) <- 'subject'

library(dplyr)
data <- cbind(subject, X, y)
tidy <- data %>%
    group_by(subject, activity) %>%
    summarize_all(mean)

rm(X, y, data, subject)


# write the tidy dataset to a txt file
write.table(tidy, '../tidy_data.txt', row.name=FALSE)


# reset working directory to what it was before
setwd(old.dir)

#Author's Note

While writing this and running these commands, I am *also* running many small (sometimes erroneous) sanity checks on my data. This usually involves some form of 'sum(Vector==Condition)' to count things and make sure everything is being accounted for. 
Rather than write *all* of the little steps I take to make sure that my steps make sense, I recommend you get in the habit of regularly running your own checks.

-Dave

# Input Data

Experiment:
> 30 volunteers between 19-48yo
> 6 activities (while wearing smartphone)
> Gyroscope&Accelerometer: (3-axial linear velocity)+(3-axial angular velocity), measured at 50Hz
> PreProcessing Of Sensors:
> > Noise Filters
> > Sampled in fixed-width sliding windows: 2.56s with 50% overlap == 128 readings/window
> > Acceleration Signal -> Butterworth low-pass filter (0.3Hz cutoff) -> (body accel + gravity)
> > Each sample = from each window (duh)

Input data contains:
> README.txt
> features.txt
> features_info.txt
> activity_labels.txt
> \*/X_\*.txt,	where \* is either 'test' or 'train'
> \*/subject_\*.txt
> \*/Inertial Signals/   **(not used)**

Input data notes:
> Features are normalized and bounded within [-1,1]

## *Their* Data Processing

This section was originally placed later in this file, but it was moved since most of this information regards things *before* we get involved (i.e., before I downloaded this dataset). 

The file *features_info.txt* details how their experiment was conducted and how their data was processed. Most of this is not used in my analysis since we're asked to do something simple, but here are the notes I took down about their process:
> * tAcc-XYZ := accelerometer 3-axial raw signal, @ rate 50Hz
> * tGyro-XYZ := gyroscope 3-axial raw signal, @ rate 50Hz
> * Filters in order (& applied to):
> > 1. Median filter (both)
> > 2. 3rd order low pass Butterworth w cornerFreq=20Hz (both)
> > 3. low pass Butterworth w cornerFreq=0.3Hz; 
(tAcc-XYZ)  becomes  (tBodyAcc-XYZ & tGravityAcc-XYZ)

> * tBodyAccJerk-XYZ := Jerk signal (accelerometer), d(accel_linear)/dt
> * tBodyGyroJerk-XYZ := Jerk signal (gyroscope), d(accel_angular)/dt
> * Magnitudes calculated using the Euclidean norm:
> > * tBodyAccMag
> > * tGravityAccMag
> > * tBodyAccJerkMag
> > * tBodyGyroMag
> > * tBodyGyroJerkMag

> * Frequency signals calculated via FFT:
> > * fBodyAcc-XYZ
> > * fBodyAccJerk-XYZ
> > * fBodyGyro-XYZ
> > * fBodyAccJerkMag
> > * fBodyGyroMag
> > * fBodyGyroJerkMag

> * For the angle() variable, they calculated some numbers *per window*, explaining why some of our features already have the word 'Mean' in their name.

#Features

##features.txt
Since we do not necessarily know how many features there could be, let's try looking at some basics of this file. We never know if it'll be a huge file that'll take forever to load, so these are some Linux (or Git Bash) command-line methods that can return relatively useful results, quickly.

	$ cat features.txt | wc -l
	561
	$ cat features.txt | head -3
	1 tBodyAcc-mean()-X
	2 tBodyAcc-mean()-Y
	3 tBodyAcc-mean()-Z
	$ cat features.txt | tail -5
	557 angle(tBodyGyroMean,gravityMean)
	558 angle(tBodyGyroJerkMean,gravityMean)
	559 angle(X,gravityMean)
	560 angle(Y,gravityMean)
	561 angle(Z,gravityMean)

##features_info.txt

Rather than post ALL of the possible bits of info they provide us, here is a subset of that list, which contains the two variables we will eventually look at:
> mean(): Mean value
> std(): Standard deviation
> mad(): Median absolute deviation 
> max(): Largest value in array
> sma(): Signal magnitude area

Below are a few extra Linux/GitBash commands to help describe the features, using what we *now* know. By the way, I guess *this* grep acts slightly differently than R's grep, since this one needed the '\\-mean' while R's grep was fine with '-mean'. 

*Note that the first command is creating the temporary file 'FeatureNames.txt', which contains the 2nd column of 'features.txt' (separated by a single blankspace via `awk -F " "`).* All subsequent commands use `wc -l` to return the number of lines within 'FeatureNames.txt' that match the following criteria :
> 1. All lines
> 2. Lines with '-mean'
> 3. Lines *with* '-mean' but *without* 'meanFreq'
> 4. Lines with '-meanFreq'
> 5. Lines *with* '-meanFreq' but do *not start* with 'f'
> 6. Lines with '-std'
> 7. Lines that *begin* with '{letters}-mean...-...', where {letters} is just a series of lower or capital letters
> 8. Lines that do *not* begin with '{letters}-mean...-...' but *do* contain 'mean'
> 9. Lines that *begin* with '{letters}-std...-...'
> 10. Lines that do *not* begin with '{letters}-std...-...' but *do* contain 'std'

Here is that GitBash/Terminal code, along with the computer's responses.

	$ cat features.txt | awk -F " " '{print $2}' > FeatureNames.txt
	$ cat FeatureNames.txt | wc -l
	561
	$ cat FeatureNames.txt | grep '\-mean' | wc -l
	46
	$ cat FeatureNames.txt | grep '\-mean' | grep -v 'meanFreq' | wc -l
	33
	$ cat FeatureNames.txt | grep '\-meanFreq' | wc -l     
	13
	$ cat FeatureNames.txt | grep '\-meanFreq' | grep -v '^f' | wc -l
	0
	$ cat FeatureNames.txt | grep '\-std' | wc -l
	33
	$ cat FeatureNames.txt | grep '^[a-zA-Z]*\-mean.*\-.*' | wc -l
	33
	$ cat FeatureNames.txt | grep -v '^[a-zA-Z]*\-mean.*\-.*' | grep 'mean' | wc -l
	13
	$ cat FeatureNames.txt | grep -v '^[a-zA-Z]*\-std.*\-.*' | grep 'std' | wc -l
	24
	$ cat FeatureNames.txt | grep -v '^[a-zA-Z]*\-std.*\-.*' | grep 'std' | wc -l
	9
	$ rm FeatureNames.txt
	
The purpose of this is two-fold: 1) the numbers add up well, so we know we're capturing everything (46==33+13, & 33==24+9), and 2) these small lists are easy to inspect and can give us an idea of what these names look like (again, *without* opening the file itself).
Inspecting the last `cat * | grep` command (i.e., remove the '| wc -l') reveals some odd feature names like "fBodyBodyGyroJerkMag-std()", but I'm certainly not going to remove any labelling that *they've* done. I will just have to work with it.



##Summary of Features

As we'll see when we review our goals, we're only really concerned about "the measurements on the mean and standard deviation for each measurement" (as per the instructions). 
Keeping that into consideration, here is a summary of the features:
> * 561 features total
> * Features are named *either* 'Object-Measurement' *or* 'Object-Measurement-Axis' (if axis is applicable)
> * Features that we want contain the string '-mean' or '-std' (as part of their '-Measurement' substring of their name)
> * Features are named with the following general indicators:
> > * Beginning with 't' or 'f' indicates if this was a time- or frequency-domain (via FFT) measurement, respectively
> > * 'Acc', 'Mag' == 'Acceleration', 'Magnitude'  (just a note for renaming)
> > * 'mean()', 'std()', 'meanFreq()' == 'Mean', 'StandardDev', 'Mean'
> > > Note: I am choosing to lose the 'Freq' part of 'meanFreq()' because I've already determined that ALL lines with 'meanFreq()' already begin with 'f' as an indicator

#Goal

OUR goal is to finish the programming assignment, copied and pasted as follows:

	You should create one R script called run_analysis.R that does the following.
		1. Merges the training and the test sets to create one data set.
		2. Extracts only the measurements on the mean and standard deviation for each measurement.
		3. Uses descriptive activity names to name the activities in the data set
		4. Appropriately labels the data set with descriptive variable names.
		5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Solution

##Part 1: Combining (and Writing)

It might seem silly, but after merging the data, I'll attempt to write it in a file so that I can easily pause, stop, continue, etc., without worrying about formatting issues.

So let's start by getting to the proper working directory in R:
	
	> ProgramAssignmentLocation <- 'PathToMyProgrammingAssignment' #not for you to see :)
	> setwd(ProgramAssignmentLocation)
	> dir()
	[1] "activity_labels.txt" "features.txt" "features_info.txt"
	[4] "README.txt"          "test"         "train"

I'm guessing we're not using the \*/Inertial Signals/ folder, especially since it only has 128 elements per row, so its not comparable to any of the rest of the data NOR do we have names for these 128 features.

Assuming what I just said is true, here are the pertinent files for this part and what they contain, allowing \* to be either 'test' or 'train':
> * '\*/subject_\*.txt'
> > contains single column of IDs (of subjects)

> * '\*/X_\*.txt
> > contains feature matrix, read in as multiple columns of numerics

> * '\*/y_\*.txt'
> > contains single column of IDs (of activities)

> * 'activity_labels.txt'
> > 1st column is ID (of activity), 2nd col is activity's name

> * 'features.txt'
> > 1st column is Index (of feature), 2nd col is feature's name 


###Combining SubjectIDs, Features, and Labels

I'm not going to worry about the feature *names* right now, or *which* features to extract. I will, however, probably do that before saving the file (just to practice efficient storing).
For each variable (subjIDs, X, and y), I'm just reading the test data, and then *rbind'ing* the training data onto it. Later, I'll cbind subjIDs, X, and y together into one dataframe.

	> subjIDs <- read.table('test/subject_test.txt')
	> subjIDs <- rbind(subjIDs, read.table('train/subject_train.txt'))
	> X <- read.table('test/X_test.txt')
	> X <- rbind(X, read.table('train/X_train.txt'))
	> dim(X)
	[1] 10299   561
	> y <- read.table('test/y_test.txt')
	> y <- rbind(y, read.table('train/y_train.txt'))
	> dim(y)
	[1] 10299     1
	
We're sort of done here (since the next step in the assignment **is** extracting only mean & standard deviation measurements). Just need to cbind everything together into the var `Ans1` ('Ans1' is simply in reference to the fact that it fulfills the first requirement of the assignment):

	> Ans1 <- cbind(subjIDs,X)
	> Ans1 <- cbind(Ans1, y)
	> class(Ans1)
	[1] "data.frame"

Again, `Ans1` is never actually used since I still want to trim this data down some more, but this dataframe does fulfill our first requirement and is (close to) the first step of what we would like to accomplish overall.
	
##Extracting the Mean and Standard Deviation Measurements 

First, I'd like a normal character vector with all of the names of the features, in order.

	> featureNames <- as.character(read.table('features.txt')$V2)

To extract the mean & standard deviation measurements, I'm going to be using grep() and grepl() to search for features with the phrase '-mean' or '-std' (which I already know are my indicators from exploring features.txt and features_info.txt).

	> ExtractedXIndices <- grep( "(-mean)|(-std)" , featureNames)
	> ExtractedFeatureNames <- featureNames[ExtractedXIndices]

So now we have the indices of X that we want to extract as well as those features' names. Before we go any further (and now that we've narrowed our features down), I am going to handle those pesky feature names so that I don't ever have to worry about them again.

To handle the names, I'm going to create a function that will simply reformat a name, based on my previous observations of names. I'll probably do some sort of global substitute to unabbreviate some stuff. On that note, my format will only be slightly different than the input dataset:
> * Input format: 'tBodyAcc-mean()-X',  'fBodyAccMag-mean()'
> * My format: 'BodyAccelerationX-Mean-TimeDomain', 'BodyAccelerationMagnitude-Mean-FreqDomain'

	> RenameFeature <- function(FeatureString){
	+ if (substring(FeatureString,0,1)=='f'){String <- c(substring(FeatureString,2), 'f')
	+ } else if (substring(FeatureString,0,1)=='t'){String <- c(substring(FeatureString,2),'t')}
	+ ## so now String[1] is what we want to format and String[2] is the domain
	+ parts <- strsplit(String[[1]], split='-')[[1]]  #[[1]] because strsplit is a list
	+ if (length(parts)==3){ outFeature <- paste(parts[c(1,3)],collapse='') 
	+ } else if (length(parts)==2){ outFeature <- parts[1] }
	+ ## so now outFeature is either something like 'BodyAcc' or 'BodyAccX'

	+ if (grepl('mean',parts[2])==TRUE){ outFeature <- c(outFeature,'Mean')
	+ } else if (grepl('std',parts[2])==TRUE){ outFeature <- c(outFeature,'StandardDev')}
	
	+ if (String[2]=='f'){ outFeature <- c(outFeature, 'FreqDomain')
	+ } else if (String[2]=='t'){ outFeature <- c(outFeature, 'TimeDomain')}
	+ ## outFeature now looks something like: c('Description','Mean','TimeDomain')
	+ paste(outFeature, collapse='-')}
	
As is, this function will take in a string like "tBodyAcc-mean()-X" and return "BodyAccX-Mean-TimeDomain". Then I'll gsub ALL of the features that look like that into a prettier form. *Note that I have `USE.NAMES=FALSE` due to how `ExtractedFeatureNames` was created and stored*.

	> ProperFeatureNames <- sapply( ExtractedFeatureNames, RenameFeature, USE.NAMES=FALSE )
	> ProperFeatureNames <- gsub('Acc', 'Acceleration', ProperFeatureNames)
	> ProperFeatureNames <- gsub('Mag', 'Magnitude', ProperFeatureNames)
	
So *now* our features should be properly named (albeit clunky). Now let's handle renaming y (since it's all just a bunch of integers now). We can then go ahead and extract the columns from X as needed and then save our file.

	> yLabels <- c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS','SITTING','STANDING','LAYING')
	> yValsAsStrings <- as.character(yLabels[as.integer(y$V1)])
	> MyData <- cbind(subjIDs, X[,ExtractedXIndices])
	> MyData <- cbind(MyData, yValsAsStrings)
	> write.table(MyData, file='CleanedData.txt', col.names=c('SubjectIDs',ProperFeatureNames,'SubjectActivity'))

	

## Averaging per Subject per Activity

Assuming everything (on your end) has been fine so far, I am going to restart R (and my variables), and then just load this "CleanedData.txt" file in.

	> ProgramAssignmentLocation = 'MY path to the [ExtractedZipFolder]/getdata_projectfiles.../UCI HAR Dataset/'
	> setwd(ProgramAssignmentLocation)
	> MyData <- read.table('CleanedData.txt',stringsAsFactors=FALSE)
	> class(MyData); names(MyData)[c(1,2,3, length(MyData[1,])]
	[1] "data.frame"
	[1] "SubjectIDs"                              
	[2] "BodyAccelerationX.Mean.TimeDomain"       
	[3] "BodyAccelerationY.Mean.TimeDomain"
	[4] "SubjectActivity"
	
So after trying a bit, I am having significant difficulty installing something like reshape or reshape2 (this is apparently due to a well-known R/Windows 7 problem with newer packages).
Anyway, in the interest of time, I am going to do this in a brute-force, usually inefficient way. I don't think we're dealing with huge amounts of numbers though, so overall, I think it'll be fine.

I'm going to create a new data.frame and store my answers there as I iterate through the different combinations of subject & activity.
Like I said, iterating this isn't the most efficient way; I would have rather subsetted MyData (easy) and then calculated and stored column means (not so easy).
I'll need to figure the subsetting and reshaping things out at a future date.

	> ActivityLabels <- c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS','SITTING','STANDING','LAYING')
	> UniqueSubjectIDs <- unique(MyData$SubjectIDs)
	
	> ## MyData[,2:80] are all the features' values. So if you see numbers in the code that are ~79, it is because we are referring to the number of features (sometimes with an offset, such as 2:80 instead of 1:79).
	
	> ## I want to record the sequence of S's and A's, just in case this is iterating in a way I didn't foresee
	> SeqS <- c(); SeqA <- c()
	
	> Averages <- NULL
	> for (S in UniqueSubjectIDs){
	>	for (A in ActivityLabels){
	>		## Record these into SeqS & SeqA
	>		SeqS <- c(SeqS,as.character(S)); SeqA <- c(SeqA,A)
	
	>		## subset data, prepare row to be added to Averages
	>		ConditionForRows = MyData$SubjectIDs==S & MyData$SubjectActivity==A
	>		SubsetData = MyData[ConditionForRows,2:80] #1+1:79+1 bc the FIRST col is subjIDs
	
	>		## it gets cranky if we don't tell it we have 1 row
	>		RowName <- paste(as.character(S),A,collapse='')
	>		AveragesRow <- data.frame(row.names=RowName) 

	>		for (n in 1:79){
	>			AveragesRow[1,n] <- mean(SubsetData[,n])}
	
	>		## temp is ready to be made/added into Averages
	>		if (class(Averages)=="NULL"){
	>			Averages <- AveragesRow
	>		} else {
	>			Averages <- rbind(Averages,AveragesRow)} }}
	
	> ## Going to re-introduce SeqS & SeqA into THIS table, since they are my SubjectIDs and SubjectActivity values
	> ## Doing this by creating a temp dataframe, then cbinding it onto my Averages dataframe
	> Sequences <- data.frame(SubjectIDs=SeqS, SubjectActivity=SeqA,stringsAsFactors=FALSE)
	> Averages <- cbind(Sequences, data.frame(Averages,row.names=NULL))
	> remove(Sequences) #be careful!
	
	## And finally, to write:
	> FeatureNames <- names(MyData)[2:80] #1+1:79+1 bc the FIRST col is subjIDs
	> ColNames <- c('SubjectIDs','SubjectActivity',FeatureNames)
	> write.table(Averages,col.names=ColNames,file='Averages.txt',row.name=FALSE)
	
And there you have it! One dataframe and file that correctly expresses the averages of *each* feature (that is a mean/std measurement) *per* subject *per* activity. Hope you enjoy; let me know if you have any comments or questions!

Dave Nair
mdavenair@gmail.com
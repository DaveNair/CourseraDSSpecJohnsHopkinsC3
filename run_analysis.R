## Note: there are TWO files that this program WILL make.
## By that, I mean that I have absolutely zero if(fileExists) clauses
## I didn't want to risk my program not running or finishing,
## especially when I'm being graded on this.
## If this concerns you, both filenames are stored 
## as the variable FILENAME (at different times) and can be changed at your convenience


RenameFeature <- function(FeatureString){
	if (substring(FeatureString,0,1)=='f'){String <- c(substring(FeatureString,2), 'f')
	} else if (substring(FeatureString,0,1)=='t'){String <- c(substring(FeatureString,2),'t')}
	
	## so now String[1] is what we want to format and String[2] is the domain
	
	parts <- strsplit(String[[1]], split='-')[[1]]  #[[1]] because strsplit is a list
	if (length(parts)==3){ outFeature <- paste(parts[c(1,3)],collapse='') 
	} else if (length(parts)==2){ outFeature <- parts[1] }
	
	## so now outFeature is either something like 'BodyAcc' or 'BodyAccX'

	if (grepl('mean',parts[2])==TRUE){ outFeature <- c(outFeature,'Mean')
	} else if (grepl('std',parts[2])==TRUE){ outFeature <- c(outFeature,'StandardDev')}
	
	## outFeatures is now something like c("BodyAccX","Mean")

	if (String[2]=='f'){ outFeature <- c(outFeature, 'FreqDomain')
	} else if (String[2]=='t'){ outFeature <- c(outFeature, 'TimeDomain')}
	
	## outFeature now looks something like: c('Description','Mean','TimeDomain')
	paste(outFeature, collapse='-')
}



run_analysis <- function(){

## Combining testing and training
subjIDs <- read.table('test/subject_test.txt')
subjIDs <- rbind(subjIDs, read.table('train/subject_train.txt'))
X <- read.table('test/X_test.txt')
X <- rbind(X, read.table('train/X_train.txt'))
y <- read.table('test/y_test.txt')
y <- rbind(y, read.table('train/y_train.txt'))

## Completing 1st requirement, then deleting answer since it's not used
Ans1 <- cbind(subjIDs,X)
Ans1 <- cbind(Ans1, y)
## Deleting
remove(Ans1)

## Extracting Mean & Standard Deviation Features
featureNames <- as.character(read.table('features.txt')$V2)
ExtractedXIndices <- grep( "(-mean)|(-std)" , featureNames)
ExtractedFeatureNames <- featureNames[ExtractedXIndices]

## Rename ExtractedFeatureNames, using my function RenameFeature & the gsub() function
ProperFeatureNames <- sapply( ExtractedFeatureNames, RenameFeature, USE.NAMES=FALSE )
ProperFeatureNames <- gsub('Acc', 'Acceleration', ProperFeatureNames)
ProperFeatureNames <- gsub('Mag', 'Magnitude', ProperFeatureNames)

## Rename Activities (y)
yLabels <- c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS','SITTING','STANDING','LAYING')
yValsAsStrings <- as.character(yLabels[as.integer(y$V1)])

## Combine Into MyData
MyData <- cbind(subjIDs, X[,ExtractedXIndices])
MyData <- cbind(MyData, yValsAsStrings)

## WRITE the data! I apologize if this does something to your system...
## if it does, you should probably not name your files such crazy names.
FILENAME <- 'HopefullyYouDontHaveAFileNamedThisBecauseImGoingToWriteOverItAnywayKThnxByeDN.txt'
write.table(MyData, file=FILENAME, col.names=c('SubjectIDs',ProperFeatureNames,'SubjectActivity'))

## To nearly completely redo what I did while writing my README.md,
## I'll need to delete a bunch of the variables I've created
remove(subjIDs,X,y,featureNames,ExtractedXIndices,ExtractedFeatureNames)
remove(ProperFeatureNames,yLabels,yValsAsStrings,MyData)

## Read it back in; obviously this is not super-efficient,
## but that's only because we are submitting this all as one function
## instead of doing one part, leaving, coming back, and then continuing
## by reading from file
MyData <- read.table(FILENAME, stringsAsFactors=FALSE)

## Get stuff ready to do my sub-optimal iteration process
## If you did not read my README.md, I am iterating because
## I'm facing significant problems installing reshaping packages
## (and this dataset isn't so big that iterating will take forever)
ActivityLabels <- c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS','SITTING','STANDING','LAYING')
UniqueSubjectIDs <- unique(MyData$SubjectIDs)
SeqS <- c(); SeqA <- c()
Averages <- NULL

## begin iterating through all subjects and all activities
## subset MyData based on a condition (which is changing w each iteration)
## calculate averages of subset, store in single row
## append single row onto the end of the dataframe 'Averages'
for (S in UniqueSubjectIDs){
	for (A in ActivityLabels){
		## Record these into SeqS & SeqA
		SeqS <- c(SeqS,as.character(S)); SeqA <- c(SeqA,A)
	
		## subset data, prepare row to be added to Averages
		ConditionForRows = MyData$SubjectIDs==S & MyData$SubjectActivity==A
		SubsetData = MyData[ConditionForRows,2:80] #1+1:79+1 bc the FIRST col is subjIDs
	
		## it gets cranky if we don't tell it we have 1 row
		RowName <- paste(as.character(S),A,collapse='')
		AveragesRow <- data.frame(row.names=RowName) 

		## this INNER loop is to iterate through each given column of the SubsetData
		for (n in 1:79){
			AveragesRow[1,n] <- mean(SubsetData[,n])}
	
		## temp is ready to be made/added into Averages
		if (class(Averages)=="NULL"){
			Averages <- AveragesRow
		} else {
			Averages <- rbind(Averages,AveragesRow)} }}

## Going to re-introduce SeqS & SeqA into THIS table, since they are my SubjectIDs and SubjectActivity values
## Doing this by creating a temp dataframe, then cbinding it onto my Averages dataframe
Sequences <- data.frame(SubjectIDs=SeqS, SubjectActivity=SeqA,stringsAsFactors=FALSE)
Averages <- cbind(Sequences, data.frame(Averages,row.names=NULL))
remove(Sequences) #be careful!
	
## And finally, to write:
FeatureNames <- names(MyData)[2:80] #1+1:79+1 bc the FIRST col is subjIDs
ColNames <- c('SubjectIDs','SubjectActivity',FeatureNames)


FILENAME <- 'Averages.DN.txt'
## note that i do NOT have a if(fileExists) clause
## because I dont want to accidentally have my program NOT run while being graded
write.table(Averages,col.names=ColNames,file=FILENAME,row.name=FALSE)

}
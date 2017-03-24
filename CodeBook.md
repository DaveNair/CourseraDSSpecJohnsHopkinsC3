# Quick Word from Author

I wasn't sure how to organize my code book for this project. As is, I've broken it up into sections based on my processing pipeline.

In general, variables beginning with lower-case letters are *raw* inputs. This isn't to say that variables for inputs *can't* be capitalized, just that you should understand the difference between variables like "featureNames" and "FeatureNames".

Though this may sound a bit confusing, I usually delete my variables well before they end up becoming repeated. In any case, it shouldn't effect you too much for this project.

# Functions

I placed this section first so that I can reference these later, and because there are very few.

RenameFeature(FeatureString)
> * Class,Length(output): `character`, 1
> * Description: This function renames a given feature to become more descriptive. 
By "more descriptive", I have programmed it to take inputs like 'DomainAndObject-Measurement-Direction' or 'DomainAndObject-Measurement' and turn them into outputs like 'ObjectAndDirection-Measurement-Domain' or 'Object-Measurement-Domain', respectively.
It does this in a few steps, in this order:
> 1. Create a length=2 character vector named `String` which contains *everything **except** the first letter* of `FeatureString` as its first element and *then* the first-letter-of-`FeatureString` as its second element. 
The first element will be worked on further, while the second will function as a 'time-domain'/'frequency-domain' flag. 
> 2. Create a new character vector named `parts` which is the split of `String[[1]]` (from the 1st step) by the character '-' : `parts <- strsplit(String[[1]],split='-')`.
This is because the various features' names tend to be in the form 'Object-Measurement-SometimesAxis'. 
> 3. If `length(parts)` is 3, that means there is a directional component to this measurement. I personally would prefer the directional component substring to be next to the object's substring (so something like 'ObjectAndDirection-Measurement').
So if there's a directional component, reorder the substrings and create the string (character vector) that will describe the ObjectAndDirection: 
`outFeature <- paste(parts[c(1,3)],collapse='')`. 
If there is **no** directional component, just let `outFeature <- parts[1]`.
> 4. Search for which type of measurement ('mean' or 'std') in `parts[2]`; add that information as a string to the growing character vector `outFeature`, which will eventually by pasted together as one string (length=1 character vector).
> 5. Add the domain information, stored in `String[2]`, as the third and last element of `outFeature`. I chose to add this information as either 'TimeDomain' or 'FreqDomain'.
> 6. Lastly, return the elements of `outFeature`, pasted together by '-': `paste(outFeature,collapse='-')`.

# Inputs

ProgramAssignmentLocation
> Class,Length: `character`, 1
> Description: The path *into* the folder containing:
> > * activity_labels.txt
> > * features.txt
> > * features_info.txt
> > * README.txt
> > * 'test/' and 'train/' folders, containing:
> > > * subject_\*.txt
> > > * X_\*.txt
> > > * y_\*.txt
> > > * 'Inertial Signals/' **(not used)**
	
subjIDs
> Class: `data.frame`
> Description: The raw, combined input from `read.table()` from both subject_\*.txt files.
	
X
> Class: `data.frame`
> Description: The raw, combined input from `read.table()` from both X_\*.txt files. 

y
> Class: `data.frame`
> Description: The raw, combined input from `read.table()` from both y_\*.txt files.
 
featureNames
> Class: `character`
> Description: The raw input from the 2nd column of `read.table('features.txt')` **after** it's been converted via `as.character()`.

yLabels
> Class: `character`
> Description: Technically, this is **defined** as
`c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS','SITTING','STANDING','LAYING')`. 
That was only to avoid asking R to read an entire 6-line file into memory as a dataframe. 
This **could have** just as easily been the raw input from the 2nd column of `read.table('activity_labels.txt')`, after being converted via `as.character()`.

yValsAsStrings
> Class: `character`
> Description: This is simply all the `y$V1` values, rewritten as their corresponding activity label, using `yLabels`: 
`yValsAsStrings <- as.character(yLabels[as.integer(y$V1)])`

# Variables used in Processing

ExtractedXIndices
> Class: `integer`
> Description: A vector containing the **column indices** of `X` whose name contains either '-mean' or '-std'. Another way of thinking this is that every element of `names(X)[ExtractedXIndices]` should contain either '-mean' or '-std'. 
> 
> Defined as: `ExtractedXIndices <- grep('(-mean)|(-std)',featureNames)`

ExtractedFeatureNames
> Class: `character`
> Description: A vector of all the features whose names contain either '-mean' or '-std'.
> 
> Defined as: `ExtractedFeatureNames <- featureNames[ExtractedXIndices]`

Ans1
> Class: `data.frame`
> Description: This is an intermediate step that was requested in the program requirements. Since it contains **all** the features and not only 'mean' and 'std' measurements, it is not used any time other than fulfilling this requirement.

ProperFeatureNames
> Class: `character`
> Description: This is the resultant character vector once the function `RenameFeature()` has been used on all elements of `ExtractedFeatureNames` and *after* a few extra `gsub()` functions have been applied (specifically to unabbreviate 'Acc' and 'Mag').
Thus, these are my preferred names for the extracted features, and the names I'll be using for the remainder of the study.

# Stored/Post-Processing Data

MyData
> Class: `data.frame`
> Description: This variable refers to the combined dataframe with **only** 'mean' and 'std' features. 
This includes all SubjectIDs, Activities, and matching features (from `ExtractedFeatureNames`). 
This dataframe is used for the remainder of the assignment.
This dataframe's rows can be summarized as follows:
> 1. SubjectIDs
> 2-80. Descriptively Named Features (named via `ProperFeatureNames`)
> 81. SubjectActivity

UniqueSubjectIDs
> Class: `integer`
> Description: An integer vector which contains each unique subject ID.
This is used briefly when iterating through each possible subject for the final averaging.
 
ActivityLabels
> Class: `character`
> Description: Like `yLabels`, this is just used to iterate through each possible activity.
> 
> Defined as: `ActivityLabels <- c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS','SITTING','STANDING','LAYING')`

Averages
> Class: `dataframe`
> Description: My **final** result of averages for *each* mean/std measurement *per* subject *per* activity (where 'std' means standard deviation).

FeatureNames
> Class: `character`
> Description: The `names()` of the features within my main dataframe (indexes 2:80).
This variable should be equal to ProperFeatureNames.

> Defined as: `FeatureNames <- names(MyData)[2:80]`

# Temporary Data (usually for loops)

SeqS & SeqA
> Class: `character`
> Description: After years of using different programs, I tend to be pretty cautious whenever I'm iterating. These two are simply vectors containing *the order* that I iterated, *as* its iterating, ensuring no confusion.
These character vectors are then used to fill in the values for the SubjectIDs and SubjectActivity columns.

ConditionForRows
> Class: `logical`
> Description: This condition changes as we iterate through subjects and activities. It is used to subset `MyData` into only the elements that are applicable to a given subject for a given activity.
I write it as a separate variable so that it's easier to see the condition itself.

SubsetData
> Class: `dataframe`
> Description: This dataframe (only used within the averaging loop) contains all of the features and their values for a given subject and a given activity (i.e., for a single, given `ConditionForRow`).
> 
> Defined as: `SubsetData <- MyData[ConditionForRows,2:80]`

RowName
> Class: `character`
> Description: With the (shameful) way that I programmed my averaging section, there is a point where I need to create an empty, single-rowed matrix. 
Since `data.frame()` doesn't have a `nrows` parameter to set, I chose to set the `row.names` parameter to a single value, giving me 1 row. 
After making this decision, I decided to make each `RowName` unique (although still only temporary), just in case R had problems binding dataframes with identically-named rows.

AveragesRow
> Class: `dataframe`
> Description: Probably one of the more memory-wasteful steps of this entire process. This single-row dataframe is only used to iteratively append onto the bottom of my final dataframe, Averages.

Sequences
> Class: `dataframe`
> Description: Visually, I thought the simplest thing to prep my `Averages` dataframe for writing to file was to cbind my results (from the averaging iteration) to the sequences of subjects and activities that I recorded in `SeqS` and `SeqA`, respectively. 
Thus, `Sequences` is a dataframe whose only 2 columns are `SeqS` and `SeqA`.

> Defined as: `Sequences <- data.frame(SubjectIDs=SeqS, SubjectActivity=SeqA,stringsAsFactors=FALSE)`

ColNames
> Class: `character`
> Description: After binding the `Averages` and `Sequences` dataframes together (into `Averages` again), I decided to specify the column names for `Averages` using this variable. 
It also takes care of any reordering done after reading in`MyData` and creating `Averages` (specifically the movement of 'SubjectActivity' to the 2nd column instead of the last). 
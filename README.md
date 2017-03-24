# CourseraDSSpecJohnsHopkinsC3

## Notes I've Added Since Submitting

I now realize I could have put a much simpler title for this repo; my bad.

Also - for this assignment, I assumed each step led to the next, so my final table 
is a table full of averages for a *subset* of the initial dataset (only the means and standard devs).
Just in case anyone did their averages on the *entire* dataset.

# run_analysis.R

My file `run_analysis` runs the following, in order:
> 1. Creates function `RenameFeature(FeatureString)`, which converts:
> > 'tBodyAcc-mean()-X'  -->  'BodyAccX-Mean-TimeDomain'
> > 'fBodyAcc-mean()'  -->  'BodyAcc-Mean-FreqDomain'

> 2. Reads and combines testing and training sets:
> > order: subjects, X, y
> > order: test, train  (ex: `y <- rbind(y,read.table('train/y_train.txt'))`)

> 3. Extracts Mean or Standard Deviation Features
> > **Keeps** features with '-meanFreq()', noting that they all begin with 'f'
and should thus be classified as a Mean in the frequency domain (FreqDomain)

> 4. Rename Extracted Features, using `RenameFeature()` and `gsub`
> > Features now look like: 'BodyAccelerationX-Mean-TimeDomain'

> 5. Rename Activities, using `y`

> 6. Combine Subjects, Extracted Features, and Activities into MyData

> 7. Save and Reload MyData from file
> > *this was out of habit since we have made a subset that we'll be using
for our final outcome*

> 8. Initialize Averages (`data.frame`)

> 9. Loop through all Unique Subject IDs and Activity Labels (nested loop):
> > 1. Record which Subject ID and Activity we're currently averaging (store in `Sequences`)
> > 2. Subset MyData for only the values for the subject and activity we're currently looking at
> > 3. Create temporary single-row dataframe
> > 4. Iterate through subset's columns, averaging and saving result in temp dataframe
> > 5. Add temp dataframe to `Averages` dataframe

> 10. Combine `Sequences` with `Averages`

> 11. Create Column Names and Save, using `write.table(table,file,row.name=FALSE)`

# AI for Actionable Warning Identification

## Details of directories
* `classes`: directory to hold class files
* `data`: directory to hold files for the input & output for this project
* `features and experimental results`: the values of features of the 40 project revisions used in the paper, as well as some experimental results
* `lib`: the JAR files the program requires
* `log`: directory to hold log files output by the tool
* `resources`: directory to hold files required for running the tool
* `src`: the source code

## Instructions on running this tool

### Preface
This SAWI project (the "tool") can be used to extract static analysis warning features from a Java project (the "target"). It is recommended to run this tool in the following order:
1. Preparation: Prepare target project, required files and SQL database
2. Parse Commit Data: Parse and load into database the git logs of target project
3. Feature Extraction: Obtain SA warning feature values for target project
4. Feature Selection: Perform feature selection using greedy backward elimination algorithm
5. Feature Evaluation: Evaluate performance of ML model trained on selected features

### 1. Preparation
* Clone the target project using `git clone <target project repository>`.
* Generate the logs of the project's commit info (log.txt) and commit content (logCode.txt), using the commands below.
```
TZ=UTC git log --date=local --name-status --no-renames --no-merges --pretty="format:GitCommitStart: %H |#& %an |#& %ae |#& %ad |#& %at |#& %s |#& %b %n---------------filePathSplit---------------" > log.txt
TZ=UTC git log -p --date=local --abbrev=7 --no-renames --no-merges --pretty="format:GitDiffStart: %H | %ad" > logCode.txt
```
* Pick a point in time you wish to analyze the target project. In the example code below, the point in time selected is "2021-04-01". The `CURRENT_COMMIT_TIME` variable in YAML config file should be set to this selected point in time. Obtain the commit hash corresponding to the most recent commit before this selected point in time, using the command below.
```
TZ=UTC git log --date=iso-local --no-renames --no-merges -n 1 --before "2021-04-01"
```
* Perform `git checkout <commit hash obtained from the previous command>` to get the source code of this commit.
* The `REMAINING_REVISIONS` variable in YAML config file should be set to the number of remaining revisions, obtained using the command below.
```
TZ=UTC git rev-list HEAD --count --no-renames --no-merges
```
* Set appropriate values for variables in `data/config.yml`.
* Build the project (or otherwise compile `*.java` source files that you wish to analyze into `*.class` class files). Build the target project and the old revision project.
* Run SpotBugs on the root directory of the target project to generate an XML bug report, saving it as `spotbugs.xml`.
* Ensure the `data/` directory has these 4 files: `config.yml`, `log.txt`, `logCode.txt`, and `spotbugs.xml`.
* Set up the SQL database using the `resources/create.sql` file.

### 2 & 3. Pipeline: Parse Commit Data + Feature Extraction
* Simply execute `pipeline.bat` (for Windows), to obtain the tool's output in the `data/tool-output/` directory
```
pipeline.bat
```

# Supplementary Commands

### 2. Parse Commit Data
* Compile and run the LogParser program to parse the commit data of the target project and load into SQL database.
```
javac -d classes -cp "src;lib/*" src/com/git/LogParser.java
java -cp "classes;lib/*" com.git.LogParser > log/output-parser.txt
```

### 3. Feature Extraction
* Compile and run the OverallFeatureExtraction program to extract SA warning feature values.
```
javac -d classes -cp "src;lib/*" src/com/featureExtractionRefined/OverallFeatureExtraction.java
java -cp "classes;lib/*" com.featureExtractionRefined.OverallFeatureExtraction > log/output-extract.txt
```
* Merge (and refine) feature values into the consolidated `totalFeatures.csv`.
```
javac -d classes -cp "src;lib/*" src/com/warningClassification/FeatureRefinement.java
java -cp "classes;lib/*" com.warningClassification.FeatureRefinement > log/output-refine.txt
```

### 4. Feature Selection
* Perform feature selection using greedy backward elimination algorithm, to produce `featureRank.csv`
```
javac -d classes -cp "src;lib/*" src/com/warningClassification/FeatureSelection.java
java -cp "classes;lib/*" com.warningClassification.FeatureSelection > log/output-selection.txt
```

### 5. Feature Evaluation
* Extract values for selected features into `newTotalFeatures.csv`, then evaluate performance of ML model trained on selected features
```
javac -d classes -cp "src;lib/*" src/com/warningClassification/FeatureEvaluation.java
java -cp "classes;lib/*" com.warningClassification.FeatureEvaluation > log/output-evaluation.txt
```

### 99. Extra
* Obtain values for earliest commit time and maximum revision number.
```
TZ=UTC git log --date=iso-local --reverse --no-renames --no-merges
TZ=UTC git rev-list HEAD --count --no-renames --no-merges
```
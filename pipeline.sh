#  Parse
javac -encoding "ISO-2022-CN" -d classes -cp "src:lib/*" src/com/git/LogParser.java
java -cp "classes:lib/*" com.git.LogParser > log/output-parser.txt

# Extract
javac -encoding "ISO-2022-CN" -d classes -cp "src:lib/*" src/com/featureExtractionRefined/OverallFeatureExtraction.java
java -cp "classes:lib/*" com.featureExtractionRefined.OverallFeatureExtraction > log/output-extract.txt

# Refine
javac -encoding "ISO-2022-CN" -d classes -cp "src:lib/*" src/com/warningClassification/FeatureRefinement.java
java -cp "classes:lib/*" com.warningClassification.FeatureRefinement > log/output-refine.txt

# About REMtoVRT
The R script REMtoVRT.R converts the CORA-XML files of the Reference Corpus of Middle High German (REM, available at https://www.linguistics.rub.de/rem/access/index.html) to VRT format. It is old and very slow (I didn't know how to do it better at the time...) but it works. 

# How does it work?
- Create a folder "REMtoVRT" in which you place 
  - the REMtoVRT.R file 
  as well as the following folders:
  - the unzipped folder "rem-coraxml-20161222" with the CORA-XML data (.zip and .tar.gz files available via the link above)
  - an empty folder "rem-vrt"
- open the REMtoVRT.R file and run it. (Make sure that the REMtoVRT folder is your working directory, which you can check using getwd(); you can change the working directory with setwd().) It will take several hours to compute.
- Then you can import the files into CWB using the terminal commands in cwb-encode.txt.

# How does the script deal with multi-layer annotation?
The REM features multi-layer annotation, and in some cases, the annotation spans differ between different layers (e.g. zewâre 'indeed' is lemmatized as two words: ze and wâre). The script takes tok_dipl - the annotation that represents the text of the original manuscript - as the reference level. If one token at the tok_dipl level (which ends up as the obligatory "word" column in the VRT files) corresponds to multiple tokens at another level, the multiple tokens at another level will be pasted together with "&_&_" als separator. 

# Caveats
- The script will probably produce less than ideal results on Windows (or other non-UTF8 locales).

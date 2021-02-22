# REDCapMatchKey

SAS script to merge other datasets with REDCap Project Data - Epidemiology | COVID-19 

# REDCap Epi Dataset SAS Code Script to Merge on Engineered Patient ID Key Set

This code script will combine EHR from REDCap, NEDDS, I-CARE, and so forth that are used by epidemoligists tasked with data preprocessing. These databases currently only make their data available in Excel formats (CSV, XLSX). The data fields have inherrent erroneous values and quantify as **big data** due to their *volume, variety* and *veracity*. This code script will create 13 unique variations of a given patient's first and last name and date of birth, while accounting for hyphens and other atypical characters that inhibit joins without duplication or omission.

Demo patient identification variations engineered:
```
Demo patient Name: Anikan Skywalker
Date of Birth (DOB): 05/25/77

**CORRECT FULL LAST + FIRST TRUNCATE 6 + DOB**
KEY01 - SKYWALKERANAKIN19770525

**DROP 2ND LETTER OF LAST NAME TRUNCATE 8, DROP 1ST LETTER OF FIRST NAME TRUNCATE 8, FULL DOB**
KEY02 - SYWALKERANAKIN19770525

**DROP 1ST LETTER OF LAST NAME TRUNCATE 6, FIRST NAME TRUNCATE 6, FULL DOB**
KEY03 - KYWALKANAKIN19770525

**FULL LAST NAME, FIRST NAME TRUNCATE 3, FULL DOB**
KEY04 - SKYWALKERANA19770525

**DROP 1ST TWO TRUNCATE 3 LAST NAME, TRUNCATE 3 FIRST NAME, FULL DOB**
KEY05 - YWAANA19770525

**TRUNCATE 4 LAST NAME, TRUNCATE 4 FIRST NAME, FULL DOB**
KEY06 - SKYWANAK19770525

**DROP 2ND LETTER LAST NAME TRUNCATE 8, DROP 1ST TRUNCATE 8, DOB DROP LAST TWO DIGITS ('77' OF '1977')**
KEY07 - SYWALKERNAKIN190525

**DROP 2ND LETTER LAST NAME TRUNCATE 8, DROP 1ST TRUNCATE 8, DOB DROP FIRST TWO YEAR DIGITS ('19' OF '1977')**
KEY08 - SYWALKERNAKIN770525

**LAST NAME TRUNCATE 5, FIRST NAME TRUNCATE 4, DOB DROP LAST TWO DIGITS ('77' OF '1977')**
KEY09 - SKYWAANAK190525

**SWITCH LAST WITH FIRST, FIRST DROP 2ND LETTER TRUNCATE 8, DROP 1ST LETTER TRUNCATE 8, DOB DROP LAST TWO DIGITS ('77' OF '1977')**
KEY10 - AAKINKYWALKER190525

**SWITCH LAST WITH FIRST, FIRST DROP 2ND LETTER TRUNCATE 8, DROP 1ST LETTER TRUNCATE 8, DOB DROP FIRST TWO YEAR DIGITS ('19' OF '1977')**
KEY11 - AAKINKYWALKER770525

**SWITCH LAST WITH FIRST, FIRST NAME TRUNCATE 5, LAST NAME TRUNCATE 4, DOB DROP LAST TWO DIGITS ('77' OF '1977')**
KEY12 - ANAKISKYW190525

**SWITCH LAST WITH FIRST, FIRST NAME TRUNCATE 5, LAST NAME TRUNCATE 4, DOB DROP FIRST TWO YEAR DIGITS ('19' OF '1977')**
KEY13 - ANAKISKYW770525
```

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project.

### Prerequisites

What things you need to install, e.g. *the* software and how to install them

```
SAS Basic Edition *or* SAS University, including dependencies (VirtualBox, SAS Studio) and a supported browser version (see list below).

SAS University Edition download and installation link:
https://www.sas.com/en_us/software/university-edition/download-software.html

Supported Browsers: 
- Microsoft Internet Explorer 11 
- Mozilla Firefox 21+
- Google Chrome 27+
- Apple Safari 6.0+ (on Apple OS X)
```

### Installing

A step by step series of examples that tell you how to get a development env running

Save a copy of the SAS code script (REDCapMatchKey_v1.SAS) to your SAS working directory (e.g. "myfolders)
```
/Users/Your/Path/Here/SASUniversityEdition/myfolders
```

Opening a SAS University Edition instance using VirtualBox and SAS Studio
```
In VirtualBox, select Machine > Start
Open your supported web browser and enter http://localhost:10080
Once the page is loaded, click Start SAS Studio
```

Note:
```
If you do not see the file listed in your working directory, refresh the server files and folders drop down menu
```

## Deployment

This code script can be run as a stand alone or can be incorporated into your own code script by completing the steps listed below. However,
you will need to make the appropriate changes as annotated below before doing either.

To include this code script in your own SAS code, add this code snippet to your sas code at the beginning of your script
```
%include '/Path/To/Your/Folder/Where/Code/Saved/REDCapEpiMatch_v1.sas';
```
*If* running within your **own code**, comment out the following lines in the code, except for MACRO Global Variable Definitons, define those
within your own script. Ensure all listed code lines have been addressed as annotated within the code comments.

Code Lines:
```
Line 85, lines 110-124, lines 133-134, lines 186-187, line 238, lines 276-312,and line 323 
```
Designed to merge REDCap Project data with NEDDS and other Epi specific datasets, listed fields (columns) values are the **minimum** needed to run, 
including label format, adjust to suit your needs/data, see list below:

REDCap Dataset Fields | Dataset To Be Matched To REDCap Fields:
```
Last_Name, First_Name, date_of_birth
```
## Built With

* [ATOM](https://atom.io) - Text editor used to create code
* [SAS](https://www.sas.com/en_us/home.html) - SAS University Edition used to test and debug code
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2) - Documentation framework used

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/danoAasland/REDCapMatchKey/Contributing.md) for details on code of conduct, and the process for submitting pull requests.

## Versioning

[SemVer](http://semver.org/) is used for versioning.
```
**Current**
Version: 1.1.0
Last update date: 22FEB2021
```

## Authors

* **Dano Aasland** - [REDCapEpiMatch](https://github.com/REDCapMatchKey)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

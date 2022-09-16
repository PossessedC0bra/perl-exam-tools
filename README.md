# Introduction to Perl for Programmers - Final Project

## Overview

## Usage

```shell
Usage:
  $ ./create_exam.pl <PATH_TO_MASTER_FILE>

Example:
  $ ./create_exam.pl _short_exam_master_file.txt
```

```shell
Usage:
  $ ./score_exams.pl <PATH_TO_MASTER_FILE> <EXAM_FILE_PATH_1> <EXAM_FILE_PATH_2> ...

Example (List of exam file paths):
  $ ./score_exams.pl _short_exam_master_file.txt Bar_Gru.txt Marz_Jupiter.txt response4.txt

Example (Globbing):
  $ ./score_exams.pl _short_exam_master_file.txt [^_]*.txt
```

## Implemented parts

### Main task (part 1a) - Randomization of questions

- Takes a single argument: <MASTER_FILE_PATH>
- Parses the master file
- Processes every questions answers as follows:
    - separates checkbox and text
    - randomizes the order of the answers
    - prints each answer with an empty checkbox
- writes the processed content into a file with name of the format YYYYMMDD-HHMMSS-<ORIGINAL_FILENAME>

### Main task (part 1b) - Scoring of student responses

- Takes two or more arguments in the following format: <MASTER_FILE_PATH> <EXAM_FILE_PATH_1> <EXAM_FILE_PATH_2> ...
  - **NOTE:** using globbing patterns for exam file paths is also supported
- Parses master and exam files
- Scores every exam file the following way:
    - loads checked answers
    - if there are more than 1 or no checked answers => score = 0
    - if there is exactly one checked answers compare it to the checked answer in the master file
        - matches => score = 1
        - otherwise => score = 0

### Extension (part 2)- Inexact matching of questions and answers

- Normalization of text:
  - converts whole text to lower-case
  - removes stopwords from text
  - trims string
  - replaces sequences of whitespace characters with a single space character (' ')
- Fuzzy matches texts using the Levenshtein-Damerau edit-distance
- Accepts matches only if the edit distance is no greater than 10% of the original texts length
- Stores "fuzzy mapping"
- Reports fuzzy matched questions and answers

### Extension (part 3) - Analyzing cohort performance and identifying below-expectation results

- Accumulates statistics over all exams for total and correct answers
- Calculates min, avg and max for every statistic
- Additionaly keeps a running count for every statistic
- Prints exam statistics
- Prints results below expectation according to the following criterias:
  1. No correct answers
  2. Bottom 25% of cohort
  3. Below average correct answers
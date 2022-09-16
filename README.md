# Introduction to Perl for Programmers - Final Project

## Overview

## Usage

```shell
$ ./create_exam.pl help
A command line utitlity for randomizing answers in a set of questions.

Usage
  $ ./create_exam.pl <PATH_TO_MASTER_EXAM_FILE>
Examples
  ./create_exam.pl _short_exam_master_file.txt
```

## Implemented parts

### Main task (part 1a)

- Takes a single argument: <MASTER_FILE_PATH>
- Parses the master file
- Processes every questions answers as follows:
    - separates checkbox and text
    - randomizes the order of the answers
    - prints each answer with an empty checkbox
- writes the processed content into a file with name of the format YYYYMMDD-HHMMSS-<ORIGINAL_FILENAME>

### Main task (part 1b)

- Takes two or more arguments in the following format: <MASTER_FILE_PATH> <EXAM_FILE_PATH_1> <EXAM_FILE_PATH_2>, ...
- Parses master and exam files
- Scores every exam file the following way:
    - loads checked answers
    - if there are more than 1 or no checked answers => score = 0
    - if there is exactly one checked answers compare it to the checked answer in the master file
        - matches => score = 1
        - otherwise => score = 0

### Extension (part 2)

- A

### Extension (part 3)

- A
#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental;

use Date::Util 'localtime_string_format';
use Exam::Grammar 'load_exam';
use IO::Util 'write_file';

use List::Util 'shuffle';
use File::Basename;

#####################################################################

my $NEWLINE               = "\n";
my $SEPARATOR             = '_' x 80 . $NEWLINE;
my $END_OF_EXAM_SEPARATOR = '=' x 80 . $NEWLINE;

#####################################################################

# check command line arguments
if ( @ARGV < 1 ) {
    print("usage: ./randomize_questions.pl <PATH_TO_MASTER_FILE>");
    exit(0);
}

# attempt to open master file for reading
my $master_file_path = $ARGV[0];

# extract the master files name from the given path
my $master_filename = basename($master_file_path);

# parse exam
my %exam_map = %{ load_exam($master_file_path) };

# store output files content into this scalar
my $output_file_content;

# 1st section is the header with information about the exam
$output_file_content .= $exam_map{HEADER} . $NEWLINE . $NEWLINE;

foreach my $question_ref ( @{ $exam_map{QUESTIONS} } ) {

    # add a section separator and a newline character
    $output_file_content .= $SEPARATOR;
    $output_file_content .= $NEWLINE;

    # write the question number and text
    $output_file_content .= "$question_ref->{NUMBER}. $question_ref->{TEXT}" . $NEWLINE;

    # add the answers in random order with an empty checkbox
    foreach my $answer_ref ( shuffle( @{ $question_ref->{ANSWERS} } ) ) {
        $output_file_content .= "\t[ ] $answer_ref->{TEXT}";
    }

    # separate from next section with two newlines
    $output_file_content .= $NEWLINE . $NEWLINE;
}

# add end of exam marker
$output_file_content .= $END_OF_EXAM_SEPARATOR;
$output_file_content .= '                                END OF EXAM';
$output_file_content .= $NEWLINE;
$output_file_content .= $END_OF_EXAM_SEPARATOR;

# current time as string in format YYYYMMDD-HHMMSS
my $current_time_string = localtime_string_format( "%04d%02d%02d-%02d%02d%02d", localtime() );
my $output_filename     = "$current_time_string-$master_filename";

write_file( $output_filename, $output_file_content );
#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental;

use lib ('./lib');

#####################################################################

# question -> {correct => $correct_answer, incorrect => @incorrect_answers}
our %question_to_answers;
our $question_count;

#####################################################################

# check command line arguments
if ( @ARGV < 2 ) {
    print(
        "usage: score_exams.pl <PATH_TO_MASTER_FILE> [<PATH_TO_SUBMISSIONS>]");
    exit(0);
}

#####################################################################
# START MASTER FILE PROCESSING
#####################################################################

# attempt to open master file for reading
my $master_file_name = $ARGV[0];
my $master_file_handle;
if ( !open( $master_file_handle, "<", $master_file_name ) ) {
    die "Failed to open $master_file_name";
}

# read all of the master files content
my $master_file_content = do {
    local $/ = undef;
    readline($master_file_handle);
};

# seperate master files content into sections (each delimited by a sequence of one or more -)
my @sections = $master_file_content =~ m{ .*? ^_+$ }gmxs;

# remove first element (header section) to have the array only contain question sections
shift @sections;

# create a mapping for each question to its correct and incorrect answers
for my $question_section (@sections) {
    my @question = $question_section =~ m {\d+\. (.*)}m;

    my @correct_answer    = $question_section =~ m {\[X\] (.*)};
    my @incorrect_answers = $question_section =~ m {\[ \] (.*)}g;

    # store incorrect and correct answers for the question
    $question_to_answers{ $question[0] } = {
        correct   => $correct_answer[0],
        incorrect => [@incorrect_answers]
    };
}

close($master_file_handle);

$question_count = keys %question_to_answers;

#####################################################################
# START EXAM FILES PROCESSING
#####################################################################

my $correct_answers = 0;
my $total_answers   = 0;

my $exam_file_name = $ARGV[1];
my $exam_file_handle;
if ( !open( $exam_file_handle, "<", $exam_file_name ) ) {
    die "Failed to open $exam_file_name";
}

# read all of the exam files content
my $exam_file_content = do {
    local $/ = undef;
    readline($exam_file_handle);
};

# seperate master files content into sections (each delimited by a sequence of one or more -)
@sections = $exam_file_content =~ m{ .*? ^_+$ }gmxs;

# remove first element (header section) to have the array only contain question sections
shift @sections;

for my $question_section (@sections) {
    # extract the question text
    my @question = $question_section =~ m {\d+\. (.*)}m;

    # get the checked answer
    my @checked_answers = $question_section =~ m {\[X\] (.*)}g;

    # no answer has been provided -> ignore this question
    if ( !@checked_answer ) {
        next;
    }

    
    if (   @checked_answers == 1
        && exists $question_to_answers{ $question[0] }
        && $question_to_answers{ $question[0] }->{correct} eq
        $checked_answers[0] )
    {
        $correct_answers++;
    }
    $total_answers++;
}

close($exam_file_handle);

say("$exam_file_name \t $correct_answers / $total_answers");
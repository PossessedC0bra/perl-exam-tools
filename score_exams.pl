#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use lib './lib';
use Exam::Parser 'parse_exam_file';

#####################################################################

# check command line arguments
if ( @ARGV < 2 ) {
    print('usage: score_exams.pl <PATH_TO_MASTER_FILE> [<PATH_TO_SUBMISSIONS>]');
    exit(0);
}

my $master_filename            = $ARGV[0];
my $master_file_map_ref        = parse_exam_file($master_filename);
my %master_question_answer_map = %{ $master_file_map_ref->{QUESTIONS} };

#####################################################################
# EXAM FILES PROCESSING
#####################################################################

my @results;

foreach my $exam_filename ( @ARGV[ 1 .. $#ARGV ] ) {
    my $exam_file_map_ref        = parse_exam_file($exam_filename);
    my %exam_question_answer_map = %{ $exam_file_map_ref->{QUESTIONS} };

    my %result = (
        FILENAME          => $exam_filename,
        TOTAL_ANSWERS     => 0,
        CORRECT_ANSWERS   => 0,
        MISSING_QUESTIONS => [],
        MISSING_ANSWERS   => {}
    );

    foreach my $question ( keys %master_question_answer_map ) {

        # question not found -> remember as missing and proceed
        if ( !exists $exam_question_answer_map{$question} ) {
            push( @{ $result{MISSING_QUESTIONS} }, $question );
            next;
        }

        # get the all checked answers
        my @checked_answers = @{ $exam_question_answer_map{$question}{CHECKED} };

        # no answer was provided -> ignore this question
        if ( !@checked_answers ) {
            next;
        }

        if ( @checked_answers == 1 && $master_question_answer_map{$question}{CHECKED}[0] eq $checked_answers[0] ) {
            $result{CORRECT_ANSWERS}++;
        }

        $result{TOTAL_ANSWERS}++;
    }

    push( @results, \%result );
}

#####################################################################
# RESULT PRINTING
#####################################################################

# print the score (correct- / total answers) for every file
foreach my $result_ref (@results) {

    # deference for better readability
    my %result = %{$result_ref};

    printf( "%-70.70s %02s / %02s\n", $result{FILENAME}, $result{CORRECT_ANSWERS}, $result{TOTAL_ANSWERS} );
}

# empty line for better readability
say('');

# print missing questions and answers for every file
foreach my $result_ref (@results) {

    # dereference for better readability
    my %result = %{$result_ref};

    # print nothing for complete files
    if ( !@{ $result{MISSING_QUESTIONS} } && !keys %{ $result{MISSING_ANSWERS} } ) {
        next;
    }

    say("$result{FILENAME}:");
    foreach my $missing_question ( @{ $result{MISSING_QUESTIONS} } ) {
        say("\tMissing question: $missing_question");
    }

    foreach my $missing_answers_map_ref ( keys %{ $result{MISSING_ANSWERS} } ) {

        # deference for better readability
        my %missing_answers_map = %{$missing_answers_map_ref};

        say("\tMissing answers for question: $missing_answers_map{QUESTION}");
        for my $missing_answer ( @{ $missing_answers_map{ANSWERS} } ) {
            say("\t\t$missing_answer");
        }
    }

    # print an empty line for better readability
    say('');
}
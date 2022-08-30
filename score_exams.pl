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

        # question not found -> remember as missing and move to the next one
        if ( !exists $exam_question_answer_map{$question} ) {
            push( @{ $result{MISSING_QUESTIONS} }, $question );
            next;
        }

        my @master_checked_answers = @{ $master_question_answer_map{$question}{CHECKED} };
        my @exam_checked_answers   = @{ $exam_question_answer_map{$question}{CHECKED} };

        # search for missing answers in exam file
        my @missing_answers;

        # collect all answers from master file
        my @master_answers = ( @master_checked_answers, @{ $master_question_answer_map{$question}{UNCHECKED} } );

        # collect all answers from exam file
        my @exam_answers =
          ( @exam_checked_answers, @{ $exam_question_answer_map{$question}{UNCHECKED} } );

        # build map of answers in exam file for quick lookups
        my %exam_answers_map = map( ( $_ => 1 ), @exam_answers );

        # check master answers against the answers in the exam file
        foreach my $master_answer (@master_answers) {
            if ( !exists $exam_answers_map{$master_answer} ) {
                push( @missing_answers, $master_answer );
            }
        }

        # only create a missing answers entry if there are some
        if (@missing_answers) {
            $result{MISSING_ANSWERS}{$question} = [@missing_answers];
        }

        # no answer was provided -> ignore this question
        if ( !@exam_checked_answers ) {
            next;
        }

        if ( @exam_checked_answers == 1 && $master_checked_answers[0] eq $exam_checked_answers[0] ) {
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

    foreach my $question ( keys %{ $result{MISSING_ANSWERS} } ) {

        # deference for better readability
        my @missing_answers = @{ $result{MISSING_ANSWERS}{$question} };

        # only print message if there are missing answers
        if ( !@missing_answers ) {
            next;
        }

        say("\tMissing answers for question: $question");
        for my $missing_answer (@missing_answers) {
            say("\t\t- $missing_answer");
        }
    }

    # print an empty line for better readability
    say('');
}
#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exam::ScoringUtil qw(build_question_answer_map fuzzy_search);

#####################################################################

sub resolve_exam_question ( $master_question, %exam_question_answer_map ) {

    # if the master question is found exactly in the exam file return it
    if ( exists $exam_question_answer_map{$master_question} ) {
        return $master_question;
    }

    # otherwise attempt to fuzzy match the master question against all exam questions
    return fuzzy_search( $master_question, keys %exam_question_answer_map );
}

sub resolve_exam_answer ( $master_answer, %exam_answer_map ) {

    # if the master answer is found exactly in the exam file return it
    if ( exists $exam_answer_map{$master_answer} ) {
        return $master_answer;
    }

    # otherwise attempt to fuzzy match the master answer against all exam question -> answers
    return fuzzy_search( $master_answer, keys %exam_answer_map );
}

#####################################################################

# check command line arguments
if ( @ARGV < 2 ) {
    print('usage: score_exams.pl <PATH_TO_MASTER_FILE> [<PATH_TO_SUBMISSIONS>]');
    exit(0);
}

my $master_file_path           = $ARGV[0];
my %master_question_answer_map = %{ build_question_answer_map($master_file_path) };

# store result for each file in this array
my @results;

# score each exam (arguments beyond the first) individually
foreach my $exam_file_path ( @ARGV[ 1 .. $#ARGV ] ) {
    my %result = (
        FILENAME                 => $exam_file_path,    # string
        TOTAL_ANSWERS            => 0,                  # int
        CORRECT_ANSWERS          => 0,                  # int
        MISSING_MASTER_QUESTIONS => {},                 # master_question => exam_question
        MISSING_MASTER_ANSWERS   => {},                 # master_question => {master_answer => exam_answer}
    );

    # build question and answer map for this exam
    my %exam_question_answer_map = %{ build_question_answer_map($exam_file_path) };

    # iterate over all questions in the master file
    foreach my $master_question ( keys %master_question_answer_map ) {

        my $exam_question = resolve_exam_question( $master_question, %exam_question_answer_map );

        # master question was not exactly found in exam file -> remember mapping
        if ( !$exam_question || $master_question ne $exam_question ) {
            $result{MISSING_MASTER_QUESTIONS}->{$master_question} = $exam_question;

            # move to the next master question if exam question was not resolved at all
            next if !$exam_question;
        }

        # remember checked answers for later lookup
        my @checked_master_answers = @{ $master_question_answer_map{$master_question}{CHECKED} };
        my @checked_exam_answers   = @{ $exam_question_answer_map{$exam_question}{CHECKED} };

        # collect all answers for comparing them against each other
        my @master_answers = ( @checked_master_answers, @{ $master_question_answer_map{$master_question}{UNCHECKED} } );
        my @exam_answers =
          ( @checked_exam_answers, @{ $exam_question_answer_map{$exam_question}{UNCHECKED} // [] } );

        # build map of answers in exam file for quick lookups
        my %exam_answers_map = map( ( $_ => 1 ), @exam_answers );

        # check master answers against the answers in the exam file
        foreach my $master_answer (@master_answers) {
            my $exam_answer = resolve_exam_answer( $master_answer, %exam_answers_map );
            if ( !$exam_answer || $master_answer ne $exam_answer ) {
                $result{MISSING_MASTER_ANSWERS}->{$master_question}{$master_answer} = $exam_answer;
            }
        }

        # no answer was provided in the exam -> ignore this question
        if ( !@checked_exam_answers ) {
            next;
        }

        if ( @checked_exam_answers == 1 && $checked_master_answers[0] eq $checked_exam_answers[0] ) {
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

    # format score in a fixed width format:
    #   70 characters for the file path
    #   1 whitespace
    #   2 characters number of correct answers
    #   1 whitespace
    #   /
    #   1 whitespace
    #   2 characters for total number of questions
    printf(
        "%-70.70s %02s / %02s\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );
}

# add an empty line for better readability
print("\n");

# print missing questions and answers for every file
foreach my $result_ref (@results) {

    # print nothing for complete files
    if ( !keys %{ $result_ref->{MISSING_MASTER_QUESTIONS} } && !keys %{ $result_ref->{MISSING_MASTER_ANSWERS} } ) {
        next;
    }

    say("$result_ref->{FILENAME}:");

    # firstly print all missing questions
    foreach my $missing_question ( keys %{ $result_ref->{MISSING_MASTER_QUESTIONS} } ) {
        say("\t- Missing question: '$missing_question'");
        if ( $result_ref->{MISSING_MASTER_QUESTIONS}{$missing_question} ) {
            say("\t  Used this instead: '$result_ref->{MISSING_MASTER_QUESTIONS}{$missing_question}'");
        }
    }

    # secondly print missing answers
    foreach my $question ( keys %{ $result_ref->{MISSING_MASTER_ANSWERS} } ) {

        # dereference for better readability
        my %missing_answers_map = %{ $result_ref->{MISSING_MASTER_ANSWERS}{$question} };

        # print question for easier "debugging"
        say("\t- Missing answers for: '$question'");
        for my $missing_answer ( keys %missing_answers_map ) {
            say("\t\t- '$missing_answer'");
            if ( $missing_answers_map{$missing_answer} ) {
                say("\t\t   Used this instead: '$missing_answers_map{$missing_answer}'");
            }
        }
    }

    # add an empty line for better readability
    print("\n");
}
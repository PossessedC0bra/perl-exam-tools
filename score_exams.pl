#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exam::Util qw(build_question_answer_map resolve_question_answer_key);

#####################################################################

# check command line arguments
if ( @ARGV < 2 ) {
    print('usage: score_exams.pl <PATH_TO_MASTER_FILE> [<PATH_TO_SUBMISSIONS>]');
    exit(0);
}

my $master_file_path           = $ARGV[0];
my %master_question_answer_map = %{ build_question_answer_map($master_file_path) };

my %statistics = (
    TOTAL => {
        MIN       => scalar keys %master_question_answer_map,
        MIN_COUNT => 0,
        AVG       => 0,
        MAX       => 0,
        MAX_COUNT => 0,
    },
    CORRECT => {
        MIN       => scalar keys %master_question_answer_map,
        MIN_COUNT => 0,
        AVG       => 0,
        MAX       => 0,
        MAX_COUNT => 0,
    }
);

# store result for each file in this array
my @results = ();

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

        my $exam_question = resolve_question_answer_key( $master_question, %exam_question_answer_map );

        # master question was found matched character for character in exam file (or not at all) -> remember mapping
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
            my $exam_answer = resolve_question_answer_key( $master_answer, %exam_answers_map );

            # exam answer could not be found character for character in exam file (or not at all) -> remember as missing
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

    # update statistics
    if ( $statistics{TOTAL}{MIN} > $result{TOTAL_ANSWERS} ) {
        $statistics{TOTAL}{MIN}       = $result{TOTAL_ANSWERS};
        $statistics{TOTAL}{MIN_COUNT} = 1;
    }
    elsif ( $statistics{TOTAL}{MIN} == $result{TOTAL_ANSWERS} ) {
        $statistics{TOTAL}{MIN_COUNT}++;
    }

    $statistics{TOTAL}{AVG} = ( $statistics{TOTAL}{AVG} * @results + $result{TOTAL_ANSWERS} ) / ( @results + 1 );

    if ( $statistics{TOTAL}{MAX} < $result{TOTAL_ANSWERS} ) {
        $statistics{TOTAL}{MAX}       = $result{TOTAL_ANSWERS};
        $statistics{TOTAL}{MAX_COUNT} = 1;
    }
    elsif ( $statistics{TOTAL}{MAX} == $result{TOTAL_ANSWERS} ) {
        $statistics{TOTAL}{MAX_COUNT}++;
    }

    if ( $statistics{CORRECT}{MIN} > $result{TOTAL_ANSWERS} ) {
        $statistics{CORRECT}{MIN}       = $result{CORRECT_ANSWERS};
        $statistics{CORRECT}{MIN_COUNT} = 1;
    }
    elsif ( $statistics{CORRECT}{MIN} == $result{CORRECT_ANSWERS} ) {
        $statistics{CORRECT}{MIN_COUNT}++;
    }

    $statistics{CORRECT}{AVG} = ( $statistics{CORRECT}{AVG} * @results + $result{CORRECT_ANSWERS} ) / ( @results + 1 );

    if ( $statistics{CORRECT}{MAX} < $result{CORRECT_ANSWERS} ) {
        $statistics{CORRECT}{MAX}       = $result{CORRECT_ANSWERS};
        $statistics{CORRECT}{MAX_COUNT} = 1;
    }
    elsif ( $statistics{CORRECT}{MAX} == $result{CORRECT_ANSWERS} ) {
        $statistics{CORRECT}{MAX_COUNT}++;
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

#####################################################################
# STATISTICS PRINTING
#####################################################################

print("\n");

say('STATISTICS');
say( '=' x 80 );

print("\n");

my $rounded_total_avg = sprintf( "%.0f", $statistics{TOTAL}{AVG} );
say("Average number of questions answered: $rounded_total_avg");
say("Minimum number of questions answered: $statistics{TOTAL}{MIN} ($statistics{TOTAL}{MIN_COUNT} students)");
say("Maximum number of questions answered: $statistics{TOTAL}{MAX} ($statistics{TOTAL}{MAX_COUNT} students)");

print("\n");

my $rounded_correct_avg = sprintf( "%.0f", $statistics{CORRECT}{AVG} );
say("Average number of correct answers: $rounded_correct_avg");
say("Minimum number of correct answers: $statistics{CORRECT}{MIN} ($statistics{CORRECT}{MIN_COUNT} students)");
say("Maximum number of correct answers: $statistics{CORRECT}{MAX} ($statistics{CORRECT}{MAX_COUNT} students)");

# sort by exam results by number of correctly answered questions
@results = sort { $a->{CORRECT_ANSWERS} <=> $b->{CORRECT_ANSWERS} } @results;

print("\n");
say('Results below expectation:');

my $results_processed = 0;
my $result_ref_index  = 0;
my $result_ref        = $results[$result_ref_index];
while ( $result_ref->{CORRECT_ANSWERS} == 0 ) {
    printf(
        "\t%-70.70s %02s / %02s (no correct answers)\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );

    $result_ref = $results[ ++$result_ref_index ];
}

my $bottom_25_percent = int( (@results) / 4 );
while ( $result_ref_index < $bottom_25_percent ) {
    printf(
        "\t%-70.70s %02s / %02s (bottom 25%% of cohort)\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );

    $result_ref = $results[ ++$result_ref_index ];
}

while ( $result_ref->{CORRECT_ANSWERS} < $statistics{CORRECT}{AVG} ) {
    printf(
        "\t%-70.70s %02s / %02s (below correct average)\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );

    $result_ref = $results[ ++$result_ref_index ];
}


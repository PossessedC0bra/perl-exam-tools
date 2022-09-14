package Exam::Scorer;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Text::FuzzyMatcher qw(fuzzy_match);
use Exam::Util qw(build_question_answer_map);

use Exporter 'import';
our @EXPORT = qw( score_exam );

#####################################################################

sub score_exam($exam_file_path %master_question_answer_map) {
    my %result = (
        FILENAME                 => $exam_file_path,    # string
        TOTAL_ANSWERS            => 0,                  # int
        CORRECT_ANSWERS          => 0,                  # int
        MISSING_MASTER_CONTENT   => {},                 # master_question => { QUESTION => exam_question, ANSWERS => { master_answer => exam_answer} }
    );

    # build question / answer map for exam
    my %exam_question_answer_map = %{ build_question_answer_map($exam_file_path) };

    # process all questions in the master file
    foreach my $master_question ( keys %master_question_answer_map ) {

        # attempt to resolve master question in exam 
        my $exam_question = resolve_exam_question( $master_question, %exam_question_answer_map );

        # master question was not matched character for character in exam file (or not at all) -> remember mapping
        if ( !$exam_question || $master_question ne $exam_question ) {
            $result{MISSING_MASTER_CONTENT}->{$master_question}{QUESTION} = $exam_question;

            # move to the next question if the current one was not found in the exam
            next if !$exam_question;
        }

        # find missing master answers
        find_missing_master_answers($master_question_answer_map{$master_question}, $exam_question_answer_map{$exam_question}, \%result );
        
        # dereference checked exam answers for readability
        my @checked_exam_answers   = @{ $exam_question_answer_map{$exam_question}{CHECKED} };

        # no answer was provided in the exam -> ignore this question
        if ( !@checked_exam_answers ) {
            next;
        }

        # dereference checked master answer for readability      
        my $checked_master_answer = @{ $master_question_answer_map{$master_question}{CHECKED} }[0];

        if ( @checked_exam_answers == 1 && $checked_exam_answers[0] eq $checked_master_answer ) {
            $result{CORRECT_ANSWERS}++;
        }

        $result{TOTAL_ANSWERS}++;
    }

    # print score for this exam
    print_exam_score(\%result);

    # update statistics
    update_global_statistics($statistics_ref, \%result);

    return \%result;
}

sub find_missing_master_answers($master_answer_map_ref, $exam_answer_map_ref, $result_ref) {

    # collect all answers for comparing them against each other
    my @master_answers = ( @{ master_answer_map_ref->{CHECKED} }, @{ $master_answer_map_ref->{UNCHECKED} } );
    my @exam_answers = ( @{ exam_answer_map_ref->{CHECKED} }, @{ $exam_answer_map_ref->{UNCHECKED} } );

    # build map of answers in exam file for quick lookups
    my %exam_answers_lookup_table = map( ( $_ => 1 ), @exam_answers );

    # check master answers against the answers in the exam file
    foreach my $master_answer (@master_answers) {
        my $exam_answer = resolve_exam_answer( $master_answer, %exam_answers_lookup_table );

        # exam answer could not be found character for character in exam file (or not at all) -> remember as missing
        if ( !$exam_answer || $master_answer ne $exam_answer ) {
            $result_ref->{MISSING_MASTER_CONTENT}{$master_question}{QUESTIONS}{$master_answer} = $exam_answer;
        }
    }
}

sub update_global_statistics($global_statistics_ref, $result_ref) {
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
}

#####################################################################
# Printing
#####################################################################

sub print_exam_score($result_ref) {

    # format score in a fixed width format:
    #   70 characters for the file path
    #   1 whitespace
    #   2 characters for number of correct answers
    #   1 whitespace
    #   1 '/' character
    #   1 whitespace
    #   2 characters for total number of questions
    printf(
        "%-70.70s %02s / %02s\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );
}

sub print_missing_questions_and_answers(@results) {

    # print missing questions and answers for every file
    foreach my $result_ref (@results) {
        
        # dereference for better readability
        %missing_content = %{ $result_ref->{MISSING_MASTER_CONTENT} };

        # print nothing for complete files
        if ( !keys %missing_content ) {
            next;
        }

        say("$result_ref->{FILENAME}:");

        # firstly print all missing questions
        foreach my $missing_question ( keys %missing_master_content_map ) {

            # dereference for better readability
            %missing_question_content = %{ $missing_content{$missing_question} };

            say("\t- Missing question: '$missing_question'");

            # master question could not be mapped at all -> move to the next missing questions content
            next if !$missing_question_content{$missing_question}{QUESTION};

            say("\t  Used this instead: '$missing_question_content{$missing_question}{QUESTION}'");

            # dereference for better readability
            my %missing_answer_content = %{ $missing_question_content{$question}{ANSWERS} };

            foreach my $missing_answer ( keys %missing_answer_content ) {
                say("\t\t- 'Missing answer: $missing_answer'");
                if ( $missing_answer_content{$missing_answer} ) {
                    say("\t\t   Used this instead: '$missing_answer_content{$missing_answer}'");
                }
            }
        }

        # add an empty line for better readability
        print("\n");
    }
}

#####################################################################
# Question and Answer resolving
#####################################################################

sub resolve_exam_question( $master_question, %exam_question_map ) {
    return resolve_question_answer_key($master_question, %exam_question_map);
}

sub resolve_exam_answer( $master_answer, %exam_answer_map ) {
    return resolve_question_answer_key($master_answer, %exam_answer_map);
}

sub resolve_question_answer_key ( $key, %question_answer_map ) {

    # if the master answer is found exactly in the exam file return it
    if ( exists $question_answer_map{$key} ) {
        return $key;
    }

    # otherwise attempt to fuzzy match the master answer against all exam question -> answers
    return fuzzy_match( $key, keys %question_answer_map );
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
package Exam::Scoring::Printer;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(print_exam_scores print_missing_content print_statistics);

use Math::Util qw(round);

#####################################################################

sub print_exam_scores (@exam_reports) {
    foreach my $exam_report_ref (@exam_reports) {
        print_exam_score($exam_report_ref);
    }
}

sub print_exam_score ($exam_report_ref) {

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
        $exam_report_ref->{FILENAME},
        $exam_report_ref->{CORRECT_ANSWERS},
        $exam_report_ref->{TOTAL_ANSWERS}
    );
}

sub print_missing_content (@exam_reports) {

    # print missing questions and answers for every file
    foreach my $exam_report_ref (@exam_reports) {

        my %exam_report = %{$exam_report_ref};

        # if there is no missing content print nothing and move on
        next if !exists $exam_report{MISSING_MASTER_CONTENT} || !keys %{ $exam_report{MISSING_MASTER_CONTENT} };

        say("$exam_report{FILENAME}:");

        # dereference for better readability
        my %missing_content = %{ $exam_report{MISSING_MASTER_CONTENT} };

        foreach my $missing_content_key ( keys %missing_content ) {

            my $missing_question         = $missing_content_key;
            my %missing_question_content = %{ $missing_content{$missing_question} };

            # the exam answer might not or only partially have been found in the exam file
            if ( exists $missing_question_content{QUESTION} ) {
                say("\t- Missing question:  '$missing_question'");

                # question could not be found in exam file at all -> move on to the next exam_report
                next if !$missing_question_content{QUESTION};

                # alternatively print the partially matched exam question
                say("\t  Used this instead: '$missing_question_content{QUESTION}'");
            }

            # some answers might not or only partially have been found in the exam file
            if ( exists $missing_question_content{ANSWERS} ) {

                # question was found 1:1 in exam file -> nothing has been printed so far -> print a nice header
                if ( !exists $missing_question_content{QUESTION} ) {
                    say("\t- Question has missing answers: '$missing_question'");
                }

                # some answers might not or only partially have been found in exam file
                foreach my $missing_answer ( keys %{ $missing_question_content{ANSWERS} } ) {
                    say("\t\t- Missing answer:    '$missing_answer'");
                    if ( $missing_question_content{ANSWERS}{$missing_answer} ) {
                        say("\t\t  Used this instead: '$missing_question_content{ANSWERS}{$missing_answer}'");
                    }
                }
            }
        }

        # add an empty line for better readability
        print("\n");
    }
}

sub print_statistics (%statistics) {

    # round average to an integer
    my $rounded_total_avg = round( $statistics{TOTAL}{AVG}{VALUE} );

    say("Average number of questions answered: $rounded_total_avg");
    say("Minimum number of questions answered: $statistics{TOTAL}{MIN}{VALUE} ($statistics{TOTAL}{MIN}{COUNT} students)"
    );
    say(
        "Maximum number of questions answered: $statistics{TOTAL}{MAX}{VALUE} ($statistics{TOTAL}{MAX}{COUNT} students)"
    );

    print("\n");

    # round average to an integer
    my $rounded_correct_avg = round( $statistics{CORRECT}{AVG}{VALUE} );
    say("Average number of correct answers: $rounded_correct_avg");
    say(
"Minimum number of correct answers: $statistics{CORRECT}{MIN}{ VALUE } ($statistics{CORRECT}{MIN}{COUNT} students)"
    );
    say(
"Maximum number of correct answers: $statistics{CORRECT}{MAX}{ VALUE } ($statistics{CORRECT}{MAX}{COUNT} students)"
    );
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
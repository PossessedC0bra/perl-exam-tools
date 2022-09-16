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

#####################################################################

=encoding utf8

=head1 NAME

Exam::Scoring::Printer - Printer used while scoring exams


=head1 VERSION

This document describes Exam::Scoring::Printer version 1.0.0


=head1 SYNOPSIS

    use Exam::Scoring::Printer;

    print_exam_scores(@reports)
    print_missing_content(@reports)
    print_statistics(%statistics)


=head1 DESCRIPTION

Module providing command line output used during exam scoring.

=head1 INTERFACE

=head2 print_exam_scores(@reports)

Prints an exam score for every report given. Displays the exams file name as well
as the ratio of correct answers vs total questions answered

=head2 print_missing_content(@reports)

Prints missing content for every report given. Prints missing content for every
question. That might include the question itself or some of its answers. If a 
suiteable replacement for the missing content was found using fuzzy text matching
a question is still reported as missing but with its replacement

=head2 print_statistics(%statistics)

Prints the statistics accumulated during the exam scoring. Includes statistics
like min, avg and max of correct and total answers.


=head1 AUTHOR

Yannick Koller  C<< <yannick.koller@students.fhnw.ch> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2022, Yannick Koller C<< <yannick.koller@students.fhnw.ch> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
ALL SUCH WARRANTIES ARE EXPLICITLY DISCLAIMED. THE ENTIRE RISK AS TO THE
QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE
PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR,
OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
FOR DAMAGES, INCLUDING ANY DIRECT, INDIRECT, GENERAL, SPECIAL, INCIDENTAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES, HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES, LOSS OF DATA OR DATA BEING RENDERED INACCURATE, OR LOSSES
SUSTAINED BY YOU OR THIRD PARTIES, OR A FAILURE OF THE SOFTWARE TO
OPERATE WITH ANY OTHER SOFTWARE) EVEN IF SUCH HOLDER OR OTHER PARTY HAS
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

package Exam::Scoring::Scorer;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(score_exam);

use Exam::Mapper              qw(build_question_answer_map);
use Exam::Scoring::Statistics qw(update_statistics);
use Text::FuzzyMatcher        qw(fuzzy_search);

#####################################################################

sub score_exam ( $exam_file_path, $master_question_answer_map_ref, $statistics_ref ) {

    # create report hash with information about the exam
    my %report = (
        FILENAME               => $exam_file_path,    # string
        TOTAL_ANSWERS          => 0,                  # int
        CORRECT_ANSWERS        => 0,                  # int
        MISSING_MASTER_CONTENT =>
          {}    # master_question => { QUESTION => exam_question, ANSWERS => { master_answer => exam_answer} }
    );

    # initialize question/answer maps for master and exam file
    my %master_question_answer_map = %{$master_question_answer_map_ref};
    my %exam_question_answer_map   = %{ build_question_answer_map($exam_file_path) };

    # process all questions in the master file
    foreach my $master_question ( keys %master_question_answer_map ) {

        # attempt to resolve master question in exam
        my $exam_question = resolve_exam_question( $master_question, %exam_question_answer_map );

        # master question was not matched character for character in exam file (or not at all) -> remember mapping
        if ( !$exam_question || $master_question ne $exam_question ) {
            $report{MISSING_MASTER_CONTENT}{$master_question}{QUESTION} = $exam_question;

            # move to the next question if the current one was not found in the exam
            next if !$exam_question;
        }

        # find missing master answers
        find_missing_master_answers(
            $master_question,
            $master_question_answer_map{$master_question},
            $exam_question_answer_map{$exam_question}, \%report
        );

        # dereference checked exam answers for readability
        my @checked_exam_answers = @{ $exam_question_answer_map{$exam_question}{CHECKED} };

        # no answer was provided in the exam -> ignore this question
        if ( !@checked_exam_answers ) {
            next;
        }

        if ( @checked_exam_answers == 1 ) {

            # dereference checked master answer for readability
            my $checked_master_answer = @{ $master_question_answer_map{$master_question}{CHECKED} }[0];
            my $checked_exam_answer   = $checked_exam_answers[0];

            # access hash content safely (with exists checks to avoid autovivification
            if (   exists $report{MISSING_MASTER_CONTENT}{$master_question}
                && exists $report{MISSING_MASTER_CONTENT}{$master_question}{ANSWERS}{$checked_master_answer} )
            {
                my $fuzzy_matched_exam_answer =
                  $report{MISSING_MASTER_CONTENT}{$master_question}{ANSWERS}{$checked_master_answer};

             # if the fuzzy matched exam answer equals to the checked master answer -> reverse the fuzzy matched mapping
                if ( $checked_exam_answer eq $fuzzy_matched_exam_answer ) {
                    $checked_exam_answer = $checked_master_answer;
                }
            }

            if ( $checked_master_answer eq $checked_exam_answer ) {
                $report{CORRECT_ANSWERS}++;
            }
        }

        $report{TOTAL_ANSWERS}++;
    }

    # update statistics by using data gather in report
    update_statistics( $statistics_ref, %report );

    return \%report;
}

#####################################################################
# Question and Answer resolving
#####################################################################

sub find_missing_master_answers ( $master_question, $master_answer_map_ref, $exam_answer_map_ref, $result_ref ) {

    # collect all answers for comparing them against each other
    my @master_answers = ( @{ $master_answer_map_ref->{CHECKED} }, @{ $master_answer_map_ref->{UNCHECKED} } );
    my @exam_answers   = ( @{ $exam_answer_map_ref->{CHECKED} },   @{ $exam_answer_map_ref->{UNCHECKED} } );

    # build lookup table for exam answers to speed up search
    my %exam_answers_lookup_table = map( ( $_ => 1 ), @exam_answers );

    # check master answers against the answers in the exam file
    foreach my $master_answer (@master_answers) {
        my $exam_answer = resolve_exam_answer( $master_answer, %exam_answers_lookup_table );

        # exam answer could not be found character for character in exam file (or not at all) -> remember as missing
        if ( !$exam_answer || $master_answer ne $exam_answer ) {
            $result_ref->{MISSING_MASTER_CONTENT}{$master_question}{ANSWERS}{$master_answer} = $exam_answer;
        }
    }

    # explicit return value to avoid implicit return value
    return undef;
}

sub resolve_exam_question ( $master_question, %exam_question_map ) {
    return resolve_question_answer_key( $master_question, %exam_question_map );
}

sub resolve_exam_answer ( $master_answer, %exam_answer_map ) {
    return resolve_question_answer_key( $master_answer, %exam_answer_map );
}

sub resolve_question_answer_key ( $key, %question_answer_map ) {

    # if the key is found character by character return it
    if ( exists $question_answer_map{$key} ) {
        return $key;
    }

    # otherwise attempt to fuzzy match the master answer against all exam question -> answers
    return fuzzy_search( $key, keys %question_answer_map );
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

Exam::Scoring::Scorer - Scores a given exam and finds missing content


=head1 VERSION

This document describes «MODULE NAME» version 1.0.0


=head1 SYNOPSIS

    use Exam::Scoring::Scorer;

    score_exam('foo.txt', \%master_question_answer_map, \%statistics);


=head1 DESCRIPTION

Module for scoring an exam. Scoring an exam includes some not so obvious parts
that are performed under the hood and returned in the report. That includes
inexact text matching for questions and answers as well as reporting of such
missing content. Finally the given statistics are immediately updated with the 
created report


=head1 INTERFACE

=head2  score_exam( $exam_file_path, $master_question_answer_map_ref, $statistics_ref )

Creates a report for the given file. Attempts to find every question and answer
found in the master question answer map in the exam files content. If content is
not found it is stored in the report and fuzzy text matching is used to attempt
to find text more loosely. If fuzzy matching is successful the fuzzy match is
used instead. Finally statistics are updated with the report that was generated.


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

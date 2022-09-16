#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exam::Mapper              qw(build_question_answer_map);
use Exam::Scoring::Scorer     qw(score_exam);
use Exam::Scoring::Printer    qw(print_exam_scores print_missing_content print_statistics);
use Exam::Scoring::Statistics qw(init_statistics);
use Math::Util                qw(round);

#####################################################################

sub print_separator ($title) {
    print("\n");
    say( '-' x 80 );
    say($title);
    print( '-' x 80 );
    print("\n\n");
}

#####################################################################

# check command line arguments
if ( @ARGV < 2 ) {
    print('usage: score_exams.pl <PATH_TO_MASTER_FILE> [<PATH_TO_SUBMISSIONS>]');
    exit(0);
}

# create global statistics object
my %exam_statistics = (
    TOTAL   => init_statistics(),
    CORRECT => init_statistics()
);

# parse master file and build q/a map
my $master_file_path           = $ARGV[0];
my %master_question_answer_map = %{ build_question_answer_map($master_file_path) };

# initinalize min value with number of questions in master file -> cannot exceed this value anyways
$exam_statistics{TOTAL}{MIN}{VALUE}   = scalar keys %master_question_answer_map;
$exam_statistics{CORRECT}{MIN}{VALUE} = scalar keys %master_question_answer_map;

# score each exam (arguments beyond the first) individually
my @reports = map( { score_exam( $_, \%master_question_answer_map, \%exam_statistics ) } @ARGV[ 1 .. $#ARGV ] );

#####################################################################
# RESULT PRINTING
#####################################################################

# print exam name and scores for every exam
print_separator('SCORES:');
print_exam_scores(@reports);

# print missing questions and answers for every file
print_separator('MISSING OR INEXACTLY MATCHED CONTENT:');
print_missing_content(@reports);

print_separator('STATISTICS:');
print_statistics(%exam_statistics);

#####################################################################
# RESULTS BELOW EXPECATION
#####################################################################

# sort by exam reports by number of correctly answered questions
@reports = sort { $a->{CORRECT_ANSWERS} <=> $b->{CORRECT_ANSWERS} } @reports;

print("\n");
say('Results below expectation:');

my $results_processed = 0;
my $result_ref_index  = 0;
my $result_ref        = $reports[$result_ref_index];
while ( $result_ref->{CORRECT_ANSWERS} == 0 ) {
    printf(
        "\t%-70.70s %02s / %02s (no correct answers)\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );

    $result_ref = $reports[ ++$result_ref_index ];
}

my $bottom_25_percent = round( (@reports) / 4 );
while ( $result_ref_index < $bottom_25_percent ) {
    printf(
        "\t%-70.70s %02s / %02s (bottom 25%% of cohort)\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );

    $result_ref = $reports[ ++$result_ref_index ];
}

while ( $result_ref->{CORRECT_ANSWERS} < $exam_statistics{CORRECT}{AVG}{VALUE} ) {
    printf(
        "\t%-70.70s %02s / %02s (below correct average)\n",
        $result_ref->{FILENAME},
        $result_ref->{CORRECT_ANSWERS},
        $result_ref->{TOTAL_ANSWERS}
    );

    $result_ref = $reports[ ++$result_ref_index ];
}

#####################################################################

=encoding utf8

=head1 NAME

score_exams - Scores the list of exams and reports missing content as well as statistics

=head1 VERSION

This documentation refers to score_exam version 1.0.0

=head1 USAGE

    score_exams.pl <PATH_TO_MASTER_FILE> <PATH_TO_SUBMISSION_1> <PATH_TO_SUBMISSION_2> ...
    score_exams.pl <PATH_TO_MASTER_FILE> <PATH_TO_EXAM_FILES_GLOBBING_PATTERN>


=head1 REQUIRED ARGUMENTS

=head2 PATH_TO_MASTER_FILE

The path to the file containing the questions and correct answers

=head2 PATH_TO_SUBMISSION_<...>

Every argument beyond the first is interpreted as a path to an exam submission.
At least one path has to be specified, otherwise no scoring would be performed.

NOTE: this parameter might also be a globbing pattern.


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

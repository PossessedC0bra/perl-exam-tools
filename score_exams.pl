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
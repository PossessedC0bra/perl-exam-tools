#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
plan tests => 1;

use Exam::Grammar qw(load_exam);

# grab expected question answer map
my $expected_question_answer_map = do { './t/test_data/Grammar.pl' };

# calculate actual question answer map
my $actual_question_answer_map = load_exam('./test_data/EXAM_MASTER_FILE.txt');

# deep compare expected and actual value
is_deeply( $expected_question_answer_map, $actual_question_answer_map, 'Question answer map' );

done_testing();
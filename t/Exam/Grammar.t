#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
plan tests => 1;

use Exam::Grammar qw(load_exam);

# load expected exam after parsing
my $expected_parsed_exam = do { './t/test_data/Grammar.pl' };

# parse exam
my $actual_parsed_exam = load_exam('./t/test_data/EXAM_MASTER_FILE.txt');

# deep compare expected and actual value
is_deeply( $expected_parsed_exam, $actual_parsed_exam, 'Parsed exam' );

done_testing();
package Exam::Statistics::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';


use Exporter 'import';
our @EXPORT = qw();

#####################################################################

sub get_empty_exam_statistics_hash () {
    return (
        MIN       => 0,
        MIN_COUNT => 0,
        AVG       => 0,
        MAX       => 0,
        MAX_COUNT => 0,
    );
}

sub print_all_exam_statistics () {
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
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
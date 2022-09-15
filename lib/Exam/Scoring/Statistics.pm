package Exam::Scoring::Statistics;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(init_statistics update_statistics print_statistics);

#####################################################################

sub init_statistics () {
    return {
        MIN => init_metric(),
        AVG => init_metric(),
        MAX => init_metric()
    };
}

sub init_metric () {
    return {
        VALUE => 0,
        COUNT => 0
    };
}

#####################################################################

sub update_statistics ( $statistics_ref, %exam_report ) {

    # dereference for better readability
    my %statistics = %$statistics_ref;

    # update total number of questions answered statistics
    update_min_statistic( $statistics{TOTAL}{MIN}, $exam_report{TOTAL_ANSWERS} );
    update_avg_statistic( $statistics{TOTAL}{AVG}, $exam_report{TOTAL_ANSWERS} );
    update_max_statistic( $statistics{TOTAL}{MAX}, $exam_report{TOTAL_ANSWERS} );

    # update correct number of questions answered statistics
    update_min_statistic( $statistics{CORRECT}{MIN}, $exam_report{CORRECT_ANSWERS} );
    update_avg_statistic( $statistics{CORRECT}{AVG}, $exam_report{CORRECT_ANSWERS} );
    update_max_statistic( $statistics{CORRECT}{MAX}, $exam_report{CORRECT_ANSWERS} );
}

sub update_min_statistic ( $min_statistic_ref, $value ) {

    # if the minimal value is larger than the given value update the minimimal value and reset the count
    if ( $min_statistic_ref->{VALUE} > $value ) {
        $min_statistic_ref->{VALUE} = $value;
        $min_statistic_ref->{COUNT} = 0;
    }

    # increment count if the given value is the same as the minimal value
    if ( $min_statistic_ref->{VALUE} == $value ) {
        $min_statistic_ref->{COUNT}++;
    }

}

sub update_avg_statistic ( $avg_statistic_ref, $value ) {

    # aliases for values in avg statistic
    my $current_avg       = $avg_statistic_ref->{VALUE};
    my $current_avg_count = $avg_statistic_ref->{COUNT};

    # calculate new avg -> (calculate old total + new value) / number of values averaged over
    $avg_statistic_ref->{VALUE} = ( ( $current_avg * $current_avg_count ) + $value ) / ( $current_avg_count + 1 );
    $avg_statistic_ref->{COUNT}++;
}

sub update_max_statistic ( $max_statistic_ref, $value ) {

    # if the maximum value is smaller than the given value update the maximum value and reset the count
    if ( $max_statistic_ref->{VALUE} < $value ) {
        $max_statistic_ref->{VALUE} = $value;
        $max_statistic_ref->{COUNT} = 0;
    }

    # increment count if the given value is the same as the minimal value
    if ( $max_statistic_ref->{VALUE} == $value ) {
        $max_statistic_ref->{COUNT}++;
    }
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
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

#####################################################################

=encoding utf8

=head1 NAME

Exam::Scoring::Statistics - Statistics accumulated during exam scoring


=head1 VERSION

This document describes «MODULE NAME» version 1.0.0


=head1 SYNOPSIS

    use Exam::Scoring::Statistics;

    %min_avg_max_statistics = init_statistics();

    update_statistics(\%min_avg_max_statistics, <EXAM_REPORT>);


=head1 DESCRIPTION

Module providing useful functions for initializing and updating statistics
accumulated while scoring exams.


=head1 INTERFACE

=head2 init_statistics()

Returns an empty statistics hash with metrics for min, avg and max values.
All of those metrics store a value as well as a count variable. The value
represents the metrics actual value and the count is used for keeping count of
how many times the same value was encoutered or how often the value was updated.


=head2 update_staistics($statistics_ref, %exam_report)

Updates the given statistics with the values from an exam report. Min, avg and
max for correct and total number of answers are updated.
s

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

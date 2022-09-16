#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental;

use Date::Util 'localtime_string_format';
use Exam::Grammar 'load_exam';
use IO::Util 'write_file';

use List::Util 'shuffle';
use File::Basename;

#####################################################################

my $NEWLINE               = "\n";
my $SEPARATOR             = '_' x 80 . $NEWLINE;
my $END_OF_EXAM_SEPARATOR = '=' x 80 . $NEWLINE;

#####################################################################

# check command line arguments
if ( @ARGV < 1 ) {
    print("usage: ./randomize_questions.pl <PATH_TO_MASTER_FILE>");
    exit(0);
}

# attempt to open master file for reading
my $master_file_path = $ARGV[0];

# extract the master files name from the given path
my $master_filename = basename($master_file_path);

# parse exam
my %exam_map = %{ load_exam($master_file_path) };

# store output files content into this scalar
my $output_file_content;

# 1st section is the header with information about the exam
$output_file_content .= $exam_map{HEADER} . $NEWLINE . $NEWLINE;

foreach my $question_ref ( @{ $exam_map{QUESTIONS} } ) {

    # add a section separator and a newline character
    $output_file_content .= $SEPARATOR;
    $output_file_content .= $NEWLINE;

    # write the question number and text
    $output_file_content .= "$question_ref->{NUMBER}. $question_ref->{TEXT}" . $NEWLINE;

    # add the answers in random order with an empty checkbox
    foreach my $answer_ref ( shuffle( @{ $question_ref->{ANSWERS} } ) ) {
        $output_file_content .= "\t[ ] $answer_ref->{TEXT}";
    }

    # separate from next section with two newlines
    $output_file_content .= $NEWLINE . $NEWLINE;
}

# add end of exam marker
$output_file_content .= $END_OF_EXAM_SEPARATOR;
$output_file_content .= '                                END OF EXAM';
$output_file_content .= $NEWLINE;
$output_file_content .= $END_OF_EXAM_SEPARATOR;

# current time as string in format YYYYMMDD-HHMMSS
my $current_time_string = localtime_string_format( "%04d%02d%02d-%02d%02d%02d", localtime() );
my $output_filename     = "$current_time_string-$master_filename";

write_file( $output_filename, $output_file_content );

#####################################################################

=encoding utf8

=head1 NAME

randomize_questions - Creates a new exam with randomized answers

=head1 VERSION

This documentation refers to score_exam version 1.0.0

=head1 USAGE

    randomize_questions.pl <PATH_TO_MASTER_FILE>


=head1 REQUIRED ARGUMENTS

=head2 PATH_TO_MASTER_FILE

The path to the master file containing all questions and its correct answer.


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

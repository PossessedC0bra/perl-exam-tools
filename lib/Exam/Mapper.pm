package Exam::Mapper;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(build_question_answer_map);

use Exam::Grammar    qw(load_exam);
use Text::Normalizer qw(normalize_whitespace);

#####################################################################

my $CHECKED_CHECKBOX_REGEX = qr {\[ [xX]+ \]}x;

#####################################################################

sub build_question_answer_map ($file_path) {
    my $exam_content_ref = load_exam($file_path);

    my %question_answer_map;

    foreach my $question_ref ( @{ $exam_content_ref->{QUESTIONS} } ) {
        my @checked_answers   = ();
        my @unchecked_answers = ();

        foreach my $answer_ref ( @{ $question_ref->{ANSWERS} } ) {
            if ( $answer_ref->{CHECKBOX} =~ $CHECKED_CHECKBOX_REGEX ) {
                push( @checked_answers, normalize_whitespace( $answer_ref->{TEXT} ) );
            }
            else {
                push( @unchecked_answers, normalize_whitespace( $answer_ref->{TEXT} ) );
            }
        }

        $question_answer_map{ normalize_whitespace( $question_ref->{TEXT} ) } = {
            CHECKED   => [@checked_answers],
            UNCHECKED => [@unchecked_answers]
        };
    }

    return \%question_answer_map;
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

Exam::Mapper - Maps a given files content into a questio => answer lookup table


=head1 VERSION

This document describes Exam::Mapper version 1.0.0


=head1 SYNOPSIS

    use Exam::Mapper;

    %q_a_map = build_question_answer_map('foo.txt');


=head1 DESCRIPTION

This module maps a given files content into a question - answer lookup table 
allowing for easy querying of questions and their respective answers. 

=head1 INTERFACE

=head1 build_question_answer_map($file_path)

Loads the file at the given path and parses its content. Returns the parsed 
content in the format of a question - answer lookup table for easy querying
and fast accesses. The returned hash is of the following structure

{
    string => {
        CHECKED => [string],
        UNCHECKED => [string]
    }
}

where the keys of the hash are a question and the contents of the CHECKED and
UNCHECKED arrays are the answers


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

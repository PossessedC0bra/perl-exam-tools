package Text::Normalizer;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(normalize_whitespace remove_stopwords);

use Text::Stopwords 'get_stopwords';

#####################################################################

my $MULTIPLE_WHITESPACE_REGEX = qr { \s+ }x;

my $STOPWORD_REGEX = qr {\b (?: @{[ join('|', get_stopwords()) ]} ) \b}x;

#####################################################################

sub normalize_whitespace ($text) {

    # replace sequences of whitespaces with a single space (' ') character
    $text =~ s { $MULTIPLE_WHITESPACE_REGEX } { }gx;

    # remove whitespace at start
    $text =~ s { ^ $MULTIPLE_WHITESPACE_REGEX } {}gx;

    # remove whitespace at end
    $text =~ s { $MULTIPLE_WHITESPACE_REGEX $ } {}gx;

    return $text;
}

sub remove_stopwords ($text) {

    # substitute all stopwords with no replacement
    $text =~ s { $STOPWORD_REGEX } {}gx;

    return $text;
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

Text::Normalizer - Normalizes text using different techniques


=head1 VERSION

This document describes Text::Normalizer version 1.0.0


=head1 SYNOPSIS

    use Text::Normalizer;

    $text = "   unnormalized\n text with    very weird whitespacing     ";

    normalize($text);
    # returns 'unnormalized text weird whitespacing'

    remove_stopwords($text);
    # returns "   unnormalized\n text      weird whitespacing     "


=head1 DESCRIPTION

This modules provides different ways to normalize text.


=head1 INTERFACE

=head2 normalize($text)

Normalizes a text according to the following scheme:

1. converts all of the text to lower-case
2. removes common english stopwords
3. normalizes whitespace using the method normalize_white($text) (see below)

=head2 remove_stopwords($text)

Normalizes a given text by filtering it and removing any word thats
contained in a list of common english stopwords.


=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


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

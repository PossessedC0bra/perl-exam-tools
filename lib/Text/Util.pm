package Exam::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Text::Stopwords 'get_stopwords';

use Exporter 'import';
our @EXPORT = qw(normalize normalize_whitespace);

#####################################################################

my $MULTIPLE_WHITESPACE_REGEX = qr { \s+ }x;

my $STOPWORD_REGEX   = qr {\b (?: @{[ join('|', get_stopwords()) ]} ) \b}x;

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
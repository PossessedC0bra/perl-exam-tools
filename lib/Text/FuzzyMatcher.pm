package Text::FuzzyMatcher;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(fuzzy_search);

use Text::Normalizer qw(remove_stopwords normalize_whitespace);

use Text::Levenshtein::Damerau::XS 'xs_edistance';

#####################################################################

sub fuzzy_search ( $source_text, @target_texts ) {

    # normalize the text before comparison
    my $normalized_source_text = normalize($source_text);

    # accept an edit distance of at most 10% of the normalized source texts total length
    my $edit_distance_threshold = 0.1 * length($normalized_source_text);

    # try to fuzzy match the source text against all any target text
    foreach my $target_text (@target_texts) {

      # if an edit distance other than -1 (placeholder for no match possible) is returned the fuzzy match was successful
        if ( xs_edistance( $normalized_source_text, normalize($target_text), $edit_distance_threshold ) != -1 ) {
            return $target_text;
        }
    }

    # no exam question could be fuzzy matched to the master question -> return undef to indicate missing exam question
    return undef;
}

sub normalize ($text) {

    # convert whole text to lowercase
    $text = lc($text);

    # remove common stopwords
    $text = remove_stopwords($text);

    return normalize_whitespace($text);
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

Text::FuzzyMatcher - Fuzzy matches a given text against a list of target texts


=head1 VERSION

This document describes Text::FuzzyMatcher version 1.0.0


=head1 SYNOPSIS

    use Text::FuzzyMatcher qw(fuzzy_search);

    $source_text = 'Tihs is a mispellled txt';
    @target_texts = ('SomeUnrelatedText', 'This is a missspelled text');

    fuzzy_search($source_text, @target_texts)
    # returns 'This is a missspelled text'

=head1 DESCRIPTION

This module uses fuzzy matching and text normalization to find a potentially
missspelled text in a list of possible text. Normalization consists of removing
common english stop words and subsequent whitespace normalization. Afterwards
the edit distance between two normalized texts is computed using the 
Levenshtein-Damerau algorithm. If the edit distance is no larger than 10% of the
original texts length the target texts is considered to be a match and is returned.


=head1 INTERFACE

=head2 fuzzy_search($source_text, @target_texts)

Takes the source text, normalizes it and calculates a maximum edit distance
threshold (10% of the normalized source text). Then iterates over all target texts,
normalizes them and calculates the edit distance between the two normalized texts.
If the edit distance does not exceed the calculated threshold we consider the two
texts to be a match and return the target text.


=head1 Dependencies

=head2 Text::Levenshtein::Damerau::XS

This module requires the module Text::Levenshtein::Damerau::XS to computed
the edit distance between two texts. As this module is not part of the 
standard Perl distribution it has to be installed as follows:

    cpan install Text::Levenshtein::Damerau::XS

NOTE: installation of this module requires a C-compiler to be installed.


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

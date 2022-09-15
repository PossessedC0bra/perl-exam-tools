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
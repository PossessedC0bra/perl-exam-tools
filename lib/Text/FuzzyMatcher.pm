package Text::Stopwords;

use v5.30.3;
use strict;
use warnings;
use experimental;

use Exporter 'import';
our @EXPORT = qw(fuzzy_match);

use Text::Levenshtein::Damerau::XS 'xs_edistance';

#####################################################################

sub fuzzy_match ( $source_text, @target_texts ) {

    # normalize the master text before comparison
    my $normalized_source_text = normalize($source_text);

    # accept an edit distance of at most 10% of the normalized master texts total length
    my $edit_distance_threshold = 0.1 * length($normalized_source_text);

    # try to fuzzy match the master text against all the given exam texts
    foreach my $target_text (@target_texts) {

        # specifying a threshold means xs_edistance will short circuit and return -1 if the threshold is exceeded
        if ( xs_edistance( $normalized_source_text, normalize($target_text), $edit_distance_threshold ) != -1 ) {
            return $target_text;
        }
    }

    # no exam question could be fuzzy matched to the master question -> return undef to indicate missing exam question
    return undef;
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
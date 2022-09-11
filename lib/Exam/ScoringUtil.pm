package Exam::ScoringUtil;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exam::Grammar 'load_exam';
use Text::Stopwords 'get_stopwords';

use Exporter 'import';
our @EXPORT = qw(build_question_answer_map resolve_question_answer_key);

use Text::Levenshtein::Damerau::XS 'xs_edistance';

#####################################################################

my $WHITESPACE_REGEX = qr { \s+ }x;
my $STOPWORD_REGEX   = qr {\b (?: @{[ join('|', get_stopwords()) ]} ) \b}x;

#####################################################################

sub build_question_answer_map ($file_path) {
    my $exam_content_ref = load_exam($file_path);

    my %question_answer_map;

    foreach my $question_ref ( @{ $exam_content_ref->{QUESTIONS} } ) {
        my @checked_answers;
        my @unchecked_answers;

        foreach my $answer_ref ( @{ $question_ref->{ANSWERS} } ) {
            if ( $answer_ref->{CHECKBOX} =~ m {\[ [Xx] \]}x ) {
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

sub resolve_question_answer_key ( $key, %question_answer_map ) {

    # if the master answer is found exactly in the exam file return it
    if ( exists $question_answer_map{$key} ) {
        return $key;
    }

    # otherwise attempt to fuzzy match the master answer against all exam question -> answers
    return fuzzy_search( $key, keys %question_answer_map );
}

sub fuzzy_search ( $source_text, @target_texts ) {

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
# TEXT NORMALIZATION
#####################################################################

sub normalize ($text) {

    # convert whole text to lowercase
    my $text = lc($text);

    # remove common stopwords
    $text =~ s { $STOPWORD_REGEX } {}gx;

    return normalize_whitespace($text);
}

sub normalize_whitespace ($text) {

    # replace sequences of whitespaces with a single space (' ') character
    $text =~ s { $WHITESPACE_REGEX } { }gx;

    # remove whitespace at start
    $text =~ s { ^ $WHITESPACE_REGEX } {}gx;

    # remove whitespace at end
    $text =~ s { $WHITESPACE_REGEX $ } {}gx;

    return $text;
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
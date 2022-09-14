package Exam::ScoringUtil;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exam::Grammar 'load_exam';
use Text::Util qw(normalize_whitespace remove_stopwords);
use Text::FuzzyMatcher qw(fuzzy_match)

use Exporter 'import';
our @EXPORT = qw(build_question_answer_map resolve_question_answer_key);

#####################################################################

my $CHECKED_CHECKBOX_REGEX = qr {\[ [xX]+ \]}x;

#####################################################################

sub build_question_answer_map ($file_path) {
    my $exam_content_ref = load_exam($file_path);

    my %question_answer_map;

    foreach my $question_ref ( @{ $exam_content_ref->{QUESTIONS} } ) {
        my @checked_answers = ();
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

sub resolve_question_answer_key ( $key, %question_answer_map ) {

    # if the master answer is found exactly in the exam file return it
    if ( exists $question_answer_map{$key} ) {
        return $key;
    }

    # otherwise attempt to fuzzy match the master answer against all exam question -> answers
    return fuzzy_match( $key, keys %question_answer_map );
}

#####################################################################
# TEXT NORMALIZATION
#####################################################################

sub normalize ($text) {

    # convert whole text to lowercase
    $text = lc($text);

    # remove common stopwords
    $text = remove_stopwords($text);

    return normalize_whitespace($text);
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
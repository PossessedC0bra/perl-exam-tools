package Exam::ScoringUtil;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exam::Grammar 'load_exam';

use Exporter 'import';
our @EXPORT = qw(build_question_answer_map);

#####################################################################

my $WHITESPACE_REGEX = qr { \s+ }x;

#####################################################################

sub build_question_answer_map ($file_path) {
    my $exam_content_ref = load_exam($file_path);

    my %question_answer_map;

    foreach my $question_ref ( @{ $exam_content_ref->{QUESTIONS} } ) {
        my @checked_answers;
        my @unchecked_answers;

        foreach my $answer_ref ( @{ $question_ref->{ANSWERS} } ) {
            if ( $answer_ref->{CHECKBOX} =~ m {\[ [Xx] \]}x ) {
                push( @checked_answers, sanitize_text( $answer_ref->{TEXT} ) );
            }
            else {
                push( @unchecked_answers, sanitize_text( $answer_ref->{TEXT} ) );
            }
        }

        $question_answer_map{ sanitize_text( $question_ref->{TEXT} ) } = {
            CHECKED   => [@checked_answers],
            UNCHECKED => [@unchecked_answers]
        };
    }

    return \%question_answer_map;
}

sub sanitize_text ($text) {
    my $sanitized_text = lc($text);

    # replace sequences of whitespaces with a single space character
    $sanitized_text =~ s { $WHITESPACE_REGEX } { }gx;

    # remove whitespace at start
    $sanitized_text =~ s { ^ $WHITESPACE_REGEX } {}gx;

    # remove whitespace at end
    $sanitized_text =~ s { $WHITESPACE_REGEX $ } {}gx;

    return $sanitized_text;
}

1;    # Magic boolean TRUE value required at end of a module
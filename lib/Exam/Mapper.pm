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
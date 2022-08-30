package Exam::Parser;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use IO::Util 'read_file';

use Exporter 'import';
our @EXPORT = ('parse_exam_file');

################################################################################

my $SEPARATOR_REGEX = qr{^ _+ $}mx;

my $QUESTION_REGEX              = qr { \d+ \. \s* (.*?) ^ \s* $  }msx;
my $QUESTION_SANITIZATION_REGEX = qr { \n \s* }x;

my $CHECKED_ANSWER_REGEX   = qr {\[ [Xx] \] \s* (.*) }x;
my $UNCHECKED_ANSWER_REGEX = qr {\[ [ ] \] \s* (.*) }x;

################################################################################

sub parse_exam_file ($filename) {
    my %exam_file_map;

    my $file_content = read_file($filename);

    # seperate the files content into sections (each delimited by a sequence of one or more -)
    my @sections = split( $SEPARATOR_REGEX, $file_content );

    # remove and store header section
    $exam_file_map{HEADER}    = shift @sections;
    $exam_file_map{QUESTIONS} = {};

    # create a mapping for each question to its checked and unchecked answers
    foreach my $question_section (@sections) {
        my @question_matches = $question_section =~ m{$QUESTION_REGEX};
        if ( !@question_matches ) {
            next;
        }

        # sanitize question match (remove newlines and additional spaces)
        my $question = $question_matches[0] =~ s {$QUESTION_SANITIZATION_REGEX} { }gr;

        my @checked_answers   = $question_section =~ m{$CHECKED_ANSWER_REGEX}g;
        my @unchecked_answers = $question_section =~ m{$UNCHECKED_ANSWER_REGEX}g;

        # map incorrect and correct answers to the question
        $exam_file_map{QUESTIONS}{$question} = {
            CHECKED   => [@checked_answers],
            UNCHECKED => [@unchecked_answers]
        };
    }

    return \%exam_file_map;
}

1;    # Magic boolean TRUE value required at end of a module
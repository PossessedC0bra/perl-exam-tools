package Exam::Grammar;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use IO::Util 'read_file';

use Regexp::Grammars;

use Exporter 'import';
our @EXPORT = qw(load_exam);

################################################################################

my $EXAM_GRAMMAR = qr{

    <EXAM=exam>     # capure the exam rule into a variable called 'EXAM'

    <nocontext:>    # turn off the context substring so we don't clutter the data structure

    <rule: exam>
        <HEADER=header>             # capture header into a variable called 'HEADER'
        <.separator>                # a separator we do not capture
        <[QUESTIONS=question]>+     # capture multiple questions into an array called 'QUESTIONS'
        %                           # ... separated by ...
        <.separator>                # a separator we do not capture (indicated by the <.xxx>)

    <token: header> 
        .*?         # capture anything

    <token: separator>
        ^       # start at a line
        \h*     # allow horizontal whitespace
        _+      # one or more underscores
        \h*     # some more horizontal whitespace
        $       # and finally end at the line

    <rule: question>
        ^                       # start at a line
        \h*                     # allow horizontal whitespace    
        <NUMBER=number>         # capture the questions number into a variable called 'NUMBER'
        \.                      # immediately followed by a literal .
        \h*                     # allow some more horizontal whitespace
        <TEXT=text>             # capture the actual questions text into a variable called 'TEXT'
        <[ANSWERS=answer]>+     # capture multiple questions into an array called 'ANSWERS'

    <token: answer>
        ^                       # start at a line
        \h*                     # allow horizontal whitespace
        <CHECKBOX=checkbox>     # capture the answers checkbox into a variable called 'CHECKBOX'
        \h*                     # allow some more horizontal whitespace
        <TEXT=text>             # capture the answers actual text into a variable called 'TEXT'

    <token: checkbox>
        \[          # start with a opening square bracket
        [^]\v]*     # allow any number of non closing square brackets or vertical whitespace 
        \]          # end with a closing square bracket

    <token: number>
        \d+     # 1 or more digits

    <token: text>
        \N* \n                              # The rest of the current line
        (?: <!answer> ^ \N* \S \N* \n )*    # ...plus any subsequent non-blank lines that does 
                                            # NOT match the answer token (indicated by the <!xxx>)
}xms;

################################################################################

sub load_exam ($file_path) {

    # read the entire files content into a single string
    my $exam_content = read_file($file_path);

    # Match the file contents against the grammar for an exam
    if ( $exam_content =~ $EXAM_GRAMMAR ) {

        # return the top level key 'EXAM' where the parsed exam is stored
        return $/{EXAM};
    }

    # If the file contents were not a valid exam, return undef to indicate failure
    return undef;
}
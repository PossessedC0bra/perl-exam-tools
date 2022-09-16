package Exam::Grammar;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(load_exam);

use IO::Util 'read_file';

use Regexp::Grammars;

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

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

Exam::Grammar - parse an exam file using Regexp::Grammars


=head1 VERSION

This document describes Exam::Grammar version 1.0.0


=head1 SYNOPSIS

    use Exam::Grammar qw(load_exam);

    %parsed_exam_file = load_exam('foo.txt');


=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.


=head1 DESCRIPTION

The Exam::Grammar module contains a structure definition of an exam file. The 
structure was implemented using the Regexp::Grammar module. Loading an exam file
using this module returns a hash of the parsed files content.


=head1 INTERFACE

=head2 load_exam($file_path)

Loades the file at the given path and parses it using a Regex Grammar.
Returns the parsed file in a hash of the following format:

{
    HEADER => string,
     QUESTIONS => [
        {
            NUMBER  => decimal,
            TEXT    => string,
            ANSWERS => [
                {
                    CHECKBOX => string,
                    TEXT     => string
                },
                ...
            ]
        },
        ...
    ]
}


=head1 DEPENDENCIES

=head2 Regexp::Grammars

This module requires the module Regexp::Grammars for defining an exam files 
structure and parsing a given file against it. As the module Regexp::Grammars
is NOT part of the standard Perl distribution it has to be installed like this:

    cpan install Regexp::Grammars


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

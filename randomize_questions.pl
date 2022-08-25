#!/usr/bin/env perl

use v5.30.3;
use strict;
use warnings;
use experimental;

use List::Util 'shuffle';

#####################################################################

# Returns the current localtime as string in the following foramt: YYYYMMDD-HHMMSS
sub localtime_string() {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime();
    return sprintf(
        "%04d%02d%02d-%02d%02d%02d",
        $year + 1900,
        $mon + 1, $mday, $hour, $min, $sec
    );
}

#####################################################################

# check command line arguments
if ( @ARGV < 1 ) {
    print("usage: randomize_questions.pl <PATH_TO_MASTER_FILE>");
    exit(0);
}

# attempt to open master file for reading
my $master_file_name = $ARGV[0];
my $master_file_handle;
if ( !open( $master_file_handle, "<", $master_file_name ) ) {
    die "Failed to open $master_file_name";
}

# read all of the master files content
my $master_file_content = do {
    local $/ = undef;
    readline($master_file_handle);
};

# calculate output file name
my $output_file_name = localtime_string() . "-$master_file_name";

# open output file for writing
my $output_file_handle;
if ( !open( $output_file_handle, ">", $output_file_name ) ) {
    die "Failed to open $output_file_name";
}

# seperate master files content into sections (each delimited by a sequence of one or more -)
my @sections = $master_file_content =~ m{ .*? ^_+$ }gmxs;

# 1st section is the header with information about the exam. we can simply print thatone into the new file
print( $output_file_handle $sections[0] );
for my $i ( 1 .. $#sections ) {
    my $question = $sections[$i];

    # replace correct answer checkbox with an empty one
    $question =~ s{\[X\]} {\[ \]}g;

    # extract all answers
    my @answers = $question =~ m{([^\S\r\n]+\[ \].*\n)}g;

    # shuffle answers and join them together into a single string
    my $shuffled_answer_string = join( '', shuffle(@answers) );

    # replace old answers with shuffled ones
    $question =~ s{^[^\S\r\n]+\[ \].*?^$} {$shuffled_answer_string}ms;

    # write the processed question (and answer) string into the file
    print( $output_file_handle $question );
}

close($output_file_handle);
close($master_file_handle);

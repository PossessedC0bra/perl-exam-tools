package IO::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT = ('read_file');

sub read_file ($filename) {
    my $filehandle = open_read($filename);

    my $content = do {
        local $/ = undef;
        readline($filehandle);
    };
    close($filehandle);

    return $content;
}

sub open_read ($filename) {
    if ( !-e $filename ) {
        say "File '$filename' does not exists";
        exit(1);
    }

    if ( !-r $filename ) {
        say "Cannot read from file '$filename'";
        exit(1);
    }

    my $filehandle;
    if ( !open( $filehandle, "<", $filename ) ) {
        say "Unable to open file '$filename': \n \t $!\nFailed";
        exit(1);
    }

    return $filehandle;
}

1;    # Magic boolean TRUE value required at end of a module
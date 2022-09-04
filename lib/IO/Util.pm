package IO::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT = qw(read_file write_file);

#####################################################################
# READ
#####################################################################

sub read_file ($file_path) {
    my $filehandle = open_read($file_path);

    my $content = do {
        local $/ = undef;
        readline($filehandle);
    };
    close($filehandle);

    return $content;
}

sub open_read ($file_path) {
    if ( !-e $file_path ) {
        say "File '$file_path' does not exists";
        exit(1);
    }

    if ( !-r $file_path ) {
        say "Cannot read from file '$file_path'";
        exit(1);
    }

    my $filehandle;
    if ( !open( $filehandle, "<", $file_path ) ) {
        say "Unable to open file '$file_path': \n \t $!\nFailed";
        exit(1);
    }

    return $filehandle;
}

#####################################################################
# WRITE
#####################################################################

sub write_file ( $file_path, $content ) {
    my $filehandle = open_write($file_path);
    print( {$filehandle} $content );
    close($filehandle);
}

sub open_write ($file_path) {
    if ( -e $file_path && !-w $file_path ) {
        say "Cannot write to file '$file_path'";
        exit(1);
    }

    my $filehandle;
    if ( !open( $filehandle, ">", $file_path ) ) {
        say "Unable to open file '$file_path': \n \t $!\nFailed";
        exit(1);
    }

    return $filehandle;
}

1;    # Magic boolean TRUE value required at end of a module
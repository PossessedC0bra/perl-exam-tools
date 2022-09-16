package IO::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(read_file write_file);

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

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

IO::Util - Safe file reading and writing with understandable diagnostic messages


=head1 VERSION

This document describes IO::Util version 1.0.0


=head1 SYNOPSIS

    use IO::Util qw(read_file write_file);

    my $file_content = read_file('foo.txt');

    write_file('bar.txt', $content);


=head1 DESCRIPTION

This module provides simple utility function for file input and output complete
with easily digestible error messages. Functions include reading a whole files
content as well as writing content into a file with the given path.


=head1 INTERFACE

=head2 read_file($file_path)

Reads a whole files content into a buffer and returns it. If a file does not
exist or is not readable a nice and easily understandable error message is
printed and the program is aborted.

=head2 write_file($file_path, $content)

Writes the given content to the file with the given file path. If the file
already exists its content is forcefully overwriten. if the file is not 
writeable a nice error message is printed and the program is aborted.


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

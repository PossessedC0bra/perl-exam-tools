package Date::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(localtime_string_format);

#####################################################################

sub localtime_string_format ( $format, @localtime ) {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = @localtime;
    return sprintf( $format, $year + 1900, $mon + 1, $mday, $hour, $min, $sec );
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
package Math::Util;

use v5.30.3;
use strict;
use warnings;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = qw(round);

#####################################################################

sub round ($number) {
    return sprintf( "%.0f", $number );
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module
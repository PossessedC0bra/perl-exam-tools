#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
plan tests => 6;

use Math::Util qw(round);

# positive numbers
ok( round(2.4) == 2, "positive floo" );
ok( round(5) == 5,   "positive integer" );
ok( round(5.5) == 6, "negative ceil" );

# negative numbers
ok( round(-2.4) == -2, "negative ceil" );
ok( round(-5) == -5,   "negative integer" );
ok( round(-5.5) == -6, "negativ floor" );

done_testing();
#!/usr/bin/env perl

use strict;
use warnings;

use Term::ReadKey;
my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

printf "Characters: %4d x %4d\n", $wchar, $hchar;
printf "Pixels:     %4d x %4d\n", $wpixels, $hpixels;


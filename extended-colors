#!/usr/bin/perl

use strict;
use warnings;

use Term::ExtendedColor qw( fg get_colors );
use Term::ReadKey;

my $width = (GetTerminalSize())[0] - 2; # only care about width (with a right gutter)
my $colors = get_colors();

my $l = length((sort { length($b) <=> length($a) } keys %{$colors})[0]);
my $cols = int($width / ($l + 2));
my $i = 0;

foreach my $color (sort keys %{$colors}) {
    printf('%s  ', fg($color, sprintf("%-${l}s", $color)));
    $i++;

    if ($i >= $cols) {
        print "\n";
        $i = 0;
    }
}

print "\n";

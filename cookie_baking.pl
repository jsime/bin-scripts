#!/usr/bin/perl

use strict;
use warnings;

use constant MAX_DEPTH => 25;
use POSIX qw( ceil );

my $b = 24;
my $c = 20;
my $d = 1500;
my $e = 1/4;
my $p = 30;
my $t = 12;

print "How many cookies will I be baking tonight?\n\n";

collect_input('1 How many minutes does it take to make the dough?', \$p);
collect_input('2 How many cookies are baked at a time?', \$b);
collect_input('3 How many minutes are the cookies baked?', \$t);
collect_input('4 How many minutes do the cookies cool for before they can be safely eaten?', \$c);
collect_input('5 How many cookies per batch do you expect to eat while you bake?', \$e);
collect_input('6 Finally, how many cookies do you hope to share with others?', \$d);

printf("Dough Preparation:  %d minutes\n", $p);
printf("Cookies Per Batch:  %d\n", $b);
printf("Baking Time:        %d minutes\n", $t);
printf("Cooling Time:       %d minutes\n", $c);
printf("Eaten per batch:    %0.2f\n", $e);
printf("Desired Number:     %d\n", $d);
printf("\nTotal Baked:        %d\n\n", rec($p * $e + $d,1));

sub collect_input {
    my ($label, $var) = @_;

    printf("%s\n  [Default: %s]: ", $label, $$var);
    my $in = <STDIN>;
    $in =~ s{(^\s+|\s+$)}{}ogs;

    if (length($in) > 0 && $in !~ m{^\d+(\.\d+)?$}o) {
        print "Please enter numbers (integers or decimals) only, or press [enter] for the default.\n";
        print "Now, let's try the previous question again ...\n";
        collect_input($label, $var);
    }

    $$var = $in if length($in) > 0;
}

sub rec {
	my ($x, $l) = @_;

	return $x if $l >= MAX_DEPTH;

	return $x + rec(((ceil($x / $b) * $t) * $e) - (($c + $t) * $e),++$l)
}


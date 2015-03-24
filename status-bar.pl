#!/usr/bin/env perl

use 5.018;
use utf8;
use strict;
use warnings FATAL => 'all';

use Getopt::Long;

binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my ($HELP, $LEFT, $RIGHT);
my $O_COL = '68,60';
my $O_BG  = '235';
my $O_TXT = '8';
my $O_BLOCKS = 'date,time,load,battery';

GetOptions(
    'colors|c=s'      => \$O_COL,
    'background|bg=s' => \$O_BG,
    'text|t=s'        => \$O_TXT,
    'left|l!'       => \$LEFT,
    'right|r!'      => \$RIGHT,
    'blocks|bl=s'   => \$O_BLOCKS,
    'help|h!'       => \$HELP,
) or die usage();

$LEFT = 1 unless $LEFT or $RIGHT;

my %blocks = (
    date      => q/date +"%a %d %b"/,
    time      => q/date +"%H:%M %Z"/,
    datetime  => q/date +"%a %d %b %H:%M %Z"/,
    load      => q/uptime | tr -d ',' | tr ' ' "\n" | tail -3 | head -1/,
    load5     => q/uptime | tr -d ',' | tr ' ' "\n" | tail -2 | head -1/,
    load15    => q/uptime | tr -d ',' | tr ' ' "\n" | tail -1/,
    battery   => q/battery-status/,
    osname    => \&block_osname,
    osver     => \&block_osver,
    osnamever => \&block_osnamever,
    host      => q/hostname/,
    uptime    => \&block_uptime,
    user      => q/whoami/,
);

exit usage() if $HELP;

sub usage {
    my $name = (split('/', $0))[-1];

    print <<EOU;
$name - Colorized status bar generator for tmux.

Example:

    $name -r -bg 235 -t 8 -c 68,60 -bl date,time,load,battery

Options:

  -c    Comma-separated list of color numbers to use, in order you wish them to
        appear. The numbers can be found by running the tmux-colors script.
        The color list will be repeated as many times as necessary to cover the
        list of blocks you select. In other words, if you supply 2 colors and
        5 blocks, the color list will automatically be expanded to:
        colora,colorb,colora,colorb,colora.

  -bg   Color number used for the background of the status bar.

  -t    Color number to use for text inside each block.

  -l    Specifies whether statusbar blocks are for the left (--left or -l) or
  -r    the right (--right or -r). Left takes precedence if you decide to use
        both for some reason. Affects which block characters are used for the
        separator and how colors shift.

        Please note that right-side status bars consume your color list in
        reverse order (i.e. the first color you specify will be for the right
        most block as it is rendered).

  -bl   Comma-separated list of blocks, in the order they should be rendered.
        See below for the acceptable values.

  -h    Displays this message and exits.

Supported Blocks:

EOU

    printf("    %s\n", $_) for sort keys %blocks;

}

my $SEP = $LEFT ? '▙▚' : '▚▜';

my @BLOCKS = grep { exists $blocks{$_} } map { lc($_) } split(',', $O_BLOCKS);
my @COLORS = (((split(',', $O_COL)) x scalar(@BLOCKS))[0..$#BLOCKS], $O_BG);
@COLORS = reverse(@COLORS) if $RIGHT;

my $OUT = '';

my $prev_color = shift(@COLORS);
foreach my $block (@BLOCKS) {
    my $cur_color = shift(@COLORS);

    my $value = get_block_value($block);

    if ($RIGHT) {
        $OUT .= "#[bg=colour${prev_color}, fg=colour${cur_color}]${SEP}";
        $OUT .= "#[bg=colour${cur_color}, fg=colour${O_TXT}]${value} ";
    } else {
        $OUT .= "#[bg=colour${prev_color}, fg=colour${O_TXT}] ${value}";
        $OUT .= "#[bg=colour${cur_color}, fg=colour${prev_color}]${SEP}";
    }

    $prev_color = $cur_color;
}

print $OUT;

sub get_block_value {
    my ($block) = @_;

    my $val;

    if (ref($blocks{$block}) eq 'CODE') {
        $val = &{$blocks{$block}}();
    } else {
        $val = `$blocks{$block}`;
    }

    $val =~ s{[\n\r]}{ }ogs;
    $val =~ s{\s+}{ }ogs;
    $val =~ s{(^\s+|\s+$)}{}ogs;

    return $val;
}

sub block_osname {
    if (-e "/etc/os-release") {
        open(my $fh, '<', '/etc/os-release');
        while (my $l = <$fh>) {
            if ($l =~ m{^NAME="([^"]+)"}o) {
                close($fh);
                return $1;
            }
        }
        close($fh);
    }

    if (-e "/etc/release") {
        open(my $fh, '<', '/etc/release');
        while (my $l = <$fh>) {
            if ($l =~ m{OmniOS}oi) {
                close($fh);
                return 'OmniOS';
            }
        }
        close($fh);
    }

    return '?';
}

sub block_osver {
    if (-e "/etc/os-release") {
        open(my $fh, '<', '/etc/os-release');
        while (my $l = <$fh>) {
            if ($l =~ m{^VERSION_ID="([^"]+)"}o) {
                close($fh);
                return $1;
            }
        }
        close($fh);
    }

    if (-e "/etc/release") {
        open(my $fh, '<', '/etc/release');
        while (my $l = <$fh>) {
            if ($l =~ m{OmniOS\s+v\d+\s+(r\d+\S*)}oi) {
                close($fh);
                return $1;
            }
        }
        close($fh);
    }

    return '?';
}

sub block_osnamever {
    return block_osname() . ' ' . block_osver();
}

sub block_uptime {
    my $uptime = `uptime`;

    if ($uptime =~ m{\s+(\d+)\s+days}oi) {
        return sprintf('up %d days', $1);
    } elsif ($uptime =~ m{up\s+(\d+):(\d+)}o) {
        if ($1 > 0) {
            return sprintf('up %d hours', $1);
        } else {
            return sprintf('up %d min', $2);
        }
    } elsif ($uptime =~ m{up\s+(\d+)\s+min}o) {
        return sprintf('up %d min', $1);
    } else {
        return 'up <1 hour';
    }
}

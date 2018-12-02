#############################################################################
#
#   Ovulation Calendar
#   $Id$
#
#
#   GNU LESSER GENERAL PUBLIC LICENSE v3
#   See LICENSE.txt for licensing information
#
#   (c) Christoph Morrison, 2018 ff.
#       <fhem@christoph-jeschke.de>
#
#   Please report bugs and feature requests using the offical ticket system
#   <https://bitbucket.org/christoph-morrison/fhem-ovulation-calendar/issues>
#
#
#############################################################################

#############################################################################
#
#   Register Ovulation_Calendar to global registry
#
#############################################################################

package main;

use strict;
use warnings FATAL => 'all';
use constant {
    VERSION => 0.0.1
};

sub Ovulation_Calendar_Initialize($)
{
    my ($hash) = @_;

    $hash->{DefFn}      =   "Ovulation_Calendar::Define";
    $hash->{UndefFn}    =   "Ovulation_Calendar::Undef";
    $hash->{SetFn}      =   "Ovulation_Calendar::Set";
    $hash->{GetFn}      =   "Ovulation_Calendar::Get";
    $hash->{AttrFn}     =   "Ovulation_Calendar::Attr";
    $hash->{NotifyFn}   =   "Ovulation_Calendar::Notify";
    $hash->{AttrList}   =   join ' ', qw(
                                OvuCal_LutalPhase
                            ) . " $readingFnAttributes";

    foreach my $d ( sort keys %{ $modules{Ovaluation_Calendar}{defptr} } ) {
        my $hash = $modules{Ovaluation_Calendar}{defptr}{$d};
        $hash->{VERSION} = VERSION;
    }
}

#############################################################################
#
#   Package: Ovulation_Calendar
#
#############################################################################

package Ovulation_Calendar;

our %cycle;
our $moduleName = 'Ovulation_Calendar';
our $hash;

use strict;
use v5.10;
use warnings FATAL => 'all';
use Date::Parse;
use POSIX;
use Switch;
use GPUtils qw(:all);

## Import der FHEM Funktionen
BEGIN {
    GP_Import(
        qw(
            readingsSingleUpdate
            readingsBulkUpdate
            readingsBulkUpdateIfChanged
            readingsBeginUpdate
            readingsEndUpdate
            ReadingsTimestamp
            defs
            modules
            Log3
            CommandAttr
            attr
            AttrVal
            ReadingsVal
            Value
            IsDisabled
            deviceEvents
            init_done
            gettimeofday
            InternalTimer
            RemoveInternalTimer
        )
    );
}

=pod

    @definition_arguments =
        0 → module name
        1 → device name
        2 → menstrual cycle start
        3 → menstrual cycle length

     |follicular
                  |ovaluation
                   |luteal phase
    |123456789|123456789|12345678
             .......
             fertile days (ascending)

=cut
sub Define($$)
{
    my ( $hash, $device_definition ) = @_;
    my @definition_arguments = split( "[ \t][ \t]*", $device_definition );
    my $name    = $definition_arguments[0];
    my $device  = $definition_arguments[1];

    return "$device needs two arguments: a timestamp for the cycle start date and the cycle length in days"
        if ( @definition_arguments != 4);

    my ($cycle_start, $cycle_length) = @definition_arguments[2..3];

    $cycle{'start'} = str2time($cycle_start);

    return "[$device] First parameter is not a valid timestamp. Use i.e. yyyy-mm-dd"
        unless defined $cycle{'start'};

    return "[$device] Second parameter is not valid: use a integer for the length of the cycle"
        unless $cycle_length =~ /^\d+$/;

    return "[$device] Second parameter seems not to be valid, it's either too small (less than 15) or too large (more than 50)"
        if ($cycle_length < 15 or $cycle_length > 50);

    $cycle{'length'} = $cycle_length;

    $hash->{NAME}           = $name;
    $hash->{STATE}          = "Initialized";
    $hash->{CYCLE_LENGTH}   = $cycle_length;
    $hash->{CYCLE_START_TS} = $cycle{'start'};
    $hash->{CYCLE_START}    = $cycle_start;

    # @todo: check if device is redefined

    return undef;
}



sub Undef($$)
{

}

sub Set($@)
{

}

sub Get($$@)
{
    my ( $hash, $name, $opt, @args ) = @_;

    switch ($opt)
    {
        case 'version' {
            return '$Id$';
        }

        else {
            return 'Unknown argument $opt, choose one of version';
        }
    }
}

sub Attr_LutalPhase($$)
{
    my ($cmd, $value) = @_;

    switch ($cmd) {
        case 'set' {
            return 'The lutal phase must be set to its duration of days; integer values from 1 to n are allowed.'
                if (not $value =~ /^\d+$/);

            return undef;
        }
        case 'del' {
            return undef;
        }
    }

    updateCalculatedData();

    return undef;
}

sub Attr($$$$)
{
    my ($cmd, $name, $attrName, $attrValue) = @_;
    Log3($moduleName, 3, "Try to set $attrName");

    $attrName =~ s/^OvuCal_(.*)$/$1/;

    switch ($attrName)
    {
        case 'LutalPhase' {
            return Attr_LutalPhase($cmd, $attrValue);
        }
        else {
            return "Unknown attribute '$attrName' set."
        }
    }

    return undef;
}

sub Notify($$)
{

}

sub updateCalculatedData()
{
    my $start       = $hash{CYCLE_START_TS};
    my $length      = $hash{CYCLE_LENGTH};
    my $lutalPhase  = AttrVal()
}

#############################################################################
#
#   internal helper functions
#
#############################################################################

sub _setReadingsBulk($@)
{
    my ($hash, %data) = @_;

    readingsBeginUpdate($hash);

    foreach my $reading (keys %data) {
        readingsBulkUpdate($hash, $reading, $data{$reading}{'value'},
            (defined $data{'reading'}{'event'})
                ? $data{'reading'}{'event'}
                : undef
        )
    }

    readingsEndUpdate($hash, undef);
}

1;

=pod

=begin html

Documentation

=begin html_DE

Dokumentation

=cut
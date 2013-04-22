package Kompot::Cookie;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';
use Kompot::Attributes;

has 'name';
has 'value';

sub init {
    my $self = shift;
    my $p = @_ % 2 ? $_[0] : {@_};

    if (not $p) {
        return $self;
    }
    elsif (not ref $p) {
        carp 'Cookie is not HASHREF!';
        return $self;
    }

    map { $self->{$_} = $p->{$_} } qw(name value path domain);

    $self->{expires}   = $self->_expires($p->{expires});
    $self->{secure}    = $p->{secure} ? 1 : 0;
    $self->{http_only} = $p->{http_only} ? 1 : 0;

    return 1;
}

sub to_string {
    my $self = shift;

    my @cookie;
    push @cookie, $self->{name} . '=' . ($self->{value} || '');

    push @cookie, 'Path='    . $self->{path}    if $self->{path};
    push @cookie, 'Expires=' . $self->{expires} if $self->{expires};
    push @cookie, 'Domain='  . $self->{domain}  if $self->{domain};
    push @cookie, 'Secure'   if $self->{secure};
    push @cookie, 'HttpOnly' if $self->{http_only};

    my $cookie_str = join '; ', @cookie;

    if (length $cookie_str > 4096) {
        carp 'cookie > 4096';
    }

    return $cookie_str;
}

sub _expires {
    my ($self, $expires) = @_;
    $expires = $self->_parse_duration($expires);
    $expires = $self->_epoch_to_gmtstring($expires);
    return $expires;
}

sub _epoch_to_gmtstring {
    my ($self, $epoch) = @_;

    my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($epoch);
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @days   = qw(Sun Mon Tue Wed Thu Fri Sat);

    return
        sprintf "%s, %02d-%s-%d %02d:%02d:%02d GMT",
        $days[$wday],
        $mday,
        $months[$mon],
        ($year + 1900),
        $hour, $min, $sec;
}

# This code is taken from Time::Duration::Parse, except if it isn't
# understood it just passes it through and it adds the current time.
sub _parse_duration {
    my $self = shift;
    my $timespec = shift;
    my $orig_timespec = $timespec;

    # This map is taken from Cache and Cache::Cache
    # map of expiration formats to their respective time in seconds
    my %units = (
        map(($_, 1),                  qw(s second seconds sec secs)),
        map(($_, 60),                 qw(m minute minutes min mins)),
        map(($_, 60 * 60),            qw(h hr hour hours)),
        map(($_, 60 * 60 * 24),       qw(d day days)),
        map(($_, 60 * 60 * 24 * 7),   qw(w week weeks)),
        map(($_, 60 * 60 * 24 * 30),  qw(M month months)),
        map(($_, 60 * 60 * 24 * 365), qw(y year years))
    );

    # Treat a plain number as a number of seconds (and parse it later)
    if ($timespec =~ /^\s*([-+]?\d+(?:[.,]\d+)?)\s*$/) {
        $timespec = "$1s";
    }

    # Convert hh:mm(:ss)? to something we understand
    $timespec =~ s/\b(\d+):(\d\d):(\d\d)\b/$1h $2m $3s/g;
    $timespec =~ s/\b(\d+):(\d\d)\b/$1h $2m/g;

    my $duration = 0;
    while ($timespec
        =~ s/^\s*([-+]?\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)(?:\s*(?:,|and)\s*)*//i)
    {
        my ($amount, $unit) = ($1, $2);
        $unit = lc($unit) unless length($unit) == 1;

        if (my $value = $units{$unit}) {
            $amount =~ s/,/./;
            $duration += $amount * $value;
        }
        else {
            return $orig_timespec;
        }
    }

    if ($timespec =~ /\S/) {
        return $orig_timespec;
    }

    return sprintf "%.0f", $duration + time;
}

1;

__END__

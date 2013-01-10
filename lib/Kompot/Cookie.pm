package Kompot::Cookie;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP { output => 'stdout' };

use URI::Escape;

use base 'Kompot::Base';


sub init {
    my ($self, $cookie) = @_;

    if (ref($cookie)) {
    }
    else {
        $self->parse($cookie);
    }


    return 1;
}

sub parse {
    my ($self, $cookie) = @_;

    my ($name, $value) = split(/\s*=\s*/, $cookie, 2);

    $self->{_name}  = $name;
    $self->{_value} = $value;

    # params: path, expires, ...
    my @values;

    if ($value) {
        @values = map { uri_unescape($_) } split(/[&;]/, $value);
    }

    $self->{_values} = \@values;
p \@values;

    return $self;
}

sub name    { shift->{_name} }
sub path    { shift->{_path} }
sub expires { shift->{_expires} }
sub domain  { shift->{_domain} }

sub secure {
    my $self = shift;
    return defined($self->{_secure}) ? 1 : 0;
}

sub http_only {
    my $self = shift;
    return defined($self->{_http_only}) ? 1 : 0;
}

sub set { shift->to_string }

sub to_string {
    my $self = shift;

    my $value = join('&', map {uri_escape($_)} $self->value);

    my @cookie;
    
    push @cookie, $self->name . '=' . $value;

    push @cookie, 'path=' . $self->path       if $self->path;
    push @cookie, 'expires=' . $self->expires if $self->expires;
    push @cookie, 'domain=' . $self->domain   if $self->domain;
    push @cookie, 'Secure'                    if $self->secure;

    push @cookie, 'HttpOnly' if $self->http_only != 0;

    return join '; ', @cookie;
}


1;

__END__

package Kompot::Request;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;
use URI::Escape;

use base 'Kompot::Base';

use Kompot::Cookie;

sub init {
    my $self = shift;

    my $p = @_ % 2 ? @_ : {@_};

    $self->{env} = $p->{env};

    $self->{_read_position} = 0;
    $self->{_chunk_size}    = 4096;
    $self->{_body_params}   = undef;
    $self->{_query_params}  = undef;
    $self->{_route_params}  = {};

    $self->_build_params;
}

sub env { shift->{env} }

sub is_forward {0}

sub method { shift->env->{REQUEST_METHOD} }
sub path { shift->env->{PATH_INFO} || '/' }

sub uri { shift->env->{REQUEST_URI} }

sub is_static { shift->path =~ /\.[\w\d]+$/ }

sub content_length { shift->env->{CONTENT_LENGTH} || 0 }
sub input_handle   { $_[0]->env->{'psgi.input'} || $_[0]->env->{'PSGI.INPUT'} }

###

sub param {
    my ($self, $param) = @_;
    return $self->{params}->{$param};
}

sub cookie {
    my ($self, $name) = @_;
    return $self->{_cookies}->{$name}; # XXX
}

sub _set_route_params {
    my ($self, $p) = @_;

    $self->{_route_params} = $p;

    map { $p->{$_} = $self->_url_decode($p->{$_}) } keys %$p;

    $self->_build_params;
}

# Taken from Dancer::Request
sub _build_params {
    my $self = shift;

    $self->_parse_query_params;
    $self->_parse_cookies;

    if ($self->is_forward) {
        $self->{_body_params} = {};
    }
    else {
        $self->_parse_body_params;
    }

    # and merge everything
    $self->{params} = {
        %{ $self->{_query_params} },
        %{ $self->{_route_params} },
        %{ $self->{_body_params} },
    };

}

sub _parse_cookies {
    my $self = shift;

    my $cookies_str = $self->env->{COOKIE} || $self->env->{HTTP_COOKIE};
    return if not $cookies_str;

    my $cookies = {};

    foreach my $cookie (split(/[,;]\s?/, $cookies_str)) {
        my $c = Kompot::Cookie->new($cookie);
        $cookies->{ $c->name } = $c;
    }

    $self->{_cookies} = $cookies;
#p $self->{_cookies};

    return $cookies;
}

sub _parse_query_params {
    my $self = shift;

    return $self->{_query_params} if defined $self->{_query_params};

    $self->{_query_params} = $self->_parse_params($self->env->{QUERY_STRING})
        || {};

    return $self->{_query_params};
}

sub _parse_body_params {
    my $self = shift;

    return $self->{_body_params} if defined $self->{_body_params};

    my $content_length = $self->content_length;

    return if not $self->input_handle;

    my $body;

    if ($content_length > 0) {
        while (my $buffer = $self->_read) {
            $body .= $buffer;
        }
    }

    $self->{_body_params} = $self->_parse_params($body) || {};

    return $self->{_body_params};
}

sub _parse_params {
    my ($self, $params) = @_;

    return {} if not $params;

    my $pp;

    foreach my $token (split /[&;]/, $params) {

        my ($key, $val) = split(/=/, $token, 2);

        next if not defined $key;


        $val = (defined $val) ? $val : '';

        $key = $self->_url_decode($key);
        $val = $self->_url_decode($val);

        # looking for multi-value params
        if (exists $pp->{$key}) {

            my $prev_val = $pp->{$key};

            if (ref($prev_val) && ref($prev_val) eq 'ARRAY') {
                push(@{ $pp->{$key} }, $val);
            }
            else {
                $pp->{$key} = [$prev_val, $val];
            }
        }

        # simple value param (first time we see it)
        else {
            $pp->{$key} = $val;
        }
    }

    return $pp;
}

# taken from Miyagawa's Plack::Request::BodyParser from Dancer::Request (=
sub _read {
    my $self = shift;

    my $remaining = $self->content_length - $self->{_read_position};
    my $maxlength = $self->{_chunk_size};

    return if $remaining <= 0;

    my $readlen = ($remaining > $maxlength) ? $maxlength : $remaining;

    my ($buffer, $rc);

    $rc = $self->input_handle->read($buffer, $readlen);

    if (not defined($rc)) {
        croak "Unknown error reading input: $!";
    }

    $self->{_read_position} += $rc;
    return $buffer;
}

# Taken from Dancer::Request
sub _url_decode {
    my ($self, $data) = @_;

    $data =~ tr/\+/ /;
    $data =~ s/%([a-fA-F0-9]{2})/pack 'H2', $1/eg;

    return $data;
}


1;

__END__

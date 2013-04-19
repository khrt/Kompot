package Kompot::Request;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;
use URI::Escape;

use base 'Kompot::Base';
use Kompot::Attributes;

has env => {};
has content_length => 0; # XXX Deprecated / To delete
has input => undef;
has is_forward => 0;
has is_static => sub { shift->path =~ /\.[\w\d]+$/ };
has method    => undef;
has path      => '/';
has uri       => undef;

sub init {
    my $self = shift;
    my $p    = @_ % 2 ? @_ : {@_};
    my $env  = $self->{env} = $p->{env};

    $self->{_read_position} = 0;
    $self->{_chunk_size}    = 4096;
    $self->{_body_params}   = undef;
    $self->{_query_params}  = undef;
    $self->{_route_params}  = {};

    # set attrs
    $self->env($env);
    $self->content_length($env->{CONTENT_LENGTH});
    $self->input($env->{'psgi.input'} || $env->{'PSGI.INPUT'});
    $self->method($env->{REQUEST_METHOD});
    $self->path($env->{PATH_INFO});
    $self->uri($env->{REQUEST_URI});

    $self->_build_params;
    $self->_parse_cookies;
}

sub param {
    my ($self, $param) = @_;
    return $self->{params}->{$param};
}

sub params {
    my $self = shift;
    return $self->{params} || {};
}

sub cookie {
    my ($self, $name) = @_;
    return $self->{_cookies}->{$name} if $name;
    return $self->{_cookies};
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

    $self->_parse_query;

    if ($self->is_forward) {
        $self->{_body_params} = {};
    }
    else {
        $self->_parse_body;
    }

    # and merge everything
    $self->{params} = {
        %{ $self->{_query_params} },
        %{ $self->{_route_params} },
        %{ $self->{_body_params} },
    };

}

# TODO make wrapper
# TODO rename
sub _parse_cookies {
    my $self = shift;

    my $cookies_str = $self->env->{COOKIE} || $self->env->{HTTP_COOKIE};
    return if not $cookies_str;

    my $cookies = {};

    foreach my $cookie (split(/[,;]\s?/, $cookies_str)) {
        my ($name) = split '=', $cookie;
        $cookies->{$name} = $cookie;
    }

    $self->{_cookies} = $cookies;

    return $cookies;
}

# TODO make wrapper
# TODO rename
sub _parse_query {
    my $self = shift;

    return $self->{_query_params} if defined $self->{_query_params};

    # From Plack::Request
    my @query;
    my $query_string = $self->env->{QUERY_STRING};

    if (defined $query_string) {
        if ($query_string =~ /=/) {
            # Handle  ?foo=bar&bar=foo type of query
            @query =
                map { s/\+/ /g; URI::Escape::uri_unescape($_) }
                map { /=/ ? split(/=/, $_, 2) : ($_ => '') }
                split(/[&;]/, $query_string);
        }
        else {
            # Handle ...?dog+bones type of query
            @query =
                map { (URI::Escape::uri_unescape($_), '') }
                split(/\+/, $query_string, -1);
        }
    }

    my %params = _array_to_multivalue_hash(@query);
    $self->{_query_params} = \%params;

    return \%params;
}

# TODO make wrapper
# TODO rename
sub _parse_body {
    my $self = shift;
    return $self->{_body_params} if defined $self->{_body_params};

    my $content_length = $self->content_length;
    return if not $self->input;

    my $body;
    if ($content_length > 0) {
        while (my $buffer = $self->_read) {
            $body .= $buffer;
        }
    }

    $self->{_body_params} = $self->_parse_params($body) || {};
    return $self->{_body_params};
}

# XXX Obsolete, DEPRECATED
# XXX Delete
# XXX uses in _parse_body
sub _parse_params {
    my ($self, $params) = @_;

    return {} if not $params;

    my $pp;

    foreach my $token (split /[&;]/, $params) {
        my ($key, $val) = split(/=/, $token, 2);
        next if not defined $key;

        $key = $self->_url_decode($key);
        $val = (defined $val) ? $val : '';
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

# From Plack::Request
sub content {
    my $self = shift;

    my $fh = $self->input or return;
    my $length = $self->content_length or return;

    my $content;

    $fh->seek(0, 0);
    $fh->read($content, $length, 0);
    $fh->seek(0, 0);

    return $content;
}

# taken from Miyagawa's Plack::Request::BodyParser from Dancer::Request (=
sub _read {
    my $self = shift;

    my $remaining = $self->content_length - $self->{_read_position};
    my $maxlength = $self->{_chunk_size};

    return if $remaining <= 0;

    my $readlen = ($remaining > $maxlength) ? $maxlength : $remaining;

    my ($buffer, $rc);

    $rc = $self->input->read($buffer, $readlen);

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

sub _array_to_multivalue_hash {
    my @query = shift;
    my %params;
    while (my ($key, $value) = splice(@query, 0, 2)) {
        # multi value
        if (exists $params{$key}) {
            my $previous = $params{$key};

            if (ref $previous) {
                push(@{$params{$key}}, $value);
            }
            else {
                $params{$key} = [$previous, $value];
            }
        }
        # single value
        else {
            $params{$key} = $value;
        }
    }
    return %params;
}

1;

__END__

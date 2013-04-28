package Kompot::Request;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;
use URI::Escape;

use HTTP::Body;
use Stream::Buffered;

use base 'Kompot::Base';
use Kompot::Attributes;
use Kompot::Request::Upload;

has env => {};
has content_length => 0;
has content_type => undef;
has is_forward => 0;
has input  => undef;
has method => undef;
has path   => '/';
has uri    => undef;

sub init {
    my $self = shift;
    my $p = @_ % 2 ? @_ : {@_};

    my $env = $p->{env};

    # set attrs
    $self->env($env);
    $self->content_length($env->{CONTENT_LENGTH});
    $self->content_type($env->{CONTENT_TYPE});
    $self->input($env->{'psgi.input'} || $env->{'PSGI.INPUT'});
    $self->method($env->{REQUEST_METHOD});
    $self->path($env->{PATH_INFO});
    $self->uri($env->{REQUEST_URI});

    return 1;
}


sub params {
    my $self = shift;

    $self->env->{'kompot.request.merged'} ||= do {
        my $query = $self->_parse_params_query || {};
        my $route = $self->_parse_params_route || {};
        my $body = $self->_parse_params_body || {};

        return { %$query, %$route, %$body, };
    }
}

sub param {
    my ($self, $param) = @_;
    return $self->params->{$param};
}

sub uploads {
    my $self = shift;

    if ($self->env->{'kompot.request.upload'}) {
        return $self->env->{'kompot.request.upload'};
    }

    $self->_parse_params_body;
    return $self->env->{'kompot.request.upload'} || {};
}

sub upload {
    my ($self, $param) = @_;
    return $self->uploads->{$param};
}

sub _parse_params_route {
    my ($self, $p) = @_;

    if ($p) {
        map { $p->{$_} = URI::Escape::uri_unescape($p->{$_}) } keys %$p;
        $self->env->{'kompot.request.route'} = $p;
    }

    return $self->env->{'kompot.request.route'} || {};
}

sub _parse_params_query {
    my $self = shift;

    return $self->env->{'kompot.request.query'}
        if $self->env->{'kompot.request.query'};

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
    $self->env->{'kompot.request.query'} = \%params;

    return $self->env->{'kompot.request.query'} || {};
}

sub _parse_params_body {
    my $self = shift;

    my $ct = $self->content_type;
    my $cl = $self->content_length;

    if (!$ct && !$cl) {
        # No Content-Type nor Content-Length -> GET/HEAD
        return;
    }

    my $body = HTTP::Body->new($ct, $cl);

    # HTTP::Body will create temporary files in case there was an
    # upload.  Those temporary files can be cleaned up by telling
    # HTTP::Body to do so. It will run the cleanup when the request
    # env is destroyed. That the object will not go out of scope by
    # the end of this sub we will store a reference here.
    $self->env->{'kompot.request.http.body'} = $body;
    $body->cleanup(1);

    my $input = $self->input;

    my $buffer;
    if ($self->env->{'psgix.input.buffered'}) {
        # Just in case if input is read by middleware/apps beforehand
        $input->seek(0, 0);
    }
    else {
        $buffer = Stream::Buffered->new($cl); # XXX
    }

    my $spin = 0;
    while ($cl) {
        $input->read(my $chunk, $cl < 8192 ? $cl : 8192);

        my $read = length $chunk;
        $cl -= $read;

        $body->add($chunk);
        $buffer->print($chunk) if $buffer;

        if ($read == 0 && $spin++ > 2000) {
            croak "Bad Content-Length: maybe client disconnect? ($cl bytes remaining)";
        }
    }

    if ($buffer) {
        $self->env->{'psgix.input.buffered'} = 1;
        $self->env->{'psgi.input'} = $buffer->rewind;
    }
    else {
        $input->seek(0, 0);
    }

    $self->env->{'kompot.request.body'} = $body->param;

    my $uploads = $body->upload;
    my @obj;
    for my $k (keys %$uploads) {
        my $v = Kompot::Request::Upload->new($uploads->{$k});
        push(@obj, $k, $v);
    }

    my %uploads = _array_to_multivalue_hash(@obj);
    $self->env->{'kompot.request.upload'} = \%uploads;

    return $self->env->{'kompot.request.body'} || {};
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

sub _array_to_multivalue_hash {
    my @query = @_;
    my %params;
    while (my ($key, $value) = splice(@query, 0, 2)) {
        next if not $key;
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

sub cookie {
    my ($self, $name) = @_;
    $self->cookies or return;
    return $self->env->{'kompot.cookie.parsed'}{$name} if $name;
    return $self->env->{'kompot.cookie.parsed'};
}

# like Plack::Request::cookies
sub cookies {
    my $self = shift;

    my $http_cookie = $self->env->{HTTP_COOKIE} or return;

    if (   $http_cookie
        && $self->env->{'kompot.cookie.parsed'}
        && $http_cookie eq $self->env->{'kompot.cookie.string'})
    {
        return $self->env->{'kompot.cookie.parsed'};
    }

    my %cookies;

    for my $pair (grep { /=/ } split '[;,] ?', $http_cookie) {
        # trim leading trailing whitespace
        $pair =~ s/^\s+//;
        $pair =~ s/\s+$//;

        my ($key, $value) =
            map { URI::Escape::uri_unescape($_) } split "=", $pair, 2;

        # Take the first one like CGI.pm or rack do
        $cookies{$key} = $value if not exists $cookies{$key};
    }

    $self->env->{'kompot.cookie.string'} = $http_cookie;
    $self->env->{'kompot.cookie.parsed'} = \%cookies;

    return $self->env->{'kompot.cookie.parsed'} || {};
}


1;

__END__

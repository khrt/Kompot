package Kompot::Routes;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };

use base 'Kompot::Base';
use Kompot::Request;
use Kompot::Routes::Route;
use Kompot::Controller;

sub init {
    my $self = shift;
    $self->{routes} ||= [];
}

sub add {
    my ($self, $methods, $path, $code) = @_;

    $methods = [$methods] if not ref($methods);

    foreach my $method (@$methods) {
        if ($self->{_routes_list}{$method}{$path}) {
            carp "Route `$path` redefined!";
        }

        my $route =
            Kompot::Routes::Route->new(
                { method => $method, path => $path, code => $code, }
            );
        push(@{ $self->{routes} }, $route);
        $self->{_routes_list}{$method}{$path} = 1;
    }
}

sub routes {
    map { { method => $_->method, path => $_->path } } @{ shift->{routes} };
}

sub find {
    my ($self, $method, $path) = @_;
    grep {(uc($method) eq $_->method) && $_->match($path)} @{ $self->{routes} };
}

1;

__END__

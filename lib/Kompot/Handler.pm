package Kompot::Handler;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';

sub start {
    my $self = shift;
    my $app = $self->psgi_app;
    return $app;
}

sub psgi_app {
    my $self = shift;

    return
        sub {
            my $env = shift;
            $self->app->request(env => $env);
            my $res = $self->process_request;
            return $res;
        };
}

sub process_request {
    my $self = shift;

    my $app = $self->app;

    my $res;
    eval { $res = $app->routes->dispatch };

    if ($@) {
        $res = $app->render->internal_error($@);
    }

    # drop `content` and `content_length`
    # if `response` is `1xx` or `204`, `304`
    if ($res->status =~ /^(?:2|3)04$|^1\d{2}$/) {
        $res->{content} = [''];
        $res->header('content-length' => 0);
    }

    return [$res->status, $res->headers, $res->content];
}

1;

__END__

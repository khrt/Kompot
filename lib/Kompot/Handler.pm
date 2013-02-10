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

    my $res = $self->app->dispatch;
    if (not $res) {
        croak "STOP EXECUTING! FATAL ERROR OCCURED!\n$@";
    }

    return [$res->status, $res->headers, $res->content];
}

1;

__END__

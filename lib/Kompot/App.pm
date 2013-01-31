package Kompot::App;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };

use base 'Kompot::Base';
use Kompot::Attributes;
use Kompot::Config;
use Kompot::Controller;
use Kompot::Handler;
use Kompot::Renderer;
use Kompot::Routes;
use Kompot::Session;

has 'development';
has 'main';
has 'name' => 'Kompot';
has 'secret';

sub init { 
    my $self = shift;
    $self->name('Kompot_' . $Kompot::VERSION);
}

sub request { 
    my $self = shift;
    state $request;
    $request = Kompot::Request->new(@_) if scalar @_;
    return $request;
}

sub renderer { state $renderer ||= Kompot::Renderer->new }
sub render   { goto &renderer }

sub routes { state $route ||= Kompot::Routes->new }
sub route  { goto &routes }

sub conf { state $conf ||= Kompot::Config->new }

sub run {
    my $self = shift;

    if (not $self->main) {
        croak 'Can not detect `main` class!';
    }

    if (not $self->secret) {
        croak 'Define `secret` before start application!';
    }
    
    if ($ENV{KOMPOT_DEVELOPMENT} || $self->development) {
        $self->development(1);
        carp 'DEVELOPMENT MODE';
    }

    my $handler = Kompot::Handler->new;
    my $response = $handler->start;

    return $response;
}

sub dispatch {
    my $self = shift;

    my $res;
    my $req = $self->request;
    my $c = Kompot::Controller->new($req);
    my $r = $self->routes;

    # static
    if ($req->is_static) {
        $res = $c->render_static; # XXX Direct render?
    }
    # action
    elsif (my ($route) = $r->find($req->method, $req->path)) {
        if ($route->cached) {
            $res = $route->cache;
        }
        else {
            # TODO Handle exceptions
            $res = $route->code->($c);
            if ($res && $res->status == 200) {
                $route->cache($res);
            }
        }
    }

    # 404
    if (not $res) {
        $res = $c->render_not_found;
    }

    return $res;
}

1;

__END__

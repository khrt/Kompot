package Kompot::Controller;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };

use base 'Kompot::Base';
use Kompot::Attributes;
use Kompot::Renderer;
use Kompot::Session;
use Kompot::Response;

has 'req';
has 'params';

sub init {
    my ($self, $req) = @_;

    $self->req($req);
    $self->params($req->params);
}

sub param {
    my ($self, $param) = @_;
    return $self->req->param($param);
}

sub stash {
    my $self = shift;
    my $stash = $self->{stash} ||= {};

    # all
    return $stash if not @_;
    # one
    return $stash->{ $_[0] } if @_ == 1 and not ref $_[0];
    # new
    my $v = @_ % 2 ? $_[0] : {@_};
    map { $stash->{$_} = $v->{$_} } keys %$v;

    return 1;
}

sub session {
    my $self = shift;
    my $session = $self->stash->{'kompot.session'} ||= {};

    # all
    return $session if not @_;
    # one
    return $session->{ $_[0] } if @_ == 1 and not ref $_[0];
    # new
    my $v = @_ % 2 ? $_[0] : {@_};
    map { $session->{$_} = $v->{$_} } keys %$v;

    return $self;
}

sub redirect_to {
    my ($self, $url) = @_;

    my $r =
        Kompot::Response->new(
            status   => 302,
            location => $url,
            content  => [],
        );

    return $r;
}

sub render {
    my $self = shift;
    my $p = @_ % 2 ? $_[0] : {@_};

    my $template = $p->{template} ? $p->{template} : undef;

    my $app = $self->app;

    my ($type, $out) = $app->renderer->render($self, $p);
    return if not $out;

    my $r =
        Kompot::Response->new(
            status         => 200,
            content_type   => $type,
            content_length => length($out),
            content        => $out,
        );

    return $r;
}

#sub render_static {
#    my $self = shift;
#    my $p = @_ % 2 ? $_[0] : {@_};
#
#    my ($type, $out) =
#        $self->renderer->static({
#            content_type => $p->{content_type},
#            path => $self->req->path,
#        });
#    return $self->render_not_found if not $out;
#
#    my $r =
#        Kompot::Response->new(
#            status         => 200,
#            content_type   => $type,
#            content_length => length($out),
#            content        => $out,
#        );
#
#    return $r;
#}

sub render_not_found {
    my $self = shift;

    $self->stash(
        engine      => 'mojo',
        template    => 'not_found',
        uri         => $self->req->path,
        development => $self->app->development
    );

    if ($self->app->development) {
        my @routes = $self->app->route->routes;
        $self->stash(routes => \@routes);
    }

    my $res = $self->render;
    $res->status(404);

    return $res;
}

# TODO
sub render_exception {
    my ($self, $error) = @_;

    my $stash = $self->stash;

    my $p;

    if ($self->app->development) {
        $p = {
            engine => 'mojo', # XXX by default use emperl
        };
    }

    $p->{template} = 'exception';

    my $res = $self->render($p);
    $res->status(500);

    return $res;
}

1;

__END__

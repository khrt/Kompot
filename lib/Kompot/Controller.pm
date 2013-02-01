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

    # XXX Move to Kompot::App
    # Init session from cookie
    my $cookie_str = $req->cookie($self->app->conf->cookie_name);
    $self->session(Kompot::Session->new($cookie_str)->params);

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

    my $text = $p->{text};
    my $json = $p->{json};

    my $app = $self->app;

    my $r = $app->renderer->render($self, $p);
    if ($r && $r->status == 200) {
        # Set cookie
        # XXX Move to Kompot:App?
        my $cookie = Kompot::Session->new->store($self->session);
        $r->set_cookie($cookie->to_string) if $cookie;
    }

    if (not $r) {
        return $self->render_exception('can not render');
    }

    return $r;
}

sub render_static {
    my $self = shift;
    my $path = $self->req->path;

    my $out = $self->render->static($path);
    return $self->not_found if not $out;

    my $r =
        Kompot::Response->new(
            content_type   => 'text/html', # TODO detect content-type
            content        => $out,
            status         => 200,
            content_length => length($out),
        );

    return $r;
}

# TODO
sub render_not_found {
    my $self = shift;

    my $req = $self->req;
    my %p = (path => $req->path,);

    if ($self->app->development) {
        $p{routes} = $self->app->route->routes;
    }

#    my $tmpl = $self->read_data_section(ref $self, 'not_found.html');

# TODO Move to Kompot::Renderer::render
    # Return user-defined 404
#    foreach my $p (@{$self->paths}) {
#        my $fp = $p . '/not_found.html';
#        return $self->static($fp) if -e $fp;
#    }
# TODO
# if has templates/not_found.html
#   render templates/not_found.html
# else
#   render default template

#    my $r =
#        Kompot::Response->new(
#            content_type   => 'text/plain',
#            content        => $out,
#            status         => 404,
#            content_length => length($out),
#        );

    return $self->render('not_found'); # XXX
}

# TODO
sub render_exception {
    my ($self, $error) = @_;

    my $stash = $self->stash;

    if ($self->app->development) {
        # params
    }

    return $self->render('exception');
#    my $r =
#        Kompot::Response->new(
#            content_type   => 'text/plain',
#            content        => $error,
#            status         => 500,
#            content_length => length($error),
#        );
#    return $r;
}

1;

__END__

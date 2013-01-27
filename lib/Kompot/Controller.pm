package Kompot::Controller;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };

use base 'Kompot::Base';

use Kompot::Renderer;
use Kompot::Session;

__PACKAGE__->import;

has 'req';
has 'params';

sub init {
    my ($self, $req) = @_;

    # Init session
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

sub render {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : {@_};

    my $template = $p->{template} ? $p->{template} : undef;

    my $text = $p->{text};
    my $json = $p->{json};

    my $app = $self->app;

    my $r = $app->render->dynamic($self, $p);
    if ($r && $r->status == 200) {
        # Set cookie
        my $cookie = Kompot::Session->new->store($self->session);
        $r->set_cookie($cookie->to_string) if $cookie;
    }

    return $r;
}

1;

__END__

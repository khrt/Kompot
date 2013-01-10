package Kompot::Controller;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };

use base 'Kompot::Base';

use Kompot::Renderer;


sub init {
    my $self = shift;

    $self->{req} = shift;
}

sub req { shift->{req} }

sub params {
    # return hashref of all params
    # key => value
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
    return $stash->{ $_[0] } if @_ == 1;

    # new
    my $v = @_ % 2 ? $_[0] : {@_};

    map { $stash->{$_} = $v->{$_} } keys %$v;

    return 1;
}

sub session {
    my $self = shift;

    my $s = $self->app->session;
say 'session in Controller';
p $s;

    return 1;
}

sub render {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : {@_};

    my $template = $p->{template} ? $p->{template} : undef;


    my $text = $p->{text};
    my $json = $p->{json};


    my $app = $self->app;

    $app->render->dynamic($self, $p);
}


1;

__END__

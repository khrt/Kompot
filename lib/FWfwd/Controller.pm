package FWfwd::Controller;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };

use base 'FWfwd::Base';

use FWfwd::Renderer;

sub init {
    my $self = shift;

    $self->{req} = shift;
}

sub req { shift->{req} }


sub params {
}

sub param { 
    my ( $self, $param ) = @_;
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
    my $v = @_ % 2 ? $_[0] : { @_ };

    map { $stash->{$_} = $v->{$_} } keys %$v;

    return 1;
}


sub render {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : { @_ };

    my $template = $p->{template} ? $p->{template} : undef;


    my $text = $p->{text};
    my $json = $p->{json};


    my $app = $self->app;

    $app->renderer->render( $self, $p);
}


1;

__END__

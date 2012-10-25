package FWfwd::Controller;

use v5.12;

use strict;
use warnings;

use utf8;

use base 'FWfwd::Base';

use FWfwd::Renderer;



sub params {
}

sub param {
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

    for my $k ( keys %$v ) {
        $stash->{$k} = $v->{$k};
    }

    return 1;
}


sub render {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : { @_ };

    my $template = $p->{template} ? $p->{template} : undef;


    my $text = $p->{text};
    my $json = $p->{json};


    my $app = FWfwd::App->app;

    $app->renderer->render( $self, $p);
}


1;

__END__

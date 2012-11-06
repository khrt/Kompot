package FWfwd::Renderer;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;

use base 'FWfwd::Base';

use FWfwd::Renderer::EPL;
use FWfwd::Renderer::JSON;
use FWfwd::Renderer::Static;
use FWfwd::Renderer::Text;

use FWfwd::Response;




#sub helpers { shift->{helpers} }
#
#sub add_helper {
#    my ( $self, $name, $code ) = @_;
#
#    carp "Replace helper $name!" if $self->{helpers}->{$name};
#
#    $self->{helpers}->{$name} = $code;
#
#    return 1;
#}




sub render {
    my ( $self, $c, $p ) = @_;

    $p ||= {};


    my $stash = $c->stash;

#p $p;
#p $stash;

    map { $p->{$_} = $stash->{$_} } keys(%$stash);


    
    my $json     = delete( $p->{json} );
    my $template = delete( $p->{template} );
    my $text     = delete( $p->{text} );



    my ( $type, $data );

    # JSON
    if ( defined($json) ) {
        ( $type, $data ) = FWfwd::Renderer::JSON->new->render( json => $json );
    }
    elsif ( defined($template) ) {

        # Mojo::Template
        # TT2
        # ???
        croak 'renderer not defined';

    }
    # Text
    elsif ( defined($text) ) {
        ( $type, $data ) = FWfwd::Renderer::Text->new->render( text => $text, params => $p );
    }
    else {
        croak 'internal error';
        return;
    }

    my $r = FWfwd::Response->new;

    $r->status(200);

    $r->header(
        'content-type'   => $type,
        'content-length' => length($data),

        'x-powered-by'   => $self->app->name,
    );

    $r->content($data);

    return $r;
}


sub static {
    my ( $self, $path ) = @_;

    my ( $type, $data ) = FWfwd::Renderer::Static->new->render($path);

    return if !$type;

    my $r = FWfwd::Response->new;

    $r->status(200);

    $r->header(
        'content-type'   => $type,
        'content-length' => length($data),

        'x-powered-by'   => $self->app->name,
    );

    $r->content($data);

    return $r;
}


sub not_found {
    my $self  = shift;
    my $error = shift;

    my $type = 'text/plain';

    my $r = FWfwd::Response->new;

    $r->status(404);

    $r->header(
        'content-type'   => $type,
        'content-length' => length($error),

        'x-powered-by'   => $self->app->name,
    );

    $r->content($error);

    return $r;
}

sub internal_error {
    my $self  = shift;
    my $error = shift;

    my $r = FWfwd::Response->new;

    $r->status(500);

    $r->header(
        'content-type'   => 'text/plain',
        'content-length' => length($error),

        'x-powered-by'   => $self->app->name,
    );

    $r->content($error);

    return $r;
}



sub _is_text {
    my ( $self, $content_type ) = @_;
    return $content_type =~ /(x(?:ht)?ml|text|json|javascript)/;
}


1;

__END__

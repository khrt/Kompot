package YAFW::Renderer;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;

use base 'YAFW::Base';

use YAFW::Renderer::EPL;
use YAFW::Renderer::JSON;
use YAFW::Renderer::Static;
use YAFW::Renderer::Text;

use YAFW::Response;




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




sub dynamic {
    my ( $self, $c, $p ) = @_;

    $p ||= {};


    my $stash = $c->stash;

#p $p;
#p $stash;

    map { $p->{$_} = $stash->{$_} } keys(%$stash);

    
    my $json     = delete( $p->{json} );
    my $template = delete( $p->{template} );
    my $text     = delete( $p->{text} );


    my $r;


    # JSON
    if ( defined($json) ) {
        $r = YAFW::Renderer::JSON->new->render( json => $json );
    }
    elsif ( defined($template) ) {

        # Mojo::Template
        # TT2
        # ???
        croak 'renderer not defined';

    }
    # Text
    elsif ( defined($text) ) {
        $r = YAFW::Renderer::Text->new->render( text => $text, params => $p );
    }
    else {

        YAFW::Response->new(
            content_type => 'text/plain',
            content      => 'internal error / no renderer',
            status       => 500,
        );

    }


    $r->status(200) if !$r->status;

    $r->header(
        'content-length' => length( $r->content ),
        'x-powered-by'   => $self->app->name,
    );

    return $r;
}


sub static {
    my ( $self, $path ) = @_;

    my $r = YAFW::Renderer::Static->new->render($path);

    if ( not $r ) {
        croak 'file not found';
        return;
    }

    $r->status(200);

    $r->header(
        'content-length' => length( $r->content ),
        'x-powered-by'   => $self->app->name,
    );

    return $r;
}


sub not_found {
    my $self  = shift;
    my $error = shift;

    my $type = 'text/plain';

    my $r = YAFW::Response->new;

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

    my $r = YAFW::Response->new;

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

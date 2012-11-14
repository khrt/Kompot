package YAWFW::Handler;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;

use base 'YAWFW::Base';




sub start {
    my $self = shift;

    my $app = $self->psgi_app;

    return $app;
}


sub psgi_app {
    my $self = shift;

    sub {
        my $env = shift;
        $self->app->request( env => $env );

        $self->process_request;
    };
}


sub process_request {
    my $self = shift;

#    Dancer::SharedData->reset_all( reset_vars => !$request->is_forward);

    # read cookies from client
#    Dancer::Cookies->init;

    my $app = $self->app;


    my $response;

    eval {
        $response = $app->routes->dispatch;
    };


    if ( $@ ) {
        $response = $app->render->internal_error($@);
    }

    return $self->render_response( $response );
}


sub render_response {
    my ( $self, $r ) = @_;

    # drop content AND content_length if reponse is 1xx or (2|3)04
    if ( $r->status =~ /^(?:2|3)04$/ ) {
        $r->{content} = [''];
        $r->header( 'content-length' => 0 );
    }

    # drop content if request is HEAD
#    $content = ['']
#        if ( defined Dancer::SharedData->request
#        && Dancer::SharedData->request->is_head() );

    return [ $r->status, $r->headers, $r->content ];
}


1;

__END__

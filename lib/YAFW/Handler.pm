package YAFW::Handler;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;

use base 'YAFW::Base';




sub start {
    my $self = shift;

    my $app = $self->psgi_app;

    return $app;
}


sub psgi_app {
    my $self = shift;

    sub {
        my $env = shift;

#        my $request = Dancer::Request->new(env => $env);
#        $self->handle_request($request);

        $self->process_request($env);
    };
}


sub process_request {
    my ( $self, $env ) = @_;

#p $env;

#    Dancer::SharedData->reset_all( reset_vars => !$request->is_forward);

    # read cookies from client
#    Dancer::Cookies->init;


    my $app = $self->app;

    my $response;

    eval {
        $response = $app->routes->dispatch($env);
    };


    if ( $@ ) {
        my $r = $self->app->render->internal_error($@);
        return $self->render_response($r);
    }

    if ( !$response ) {
        croak 'no reponse';
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

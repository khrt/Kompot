package FWfwd::Handler;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP;

use Plack::Request;

use base 'FWfwd::Base';




sub start {
    my $self = shift;

    my $app = $self->psgi_app;

    return $app;
}


sub psgi_app {
    my $self = shift;

    sub {
        my $env = shift;
p($env);

        my $he = $self->init_request_headers($env);

        return [ 200, [ 'Content-Type' => 'text/plain' ], [ p($env), "\r\n", p($he) ] ];

#        my $request = Dancer::Request->new(env => $env);
#        $self->handle_request($request);
    };

}


sub init_request_headers {
    my ( $self, $env ) = @_;

    my $plack = Plack::Request->new($env);
#p($plack);

#    Dancer::SharedData->headers( $plack->headers );
}




sub handle_request {
    my ( $self, $request ) = @_;

    my $ip_addr = $request->remote_address || '-';

#    Dancer::SharedData->reset_all( reset_vars => !$request->is_forward);


    # save the request object
#    Dancer::SharedData->request($request);


    # deserialize the request body if possible
#    $request = Dancer::Serializer->process_request($request)
#      if Dancer::App->current->setting('serializer');



    # read cookies from client
#    Dancer::Cookies->init;

#    if (Dancer::Config::setting('auto_reload')) {
#        Dancer::App->reload_apps;
#    }


    $self->process_request( $request );


    return $self->render_response;
}


sub process_request {
    my ( $self, $request ) = @_;

    my $action;

    $action = try {
               Dancer::Renderer->render_file
            || Dancer::Renderer->render_action
            || Dancer::Renderer->render_autopage
            || Dancer::Renderer->render_error(404);
    }
    continuation {
        # workflow exception (continuation)
        my ($continuation) = @_;

        $continuation->isa('Dancer::Continuation::Halted')
            or $continuation->rethrow();

      # special case for halted workflow continuation: still render the response
        Dancer::Serializer->process_response( Dancer::SharedData->response );
    }
    catch {
        my ($exception) = @_;

        Dancer::Factory::Hook->execute_hooks( 'on_handler_exception', $exception );

        Dancer::Logger::error(
            sprintf(
                'request to %s %s crashed: %s',
                $request->method, $request->path_info, $exception
            ) );

        # use stringification, to get exception message in case of a
        # Dancer::Exception
        Dancer::Error->new(
            code      => 500,
            title     => "Runtime Error",
            message   => "$exception",
            exception => $exception,
        )->render();
    };

    return $action;
}


sub render_response {
    my $self = shift;

    my $response = Dancer::SharedData->response();

    my $content = $response->content;




    unless ( ref($content) eq 'GLOB' ) {
        my $charset = setting('charset');
        my $ctype   = $response->header('Content-Type');

        if ( $charset && $ctype && _is_text($ctype) ) {
            $content = Encode::encode( $charset, $content )
                unless $response->_already_encoded;
            $response->header( 'Content-Type' => "$ctype; charset=$charset" )
                if $ctype !~ /$charset/;
        }
        $response->header( 'Content-Length' => length($content) )
            if !defined $response->header('Content-Length');
        $content = [$content];
    }
    else {
        if ( !defined $response->header('Content-Length') ) {
            my $stat = stat $content;
            $response->header( 'Content-Length' => $stat->size );
        }
    }




    # drop content if request is HEAD
    $content = ['']
        if ( defined Dancer::SharedData->request
        && Dancer::SharedData->request->is_head() );


    # drop content AND content_length if reponse is 1xx or (2|3)04
    if ( $response->status =~ (/^[23]04$/) ) {
        $content = [''];
        $response->header( 'Content-Length' => 0 );
    }


    Dancer::Logger::core( "response: " . $response->status );


    my $status  = $response->status();
    my $headers = $response->headers_to_array();


    # reverse streaming
    if ( ref $response->streamed and ref $response->streamed eq 'CODE' ) {
        return $response->streamed->( $status, $headers );
    }


    return [ $status, $headers, $content ];
}


1;

__END__

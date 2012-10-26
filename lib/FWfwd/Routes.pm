package FWfwd::Routes;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP { output => 'stdout' };

use base 'FWfwd::Base';

use FWfwd::Request;
use FWfwd::Routes::Route;


sub init {
    my $self = shift;

    $self->{routes} ||= [];
}

###

sub add {
    my $self = shift;

    my ( $methods, $path, $code ) = @_;

    $methods = [ $methods ] if not ref($methods);

    foreach my $method ( @$methods ) {
        my $route = 
            FWfwd::Routes::Route->new( {
                method => $method,
                path   => $path,
                code   => $code,
            } );

        push( @{ $self->{routes} }, $route );
    }
}



sub routes {
    map { { method => $_->method, path => $_->path } } @{ shift->{routes} }
}


sub find {
    my ( $self, $method, $path ) = @_;

    grep { $_->method eq uc($method) && $_->path eq $path } @{ shift->{routes} }
}


sub dispatch {
    my ( $self, $env ) = @_;

    my $req = FWfwd::Request->new($env);


    my ($route) = $self->find( $req->method, $req->path );
say 'route:';
p $route;

    if ( not defined($route) ) {

        # TODO try to render static file
        #      otherwise - 404
        #$self->app->renderer->render_static( $path );

        my $errmsg =
              'No route to `' . $req->path . '` via '
            . uc( $req->method )
            . ".\nAvailable routes:\n";

        my @routes = $self->routes;

        foreach ( @routes ) {
            $errmsg .= $_->{method} . "\t=> " . $_->{path} . "\n";
        }

#        croak $errmsg;

        my $r = $self->app->render->not_found($errmsg);

say '404';
p $r;
        return $r;
    }


    # cache here
    # return cached

    # return new && TODO cache
    my $r = $route->code->( FWfwd::Controller->new($req) );
    # end

#say 'result from controller';
#p $r;

    return $r;
}


1;

__END__

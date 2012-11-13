package YAFW::Routes;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP { output => 'stdout' };

use base 'YAFW::Base';

use YAFW::Request;
use YAFW::Routes::Route;
use YAFW::Controller;


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
            YAFW::Routes::Route->new( {
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

    grep { ( uc($method) eq $_->method ) && $_->match($path) } @{ $self->{routes} };
}


sub dispatch {
    my $self = shift;

    my $req = $self->app->request;

    my $res;

    # static
    if ( $req->is_static ) {
        $res = $self->app->render->static( $req->path );
    }
    # action
    elsif ( my ($route) = $self->find( $req->method, $req->path ) ) {

say 'route:';
p $route;
say "\n\n";

        if ( $route->cached ) {
            $res = $route->cache;
        }
        else {

            if ( $res = $route->code->( YAFW::Controller->new($req) ) ) {
                $route->cache($res);
            }
        }

    }
    # 404
    else {

        my $errmsg =
              'No route to `' . $req->path . '` via '
            . uc( $req->method )
            . ".\nAvailable routes:\n";

        my @routes = $self->routes;

        foreach ( @routes ) {
            $errmsg .= $_->{method} . "\t=> " . $_->{path} . "\n";
        }

        $res = $self->app->render->not_found($errmsg);

    }


    return $res;
}


1;

__END__

package FWfwd::Routes;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP;

use base 'FWfwd::Base';

use FWfwd::Routes::Route;


sub init {
    my $self = shift;

    $self->{routes} ||= [];
}

###

sub add {
    my $self = shift;

    my ( $methods, $path, $code ) = @_;

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
    my ( $self, $method, $path ) = @_;

    my ($route) = $self->find( $method, $path );
say 'route:';
p $route;

    if ( not defined($route) ) {

        my $errmsg = <<EOF;
No route to `$path` via ${ \uc($method) }.\n
Available routes:
EOF
        my @routes = $self->routes;
        foreach ( @routes ) {
            $errmsg .= $_->{method} . "\t=> " . $_->{path} . "\n";
        }

        croak $errmsg;
    }


    # cache here
    #
    # end

    my $response = $route->code->( FWfwd::Controller->new );
say 'result from controller';
p $response;


    return $response;
}


1;

__END__

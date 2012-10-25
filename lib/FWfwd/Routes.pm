package FWfwd::Routes;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP;

use base 'FWfwd::App';

use FWfwd::Routes::Route;


sub init {
    my $self = shift;

    $self->{routes} ||= [];
}

###

sub add {
    my $self = shift;

    my $route = 
        FWfwd::Routes::Route->new( {
            method => $_[0],
            path   => $_[1],
            code   => $_[2],
        } );

    push( @{ $self->{routes} }, $route );
}



sub routes {
    map { { $_->method => $_->path } } @{ shift->{routes} }
}


sub get_route_by_path {
    my ( $self, $method, $path ) = @_;

    grep { $_->method eq uc($method) && $_->path eq $path } @{ shift->{routes} }
}


sub dispatch {
    my ( $self, $method, $path ) = @_;

    my ($route) = $self->get_route_by_path( $method, $path );
p $route;

    croak "No route to `$path` via " . uc($method) if not defined($route);

    # cache here
    #
    # end

    my @r = $route->code->( FWfwd::Controller->new );
p @r;


    return @r;
}


1;

__END__

package FWfwd v0.0.1;

use v5.12;

use strict;
use warnings;

use utf8;

# FINDBIN
use FindBin;
use lib $FindBin::Bin;
# END

use DDP;


use File::Spec;


use FWfwd::App;
#use FWfwd::Config;

use FWfwd::Controller;

use FWfwd::Renderer;
use FWfwd::Routes;

#use FWfwd::Cookie;
#use FWfwd::Session;
#
#use FWfwd::Handler;
#
#use FWfwd::MIME;


use base 'Exporter';

our @EXPORT = qw(
    get put post delete

    param params

    start
);


###


sub get {
    FWfwd::App->app->route->add( 'get', @_ )
}

sub put { }
sub post { }
sub delete { }
sub head { }

###

sub start { goto &_start }

###

sub import {
    my ( $class, @args ) = @_;
    my ( $package, $script ) = caller;

    strict->import;
    utf8->import;
    
    $class->export_to_level( 1, $class, qw() );
}


###

sub _start {
    my $self = shift;
#p $self;


    my $app = FWfwd::App->app;

    my $response = $app->run;
#p $response;

    return $response;




    my @r;
    @r = $app->routes->dispatch( get => '/' );
#    @r = $app->routes->dispatch('/json');
p @r;

    return [ 200, [ $r[0] ], [ $r[1] ] ];
}



1;

__END__

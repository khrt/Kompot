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

sub _app { FWfwd::App->app }

###


sub delete { _app->route->add( ['delete'], @_ ) }
sub get    { _app->route->add( ['get'],    @_ ) }
sub head   { _app->route->add( ['head'],   @_ ) }
sub post   { _app->route->add( ['post'],   @_ ) }
sub put    { _app->route->add( ['put'],    @_ ) }

sub any    { _app->route->add(@_) }

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

    my $app = _app;

    my $response = $app->run;
#p $response;

    return $response;
}



1;

__END__

package FWfwd;

use v5.12;

use strict;
use warnings;

use utf8;

our $VERSION = '0.0.1';

# FINDBIN
use FindBin;
use lib $FindBin::Bin;
# END

use DDP output => 'stdout';

use File::Spec;

use FWfwd::App;


use base 'Exporter';

our @EXPORT = qw(
    delete get head options post put any

    app start
);

sub import {
    my ( $class, @args ) = @_;
    my ( $package, $script ) = caller;

    strict->import;
    utf8->import;
    
    $class->export_to_level( 1, $class, qw() );
}

sub _app   { FWfwd::App->app }
sub _start { _app->run }


### Export subs

sub app   { __PACKAGE__ }
sub start { goto &_start }

sub delete  { _app->route->add( ['delete'],  @_ ) }
sub get     { _app->route->add( ['get'],     @_ ) }
sub head    { _app->route->add( ['head'],    @_ ) }
sub options { _app->route->add( ['options'], @_ ) }
sub post    { _app->route->add( ['post'],    @_ ) }
sub put     { _app->route->add( ['put'],     @_ ) }

sub any     { _app->route->add(@_) }


1;

__END__


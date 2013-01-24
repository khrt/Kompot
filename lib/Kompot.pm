package Kompot;

use strict;
use warnings;

use utf8;
use v5.12;

our $VERSION = '0.15';

use FindBin;

use base 'Exporter';
use lib $FindBin::Bin;

use Kompot::App;

our @EXPORT = qw(
    delete get head options post put any
    app start
);

sub import {
    my ($class, @args) = @_;
    my ($package, $script) = caller;

    strict->import;
    utf8->import;
    
    $class->export_to_level(1, $class, qw());
}

sub _app   { Kompot::App->app }
sub _start { _app->run }

### Export subs

sub app   { __PACKAGE__ }
sub start { goto &_start }

sub secret { _app->secret(@_) }

sub delete  { _app->route->add(['delete'],  @_) }
sub get     { _app->route->add(['get'],     @_) }
sub head    { _app->route->add(['head'],    @_) }
sub options { _app->route->add(['options'], @_) }
sub post    { _app->route->add(['post'],    @_) }
sub put     { _app->route->add(['put'],     @_) }
sub any     { _app->route->add([qw(delete get head post put)], @_) }


1;

__END__


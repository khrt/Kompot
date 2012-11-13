package YAFW::App;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };

use base 'YAFW::Base';

use YAFW::Config;
use YAFW::Handler;
use YAFW::Renderer;
use YAFW::Routes;


#use YAFW::Cookie;
#use YAFW::Session;


sub renderer { state $_renderer ||= YAFW::Renderer->new }
sub render   { goto &renderer }

sub routes { state $_route ||= YAFW::Routes->new }
sub route  { goto &routes }

sub config { state $_config ||= YAFW::Config->new }

sub dir { shift->config }

#


#

sub run {
    my $self = shift;

    my $cfg = $self->config;
#p($cfg);

    my $handler = YAFW::Handler->new;
#p($handler);

    my $response = $handler->start;
#p($response);

    return $response;
}






1;

__END__

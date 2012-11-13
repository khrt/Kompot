package YAWFW::App;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };

use base 'YAWFW::Base';

use YAWFW::Config;
use YAWFW::Handler;
use YAWFW::Renderer;
use YAWFW::Routes;


#use YAWFW::Cookie;
#use YAWFW::Session;


sub name { 'yawfw-v' . $YAWFW::VERSION }


sub request { shift; state $_request ||= YAWFW::Request->new(@_) }

sub renderer { state $_renderer ||= YAWFW::Renderer->new }
sub render   { goto &renderer }

sub routes { state $_route ||= YAWFW::Routes->new }
sub route  { goto &routes }

sub config { state $_config ||= YAWFW::Config->new }

sub dir { shift->config }

#


#

sub run {
    my $self = shift;

    my $cfg = $self->config;
#p($cfg);

    my $handler = YAWFW::Handler->new;
#p($handler);

    my $response = $handler->start;
#p($response);

    return $response;
}






1;

__END__

package FWfwd::App;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };

use base 'FWfwd::Base';

use FWfwd::Config;

use FWfwd::Renderer;
use FWfwd::Routes;

use FWfwd::Handler;



use FWfwd::Controller;

#use FWfwd::Cookie;
#use FWfwd::Session;
#
#use FWfwd::Handler;
#
#use FWfwd::MIME;



#sub controller { state $_controller ||= FWfwd::Controller->new }

sub renderer { state $_renderer ||= FWfwd::Renderer->new }
sub render   { goto &renderer }

sub routes { state $_route ||= FWfwd::Routes->new }
sub route  { goto &routes }

sub config { state $_config ||= FWfwd::Config->load }

#


sub run {
    my $self = shift;

    my $cfg = $self->config;
#p($cfg);

    my $handler = FWfwd::Handler->new;
#p($handler);

    my $response = $handler->start;
#p($response);

    return $response;
}






1;

__END__

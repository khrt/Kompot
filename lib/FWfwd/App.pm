package FWfwd::App;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP;

use base 'FWfwd::Base';

use FWfwd::Config;

use FWfwd::Renderer;
use FWfwd::Routes;

use FWfwd::Handler;



sub app { state $_app ||= FWfwd::App->new }

#sub controller { state $_controller ||= FWfwd::Controller->new }
sub renderer   { state $_renderer   ||= FWfwd::Renderer->new }

sub routes  { state $_route ||= FWfwd::Routes->new }
sub route   { goto &routes }

sub config  { state $_config ||= FWfwd::Config->load }
sub conf    { goto &config }

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

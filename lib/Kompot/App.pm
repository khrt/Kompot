package Kompot::App;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };

use base 'Kompot::Base';

use Kompot::Config;
use Kompot::Handler;
use Kompot::Renderer;
use Kompot::Routes;

sub name { 'Kompot' . $Kompot::VERSION }

sub secret {
    my ($self, $value) = @_;

    state $secret;

    if ($value) {
        carp 'set secret value';
        $secret = $value;
    }

    return $secret;
}

sub request { 
    my $self = shift;

    state $_request;
    
    if (scalar @_) {
        $_request = Kompot::Request->new(@_);
    }

    return $_request;
}

sub renderer { state $_renderer ||= Kompot::Renderer->new }
sub render   { goto &renderer }

sub routes { state $_route ||= Kompot::Routes->new }
sub route  { goto &routes }

sub config { state $_config ||= Kompot::Config->new }
sub dir { goto &config }

#
# Main function
sub run {
    my $self = shift;

    my $cfg = $self->config;
#p($cfg);

    if (not $self->secret) {
        carp 'no secret';
        return;
    }

    my $handler = Kompot::Handler->new;
#p($handler);

    my $response = $handler->start;
#p($response);

    return $response;
}

1;

__END__

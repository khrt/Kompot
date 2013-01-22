package Kompot::App;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };

use base 'Kompot::Base';

use Kompot::Config;
use Kompot::Handler;
use Kompot::Renderer;
use Kompot::Routes;
use Kompot::Session;

# XXX NEED SECRET

sub name { 'Kompot' . $Kompot::VERSION }

sub request { 
    my $self = shift;

    state $_request;
    
    if ( scalar @_ ) {
        $_request = Kompot::Request->new(@_);
    }

    return $_request;
}

sub renderer { state $_renderer ||= Kompot::Renderer->new }
sub render   { goto &renderer }

sub routes { state $_route ||= Kompot::Routes->new }
sub route  { goto &routes }

sub config { state $_config ||= Kompot::Config->new }
sub dir { shift->config }

# XXX
sub session { state $_session ||= Kompot::Session->new(@_) }
sub cookie  { state $_cookie ||= Kompot::Cookie->new(@_) }

#
# Main function
sub run {
    my $self = shift;

    my $cfg = $self->config;
#p($cfg);

    my $handler = Kompot::Handler->new;
#p($handler);

    my $response = $handler->start;
#p($response);

    return $response;
}


1;

__END__

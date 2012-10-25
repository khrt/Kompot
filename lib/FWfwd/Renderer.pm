package FWfwd::Renderer;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP;
use Carp;

use base 'FWfwd::Base';

use FWfwd::Renderer::EPL;
use FWfwd::Renderer::Plain;
use FWfwd::Renderer::JSON;




#sub helpers { shift->{helpers} }
#
#sub add_helper {
#    my ( $self, $name, $code ) = @_;
#
#    carp "Replace helper $name!" if $self->{helpers}->{$name};
#
#    $self->{helpers}->{$name} = $code;
#
#    return 1;
#}




sub render {
    my ( $self, $c, $p ) = @_;

    $p ||= {};


    my $stash = $c->stash;

#p $p;
#p $stash;

    map { $p->{$_} = $stash->{$_} } keys(%$stash);


    
    my $text = delete( $p->{text} );
    my $json = delete( $p->{json} );



    my $response;

    # Text
    if ( defined($text) ) {

        my $response = FWfwd::Renderer::Plain->new->render( text => $text, params => $p );

    }
    # JSON
    elsif ( defined($json) ) {

        my $response = FWfwd::Renderer::JSON->new->render( json => $json );

    }
    # Template
    else {

    }


    return $response;
}


1;

__END__

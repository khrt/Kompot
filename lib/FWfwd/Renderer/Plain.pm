package FWfwd::Renderer::Plain;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP;

use base 'FWfwd::Base';


sub render {
    my $self = shift;

    my $p = { @_ };

    my $pp   = delete( $p->{params} );
    my $text = delete( $p->{text} );

    my $ctype = delete( $pp->{'content-type'} ) || 'text/plain';

    foreach my $ph ( keys(%$pp) ) {
        $text =~ s/<%\s?$ph\s?%>/$pp->{$ph}/g;
    }

    return {
        status  => 200,
        headers => [ 'content-type' => $ctype ],
        content => [ $text ],
    };
}



1;

__END__

package FWfwd::Renderer::Text;

use v5.12;

use strict;
use warnings;

use utf8;

use base 'FWfwd::Base';


sub render {
    my $self = shift;

    my $p = { @_ };

    my $pp    = delete( $p->{params} );
    my $text  = delete( $p->{text} );

    my $ctype = delete( $pp->{'content-type'} ) || 'text/plain';


    foreach my $ph ( keys(%$pp) ) {
        $text =~ s/<%\s?$ph\s?%>/$pp->{$ph}/g;
    }

    return $ctype, $text;
}


1;

__END__

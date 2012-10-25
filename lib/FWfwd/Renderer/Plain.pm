package FWfwd::Renderer::Plain;

use v5.12;

use strict;
use warnings;

use utf8;

use base 'FWfwd::Base';


sub render {
    my $self = shift;

    my $p = { @_ };

    my $pp = $p->{params};
    my $text = $p->{text};

    foreach my $ph ( keys(%$pp) ) {
        $text =~ s/<%\s?$ph\s?%>/$pp->{$ph}/g;
    }

    return 'text/plain', $text;
}



1;

__END__

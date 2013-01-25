package Kompot::Renderer::Text;

use strict;
use warnings;

use utf8;
use v5.12;

use base 'Kompot::Base';

sub render {
    my ($self, %p) = @_;

    my $pp   = delete($p{params});
    my $text = delete($p{text});

    # substitute values
    foreach my $ph (keys(%$pp)) {
        $text =~ s/<%\s?$ph\s?%>/$pp->{$ph}/g;
    }

    return $text;
}

1;

__END__

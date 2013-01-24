package Kompot::Renderer::Text;

use strict;
use warnings;

use utf8;
use v5.12;

use base 'Kompot::Base';

use Kompot::Response;

sub render {
    my ($self, %p) = @_;

    my $pp   = delete($p{params});
    my $text = delete($p{text});

    # substitute values
    foreach my $ph (keys(%$pp)) {
        $text =~ s/<%\s?$ph\s?%>/$pp->{$ph}/g;
    }

    return
        Kompot::Response->new(
            content_type => $pp->{'content-type'} || 'text/plain',
            content      => $text,
            status       => 200,
        );
}

1;

__END__

package Kompot::Renderer::JSON;

use v5.12;

use strict;
use warnings;

use utf8;

use JSON::XS;

use base 'Kompot::Base';

use Kompot::Response;

sub render {
    my $self = shift;

    my $p = { @_ };

    return
        Kompot::Response->new(
            content_type => 'application/json',
            content      => encode_json( $p->{json} ),
        );
}


1;

__END__

package FWfwd::Renderer::JSON;

use v5.12;

use strict;
use warnings;

use utf8;

use JSON::XS;

use base 'FWfwd::Base';


sub render {
    my $self = shift;

    my $p = { @_ };

    my $json = encode_json( $p->{json} );

    return 'application/json', $json;
}


1;

__END__

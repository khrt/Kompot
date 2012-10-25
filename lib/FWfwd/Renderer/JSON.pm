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

    return {
        status  => 200,
        headers => [ 'content-type' => 'application/json' ],
        content => [ encode_json( $p->{json} ) ],
    };
}


1;

__END__

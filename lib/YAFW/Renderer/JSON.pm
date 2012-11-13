package YAFW::Renderer::JSON;

use v5.12;

use strict;
use warnings;

use utf8;

use JSON::XS;

use base 'YAFW::Base';

use YAFW::Response;

sub render {
    my $self = shift;

    my $p = { @_ };

    return
        YAFW::Response->new(
            content_type => 'application/json',
            content      => encode_json( $p->{json} ),
        );
}


1;

__END__

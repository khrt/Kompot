package Kompot::Session;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP { output => 'stdout' };
use Digest::SHA qw(hmac_sha1_hex);
use JSON::XS;
use MIME::Base64;

use base 'Kompot::Base';

sub decode {
    my ($self, $value) = @_;

    if ($value =~ s/--([^\-]+)$//) {
        my $sign = $1;

        my $secret = 'secret'; # TODO $self->app->secret
        my $check_value = hmac_sha1_hex($value, $secret);
say "dec>>>sign>>>$sign";
say "dec>>>check_value>>>check_value>>$value";

        if (not secure_compare($sign, $check_value)) {
            # log message
            carp 'cookie sign is incorrect';
            return;
        }
    }
    else {
        # cookie is not signed
        carp 'cookie is not signed';
        return;
    }

    $value =~ s/-/=/g;
    my $p = decode_json(decode_base64($value)) or return;

    return $p;
}

sub encode {
    my ($self, $p) = @_;

    return if not keys %$p;

    my $value = encode_base64(encode_json($p), '');
    $value =~ s/=/-/g;

    # get secret
    my $secret = 'secret'; # TODO $self->app->secret

    my $hex = hmac_sha1_hex($value, $secret);

say "enc>>>value>>>$value";
say "enc>>>hex>>>$hex";
    $value = $value . '--' . $hex;

    return $value;
}

# Mojo::Util
sub secure_compare {
    my ($a, $b) = @_;
    return undef if length $a != length $b;
say ">>>secure_compare>>";
    my $r = 0;
    $r |= ord(substr $a, $_) ^ ord(substr $b, $_) for 0 .. length($a) - 1;
say ">>>secure_compare>>$r";
    return $r == 0;
}


1;

__END__

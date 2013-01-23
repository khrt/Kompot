package Kompot::Session;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };
use Digest::SHA qw(hmac_sha1_hex);
use JSON::XS;
use MIME::Base64;

use base 'Kompot::Base';

use Kompot::Cookie;

my $cookie_name    = 'kompot';
my $cookie_path    = '/';
my $cookie_expires = 30 * 60;

# from cookie to session values
sub load_params {
    my ($self, $cookies) = @_;
    my $cookie = $cookies->{$cookie_name} or return {};
    my $params = $self->decode($cookie->value);
    return $params || {};
}

# from session values to cookie
sub generate_cookie {
    my ($self, $p) = @_;

    my $cookie = Kompot::Cookie->new(
        name      => $cookie_name,
        value     => $self->encode($p),
        path      => $cookie_path,
        expires   => $cookie_expires,
        http_only => 1,
    );

    return $cookie;
}

sub decode {
    my ($self, $v) = @_;

    if ($v =~ s/--([^\-]+)$//) {
        my $sign = $1;

        my $secret = $self->app->secret;
        my $check_value = hmac_sha1_hex($v, $secret);

        if (not secure_compare($sign, $check_value)) {
            carp 'cookie sign is incorrect';
            return;
        }
    }
    else {
        carp 'cookie is not signed';
        return;
    }

    $v =~ s/-/=/g;
    my $p = decode_json(decode_base64($v)) or return;

    return $p;
}

sub encode {
    my ($self, $p) = @_;

    return if not keys %$p;

    my $v = encode_base64(encode_json($p), '');
    $v =~ s/=/-/g;

    my $secret = $self->app->secret;

    $v = $v . '--' . hmac_sha1_hex($v, $secret);
    return $v;
}

# Mojo::Util
sub secure_compare {
    my ($a, $b) = @_;
    return undef if length $a != length $b;
    my $r = 0;
    $r |= ord(substr $a, $_) ^ ord(substr $b, $_) for 0 .. length($a) - 1;
    return $r == 0;
}

1;

__END__

package Kompot::Config;

use strict;
use warnings;

use utf8;
use v5.12;

use FindBin qw($Bin);
#use YAML::XS qw(LoadFile);

use base 'Kompot::Base';

sub init {
    my $self = shift;

    my $root = $self->{app_root} = $Bin;

    my $config_file = '';
    my $config = '';#LoadFile();
    $self->{_config} = $config;
}

sub cache_ttl { 5 }

sub root { shift->{app_root} }
sub static { shift->{app_root} . '/static' }

#
# Cookie
#
sub secret {
    my ($self, $secret) = @_;
    $self->{_secret} = $secret if $secret;
    return $self->{_secret};
}

sub cookie_name {
    my ($self, $name) = @_;
    $self->{_cookie_name} = $name if $name;
    return $self->{_cookie_name} || 'kompot';
}

sub cookie_expires {
    my ($self, $expires) = @_;
    $self->{_cookie_expires} = $expires if $expires;
    return $self->{_cookie_expires} || 60 * 60; # one hour by default
}

1;

__END__

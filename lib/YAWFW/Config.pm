package YAWFW::Config;

use v5.12;

use strict;
use warnings;

use utf8;

use FindBin qw($Bin);
#use YAML::XS qw(LoadFile);


use base 'YAWFW::Base';


# constuctor like new
# return hashref
sub init {
    my $self = shift;

    my $root = $self->{app_root} = $Bin;

    my $config_file = '';
    my $config = '';#LoadFile();
    $self->{_config} = $config;

}

sub get {
    my ( $self, $key ) = @_;
    return $self->{_config}->{$key};
}


sub salt {
    '2ewdsock23ws9iockd'
}

sub cache_ttl {
    10
}

sub root { shift->{app_root} }
sub static { shift->{app_root} . '/static' }


1;

__END__

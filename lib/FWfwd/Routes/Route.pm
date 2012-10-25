package FWfwd::Routes::Route;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;

use base 'FWfwd::Base';


sub init {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : { @_ };

    croak 'Not enough parameters for add route'
        if ( !$p->{method} || !$p->{path} || !$p->{code} );

    map { $self->{$_} = $p->{$_} } keys( %$p );

    return 1;
}

sub method { uc( shift->{method} ) }
sub path   { shift->{path} }
sub code   { shift->{code} }


1;

__END__

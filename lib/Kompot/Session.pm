package Kompot::Session;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP { output => 'stdout' };

use base 'Kompot::Base';

my %SESSIONS;

sub init {
    my $self = shift;
    my $sid = shift;

    # check cookie with `sid`
    # - if: exists get it
    # - else: set cookie & save sid

    my $s;

    if ($sid) {
        return if not $self->get($sid);
    }
    else {
        $s = $self->cre;

        # how to get response?
    }

    # define engine

    return 1;
}

sub generate_sid {

}

# retrieve or create
sub current_session {
#    $self->set_cookie;
}

sub get {

}

sub read {
    #$session->{$key}
}

sub write {
    #$session->{key} = $value
    #$session->flush
}


1;

__END__

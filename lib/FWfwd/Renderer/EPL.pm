package FWfwd::Renderer::EPL;

use v5.12;

use strict;
use warnings;

use utf8;

use Mojo::Template;

use base 'FWfwd::Base';


#sub render {
#    my ( $self, $c, @p ) = @_;
#
#    my $args = @p % 2 ? $p[0] : { @p };
#
#    my $path = delete( $p->{path} );
#
#
#    my $prepend = q/
#my $self = shift;
#
#use Scalar::Util 'weaken';
#weaken $self;
#
#no strict 'refs';
#no warnings 'redefine';
#
## Helpers
#my $_H = $self->helpers;
#/;
#
#
#    for my $name ( sort keys %{ $self->helpers } ) {
#        next if $name !~ /^\w+$/;
#
#        $prepend .= <<END;
#sub $name;
#*$name = sub { \$_H->{'$name'}->(\$self, \@_) };
#END
#    }
#
#    $prepend .= q/
#use strict;    
#
## Stash
#my $_S = $self->stash;
#/;
#
#
#    for my $var ( keys %{ $self->stash } ) {
#        next if $var !~ /^\w+$/;
#
#        $prepend .= <<END;
#my \$$var = \$_S->{'$var'};
#END
#    }
#
#
#    my $mt = Mojo::Template->new;
#
#    $mt->prepend($prepend);
#
#    my $output = $mt->encoding('UTF-8')->render_file( $path, $self );
#
#
#    return 'text/html', $output;
#}





1;

__END__

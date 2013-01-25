package Kompot::Config;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use FindBin qw($Bin);

use base 'Kompot::Base';

# Path
__PACKAGE__->attr(root => $Bin);
__PACKAGE__->attr(static => "$Bin/static");

# Cache
__PACKAGE__->attr(cache_ttl => 0);

# Cookie
__PACKAGE__->attr(cookie_name => 'kompot');
__PACKAGE__->attr(cookie_expires => 60*60); # one hour

1;

__END__

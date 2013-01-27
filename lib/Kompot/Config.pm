package Kompot::Config;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use FindBin qw($Bin);

use base 'Kompot::Base';

__PACKAGE__->import;

# Path
has(root => $Bin);
has(static => "$Bin/static");

# Cache
has(cache_ttl => 0);

# Cookie
has(cookie_name => 'kompot');
has(cookie_expires => 60*60); # one hour

1;

__END__

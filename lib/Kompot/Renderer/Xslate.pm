package Kompot::Renderer::Xslate;

use strict;
use warnings;

use utf8;
use v5.12;

use Text::Xslate;

use base 'Kompot::Base';

use Kompot::Response;

sub init {
    my ($self, %xslate) = @_;

    my $conf = $self->app->conf;

    my $cache_dir = $conf->cache_dir;
    my @path      = $conf->template_paths;

    $self->{xslate} =
        Text::Xslate->new({
            cache_dir => $cache_dir,
            path      => \@path,
            %xslate,
        });

    return 1;
}

sub render {
    my ($self, %p) = @_;

    my $tmpl = delete($p{template});

    my $out;
    eval { $out = $self->{xslate}->render($tmpl, \%p); };
    if ($@) {
        carp $@;
        $out = '';
    }

    return
        Kompot::Response->new(
            content_type => 'text/html', # TODO detect content type
            content      => $out,
            status       => 200,
        );
}


1;

__END__

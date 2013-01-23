package Kompot::Renderer;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';

use Kompot::Renderer::EPL;
use Kompot::Renderer::JSON;
use Kompot::Renderer::Static;
use Kompot::Renderer::Text;
use Kompot::Response;

#sub helpers { shift->{helpers} }
#
#sub add_helper {
#    my ( $self, $name, $code ) = @_;
#
#    carp "Replace helper $name!" if $self->{helpers}->{$name};
#
#    $self->{helpers}->{$name} = $code;
#
#    return 1;
#}

sub dynamic {
    my ($self, $c, $p) = @_;

    $p ||= {};

    my $stash = $c->stash;
#p $p;
#p $stash;

    map { $p->{$_} = $stash->{$_} } keys(%$stash);

    my $json     = delete($p->{json});
    my $template = delete($p->{template});
    my $text     = delete($p->{text});

    my $r;

    # JSON
    if (defined($json)) {
        $r = Kompot::Renderer::JSON->new->render(json => $json);
    }
    elsif (defined($template)) {
        # Xslate
        # TT2
        # Mojo::Template
        croak 'renderer not defined';
    }
    # Text
    elsif (defined($text)) {
        $r = Kompot::Renderer::Text->new->render(text => $text, params => $p);
    }
    else {
        $r = $self->internal_error('No renderer');
    }

    # in case of errors
    if (not $r) {
        return $self->internal_error('render dynamic error');
    }

    return $self->_render($r);
}

sub static {
    my ($self, $path) = @_;

    my $r = Kompot::Renderer::Static->new->render($path);

    if (not $r) {
        croak 'file not found';
        return $self->not_found('file not found');
    }

    return $self->_render($r);
}

sub not_found {
    my ($self, $error) = @_;

    my $r =
        Kompot::Response->new(
            content_type => 'text/plain',
            content      => $error,
            status       => 404,
        );

    return $self->_render($r);
}

sub internal_error {
    my ($self, $error) = @_;

    my $r =
        Kompot::Response->new(
            content_type => 'text/plain',
            content      => $error,
            status       => 500,
        );

    return $self->_render($r);
}


sub _render {
    my ($self, $r) = @_;

    $r->header(
        'content-length' => length($r->content),
        'x-powered-by'   => $self->app->name,
    );

    $r->status(200) if !$r->status;

    return $r;
}

sub _is_text {
    my ($self, $content_type) = @_;
    return $content_type =~ /(x(?:ht)?ml|text|json|javascript)/;
}


1;

__END__

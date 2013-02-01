package Kompot::Renderer;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';
use Kompot::Attributes;
use Kompot::Renderer::JSON;
use Kompot::Renderer::Static;
use Kompot::Response;

has default_content_type => 'text/html';
has engine  => 'Kompot::Renderer::MojoTemplate';
has helpers => {};

sub init {
    my $self = shift;

    # def tmpl path
    my $tpath = $self->app->conf->root . '/templates';
    $self->paths([$tpath]);

    $self->add_helper(dummy => sub { 'DUMMY' });
}

sub add_helper {
    my ($self, $name, $cb) = @_;
    $self->{helpers}{$name} = $cb;
}

sub paths {
    my ($self, $path) = @_;
    if ($path && ref($path)) {
        push(@{ $self->{paths} }, @$path);
    }
    return $self->{paths};
}

sub render {
    my ($self, $c, $p) = @_;

    $p ||= {};

    my $stash = $c->stash;

    map { $p->{$_} = $stash->{$_} } keys(%$stash);

    my $json     = delete($p->{json});
    my $template = delete($p->{template});
    my $text     = delete($p->{text});
    my $type     = $p->{content_type} || $self->default_content_type;

    my $out;

    # JSON
    if (defined($json)) {
        $out = Kompot::Renderer::JSON->new->render(json => $json);
        $type = 'text/json';
    }
    # Text
    elsif (defined($text)) {
        $out = $text;
        $type = $p->{content_type} || 'text/plain';
    }
    elsif (defined($template)) {
        my $renderer = $self->engine;
        if ($self->load_package($renderer)) {
            $out = $renderer->new($c)->render($template);
        }
    }

    return if not $out;

    my $r =
        Kompot::Response->new(
            status         => 200,
            content_type   => $type,
            content_length => length($out),
            content        => $out,
        );

    return $r;
}

sub static {
    my ($self, $path) = @_;
    my $out = Kompot::Renderer::Static->new->render($path);
    return $out;
}

# TODO Maybe worth create implementing superclass for all template systems?
sub read_data_section {
    my ($self, $class, $data) = @_;
    state %CACHE;

    # Refresh or use cached data
    my $handle = do { no strict 'refs'; \*{"${class}::DATA"} };
    if (not fileno $handle) {
        return $data ? $CACHE{$class}{$data} : $CACHE{$class} || {};
    }

    seek $handle, 0, 0;
    my $content = join '', <$handle>;
    close $handle;

    # Ignore everything before __DATA__ (Windows will seek to start of file)
    $content =~ s/^.*\n__DATA__\r?\n/\n/s;

    # Ignore everything after __END__
    $content =~ s/\n__END__\r?\n.*$/\n/s;

    # Split
    my @data = split /^@@\s*(.+?)\s*\r?\n/m, $content;
    shift @data;

    # Find data
    my $all = $CACHE{$class} = {};
    while (@data) {
        my ($name, $content) = splice @data, 0, 2;
        $all->{$name} = $content;
    }

    return $data ? $all->{$data} : $all;
}

sub _is_text {
    my ($self, $content_type) = @_;
    return $content_type =~ /(x(?:ht)?ml|text|json|javascript)/;
}

1;

__DATA__

@@ not_found.html
<!DOCTYPE html>
<html>
<head>
<title>Not Found</title>
</head>
<body>
<h1>Page not found</h1>
<p>Requested URI not found.</p>
<% if ($dev_mode) {
  foreach my $r (@routes) {
    print $r->method;
    print $r->path;
  }
} %>
</body>
</html>

@@ exception.html
<!DOCTYPE html>
<html>
<head>
<title>Exception</title>
</head>
<body>
<h1>Exception</h1>
<p>An error was happened.</p>
</body>
</html>

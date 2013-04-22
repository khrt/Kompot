package Kompot::Template;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };

use Kompot::Attributes;

has 'tag_start'    => '<%';
has 'tag_end'      => '%>';
has 'line_start'   => '%';
has 'escape_mark'  => '=';
has 'comment_mark' => '#';

sub new {
    my $class = shift;
    my $self = bless {}, ref $class || $class;
    return $self;
}

#sub init {
#}

sub parse {
    my ($self, $data) = @_;

    my $tag_start    = $self->tag_start;
    my $tag_end      = $self->tag_end;
    my $line_start   = $self->line_start;
    my $escape_mark  = $self->escape_mark;
    my $comment_mark = $self->comment_mark;

    foreach my $line (split "\n", $data) {

    }

    return;
}

sub build {
    # 2 generate perl code
}

sub interpret {
    # 3 execute code
}

sub render {
    my ($self, $data) = @_;

    my $parsed_data = $self->parse($data);
p $parsed_data;

    return;
}

sub render_file {
    die;
}

1;

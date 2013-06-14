package Kompot::Template;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };

use Kompot::Attributes;

has 'tree';

sub new {
    my $class = shift;
    my $self = bless {}, ref $class || $class;
    return $self;
}

#sub init {
#}


sub prepend {
    # XXX
}
sub name {
    # XXX
    shift
}


sub parse {
    my ($self, $data) = @_;

    my $tag = '<%';#$self->tag_start;
    my $end = '%>';#$self->tag_end;

    my $replace = '%';#
    my $expr = '=';#
    my $escp = '=';#$self->escape_mark;

    my $cpst = 'begin';#
    my $cpen = 'end';#
    my $cmnt = '#';#$self->comment_mark;

    my $trim = '=';#
    my $start = '%';#


    my $token_re = qr/
        (
          $tag$replace                       # Replace
        |
          $tag$expr$escp\s*$cpen(?!\w)   # Escaped expression (end)
        |
          $tag$expr$escp                     # Escaped expression
        |
          $tag$expr\s*$cpen(?!\w)        # Expression (end)
        |
          $tag$expr                          # Expression
        |
          $tag$cmnt                          # Comment
        |
          $tag\s*$cpen(?!\w)             # Code (end)
        |
          $tag                               # Code
        |
          (?<!\w)$cpst\s*$trim$end       # Trim end (start)
        |
          $trim$end                          # Trim end
        |
          (?<!\w)$cpst\s*$end            # End (start)
        |
          $end                               # End
        )
      /x;
    my $cpen_re = qr/^($tag)(?:$expr)?(?:$escp)?\s*$cpen/;
    my $end_re  = qr/^(?:($cpst)\s*)?($trim)?$end$/;


    my $state = 'text';
    my ($trimming, @capture_token);
    for my $line (split "\n", $data) {

#        # Perl line
#        if ($state eq 'text' && $line !~ s/^(\s*)\Q$start$replace\E/$1$start/) {
#            $line =~ s/^(\s*)\Q$start\E(\Q$expr\E)?//
#            and $line = $2 ? "$1$tag$2$line $end" : "$tag$line $trim$end";
#        }

        # Comment line
        next if $line =~ /^$start$cmnt/;

        # Escaped line ending
        if ($line =~ /(\\+)$/) {
            my $len = length $1;

            # Newline
            if ($len == 1) {
                $line =~ s/\\$//;
            }
            # Backslash
            elsif ($len > 1) {
                $line =~ s/\\\\$/\\\n/;
            }
        }
        # Normal line ending
        else {
            $line .= "\n";
        }

        my @token;
        for my $token (split $token_re, $line) {
            # capture end
            @capture_token = ('cpen', undef) if $token =~ s/$cpen_re/$1/;

            # end
            if ($state ne 'text' && $token =~ $end_re) {
                splice(@token, -2, 0, 'cpst', undef) if $1;

                if ($2) {
                    $trimming = 1;
                    $self->_trim(\@token); # XXX 
                }

                push @token, 'text', '';
            }
            # code
            elsif ($token =~ /^$tag$/) {
                $state = 'code';
            }
            # expression
            elsif ($token =~ /^$tag$expr$/) {
                $state = 'expr';
            }
            # expression that needs to be escaped
            elsif ($token =~ /^$tag$expr$escp$/) {
                $state = 'escp';
            }
            # comment
            elsif ($token =~ /^$tag$cmnt$/) {
                $state = 'cmnt';
            }
            # value
            else {
                $token = $tag if $token eq "$tag$replace";

                if ($trimming && $token =~ s/^(\s+)//) {
                    push @token, 'code', $1;
                    $trimming = 0;
                }

                # comments
                next if $state eq 'cmnt';
                push @token, @capture_token, $state, $token;
                @capture_token = ();
            }

            if ($token =~ /\n$/) {
                
            }
        }
        push @{ $self->{tree} }, \@token;
    }

    return $data; # XXX
}

sub build {
}

sub interpret {
}

sub render {
    my ($self, $data) = @_;

    my $parsed_data = $self->parse($data);

    return $parsed_data;
}

sub render_file {
    my ($self, $path) = splice @_, 0, 2;
    
    my $tmpl = _read_file($path);

    return $self->render($tmpl, @_);
}

sub _read_file {
    my $path = shift;
    open my $fh, '<', $path;
    my $data = do { local $/; <$fh> };
    close $fh;
    return $data;
}

1;

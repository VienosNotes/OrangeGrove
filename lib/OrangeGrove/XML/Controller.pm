package OrangeGrove::XML::Controller;

use 5.12.3;
use Moose;
use MooseX::AttributeHelpers;
use XML::Simple;

use Data::Dumper;

use OrangeGrove::XML::Config;
use OrangeGrove::XML::Page;
use OrangeGrove::XML::Renderer;

has proj => (
    is => "ro"
);

has pages => (
    metaclass => "Collection::Array",
    is => "rw",
    isa => "ArrayRef",
    default => sub { [] },
    provides => {
        push => "add_page",
    },
);

has renderer => (
    is => "rw",
);

has log => (
    is => "rw",
);

has config => (
    is => "rw",
);

sub BUILDARGS {
    my ($self, $proj) = @_;

    return { proj => $proj };
}

sub BUILD {

    my $self = shift;

    print " => loading scenario.xml ...";
    my $tree = XML::Simple->new->XMLin($self->proj . "scenario.xml");
    say "done.";

    print " => loading config.xml ...";
    $self->config(OrangeGrove::XML::Config->new(XML::Simple->new->XMLin($self->proj . "config.xml")));
    say "done.";

    for (0.. scalar @{$tree->{page}}) {
        print ("\r => Building page " .  ($_ + 1) . " / " . (scalar(@{$tree->{page}}) + 1) . " ...");
        if ($_ == 0) {
            $self->add_page(OrangeGrove::XML::Page->new($self)->init($tree->{page}->[0]));
        }
        else {
            $self->add_page(OrangeGrove::XML::Page->new($self)->init($tree->{page}->[$_], $self->pages->[$_-1]));
        }
    }
    say "done.";

    $self->renderer(OrangeGrove::XML::Renderer->new($self->proj, @{$self->pages}));
#    $self->renderer->init();
    $self->renderer->run();
}

1;

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

    my $tree = XML::Simple->new->XMLin($self->proj . "/scenario.xml");
    $self->config(OrangeGrove::XML::Config->new(XML::Simple->new->XMLin($self->proj . "/config.xml")));

    for (0.. scalar @{$tree->{page}}) {
        if ($_ == 0) {
            $self->add_page(OrangeGrove::XML::Page->new($self)->init($tree->{page}->[0]));
        }
        else {
            $self->add_page(OrangeGrove::XML::Page->new($self)->init($tree->{page}->[$_], $self->pages->[$_-1]));
        }
    }

    $self->renderer(OrangeGrove::XML::Renderer->new(@{$self->pages}));
    $self->renderer->init();
    $self->renderer->run();
}

1;

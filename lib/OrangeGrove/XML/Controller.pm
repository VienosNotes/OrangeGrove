package OrangeGrove::XML::Controller;

use 5.12.3;
use Moose;
use MooseX::AttributeHelpers;

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
    is => "ro",
);

has log => (
    is => "rw",
);

has config => (
    is => "ro",
);

sub BUILDARGS {
    my ($self, $proj) = @_;

    return { proj => $proj };
}

sub BUILD {
    my $self = shift;

    my $tree = XML::Simple->new->XMLin($proj . "/scenario.xml");
    $self->config(OrangeGrove::XML::Config->new(XML::Simple->new->XMLin($proj . "/config.xml")));

    for (0..${$tree->{pages}}) {
        if ($_ == 0) {
            $self->add_page(OrangeGrove::XML::Page->new($self, $tree->{pages}->[0]));
        }
        else {
            $self->add_page(OrangeGrove::XML::Page->new($self, $tree->{pages}->[$_], $tree->{pages}->[$_-1]));
        }
    }

    $self->renderer(OrangeGrove::XML::Renderer->new($self->config));
}
return 1;

package OrangeGrove::XML::Controller;

use 5.14.0;
use Moose;
use MooseX::AttributeHelpers;
use XML::Simple;
use XML::LibXML;
use Digest::SHA1 qw/sha1_hex/;
use OrangeGrove::XML::Config;
use OrangeGrove::XML::Page;
use OrangeGrove::XML::Renderer;
use OrangeGrove::Utils;

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
}

sub run {
    my $self = shift;
    open my $prof, ">", $self->proj . "profile";

    print " => loading scenario.xml ...";
    my $tree = XML::Simple->new->XMLin($self->proj . "/scenario.xml");
    say "done.";

    print " => loading config.xml ...";
    $self->config(OrangeGrove::XML::Config->new(XML::Simple->new->XMLin($self->proj . "config.xml")));
    say "done.";
    OrangeGrove::Cache->initialize(proj => $self->proj, config => $self->config);
    my $page;
    for (0.. (scalar @{$tree->{page}} -1)) {
        print ("\r => Building page " .  ($_ + 1) . " / " . (scalar(@{$tree->{page}})) . " ...");
        if ($_ == 0) {
            $page = OrangeGrove::XML::Page->new($self)->init($tree->{page}->[0]);
            $self->add_page($page);
        }
        else {
            $page = OrangeGrove::XML::Page->new($self)->init($tree->{page}->[$_], $self->pages->[$_-1]);
            $self->add_page($page);
        }
        $self->_output_profile($prof, $page);
    }
    say "done.";
    close $prof;
    $self->renderer(OrangeGrove::XML::Renderer->new($self->proj, @{$self->pages}));
    $self->renderer->run();
}

sub _output_profile {
    my ($self, $prof, $page) = @_;
    say $prof (sha1_hex(Dumper $page->fg, $page->bg) . "-" . sha1_hex(Dumper $page->name, $page->msg));
}

1;

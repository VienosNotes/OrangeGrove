########################################################################
#
#  Pager::XML::Page - Convert from XML scenario files to Page objects.
#  Wrote by D.Aoki in 2011.03.17 - yyyy.mm.dd
#
########################################################################

package OrangeGrove::XML::Page;
use 5.14.0;
use Moose;
use MooseX::AttributeHelpers;
use Data::Dumper;

has proj => (
    is => "ro",
);

has title => (
    is => "rw",
);

has bg => (
    is => "rw",
);

has fg => (
    metaclass => "Collection::Array",
    is => "rw",
    isa => "ArrayRef",
    default => sub { [] },
    provides => {
        push => "add_fg",
        clear => "clear_fg",
    },
);

has name => (
    is => "rw",
);

has msg => (
    is => "rw",
);

has ext => (
    is => "rw",
);

has config => (
    is => "rw",
);

has tree => (
    is => "ro",
);

sub BUILDARGS {

    my ($self, $ctrlr) = @_;

    return { proj => $ctrlr->proj, config => $ctrlr->config };
}

sub init {

    my ($self, $tree, $prev) = @_;

    $self->clear unless defined $prev;

    #ページタイトルは引き継がないので毎回初期化
    if (defined $tree->{title}) {
        $self->title($tree->{title});
    } else {
        $self->title("none");
    }

    #背景画像の上書き/引き継ぎ/初期化
    if (defined $tree->{fig}->{bg}->{fig}) {
        $self->bg($tree->{fig}->{bg}->{fig});
    } elsif (defined $prev) {
        $self->bg($prev->bg);
    } else {
        $self->bg("none");
    }

    #前景画像リストの上書き/引き継ぎ/初期化
    $self->clear_fg;

    #$self->fgをclearしてからpushで突っ込む
    for (0..$self->config->fg_max - 1) {
        if (defined $tree->{fig}->{fg}->{"pos$_"}) {
            $self->add_fg($tree->{fig}->{fg}->{"pos$_"});
        } elsif (defined $prev) {
            $self->add_fg($prev->fg->[$_]);
        } else {
            $self->add_fg("none");
        }
    }

    #発言者は引き継がないので毎回初期化
    if (! $tree->{text}->{name} eq "") {
        $self->name($tree->{text}->{name})
    } else {
        $self->name("none");
    }

    #本文は引き継がないので毎回初期化
    if (defined $tree->{text}->{msg}) {
        $self->msg($tree->{text}->{msg});
    } else {
        $self->msg("none");
    }

    #拡張は引き継がないので毎回初期化
    if (defined $tree->{ext}) {
        $self->ext($tree->{ext});
    } else {
        $self->ext("none");
    }

    return $self;
}

sub clear {
    my $self = shift;

    $self->bg("none");
    for (0..$self->config->fg_max) {
        $self->add_fg("none");
    }
    $self->name("none");
    $self->msg("none");
    $self->ext("none");

    return $self;
}

1;

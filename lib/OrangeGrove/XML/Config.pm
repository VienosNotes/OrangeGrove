package OrangeGrove::XML::Config;

use 5.14.0;
use Moose;

our $VERSION = "1.0";

#出力画面サイズ
has size => (
    is => "rw",
    isa => "HashRef[Int]",
);

#出力設定
has output => (
    is => "rw",
    isa => "HashRef",
);

#立ち絵の数
has fg_max => (
    is => "rw",
    isa => "Int",
);

#立ち絵の位置
has fg_pos => (
    isa => "ArrayRef[HashRef[Int]]",
    is => "rw",
);

#文字の設定
has character => (
    is => "rw",
    isa => "HashRef",
);

#メッセージボッックスの設定
has msgbox => (
    is => "rw",
    isa => "HashRef",
);

#表示スタイルの設定
has style => (
    is => "rw",
    isa => "HashRef[Int]",
);


sub BUILDARGS {
    my ($self, $tree) = @_;
    return {
        size => $tree->{system}->{size},
        output => $tree->{system}->{output},
        fg_max => scalar @{$tree->{fig}->{fg}->{pos}},
        fg_pos => $tree->{fig}->{fg}->{pos},
        character => $tree->{text}->{character},
        msgbox => $tree->{text}->{msgbox},
        style => $tree->{text}->{style},
    }
}

1;

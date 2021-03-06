package OrangeGrove::XML::Renderer;

use 5.14.0;

use Moose;
use MooseX::AttributeHelpers;
use Imager;
use Imager::Font;
use Imager::DTP::Textbox::Horizontal;
use OrangeGrove::Utils;
use OrangeGrove::Cache;

has pages => (
    isa => "ArrayRef",
    is => "rw"
);

has done => (
    isa => "Int",
    is => "rw"
);

has proj => (
    is => "ro"
);

has total => (
    is => "rw",
    isa => "Int"
);

sub BUILDARGS {
    my ($self, $proj, @pages) = @_;
    return { proj => $proj, pages => \@pages, done => 1};
}

sub _init {
    my $self = shift;
    sayd;
    $self->total(@{$self->pages} * $self->pages->[0]->config->output->{wait} * $self->pages->[0]->config->output->{frame});

}

sub run {
    my $self = shift;
    $self->_init;
    for (@{$self->pages}) {
        my $img = $self->_build($_);
        $self->_write($img) for 1..($self->pages->[0]->config->output->{wait} * $self->pages->[0]->config->output->{frame});
    }
        say "done.";
}

sub _build {
    my ($self, $page)  = @_;

    #背景のロード
    my $bg = OrangeGrove::Cache->load($page->bg);
#    my $bg = Imager->new;
#    $bg->read(file => $self->proj . "fig/" . $page->bg . ".png") or die $bg->errstr;
    $bg = $bg->scale(type => "nonprop", xpixels => $page->config->size->{x}, ypixels => $page->config->size->{"y"});

    #前景のロード
    for (0..$page->config->fg_max) {

        next if ((!defined $page->fg->[$_]) or ($page->fg->[$_] eq "none"));
        my $fg = OrangeGrove::Cache->load($page->fg->[$_]);
        # my $fg = Imager->new;
        # $fg->read(file => $self->proj . "fig/" . $page->fg->[$_] . ".png") or die $fg->errstr;

        #背景と合成

        $bg->rubthrough(src => $fg,
                        tx => $page->config->size->{x} * ($page->config->fg_pos->[$_]->{xmid} / 100) - $fg->getwidth/2,
                        ty => $page->config->size->{"y"} * ($page->config->fg_pos->[$_]->{ymid} / 100) - $fg->getheight/2
                    ) or die $bg->errstr;
    }

    #名前も文章もnoneならメッセージボックスを表示しない
    unless ($page->name eq "none" && $page->msg eq "none") {
        #メッセージボックスのロード
        my $msgbox = OrangeGrove::Cache->load($page->config->msgbox->{fig});
        # my $msgbox = Imager->new;
        # $msgbox->read(file => $self->proj . "fig/" . $page->config->msgbox->{fig} . ".png") or die $msgbox->errstr;


        #フォントのロード
        my $font = OrangeGrove::Cache->load_font(file => $self->proj . $page->config->character->{font} . ".ttf",
                                                 size => $page->config->character->{size},
                                                 aa => 1,
                                                 color => Imager::Color->new(r => 255, g => 255, b => 255));
        # my $font = Imager::Font->new(file => $self->proj . $page->config->character->{font} . ".ttf",
                                     # size => $page->config->character->{size},
                                     # aa => 1,
                                     # color => Imager::Color->new(r => 255, g => 255, b => 255)
        #                          );

        die "フォント見つからないよ" unless defined $font;

        #テキストの生成
        my $text = $page->msg;
        $text =~ s/\A\n//;
        $text =~ s/\t+//g;

        unless ($page->name eq "none") {
            #名前からタブと二文字以上の空白の除去
            my $name = $page->name;
            $name =~ s/\n//g;
            $name =~ s/\t+//g;
            $name =~ s/\s\s+//g;
            $text = " - " . $name . " - \n" . $text;
        } else {
            $text = "\n" . $text;
        }

        my $tb = Imager::DTP::Textbox::Horizontal->new(text => $text,
                                                       font => $font,
                                                       wspace => 1,
                                                       leading => 130,
                                                       halign => "left",
                                                       valign => "top",
                                                       wrapWidth => int $msgbox->getwidth - ($msgbox->getwidth * ($page->config->msgbox->{xmergin} / 50)),
                                                       wrapHeight => int $msgbox->getheight - ($msgbox->getheight * ($page->config->msgbox->{ymergin} / 50)),
                                                       xscale => 1,
                                                       yscale => 1
                                                   );
#        say scalar @{$tb->getLines};
        #テキストの合成
        $tb->draw(target => $msgbox,
                  x => $msgbox->getwidth * ($page->config->msgbox->{xmergin} / 100),
                  y => $msgbox->getheight * ($page->config->msgbox->{ymergin} /100),
              );

        #メッセージボックスの合成
        $bg->rubthrough(src => $msgbox,
                        tx => $page->config->size->{x} * ($page->config->msgbox->{x} / 100) - $msgbox->getwidth/2,
                        ty => $page->config->size->{"y"} * ($page->config->msgbox->{"y"} / 100) - $msgbox->getheight/2,
                    ) or die $bg->errstr;
    }
    return $bg;
}

sub _write {

    my ($self, $img) = @_;
    local $| = 1;
    print "\r";
    printf (" => Drawing frame %d / %d ...", $self->done, $self->total);
    mkdir $self->proj . "/output" unless -d $self->proj . "/output";
    my $num = sprintf("%010d", $self->done);
    $img->write(file => $self->proj . "/output/" . $num . ".png") if $OrangeGrove::FLAGS{OUTPUT};
    $self->done($self->done + 1);

}

sub run_with_index {
    # 可変フレームレート未対応版
    # インデックスはページ番号であり、フレーム番号ではないことに注意
    my ($self, $idx) = @_;

    my $img = $self->_build_with_index($idx);
    $self->_write_with_index($idx, $img);
    # mkdir $self->proj . "/output" unless -d $self->proj . "/output";
    # my $name = $self->config->output->{wait} * $self->config->output->{frame} * $idx;

    # my $num = sprintf("%010d", $self->done);
    # $img->write(file => $self->proj . "/output/" . $num . ".png");
    # $self->done($self->done + 1);

}

sub _write_with_index {
    my ($self, $idx, $img) = @_;

    mkdir $self->proj . "/output" unless -d $self->proj . "/output";
    my $start = $self->config->output->{wait} * $self->config->output->{frame} * $idx;

    for (1..($self->config->output->{wait} * $self->config->output->{frame})) {
        my $num = sprintf("%010d", $start);
        $img->write(file => $self->proj . "/output/" . $num . ".png");
        $self->done($start + 1);
    }
}

sub _build_with_index {

    my ($self, $idx) = @_;
    my $count = $self->config->output->{wait} * $self->config->output->{frame};

    my $target = $self->page->[$idx];
    return $self->_build($target);
}

return 1;

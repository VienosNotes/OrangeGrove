use 5.12.3;
use OrangeGrove;
use Test::More;
use Moose;

my $og = OrangeGrove->new(type => "XML", proj => "./t/proj");
ok $og->type eq "XML";
ok $og->proj eq "./t/proj";

done_testing;

use 5.12.3;
use OrangeGrove;
use Test::More;
use Moose;

my $og = OrangeGrove->new(type => "XML", proj => "./proj");
ok $og->type eq "XML";
ok $og->proj eq "./proj";

done_testing;

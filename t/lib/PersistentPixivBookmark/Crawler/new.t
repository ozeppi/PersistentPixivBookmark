use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok 'PersistentPixivBookmark::Crawler';
};

my $crawler = PersistentPixivBookmark::Crawler->new();
isa_ok $crawler, 'PersistentPixivBookmark::Crawler';
isa_ok $crawler->_crawler, 'WWW::Mechanize';

done_testing;

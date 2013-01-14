use strict;
use warnings;

use Test::More;
use Test::MockModule;

BEGIN {
    use_ok 'PersistentPixivBookmark::Crawler';
};

my $LATEST_IMAGE_URL = 'http://ozeppi.com/hoge.jpg';

my $mocked_latest_image_log = Test::MockModule->new(
    'PersistentPixivBookmark::LatestImageLog'
);
$mocked_latest_image_log->mock(get => sub {
    return $LATEST_IMAGE_URL;
});

my $crawler = PersistentPixivBookmark::Crawler->new();
is(
    $crawler->includes_already_saved_image([
        'http://ozeppi.com/fuga.jpg',
        $LATEST_IMAGE_URL,
        'http://ozeppi.com/piyo.jpg',
    ]),
    1,
);

is(
    $crawler->includes_already_saved_image([
        'http://ozeppi.com/fuga.jpg',
        'http://ozeppi.com/piyo.jpg',
    ]),
    0,
);

done_testing;

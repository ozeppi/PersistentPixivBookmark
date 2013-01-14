use strict;
use warnings;

use Test::More;
use Test::MockModule;

BEGIN {
    use_ok 'PersistentPixivBookmark::BookmarkReader';
};

my $mocked_latest_image_log = Test::MockModule->new(
    'PersistentPixivBookmark::LatestImageLog'
);
$mocked_latest_image_log->mock(get => sub { 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=25878749'} );

my $bookmark_reader = PersistentPixivBookmark::BookmarkReader->new({});

is(
    $bookmark_reader->_includes_already_saved_image([qw/
        a.php
        b.php
    /]),
    0,
);

is(
    $bookmark_reader->_includes_already_saved_image([qw|
        a.php
        b.php
        http://www.pixiv.net/member_illust.php?mode=medium&illust_id=25878749
    |]),
    1,
);

done_testing;

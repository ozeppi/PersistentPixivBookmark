use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::MockModule;

my $DUMMY_FILE_NAME = 'latest_image_url.log';
my $DUMMY_DIRECTORY_PATH = 't/lib/PersistentPixivBookmark/dummy_log/';
my $DUMMY_FILE_PATH = $DUMMY_DIRECTORY_PATH . $DUMMY_FILE_NAME;

BEGIN {
    use_ok 'PersistentPixivBookmark::LatestImageLog';
};

my $mocked = Test::MockModule->new('PersistentPixivBookmark::LatestImageLog');
$mocked->mock(FILE_PATH_LATEST_IMAGE => sub {
    return $DUMMY_FILE_PATH;
});
$mocked->mock(DIRECTORY_PATH_LATEST_IMAGE => sub {
    return $DUMMY_DIRECTORY_PATH;
});

subtest 'get, when not exists log-file' => sub {
    _unlink_dummy_file() if -e $DUMMY_FILE_PATH;
    is(PersistentPixivBookmark::LatestImageLog->get, '');
};

subtest 'save and get' => sub {
    lives_ok(sub {
        PersistentPixivBookmark::LatestImageLog->save("hoge.jpg");
    });
    is(
        PersistentPixivBookmark::LatestImageLog->get(),
        'hoge.jpg',
    );
};

subtest 'control character' => sub {
    lives_ok(sub {
        PersistentPixivBookmark::LatestImageLog->save("hoge.jpg\n");
    });
    is(
        PersistentPixivBookmark::LatestImageLog->get(),
        'hoge.jpg',
    );
    lives_ok(sub {
        PersistentPixivBookmark::LatestImageLog->save("hoge.jpg\r\n");
    });
    is(
        PersistentPixivBookmark::LatestImageLog->get(),
        'hoge.jpg',
    );
};

sub _unlink_dummy_file { unlink $DUMMY_FILE_PATH; }

END {
    _unlink_dummy_file();
    rmdir $DUMMY_DIRECTORY_PATH;
};

done_testing;

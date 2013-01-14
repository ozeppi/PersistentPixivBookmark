package PersistentPixivBookmark::LatestImageLog;

use strict;
use warnings;

use Path::Class qw/file/;

sub FILE_PATH_LATEST_IMAGE {
    return &DIRECTORY_PATH_LATEST_IMAGE .  'latest_image_url.log';
};
sub DIRECTORY_PATH_LATEST_IMAGE { '.log/'; }

sub get {
    my ($class) = @_;
    return '' unless -e &FILE_PATH_LATEST_IMAGE();
    my $latest_image_url = file(&FILE_PATH_LATEST_IMAGE())->slurp();
    $latest_image_url =~ s/\r\n//g;
    chomp($latest_image_url);
    return $latest_image_url;
}

sub save {
    my ($class, $latest_image_url) = @_;
    return unless $latest_image_url;

    mkdir &DIRECTORY_PATH_LATEST_IMAGE unless -d &DIRECTORY_PATH_LATEST_IMAGE;

    my $fh = file(&FILE_PATH_LATEST_IMAGE())->openw();
    print $fh $latest_image_url;
    return;
}

1;

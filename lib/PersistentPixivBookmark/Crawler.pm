package PersistentPixivBookmark::Crawler;

use parent qw/Class::Accessor::Fast/;

use WWW::Mechanize;
use Web::Query;
use List::MoreUtils qw/any/;
use PersistentPixivBookmark::Identity;
use PersistentPixivBookmark::LatestImageLog;
use PersistentPixivBookmark::BookmarkReader;
use PersistentPixivBookmark::Log;

__PACKAGE__->mk_ro_accessors(qw/_crawler/);

sub new {
    my ($class) = @_;
    return $class->SUPER::new({
        _crawler => WWW::Mechanize->new(agent => 'Mac Safari'),
    });
}

sub save_unsaved_images {
    my ($self) = @_;

    $self->login();
    $self->move_bookmark();
    my $bookmark_reader = PersistentPixivBookmark::BookmarkReader->new({
        crawler => $self->_crawler,
    });
    my $image_page_url_list = $bookmark_reader->get_unsaved_image_page_url_list();
    unless (scalar @$image_page_url_list) {
        PersistentPixivBookmark::Log->debug('unsaved image not found.');
        return;
    }
    PersistentPixivBookmark::LatestImageLog->save($image_page_url_list->[0]);
    for my $image_page_url (@$image_page_url_list) {
        $self->save($image_page_url);
    }
    return;
}

sub login {
    my ($self) = @_;

    $self->_crawler->get('https://ssl.pixiv.net/login.php');
    my $response = $self->_crawler->submit_form(
        form_number => 2,
        fields  => {
            pixiv_id    => PersistentPixivBookmark::Identity->id,
            pass        => PersistentPixivBookmark::Identity->pass,
        },
    );
    PersistentPixivBookmark::Log->debug(sprintf(
        'method: login() is %s',
        $response && $response->is_success ? 'success' : 'failed',
    ));
    return $response->is_success ? 1 : 0;
}

sub move_bookmark {
    my ($self) = @_;

    my $bookmark_link = $self->_crawler->find_link(url_regex => qr/bookmark.php/);
    my $response = $self->_crawler->get($bookmark_link);

    PersistentPixivBookmark::Log->debug(sprintf(
        'method: move_bookmark() is %s',
        $response && $response->is_success ? 'success' : 'failed',
    ));
    return $response->is_success ? 1 : 0;
}

sub save {
    my ($self, $image_page_url) = @_;
    $self->_crawler->get($image_page_url);
    next unless $self->_crawler->find_link(url_regex => qr/member_illust\.php\?mode=big/);
    _random_sleep();
    $self->_crawler->follow_link(url_regex => qr/member_illust\.php\?mode=big/);
    my $target_page_html = $self->_crawler->content();
    my $img_url = Web::Query->new_from_html($target_page_html)->find('img')->attr('src');
    print "$img_url\n";
    _random_sleep();
    my $file_name = ($img_url =~ qr|/(\d+)\.jpg|) ? "$1.jpg" : sprintf('%d.jpg', time());
    $self->_crawler->get($img_url, ':content_file' => "saved_images/$file_name");
}

sub _save_to_local {
}

sub _save_to_cloud { die 'yet implement'; }

sub _random_sleep {
    sleep(int(rand(4)));
}

1;

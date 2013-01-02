#/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use WWW::Mechanize;
use Web::Query;

my $crower = WWW::Mechanize->new(agent => 'Mac Safari');
$crower->get('https://ssl.pixiv.net/login.php');

$crower->submit_form(
    form_number => 2,
    fields  => {
        pixiv_id    => 'ozeppi',
        pass        => '851226tsukasa',
    },
);

my $bookmark_link = $crower->find_link(url_regex => qr/bookmark.php/);
$crower->get($bookmark_link);
my $bookmark_page_html = $crower->content();
my $images_url_list = Web::Query->new_from_html($bookmark_page_html)->find('div.linkStyleWorks ul li a')->filter(sub {
    my ($i, $element) = @_;
    $element->attr('href') =~ /member_illust\.php/ && $element->attr('href') =~ /illust_id=\d+/;
})->map(sub {
    my ($i, $element) = @_;
    sprintf(
        'http://www.pixiv.net/%s',
        $element->attr('href'),
    );
});
print Dumper $images_url_list;

for my $url (@$images_url_list) {
    $crower->get($url);
    next unless $crower->find_link(url_regex => qr/member_illust\.php\?mode=big/);
    sleep(1);
    $crower->follow_link(url_regex => qr/member_illust\.php\?mode=big/);
    my $target_page_html = $crower->content();
    my $img_url = Web::Query->new_from_html($target_page_html)->find('img')->attr('src');
    print "$img_url\n";
    sleep(1);
    my $file_name = ($img_url =~ qr|/(\d+)\.jpg|) ? "$1.jpg" : sprintf('%d.jpg', time());
    $crower->get($img_url, ':content_file' => $file_name);
}

#print $crower->content();

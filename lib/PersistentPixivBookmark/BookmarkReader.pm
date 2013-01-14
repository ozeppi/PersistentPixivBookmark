package PersistentPixivBookmark::BookmarkReader;

use strict;
use warnings;

use parent qw/Class::Accessor::Fast/;

use List::MoreUtils qw/before any/;
use Web::Query;
use PersistentPixivBookmark::LatestImageLog;
use PersistentPixivBookmark::Log;

__PACKAGE__->mk_ro_accessors(qw/
    crawler
/);
__PACKAGE__->mk_accessors(qw/
    _is_EOP
    _is_last
/);

sub new {
    my ($class, $args) = @_;
    return $class->SUPER::new({
        %$args,
        _is_EOP => 0,
    });
}

sub get_unsaved_image_page_url_list {
    my ($self) = @_;

    my @unsaved_image_page_url_list;
    my $is_complete = 0;
    while (!$is_complete) {
        PersistentPixivBookmark::Log->debug("start read at " . $self->crawler->uri);
        my $image_page_url_list = $self->_pickup_image_page_url_list();
        my $filtered_image_page_url_list = $self->_filter_image_page_url_list(
            $image_page_url_list
        );
        push @unsaved_image_page_url_list, @$filtered_image_page_url_list;

        my $exists_saved_image_at_current_page = $self->_includes_already_saved_image(
            $image_page_url_list
        );
        $is_complete = 1 if $exists_saved_image_at_current_page;

        unless ($is_complete) {
            if (my $next_link = $self->has_next()) {
                $self->next($next_link);
            } else {
                $is_complete = 1;
            }
        }

        PersistentPixivBookmark::Log->debug('end read.');
    }
    return \@unsaved_image_page_url_list;
}

sub has_next {
    my ($self) = @_;
    my $next_links = $self->crawler->find_all_links(
        class   => 'button',
        url_regex => qr/bookmark.php.+p=\d+/,
    );
    return $next_links
        ? (scalar $next_links > 1) ? $next_links->[1] : $next_links->[0]
        : $next_links;
}

sub next {
    my ($self, $link) = @_;
    sleep(1);
    $self->crawler->get($link);
    $self->_is_EOP(0);
    return $self;
}

sub _pickup_image_page_url_list {
    my ($self) = @_;

    my $bookmark_page_html = $self->crawler->content();
    $self->_is_EOP(1);
    return Web::Query->new_from_html($bookmark_page_html)->find('div.linkStyleWorks ul li a')->filter(sub {
        my ($i, $element) = @_;
        $element->attr('href') =~ /member_illust\.php/ && $element->attr('href') =~ /illust_id=\d+/;
    })->map(sub {
        my ($i, $element) = @_;
        sprintf(
            'http://www.pixiv.net/%s',
            $element->attr('href'),
        );
    });
}

sub _filter_image_page_url_list {
    my ($self, $image_page_url_list) = @_;
    my $latest_image_page_url = PersistentPixivBookmark::LatestImageLog->get();
    return [before {
        $latest_image_page_url eq $_
    } @$image_page_url_list];
}

sub _includes_already_saved_image {
    my ($self, $image_page_url_list) = @_;
    my $latest_image_page_url = PersistentPixivBookmark::LatestImageLog->get();
    return (any {$latest_image_page_url eq $_} @$image_page_url_list) ? 1 : 0;
}

1;

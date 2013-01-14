#/usr/env perl

use strict;
use warnings;

use FindBin::libs;

use PersistentPixivBookmark::Crawler;

my $crawler = PersistentPixivBookmark::Crawler->new();
$crawler->save_unsaved_images();

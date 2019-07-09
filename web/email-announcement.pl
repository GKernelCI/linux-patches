#!/usr/bin/perl
# Copyright 2014 Gentoo Foundation; Distributed under the GPL v2

use Cwd;
#use gentoo_sources_web;

$tag = shift;
$kernel_name = shift;
$LOCAL_TMP = shift;
$REMOTE_BASE = shift;

if ($tag =~ m/(2\.6\.\d+)-(\d+)/) {
    $ver = $1;
    $rel = $2;
}
else { # support for kernels >= 3.0
    $tag =~ m/(\d+\.\d+)-(\d+)/;
    $ver = $1;
    $rel = $2;
}

$have_history = 0;
$website_base = 'http://dev.gentoo.org/~mpagano/genpatches';

$result = `rm -rf ${LOCAL_TMP}/linux-patches`;
$result = `cd $LOCAL_TMP`;
$result = `git -C ${LOCAL_TMP}/linux-patches reset`;

# for X.Y.0 kernels, you can't do a shallow clone
# for non X.Y.0 kernels (notice the 0), you can do a shallow clone
if ($rel == 1) {
	$result = `git clone $REMOTE_BASE ${LOCAL_TMP}/linux-patches`;
}
else {
	$result = `git clone -b $ver --single-branch $REMOTE_BASE ${LOCAL_TMP}/linux-patches`;
}

# checkout branch, not really needed fir subgke-branch checkout
$result = `git -C ${LOCAL_TMP}/linux-patches checkout ${ver}`;

# Try and find previous release
if ($rel > 1) {
	$oldtag = $ver.'-'.($rel-1);
    $cmd='git -C '.${LOCAL_TMP}.'/linux-patches rev-list '.$oldtag;
    @output = `$cmd`;

    foreach $line (@output) { 
        $have_history = 1;
        if (index($line, "fatal") != -1) {
            $have_history =0;
        }
        if ($have_history == 0) {
           break;
        }
    }

    if ($have_history == 1) {
        $cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" --name-status '.$oldtag.'..'.$tag;
        @log_lines = `$cmd`;
        $have_history = 1;
    }
    else {
        $cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" --name-status '.$tag;
        @log_lines = `$cmd`;
    }
}
else {
    # just do git log
    $cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" --name-status  master..remotes/origin/'.$ver.' /tmp/linux-patches';
    @log_lines = `$cmd`;
}

$email .= "To: Gentoo Kernel List <gentoo-kernel\@lists.gentoo.org>\n";
$email .= "Subject: [ANNOUNCE] $kernel_name-$tag release\n";

$email .= "\nThis is an automated email announcing the release of $kernel_name-$tag\n\n";

if ($have_history) {
	$email .= "\nCHANGES SINCE $oldtag\n";
}
else {
	$email .= "\nCHANGES\n";
}
	$email .= "-----------------------\n\n";
	foreach $line (@log_lines) {
        if (index($line, "0000_README") == -1) {
            $email .= "$line";
        }
	}

if ($kernel_name == "genpatches") {
	$email .= "\n\nABOUT GENPATCHES\n";
	$email .= "----------------\n\n";
	$email .= "genpatches is the patchset applied to some kernels available in Portage.\n\n";
	$email .= "For more information, see the genpatches homepage:\n";
	$email .= $website_base."\n\n";
	$email .= "For a simple example of how to use genpatches in your kernel ebuild, look at a\n";
	$email .= "recent gentoo-sources ebuild.\n";
}

print $email;

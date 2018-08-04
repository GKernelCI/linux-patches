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
#$result = `git clone --depth=50 $REMOTE_BASE ${LOCAL_TMP}/linux-patches`;
$result = `git clone -b $ver --single-branch $REMOTE_BASE ${LOCAL_TMP}/linux-patches`;

# checkout branch
$result = `git -C ${LOCAL_TMP}/linux-patches checkout ${tag}`;

# Try and find previous release
if ($rel > 1) {
	$oldtag = $ver.'-'.($rel-1);
    $cmd='git -C '.${LOCAL_TMP}.'/linux-patches rev-list '.$oldtag;
#    printf ("1 cmd is $cmd\n");
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
#    	printf ("2 cmd is $cmd\n");
        @log_lines = `$cmd`;
        $have_history = 1;
    }
    else {
        $cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" --name-status '.$tag;
#    	printf ("3 cmd is $cmd\n");
        @log_lines = `$cmd`;
    }
}
else {
    # just do git log
    #$cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" --name-status '.$ver;
    #$cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" ..'.$tag;
    $cmd='git --no-pager -C '.${LOCAL_TMP}.'/linux-patches log  --pretty=format:"%s (%an)" '.$tag.'...master';
#    printf ("4 cmd is $cmd\n");
    @log_lines = `$cmd`;
}


#if ($rel > 1) {
#	$oldtag = $ver.'-'.($rel-1);
#	#$cmd = 'svn log -q --stop-on-copy '.$subversion_root.'/tags/'.$oldtag;
#	#$cmd = 'svn log -q --stop-on-copy '.$subversion_root.'/tags/'.$oldtag;
#
#    # check out branch
#    printf("LOCAL_TMP is ${LOCAL_TMP}\n");
#    $cmd='git -C '.${LOCAL_TMP}.' checkout '.$ver;
#    @result = `$cmd`;
#
#    # get log in between tags
#    $cmd='git -C '.${LOCAL_TMP}.' log '.$oldtag.'..'.$tag.' --name-status';
#    printf (" cmd is $cmd\n");
#
#	@log_lines = `$cmd`;
#	$lastrev = 0;
#	foreach (@log_lines) {
#		next if $_ !~ /^r(\d+) \|/;
#		$lastrev = $1;
#		last;
#	}
#}
#
#printf("lastrev is $lastrev\n");
#
#if ($lastrev) {
#    printf("inside lastrev\n");
#	@commits = _parse_log($tag, $lastrev);
#	$have_history = @commits;
#}
#
#local $ext;
#$ext = get_tarball_ext($tag);
#
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

#$email .= "\nPATCHES\n";
#$email .= "-------\n\n";
#$email .= "When the website updates, the complete patch list and split-out patches will be\n";
#$email .= "available here:\n";
#$email .= $website_base."/patches-".$tag.".html\n";
#$email .= $website_base."/tarballs/".$kernel_name."-".$tag.".base.tar".$ext."\n";
#$email .= $website_base."/tarballs/".$kernel_name."-".$tag.".extras.tar".$ext."\n";
#$email .= $website_base."/tarballs/".$kernel_name."-".$tag.".experimental.tar".$ext."\n";

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

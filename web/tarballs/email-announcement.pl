#!/usr/bin/perl
# Copyright 2005 Gentoo Foundation; Distributed under the GPL v2

use Cwd;
use gentoo_sources_web;

$tag = shift;
$kernel_name = shift;

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

# Try and find previous release
if ($rel > 1) {
	$oldtag = $ver.'-'.($rel-1);
	$cmd = 'svn log -q --stop-on-copy '.$subversion_root.'/tags/'.$oldtag;
	@log_lines = `$cmd`;
	$lastrev = 0;
	foreach (@log_lines) {
		next if $_ !~ /^r(\d+) \|/;
		$lastrev = $1;
		last;
	}
}

if ($lastrev) {
	@commits = _parse_log($tag, $lastrev);
	$have_history = @commits;
}

local $ext;
$ext = get_tarball_ext($tag);

$email .= "To: Gentoo Kernel List <gentoo-kernel\@lists.gentoo.org>\n";
$email .= "Subject: [ANNOUNCE] $kernel_name-$tag release\n";

$email .= "\nThis is an automated email announcing the release of $kernel_name-$tag\n\n";

if ($lastrev && $have_history) {
	$email .= "\nCHANGES SINCE $oldtag\n";
	$email .= "-----------------------\n\n";
	foreach $rev (@commits) {
		next if !$rev->{'rev'};
		chomp $rev->{'logmsg'};
		$email .= 'Revision '.$rev->{'rev'}.': ';
		$email .= $rev->{'logmsg'}.' ('.$rev->{'author'}.')'."\n";
		$email .= 'Added: '.$_."\n" foreach (@{$rev->{'actionA'}});
		$email .= 'Modified: '.$_."\n" foreach (@{$rev->{'actionM'}});
		$email .= 'Deleted: '.$_."\n" foreach (@{$rev->{'actionD'}});
		$email .= "\n";
	}
}

$email .= "\nPATCHES\n";
$email .= "-------\n\n";
$email .= "When the website updates, the complete patch list and split-out patches will be\n";
$email .= "available here:\n";
$email .= $website_base."/patches-".$tag.".htm\n";
$email .= $website_base."/tarballs/".$kernel_name."-".$tag.".base.tar".$ext."\n";
$email .= $website_base."/tarballs/".$kernel_name."-".$tag.".extras.tar".$ext."\n";
$email .= $website_base."/tarballs/".$kernel_name."-".$tag.".experimental.tar".$ext."\n";

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

#!/usr/bin/perl
# Copyright 2004-2005 Gentoo Foundation; Distributed under the GPL v2
#
# Scripts to automatically generate the gentoo-sources-2.6 information pages
#
# Disclaimer: This code is really ugly, I'm really good at writing horrible perl
# But it works (to an extent) :)

use File::Basename;
use File::Copy;
use URI::Escape;
use Cwd;
use lib '.';
use gentoo_sources_web;
use Sort::Versions;

# print out arguments for easier debugging
print "makesite.pl called with arguments: @ARGV \n";

if (!precheck()) {
	exit 0;
}

my $cmd = 'rm -rf /tmp/linux-patches';
$output = `$cmd`;

$cmd = 'git clone git+ssh://git@git.gentoo.org/proj/linux-patches.git /tmp/linux-patches';
$output = `$cmd`;

make_index_page();
make_about_page();
make_faq_page();
make_bugs_page();
make_issues_page();
make_kernels_page();
make_release_pages();
process_static_content();

sub make_index_page {
	local *FD;
	print ">> Making index page\n";
	open(FD, '> '.$output_path.'/index.html');
	html_header *FD;
	include_content *FD, 'sitemap';
	html_footer *FD;
	close(FD);
}

sub make_about_page {
	local *FD;
	print ">> Making about page\n";
	open(FD, '> '.$output_path.'/about.html');
	html_header *FD;
	include_content *FD, 'about';
	html_footer *FD;
	close(FD);
}

sub make_faq_page {
	local (*FD, *DIR);
	print ">> Making FAQ page\n";
	open(FD, '> '.$output_path.'/faq.html');
	html_header *FD;
	print FD '<h1>Frequently Asked Questions</h1>';
	opendir(DIR, 'content/faq');
	include_faq *FD, $_ foreach grep { -f "content/faq/$_" } sort readdir DIR;
	closedir(DIR);
	html_footer *FD;
	close(FD);
}

sub make_bugs_page {
	local *FD;
	print ">> Making bugs page\n";
	open(FD, '> '.$output_path.'/bugs.html');
	html_header *FD;
	include_content *FD, 'bugs';
	html_footer *FD;
	close(FD);
}

sub make_issues_page {
	local *FD;
	print ">> Making issues page\n";
	open(FD, '> '.$output_path.'/issues.html');
	html_header *FD;
	generate_issues_index(FD);
	html_footer *FD;
	close(FD);
	
	generate_issues_current();
	generate_issues_resolved();
}

sub generate_issues_index {
	local *FD = shift;
	local *DIR;
	my ($file, $path);

	print FD '<h1>Current/Recent Issues and Solutions</h1>';
	print FD '<ul>';
	opendir(DIR, 'content/issues/current');
	foreach $file (grep { -f "content/issues/current/$_" } sort readdir DIR) {
		$path = 'content/issues/current/'.$file;
		print FD '<li><a href="issues-current.html#'.$file.'">';
		print FD nl2br html_escape issues_get_questions $path;
		print FD '</a></li>';
	}
	closedir(DIR);
	print FD '</ul><hr />';
	
	print FD '<h1>Previous/Resolved Issues and Solutions</h1>';
	print FD '<ul>';
	opendir(DIR, 'content/issues/resolved');
	foreach $file (grep { -f "content/issues/resolved/$_" } sort readdir DIR) {
		$path = 'content/issues/resolved/'.$file;
		print FD '<li><a href="issues-resolved.html#'.$file.'">';
		print FD nl2br html_escape issues_get_questions $path;
		print FD '</a></li>';
	}
	closedir(DIR);
	print FD '</ul>';
}

sub generate_issues_current {
	local (*DIR, *FD);
	my $file;
	open(FD, '> '.$output_path.'/issues-current.html');
	html_header *FD;
	print FD '<h1>Current Issues and Solutions</h1>';
	
	opendir(DIR, 'content/issues/current');
	foreach $file (grep { -f "content/issues/current/$_" } sort readdir DIR) {
		$path = 'content/issues/current/'.$file;
		print FD '<a name="'.$file.'"></a>';
		print FD '<b><i>';
		print FD nl2br issues_get_questions $path;
		print FD '</b></i><br /><b>Solution. </b>';
		print FD nl2br issues_get_answers $path;
		print FD '<br /><font size="2">';
		print FD nl2br issues_get_info $path;
		print FD '</font><br /><hr />';

	}
	closedir(DIR);
	
	html_footer *FD;
	close(FD);
}

sub generate_issues_resolved {
	local (*DIR, *FD);
	my $file;
	open(FD, '> '.$output_path.'/issues-resolved.html');
	html_header *FD;
	print FD '<h1>Previous/Resolved Issues and Solutions</h1>';
	
	opendir(DIR, 'content/issues/resolved');
	foreach $file (grep { -f "content/issues/resolved/$_" } sort readdir DIR) {
		$path = 'content/issues/resolved/'.$file;
		print FD '<a name="'.$file.'"></a>';
		print FD '<b><i>';
		print FD nl2br issues_get_questions $path;
		print FD '</b></i><br /><b>Solution. </b>';
		print FD nl2br issues_get_answers $path;
		print FD '<br /><font size="2">';
		print FD nl2br issues_get_info $path;
		print FD '</font><br /><hr />';

	}
	closedir(DIR);
	
	html_footer *FD;
	close(FD);
}

sub order_kernel {
	my $pkgCmp = ($a->{'pkg'} cmp $b->{'pkg'});
	if ($pkgCmp != 0) {
		return $pkgCmp;
	} else {
		return ($a->{'ver'} cmp $b->{'ver'});
	}
}

sub make_kernels_page {
	local *FD;
	my $kernel;
	print ">> Making kernels page\n";
	my %kernels = _get_genpatches_kernels();

	if (!@kernels) {
		print ">> No Kernels found, check ebuild_base variable in gentoo_sources_web.pm\n";
		exit
	}
	
	open(FD, '> '.$output_path.'/kernels.html');
	html_header *FD;
	print FD '<h1>Available Kernels</h1>';
	print FD '<table id="hor-minimalist-a" class="kernels">';
	print FD '<tr><th>Kernel</th><th>Version</th><th>Genpatches</th></tr>';
	foreach $kernel (sort order_kernel (values %kernels)) {
		print FD '<tr>';
		print FD '<td>'.$kernel->{'pkg'}.'</td>';
		print FD '<td>'.$kernel->{'ver'}.'</td>';
        # need link to be http://git.mpagano.com/?p=linux-patches.git;a=tree;h=9fe89d1c30a6de1bf4996aa8cfaf2a24b77919fe;hb=ae90dea77ef818eb638b8bb086ac8f0b671b28cf
		
		print FD '<td><a href="patches-'.$kernel->{'gprev'}.'.html">'.$kernel->{'gprev'}.'</a> '.$kernel->{'wanted'}.'</td>';
		print FD '</tr>';
	}

	print FD '</table>';
	html_footer *FD;
	close(FD);
}

sub make_release_pages {
	my ($cmd, @out, @patches, @patchpages, $patch);
	local *DIR;
	print ">> Making release pages\n";

    # get list of tags mike
	$cmd = 'git -C '.$git_root.' tag -l';
	print "cmd is git -C $git_root tag -l\n";
	@out = `$cmd`;


	foreach (@out) {
		chomp;
		#chop;
		#next if $_ !~ /^2\.6\./;
		next if $_ !~ /^\d\.\d/;
		if (!release_is_generated($_)) {
			print ">> Generating release pages for $_\n";
			@patches = _get_patch_list($_);
			generate_patchlist($_, @patches);
			generate_info($_, @patches);
		}
	}
	
	make_releases_index();
    
    
	opendir(DIR, $webscript_path.'/generated');
	@patchpages = grep { /-patches\.html$/ } sort readdir DIR;
	closedir(DIR);
	
	foreach $patch (@patchpages) {
		$patch =~ m/^(.*)-patches\.html$/;
		copy($webscript_path.'/generated/'.$patch, $webscript_path.'/output/patches-'.$1.'.html');
	}

}

sub mysort {
    return (versioncmp($a, $b));
}

sub mysort_old {

	$a =~ m/^\d\.\d\.(\d+)-(\d+)-info\.html$/;
	$mya = $2;
	$b =~ m/^\d\.\d\.(\d+)-(\d+)-info\.html$/;
	$myb = $2;
	return $mya - $myb;
}

sub make_releases_index {
    print "make_releases_index called\n";

	my (%kernels, $info, @infopages, $kernel);
	local (*DIR, *FILE, *INDEX);
	opendir(DIR, $webscript_path.'/generated');
	@infopages = grep { /-info\.html$/ } readdir DIR;
	foreach $info (@infopages) {
		#$info =~ m/^(\d\.\d\.\d+)-\d+-info\.html$/;
		$info =~ m/^(\d\.\d+)-\d+-info\.html$/;
		$kernels{$1} = 1;
	}

#	foreach $info (@infopages) {
#		$info =~ m/^(\d\.\d+)-\d+-info\.html$/;
#		$kernels{$1} = 1;
#	}

	open(INDEX, '> '.$webscript_path.'/output/releases.html');
	html_header(INDEX, 'genpatches Releases');
	print INDEX '<h1>genpatches Releases</h1>';

	foreach $kernel (sort keys %kernels) {
		print("kernel: $kernel\n");
        if ($kernel == "") {
            next;
        }
		print INDEX '<p><a href="releases-'.$kernel.'.html">genpatches releases for Linux '.$kernel.'</a></p>';
		open(FILE, '> '.$webscript_path.'/output/releases-'.$kernel.'.html');
		html_header(FILE, "$kernel Releases");
		print FILE '<h1>'.$kernel.' Releases</h1>';
		foreach (grep { /^$kernel-/ } sort mysort @infopages) {
			include_generated(FILE, $_);
		}
		html_footer(FILE);
		close(FILE);
	}

	html_footer(INDEX);
	close (INDEX);
	closedir(DIR);

}

sub generate_patchlist {
	my ($tag, @patches) = @_;
	local *PATCHLIST;
	my $patch;

	local $ext;
	$ext = get_tarball_ext($tag);

	open(PATCHLIST, '> '.$webscript_path.'/generated/'.$tag.'-patches.html');
	html_header(PATCHLIST, "$tag Patch List");
	print PATCHLIST '<h1>'.$tag.' Patch List</h1>';
	print PATCHLIST '<p>Patches 0000-2999 are available in ';
	print PATCHLIST '<a href="tarballs/genpatches-'.$tag.'.base.tar'.$ext.'">genpatches-'.$tag.'.base.tar'.$ext.'</a>';
	print PATCHLIST '<br />Patches 3000-4999 are available in ';
	print PATCHLIST '<a href="tarballs/genpatches-'.$tag.'.extras.tar'.$ext.'">genpatches-'.$tag.'.extras.tar'.$ext.'</a>';
	print PATCHLIST '<br />Patches 5000-5099 are available in ';
	print PATCHLIST '<a href="tarballs/genpatches-'.$tag.'.experimental.tar'.$ext.'">genpatches-'.$tag.'.experimental.tar'.$ext.'</a></p>';
	print PATCHLIST '<table id="hor-minimalist-a">';
	print PATCHLIST '<tr><th>Patch</th><th>From</th><th>Description</th></tr>';
	foreach $patch (@patches) {
		print PATCHLIST '<tr>';
		print PATCHLIST '<td class="patch">'.$patch->{'patch'}.'</td>';
		print PATCHLIST '<td class="from">'.html_urlify($patch->{'from'}).'</td>';
		print PATCHLIST '<td class="desc">'.$patch->{'desc'}.'</td>';
		print PATCHLIST '</tr>';
	}
	print PATCHLIST '</table>';
	html_footer(PATCHLIST);
	close(PATCHLIST);
}

sub generate_info {
	my ($tag, @patches) = @_;
	my (@commits, $ver, $rel, $have_history, $oldtag, @log_lines, $tag_save);
	my ($lastrev);
	local *INFO;
    local $ext;

    $ext = get_tarball_ext($tag);

    $tag_save = $tag;
	$tag =~ m/(2\.6\.\d+)-(\d+)/;
	$ver = $1;
	$rel = $2;
	$have_history = 0;

	# Try and find previous release
    $lastrev = get_last_revision($tag, $ver, $rel);

    if (!$lastrev) {
    	$tag_save =~ m/(3\.\d+)-(\d+)/;
	    $ver = $1;
	    $rel = $2;
        $lastrev = get_last_revision($tag, $ver, $rel);
    }

	if ($lastrev) {
		#@commits = _parse_log($tag, $lastrev);
		$have_history = @commits;
        #print "cmd: git --no-pager -C '.$git_root.' log  --pretty=format:%s (%an) --name-status '.$oldtag.'..'.$tag\n";
        $cmd='git --no-pager -C '.$git_root.' log  --pretty=format:"%s (%an)" --name-status '.$oldtag.'..'.$tag;
        @commits = `$cmd`;
        $have_history = 1;
	}
    else {
        print "no revision found for tag: $tag\n";
    }
	
	open (INFO, '> '.$webscript_path.'/generated/'.$tag.'-info.html');
	print INFO '<h2>Release '.$tag.'</h2>';
	print INFO '<p><a href="patches-'.$tag.'.html">View entire patch list</a><br />';
	print INFO 'Split-out patch tarballs: ';
	print INFO '<a href="tarballs/genpatches-'.$tag.'.base.tar'.$ext.'">base</a>, ';
	print INFO '<a href="tarballs/genpatches-'.$tag.'.extras.tar'.$ext.'">extras</a></p>';
	print INFO '<a href="tarballs/genpatches-'.$tag.'.experimental.tar'.$ext.'">experimental</a></p>';
	
	if ($lastrev && $have_history) {
		print INFO '<h3>Changes since '.$oldtag.'</h3>';
		foreach $rev (@commits) {
            if (index($rev, "0000_README") == -1) {

		    	print INFO '<p><strong>'.$rev.'</strong></p>';
    
    			#next if !$rev->{'rev'};
    			#print INFO '<p><strong>Revision '.$rev->{'rev'}.':</strong> ';
    			#print INFO $rev->{'logmsg'}.' ('.$rev->{'author'}.')<br />';
    			#print INFO '<strong>Added:</strong> '.$_.'<br />' foreach (@{$rev->{'actionA'}});
    			#print INFO '<strong>Modified:</strong> '.$_.'<br />' foreach (@{$rev->{'actionM'}});
    			#print INFO '<strong>Deleted:</strong> '.$_.'<br />' foreach (@{$rev->{'actionD'}});
    			#print INFO '</p>';
    		}
    	}
    }
	print INFO '<hr />';
	close (INFO);
}

sub process_static_content {
	copy($webscript_path.'/content/style.css', $output_path);
	copy($webscript_path.'/content/.htaccess', $output_path);
}


# get the last revision 
sub get_last_revision {
    my ($tag, $ver, $rel) = @_;

    #print "Inside get_last_revision: ";
    #print "tag: ".$tag." ";
    #print "ver: ".$ver." ";
    #print "rel: ".$rel."\n";

	my ($have_history, $oldtag, @log_lines,$lastrev);
   	$have_history = 0;

   	# Try and find previous release
#  	if ($rel > 1) {
#   		$oldtag = $ver.'-'.($rel-1);
#        # get last tag mike
#   		$cmd = 'svn log -q --stop-on-copy '.$subversion_root.'/tags/'.$oldtag;
#   		@log_lines = `$cmd`;
#   		$lastrev = 0;
#   		foreach (@log_lines) {
#   			next if $_ !~ /^r(\d+) \|/;
#   			$lastrev = $1;
#    		last;
#    	}
#    }

    if ($rel > 1) {
        $oldtag = $ver.'-'.($rel-1);
        #print "cmd: git -C ".$git_root." rev-list ".$oldtag."\n";
        $cmd='git -C '.$git_root.' rev-list '.$oldtag;
        @output = `$cmd`;

        foreach $line (@output) {
            $have_history = 1;
       		$lastrev = 0;
            if (index($line, "fatal") != -1) {
                $have_history =0;
            }
            if ($have_history == 0) {
               $lastrev = $oldtag;
               break;
            }
        }
    }

    return $lastrev;
}

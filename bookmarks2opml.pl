#!/usr/bin/perl

# $Id$
#
# File:         bookmarks2opml.pl
# 
# Function:     Converts IE Bookmarks/Favorites from HTML to OPML
#
# Author(s):    Erik C. Thauvin (erik@thauvin.net)
#
# Copyright:    Copyright (C) 2000 Erik C. Thauvin
#               All Rights Reserved.
#
# Source:       Started anew.
#
# Notes:        Usage: bookmarks2opml.pl bookmarks.htm
#                      --> bookmarks.opml
#
#
# History:
#
#   12/22/00    ECT     Added & -> &amp; matching pattern to cleanText()
#                       and cleanLink().
#   12/22/00    ECT     Added cleanText().
#                       Changed local() calls to my().
#   12/21/00    ECT     Improved link/url expression matching.
#   12/20/00    ECT     Added cleanLink().
#   12/18/00    ECT     Initial coding.
#
#   
# Disclaimer:
#   
#   This software is provided "as is" without express or implied warranties.
#   Permission is granted to use, copy, modify and distribute this software,
#   provided this disclaimer and copyright are preserved on all copies. This
#   software may not, however, be sold or distributed for profit, or included
#   with other software which is sold or distributed for profit, without the
#   permission of the author.
#


# Declare local variables
my($progname, $bookmarks, $title, $body, $opmlfile);

# Get the program's name
($progname = $0) =~ s/.*\///;

# One argument is required, the name of the bookmarks file
if (scalar @ARGV == 1)
{
	$bookmarks = shift;
}
else
{
	die "Usage: $progname <bookmarks-filename>\n";
}

#
# The Truth is Out There!
#

# Open the bookmarks file
open(F, "$bookmarks") || die "$progname: Could not open $bookmarks: $!\n";

# Read the bookmarks file
while (<F>)
{
	# Get the title
	if (/<TITLE>(.*)<\/TITLE>/i)
	{
		$title = $1;
	}
	# Get directory names
	elsif (/<DT><H3.*>(.*)<\/H3>/i)
	{
		# Build directory outline 
		$body .= '<outline text="' . cleanText($1) . "\">\n";
		next;
	}
	# Get end of directory marker
	elsif (/\s<\/DL>/i)
	{
		# Close directory outline
		$body .= "<\/outline>\n";
		next;
	}
	# Get link reference
	elsif (/<DT><A HREF=\"(\S+)\" .*\">(.*)<\/A>/i)
	{
		# Build link outline
		$body .= '<outline text="' . cleanText($2) . '" type="link" url="' . cleanLink($1) . "\" \/>\n";
		next;
	}
}

# Close bookmarks file
close(F);

# Remove extra newline
chomp($body);
chomp($title);

# OPML output filename is based on bookmarks
$opmlfile = $bookmarks;
# Remove path, if any
$opmlfile =~ s/.*\/(.*)/$1/;
# Remove .???? suffix, if any
$opmlfile =~ s/(.*)\..*/$1/;
# Add .opml suffix
$opmlfile .= '.opml';

# Open OPML output file
open(F, ">$opmlfile") || die "$progname: Could not open $opmlfile: $!\n";

# Generate simple XML/OPML document
print F <<EOT;
<?xml version="1.0" encoding="ISO-8859-1"?>
<opml version="1.0">
<head>
<title>$title</title>
</head>
<body>
$body
</body>
</opml>
EOT

# Close OPML file
close(F);

# Change OPML file type to Radio UserLand (MacPerl only)
if ($MacPerl::Version)
{
	MacPerl::SetFileInfo("Radu ", "OPML", $opmlfile);
}


#
# URL-Encode problematic characters
#
sub cleanLink()
{
	my($link) = @_;
	
	$link =~ s/>/%3F/g;
	$link =~ s/</%3C/g;
	$link =~ s/'/%27/g;
	$link =~ s/"/%22/g;
	$link =~ s/&(?!(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&amp;/g;
	
	return $link
}

#
# HTML-Encode problematic characters
#
sub cleanText()
{
	my($link) = @_;
	
	$link =~ s/>/&gt;/g;
	$link =~ s/</&lt;/g;
	$link =~ s/"/&quot;/g;
	$link =~ s/&(?!(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&amp;/g;
	
	return $link
}
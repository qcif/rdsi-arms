#!/usr/bin/perl
#
# Automatic numbering of headings and/or test/checks in a Markdown
# file. Also updates the version string.
#
#----------------------------------------------------------------

use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my $PROG = basename($0);

#----------------------------------------------------------------

sub number_file {
  my($src, $dest, $do_headings, $do_test_and_checks, $clear_numbering) = @_;

  my $test_count = 0;
  my $check_count = 0;
  my @heading_count = ( 0 );
  my $current_level = 2;

  while (<$src>) {

    if (/^Version\: # Version: at beginning of line
        \s*         # optional whitespace
        ([\d\.]+)   # Number
        \s*         # optional whitespace
        (draft)?    # optional keyword draft
        \s*         # optional whitespace
        \d+\-\d+\-\d+ # date
        \s*         # optional whitespace
        $           # end of line
        /x) {
      # Version string: update with today's date

      my ($s,$m,$h,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());

      my $datestr = sprintf("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

      if (defined($2)) {
	$_ = "Version: $1 $2 $datestr\n";
      } else {
	$_ = "Version: $1 $datestr\n";
      }
    }

    if ($do_test_and_checks &&
	/\*\*  # leading **
	Test   # test keyword
	\s*    # optional whitespace
	(\d+)? # optional number
	\*\*  # trailing **
	\:      # colon
	/x) {
        # Test detected /
	$test_count++; # increment test counter
	$check_count = 0; # reset check counter, since this is a new test

	if ($clear_numbering) {
	  $_ = "$`**Test**:$'";
	} else {
	  $_ = "$`**Test $test_count**:$'";
	}
    }

    if ($do_test_and_checks &&
	/\*\*     # leading **
	Check     # check keyword
	\s*       # optional whitespace
	([\d-]+)? # optional check number
	\*\*      # trailing **
	\:        # colon
	/x) {
      # Check detected /

      $check_count++;
      if ($clear_numbering) {
	$_ = "$`**Check**:$'";
      } else {
	$_ = "$`**Check $test_count-$check_count**:$'";
      }
    }

    if ($do_headings &&
	/^      # beginning of line
	(\#+)   # hashes indicating this is a heading
	\s*     # optional whitespace
	[\d\.]* # optional numbers (digits or full stops)
	\s*     # optional whitespace
	(.*)    # contents of heading
	$       # end of line
	/x) {
      # Heading detected
      my $hashes = $1;
      my $level = length($hashes);
      my $heading = $2;

      if ($level < $current_level) {
	for (my $x = $current_level; $level < $x; $x--) {
	  pop(@heading_count);
	}
      }
      if ($level < $current_level || $level == $current_level) {
	my $x = pop(@heading_count);
	if ($x =~ /^\d+$/) {
	  $x += 1; # numeric: increment
	} else {
	  $x = chr(ord($x) + 1); # letter: next character
	}
	push(@heading_count, $x);
	$current_level = $level;
      } else {
	push(@heading_count, 1);
	$current_level = $level;
      }

      print $dest "$hashes ";
      if ($current_level == 2 && $heading =~ /^Appendix\s+([^:]+)\:/) {
	# Appendix top level heading
	@heading_count = ( $1 );
      } else {
	if (! $clear_numbering) {
	  # Numbered heading
	  foreach my $n (@heading_count) {
	    print $dest "$n.";
	  }
	  print $dest " ";
	}
      }

      print $dest "$heading\n";

    } else {
      # Non-heading
      print $dest $_;
    }
  }

}

#----------------------------------------------------------------

sub process_arguments {
  my ($output_ref, $verbose_ref, $do_test_and_checks_ref, $do_headings_ref,
      $clear_ref) = @_;
  my $help;

  $$output_ref = undef;
  $$do_test_and_checks_ref = undef;
  $$do_headings_ref = undef;
  $$clear_ref = undef;

  if (! GetOptions("verbose" => $verbose_ref,
		   "output=s" => $output_ref,
		   "clear" => $clear_ref,
		   "no-checks" => $do_test_and_checks_ref,
		   "no-headings" => $do_headings_ref,
		   "help" => \$help)) {
    exit(1);
  }

  $$do_test_and_checks_ref = ! $$do_test_and_checks_ref;
  $$do_headings_ref = ! $$do_headings_ref;

  if ($help) {
    print "Usage: $PROG [options] [infile]\n";
    print "Options:\n";
    print "  --help             show this help message\n";
    print "  --output filename  save output to file\n";
    print "  --clear            remove numbering\n";
    print "  --no-headings      do not renumber headings\n";
    print "  --no-requirements  do not renumber tests and checks\n";
    #print "  --verbose\n";
    exit(0);
  }

  if (1 < scalar(@ARGV)) {
    die "Usage error: too many arguments\n";
  } elsif (scalar(@ARGV) == 1) {
    return $ARGV[0];
  } else {
    return undef;
  }
}

#----------------------------------------------------------------

sub main {
  my $outfile;
  my $verbose;
  my $do_test_and_checks;
  my $do_headings;
  my $clear;
  my $infile = process_arguments(\$outfile, \$verbose,
				 \$do_test_and_checks, \$do_headings,
				 \$clear);

  if (defined($infile)) {
    open(STDIN, '<', $infile) || die "Error: $!: $infile\n";
  }
  if (defined($outfile)) {
    open(STDOUT, '>', $outfile) || die "Error: $!: $outfile\n";
  }

  number_file(\*STDIN, \*STDOUT, $do_headings, $do_test_and_checks, $clear);

  return 0;
}

exit main();

#----------------------------------------------------------------
#EOF

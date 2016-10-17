#!/usr/bin/perl
# Mingyu @ Jul 01 2012
# User Independent case (leave-one-out)
# 

use File::Path qw(make_path remove_tree);

$totalRuns = 28; # should be equal to the total number of users in 6DMG

if ($#ARGV < 1)
{
    print "usage: exp3 [data_dir] [datatype1] .. [datatypen]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}

# check if the data types are valid

$data_dir = $ARGV[0];
@myDataTypes = @ARGV[1..$#ARGV];

#-------------------------------------------------------------------------
# ForkManager Init
#-------------------------------------------------------------------------
use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

#-------------------------------------------------------------------------
# Execute each SINGLE run with each datatype (exp2_single.pl)
#-------------------------------------------------------------------------
foreach my $dtype (@myDataTypes)
{
    unless (-d "exp3/$dtype") { make_path "exp3/$dtype"; } 
    foreach my $run (1..$totalRuns)
    {
	$pm->start and next;
	#--------------------------------------------------------
	print "pid($$) exp3_single.pl $dtype $run $data_dir\n";
	system("perl exp3_single.pl $dtype $run $data_dir");
	#--------------------------------------------------------
	$pm->finish;
    }
}
$pm->wait_all_children;

exit;

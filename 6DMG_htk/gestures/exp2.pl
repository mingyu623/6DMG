#!/usr/bin/perl
# Mingyu @ Aug 30 2011
# User Independent case
# Train with random 5 right-handed users and test with:
# Exp 2.1: the rest 16 right-handers
# Exp 2.2: all 7 left-handers
# Run exp2.pl on top of exp2_single.pl (single run only)
use File::Path qw(make_path remove_tree);


$totalRuns = 3; # no greater than 200 (o.w. need a larger UI.idx)

if ($#ARGV < 1)
{
    print "usage: exp2 [data_dir] [datatype1] .. [datatypen]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}

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
    unless (-d "exp2/$dtype") { make_path "exp2/$dtype"; }    
    foreach my $run (1..$totalRuns)
    {
	$pm->start and next;
	#--------------------------------------------------------
	print "pid($$) exp2_single.pl $dtype $run $data_dir\n";
	system("perl exp2_single.pl $dtype $run $data_dir");
	#--------------------------------------------------------
	$pm->finish;
    }
}
$pm->wait_all_children;

exit;

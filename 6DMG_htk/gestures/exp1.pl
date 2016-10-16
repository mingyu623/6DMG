#!/usr/bin/perl
# Mingyu @ Aug 29 2011
# User Dependent case
# Train with random 5 trials of a SINGLE right-handed user and test with the rest 5 trials
# Should use the exp1.pl to call exp1_single.pl

$totalRuns = 5; # no greater than 50 (o.w. need a larger UD.idx)

if ($#ARGV < 1)
{ 
    print "usage: exp1 [data_dir] [datatype1] .. [datatypen]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}

# TODO(mingyu): Check if the data_dir is valid
$data_dir = $ARGV[0];
@myDataTypes = @ARGV[1..$#ARGV];

@userR = ("B1", "B2");
## [Mingyu]: Uncomment to use the full sets of users
#@userR = ("B1", "B2", "C1", "C2", "D1", "J1", "J2", "J3", "J5", "M1",
#          "M2", "M3", "R2", "S1", "S2", "T1", "T2", "U1", "W1", "Y1",
#          "Y3");

#-------------------------------------------------------------------------
# ForkManager Init
#-------------------------------------------------------------------------
use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

#-------------------------------------------------------------------------
# Execute each SINGLE user with each datatype (exp1_single.pl)
# Use exp1_rec.pl to collect the MLF and recognition results
# exp1_single.pl cannot run in paralle... (due to some shared data)
#-------------------------------------------------------------------------
foreach my $dtype (@myDataTypes)
{
    foreach my $usr (@userR)
    {
	foreach my $run (1..$totalRuns)
	{	    
	    $pm->start and next;
	    #--------------------------------------------------------
	    print "pid($$) exp1_single.pl $usr $dtype $run $data_dir\n";
	    system("perl exp1_single.pl $usr $dtype $run $data_dir");
	    #--------------------------------------------------------
	    $pm->finish;
	}
    }
}
$pm->wait_all_children;  # it's safe to put wait here

exit;

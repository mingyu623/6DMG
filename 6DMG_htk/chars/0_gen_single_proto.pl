#!/usr/bin/perl
# Mingyu @ Feb 21 2013
# Generate template of HMM models for a given datatype and state #

use strict;
use File::Path qw(make_path);

my $dtype;
my $state_n;
if ($#ARGV !=1)
{
    print "usage: 0_gen_single_proto [datatype] [# states]\n";
    print "[# states] is the actual state number\n";
    print "           # states of HTK = [# states] +2;\n";
    exit;
}
else
{
    $dtype   = $ARGV[0];
    $state_n = $ARGV[1];
}

#=================================================
# Check the vec size of datatype
#=================================================
my $vecSize = 0;
my $i = 0;
while($i < length($dtype))
{
    my $D = substr($dtype,$i,2);    
    if ($D eq 'NA' or $D eq 'NW' or $D eq 'NV' or $D eq 'NP')
    {	
	if (substr($dtype,$i+2,2) eq '2D')
	{	 	    
	    $vecSize = $vecSize + 2;
	    if (substr($dtype,$i+4,2) eq 'uv'){
		$i += 6;
	    }else{
		$i += 4;
	    }
	}
	else
	{
	    $vecSize = $vecSize + 3;
	    $i += 2;
	}
    }
    elsif ($D eq 'NO')
    {
	$vecSize = $vecSize + 4;
	$i += 2;
    }
    else
    {
	print " !unsupported datatype: $dtype!\n";
	exit;
    }
}

if ($state_n <1)
{
    print " ! incorrect  # states !\n";
}

my $statesHTK = $state_n+2;
my $path = "proto/$dtype/";
unless(-d $path){ make_path $path };

#=================================================
# Generate HMM file
#=================================================
my $meanStr = "";
my $varStr  = "";
my $s0 = '0.000e+0';
my $s1 = '6.000e-1';
my $s2 = '4.000e-1';

foreach (1..$vecSize)
{
    $meanStr = $meanStr.'0.0 ';
    $varStr  = $varStr.'1.0 ';
}

open HMM, ">$path/template_".$state_n or die $!;
print HMM "~o <VecSize> $vecSize <nullD><USER> <StreamInfo> 1 $vecSize\n";
print HMM "<BeginHMM>\n";
print HMM "  <NumStates> $statesHTK\n";

foreach my $s (2..$statesHTK-1)
{
    print HMM "  <State> $s <NumMixes> 1\n".
	      "  <Stream> 1\n".
	      "  <Mixture> 1 1.0\n".
	      "    <Mean> $vecSize\n".
	      "      $meanStr\n".
	      "    <Variance> $vecSize\n".
	      "      $varStr\n";
}

print HMM "  <TransP> $statesHTK\n";
foreach my $row (1..$statesHTK)
{
    print HMM "   ";
    if ($row eq 1)
    {
	print HMM "$s0   1.000e+0   ";
	foreach (3..$statesHTK){ print HMM "$s0   "; }
    }
    elsif ($row eq $statesHTK)
    {
	foreach (1..$statesHTK){ print HMM "$s0   "; }	
    }
    else
    {
	foreach my $col (1..$statesHTK)
	{
	    if    ($col eq $row)  { print HMM "$s1   "; }
	    elsif ($col eq $row+1){ print HMM "$s2   "; }
	    else                  { print HMM "$s0   "; }
	}
    }
    print HMM "\n";
}
print HMM "<EndHMM>\n";
close HMM;

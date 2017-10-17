#!usr/bin/perl -w
use strict;

die "Usage: perl $0 [Sample] [Control] [out.table]\n Threshold correction approach used in Evans, N. T., Li, Y., Renshaw, M. A., Olds, B. P., Deiner, K., Turner, C. R., … Pfrender, M. E. (2017). Fish community assessment with eDNA metabarcoding: effects of sampling design and bioinformatic filtering. Canadian Journal of Fisheries and Aquatic Sciences\n" unless (@ARGV == 3);

my $con_sum;
my (%control, %con_perc);

open (CON, $ARGV[1]) or die "$ARGV[1] $!\n";
my $header = <CON>;
while(<CON>){
	chomp;
	my @line = split;
	my $otu = shift @line;
	pop @line;
	pop @line;
	my $sum;

	foreach my $l (@line){
		$sum += $l;
	}

	$control{$otu} = $sum;
	$con_sum += $sum;
}
close CON;

foreach my $k (sort {$a<=>$b} keys %control){
	$con_perc{$k} = $control{$k} / $con_sum;
	print "$k\t$con_perc{$k}\n";
}

open (SMP, $ARGV[0]) or die "$ARGV[0] $!\n";
open OT, ">$ARGV[2]" or die "$ARGV[2] $!\n";

$header = <SMP>;
my @header = split /\s+/, $header;
shift @header;
pop @header;
pop @header;

my (%sample_sum, %sample, %sap, %usearch);
while(<SMP>){
	chomp;
	my @line = split;
	my $otu = shift @line;

my $usearch = pop @line;
my $sap = pop @line;

$usearch{$otu} = $usearch;
$sap{$otu} = $sap;

	my $s = 0;

	foreach my $l (@line){
		$sample_sum{$header[$s]} += $l;
		$sample{$otu}{$header[$s]} = $l;
		$s ++;
	}
}

print OT "$header";
foreach my $o (sort {$a<=>$b} keys %sample){
	print OT "$o\t";
	foreach my $s (@header){
		my $perc = $sample{$o}{$s} / $sample_sum{$s};
		$perc = $perc - $con_perc{$o};
#		print "$o\t$s\t$con_perc{$o}\t$perc\t$sample{$o}{$s}\n";
		if($perc >= 0){
			my $corrected = $sample_sum{$s} * $perc;
			$corrected = int ($corrected + 0.5);
			print OT "$corrected\t";
		}else{
			print OT "0\t";
		}
	}
	print OT "$sap{$o}\t$usearch{$o}\n"
}
print "DONE!\n";

#! /usr/bin/perl

if(@ARGV < 2) {
    print STDERR "choosefasta.pl <fasta> <list> [<remain>] > <output>\n";
    exit;
}

$fas = shift;
$list = shift;
$rest = shift;

open (FAS, "<$fas") or die;

%id;
%fas;
$name = "";
while(<FAS>) {
    chomp($_);
    if($_ =~ /^>/) {
	$name = $_;
	$_ =~ /^>(\S+)/;
	$id{$1} = $name;
	$fas{$name} = "";
    } else {
	$_ =~ s/[^a-zA-z-\.]//g;
	if($name ne "") {
	    $fas{$name} .= $_;
	}
    }
}
close(FAS);

local %used;
open (LIST, "<$list") or die;
while(<LIST>) {
    chomp($_);
    $now_seq = "";
    @picked = split(/\s+/, $_);
    $now_seq = $fas{$id{$picked[0]}};
    if ($picked[1] == "") {
        $now = $picked[0];
    } else {
        $now = $picked[1];
    }
    if($now_seq eq "") {
	print ">".$now."\n-\n";
	print STDERR "WARNING: $now cannot be found in the fasta file!\n";
    } else {
	local @part = split /\s+/, $_;
	if($part[1] =~ /[cCrR]/) {
	    $now_seq = reverse $now_seq;
	    $now_seq =~ tr/atcg/ATCG/;
	    $now_seq =~ tr/ATCG/TAGC/;
	} elsif ($part[1] =~ /^[0-9]+$/ && $part[2] =~ /^[0-9]+$/) {
	    if($part[1] < $part[2]) {
		$now_seq = substr($now_seq, $part[1]-1, $part[2]-$part[1]+1);
	    } else {
		$now_seq = substr($now_seq, $part[2]-1, $part[1]-$part[2]+1);
		$now_seq = reverse $now_seq;
		$now_seq =~ tr/atcgATCG/TAGCTAGC/;
	    }
	}
	if($part[1] ne "") {
	    print $id{$now}.":$part[1]:$part[2]\n".$now_seq."\n";
	} else {
	    print $id{$now}."\n".$now_seq."\n";
	    # print STDERR "WARNING: $id{$now} cannot be found in the fasta file!\n";
	}
	if($rest ne "") {
	    $used{$id{$now}} = 1;
	}
    }
}

if($rest eq "") {exit;}
open (REST, ">$rest") or die;

foreach (keys %fas) {
    if($used{$_} != 1) {
	print REST $_."\n".$fas{$_}."\n";
    }
}
close REST;

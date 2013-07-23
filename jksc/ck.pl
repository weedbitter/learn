#!/usr/bin/perl
use strict;
use warnings;
use Data::Dump;
use Encode;
use IO::File;

my $file_name = $ARGV[0] or die "Must specify filename to parse.\n";
my $data_file = "";
my $df = IO::File->new(">>$data_file");


&three_File();


sub three_File{
	open(FILE,"$file_name") or die "Can't Open $file_name .\n";

	while(<FILE>){
		s/^\s+//g;
 		s/\s+$//g;
		next if /^$/;
    	
    	$_ = decode('gbk', $_);
    	warn "$_";

    	my @list=split /;/;
	
		foreach (@list){
			printf FILEHANDLE ($_);
			printf FILEHANDLE ('|');			
		}
		printf FILEHANDLE ("\n");
	}				
	close (FILEHANDLE);
	print "file ${data_file} create success!\n";
	
}



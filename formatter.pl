#!/usr/bin/perl
use strict;
use warnings;
use DaZeus;

my ($socket, $filename, @commands) = @ARGV;

if(!@commands) {
	warn "Usage: $0 socket filename command [command2 [command3 [...]]]\n";
	warn "Reads the formattable lines from filename, listens to commands\n";
	exit 1;
}

my @lines;
open my $fh, $filename or die "Failed to open lines file $filename: $!";
foreach(<$fh>) {
	1 while chomp;
	push @lines, $_;
}
close $fh;

if(!@lines) {
	die "No lines loaded. Cowardly refusing to start.\n";
}

my $dazeus = DaZeus->connect($socket);

foreach my $cmd (@commands) {
	$dazeus->subscribe_command($cmd, \&do_format);
}

while($dazeus->handleEvents()) {}

sub do_format {
	my (undef, $network, $sender, $channel, undef, $param) = @_;

	$param ||= $sender;

	my $line = $lines[rand @lines];
	$line =~ s/\%s/$param/g;

	if($channel eq $dazeus->getNick($network)) {
		$dazeus->message($network, $sender, $line);
	} else {
		$dazeus->message($network, $channel, $line);
	}
}

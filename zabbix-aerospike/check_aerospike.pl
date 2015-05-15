#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Getopt::Long;
use Pod::Usage;

use Data::Dumper;


my $pull;
my $help;
my $list_metrics;

my $hostname = qx/hostname -f/;
chomp($hostname);
my $timestamp = time;

my $zbx_sender = "/usr/bin/zabbix_sender";
my $zbx_sender_opts = " -c /etc/zabbix/zabbix_agentd.conf -v -T -i -";
my $sender_cmd = $zbx_sender . $zbx_sender_opts;

my $asinfo = "/usr/bin/asinfo";
my $asinfo_opts = " -v statistics";
my $asinfo_cmd = $asinfo . $asinfo_opts;

&usage if !@ARGV;

GetOptions(
   'pull'		=> \$pull,
   'list-metrics'	=> \$list_metrics,
   'help|?'		=> \$help,
) or die "Error in command line arguments";

&usage if defined $help;

if (not -f $zbx_sender) {
 print "File not found : $zbx_sender\n";
 exit 2;
}
if (not -f $asinfo) {
 print "File not found : $asinfo\n";
 exit 2;
}


open (my $fh, "$asinfo_cmd |") or die;
my $raw;
{
 undef $/;
 $raw = <$fh>;
}
close($fh);

$raw =~ s/^.*\s+(.+)$/$1/sx;
my @elements = split(/\;/, $raw);


if ($pull) {

 my @metrics;
 foreach my $e (@elements) {
  my ($key, $val) = split(/\=/, $e);

  my $string = "";

  $string .= "\"$hostname\" ";
  $string .= "aerospike.asinfo\[$key\] ";
  $string .= "$timestamp ";
  $string .= "$val";

  push @metrics, $string;
 }
 
 my $result = join('\n', @metrics);

 #print $result, "\n";
 #system("/bin/echo -ne \'$result\' | $sender_cmd");
 system("/bin/echo -ne \'$result\' | $sender_cmd 1>/dev/null 2>/dev/null");
 print $?, "\n";
 #print 0;
 
}

if ($list_metrics) {

 foreach my $e (@elements) {
  my ($key, $val) = split(/\=/, $e);
  print $key, "\n";   
 }

}

sub usage {
 pod2usage({
    -verbose    => 2,
    -output     => \*STDERR,
    -exitstatus => 2
 });
 exit 1;
}


__END__

=encoding utf8

=head1 NAME

scriptname - descriotion

=head1 SYNOPSIS

scriptname.pl <options>

Options:

 --pull	send metrics to zbx server using zabbix_sender
 --list-metrics	avaliable metrics list

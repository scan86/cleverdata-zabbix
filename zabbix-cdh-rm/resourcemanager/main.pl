#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  main.pl
#
#        USAGE:  ./main.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  04/09/2015 01:47:02 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use diagnostics;


use Getopt::Long;
use Pod::Usage;

use Data::Dumper;
use JSON::XS;
use NCB::Http;

my $discovery;
my $pull;
my $help;

my $hostname = qx/hostname -f/;
chomp($hostname);
my $timestamp = time;

my $zbx_sender = "/usr/bin/zabbix_sender";
my $zbx_sender_opts = " -c /etc/zabbix/zabbix_agentd.conf -v -T -i -";
my $sender_cmd = $zbx_sender . $zbx_sender_opts;

my $url = "http://$hostname:8088/ws/v1/cluster/metrics";

&usage if !@ARGV;

GetOptions(
	'discovery'	=> \$discovery,
	'pull'		=> \$pull,
	'help|?'	=> \$help,
) or die "Error in command line arguments";

&usage if defined $help;

if ($discovery && $pull) {
 die "Only one option allowed at one moment: --discovery or --pull"
}

if (not -f $zbx_sender) {
 print "ERROR: file not found : $zbx_sender\n";
 exit 2;
}


# simple http cli (libcurl::easy inside)
my $http_cli = new NCB::Http;
# REST-server response data
my $server_response_data;
# ResourceManager state
my $server_state;

&detect_state(\$server_state, \$server_response_data);

if ($discovery) {
 &do_discovery;
 exit 0;
}

if ($pull) {
 &pull;
 exit 0;
}

sub pull {
 
 my @strings;
 
 if ($server_state eq "active") {

  my $json = decode_json($server_response_data);
  if ($json->{'clusterMetrics'}) {

   my $clusterMetrics = $json->{'clusterMetrics'};
   foreach my $key (keys %{$clusterMetrics}) {
    my $value = $clusterMetrics->{$key};
    my $str = &buildString($key, $value);
    push (@strings, $str);
   }
   push (@strings, &buildString("serverState", $server_state));
  }    
 } elsif ($server_state eq "standby") {
    push (@strings, &buildString("serverState", $server_state));
 }

 my $result = join('\n', @strings);

 #print $result, "\n";
 #system("/bin/echo -ne \'$result\' | $sender_cmd");
 system("/bin/echo -ne \'$result\' | $sender_cmd 1>/dev/null 2>/dev/null");
 print $?, "\n";
 #print 0;

}


sub buildString {
 my ($key, $value) = @_;
 
 my $result = "";
 
 $result .= "\"$hostname\" ";
 $result .= "resourcemanager.metric\[$key\] ";
 $result .= "$timestamp ";
 $result .= $value;

 return $result;
}

sub do_discovery {

 my ($json, $output_ref);

 if ($server_state eq "active") {
  $json = decode_json($server_response_data);  
  $output_ref = &process_json($json);  
 } elsif ($server_state eq "standby") {
  $output_ref = &make_standby_metrics();
 } else {
   die "Unknown server state";
 }

 print encode_json($output_ref);

}

sub make_standby_metrics {
 my @out;
 
 push (@out, {"{#RM_METRIC_STRING}" => "serverState"});
 push (@out, {"{#RM_PULL}" => $server_state});

 return { "data" => \@out };
}

sub detect_state {
 my ($state_ref, $data_ref)  = @_;
 
 #my $resp = &do_get_mock();
 my $resp = $http_cli->get($url);
 
 if ($resp =~ m/This is standby RM/) {
  $$state_ref = "standby";
  $$data_ref = $resp;
  return;
 }
 
 if ($resp =~ m/clusterMetrics/) {
  $$state_ref = "active";
  $$data_ref = $resp;
  return;
 }
 
 die "Failed to detect server state";
   
}

sub process_json {
 my $json = shift;
 
 my @out;

 if ($json->{'clusterMetrics'}) {

   my $clusterMetrics = $json->{'clusterMetrics'};
   for my $key (keys %{$clusterMetrics}) {
      my $ref = { '{#KEY_INT}' => $key };
      push (@out, $ref);
   }

   return { "data" => \@out };
 }

 return {  };
}


sub get_state {
 return "active";
 #return "standby";
}



sub do_get_mock {
 #my $f = "./mock.metrics";
 my $f = "./mock.slave";
 open (my $fh, '<', $f) or die;
 my $line = <$fh>;
 close($fh);
 return $line;
}

sub usage {
 pod2usage({
	-verbose	=> 2,
	-output		=> \*STDERR, 
	-exitstatus	=> 2
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

 --discovery	return json for zbx item llc
 --pull		send metrics to zbx server using zabbix_sender


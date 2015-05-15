#
#===============================================================================
#
#         FILE:  Utils.pm
#
#  DESCRIPTION:
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  06/20/2014 01:19:28 PM
#     REVISION:  ---
#===============================================================================

package NCB::Util;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(getSplits check_single cleanup);

use strict;
use warnings;

use Log::Log4perl qw(get_logger);

sub getSplits {
    my ( $arr_ref, $num ) = @_;
    my $log = get_logger();

    my %result;

    my $cnt = scalar( @{$arr_ref} );

    my $last = 0;
    for ( my $part = 0 ; $part < $num ; $part++ ) {
        my $part_size = int( $cnt / $num );
        
		my $start = $last;
        my $stop;

        if ($part == ($num - 1)) {
		 $stop = $cnt - 1;
		} else {
		 $stop = $start + $part_size - 1;
		}

        $result{$part} = { 'start' => $start, 'stop' => $stop };

        $last = $stop + 1;

    }

    return %result;
}

sub check_single() {
 my $pidfile = shift;
 if (! -e $pidfile) {
   &save_pid_to_file($pidfile);
 } else {
   my $other_pid = &get_pid_from_file($pidfile);
   if ($other_pid  && -d "/proc/$other_pid") {
      print "ERROR: another copy running : pid $other_pid\n";
      exit 2;
   } else {
      &save_pid_to_file($pidfile);
   }
 }
}
sub cleanup() {
 my $pidfile = shift;
 my $cmd = "/bin/rm -f $pidfile";
 system($cmd);
}
sub save_pid_to_file() {
 my $f = shift;
 open(my $fh, '>', $f) or die;
 print $fh $$;
 close($f);
}
sub get_pid_from_file() {
 my $f = shift;
 open (my $fh, '<', $f) or die;
 my $pid = <$fh>;
 close($fh);
 return $pid;
}

1;

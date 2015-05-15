#
#===============================================================================
#
#         FILE:  Http.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  11/26/2014 03:36:37 PM
#     REVISION:  ---
#===============================================================================

package NCB::Http;

use strict;
use warnings;

use WWW::Curl::Easy;

sub new() {
 my $class = shift;
 my $self = {

	login			=> undef,
	password		=> undef,
	agent			=> undef,
	verbose			=> undef,
	header			=> undef,
    conn_tout		=> undef,
    exec_tout		=> undef,

 };
 bless $self, $class;
 return $self;
}

# http simple get
sub get() {
 my ($self, $url) = @_;

 our $response_data = "";
 
 my $curl = new WWW::Curl::Easy;
 &_init($self, \$curl);
 
 $curl->setopt(CURLOPT_URL, $url);
 $curl->setopt(CURLOPT_WRITEFUNCTION, \&process_resp);
 my $rv = $curl->perform();


 sub process_resp() {
  my $chunk = shift;
  my $len = length($chunk);
  if ($len > 0) {
    $response_data .= $chunk;
  }
  return $len;
 }
 
 if ($rv == 0) { return $response_data };

}


# construct www::curl::easy
sub _init() {
 my ($self, $curl_ref) = @_;
 
 my $header = $self->{'header'};
 my $verbose = $self->{'verbose'};

 my $login = $self->{'login'};
 my $password = $self->{'password'};

 my $agent = $self->{'agent'};

 if ($header) {
  $$curl_ref->setopt(CURLOPT_HEADER, $header);
 }

 if ($verbose) {
  $$curl_ref->setopt(CURLOPT_VERBOSE, $verbose);
 }
 
 if ($login && $password) {
  my $secret = $login . ":" . $password;
  $$curl_ref->setopt(CURLOPT_USERPWD, $secret);
 }

}

### setter ###
sub set_verbose() {
 my ($self, $val) = @_;
 $self->{'verbose'} = $val;
}
sub set_header() {
 my ($self, $val) = @_;
 $self->{'header'} = $val;
}
sub set_login() {
 my ($self, $val) = @_;
 $self->{'login'} = $val;
}
sub set_password() {
 my ($self, $val) = @_;
 $self->{'password'} = $val;
}
### setter ###

1;

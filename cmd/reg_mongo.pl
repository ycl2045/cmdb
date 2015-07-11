#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;

my $post_data='{
    "databaseName": "cmdb", 
    "collectionName": "testver", 
    "compareKey": "_metadata.deviceid", 
    "verInterval": 86400, 
    "indexKeys": [ 
      "base_hardware.name"
    ],
    "verKeys": [ 
      "base_bios.ssn"
    ]
  }';


my $ua = LWP::UserAgent->new;
 
my $server_endpoint = "http://localhost:8080/api/registry";
 
# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => $server_endpoint);
$req->header('content-type' => 'application/json');
 
# add POST data to HTTP request body
$req->content($post_data);
 
my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    print "Received reply: $message\n";
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}

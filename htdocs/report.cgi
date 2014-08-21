#!/usr/bin/perl

use strict;
use warnings;

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;

use DBI;
use Template;

use lib './lib';

use Relais2::Duedate;
use Relais2::Recall;

print header();

my $conn = 'xXxXxXxXxXx';

my $connections = {
	xXxXxXxXxXx => ['xXxXxXxXxXx', 'xXxXxXxXxXx', 'xXxXxXxXxXx'],
	xXxXxXxXxXx => ['xXxXxXxXxXx', 'xXxXxXxXxXx', 'xXxXxXxXxXx'],
};

my $dbh = DBI->connect( @{ $connections->{$conn} }, 
	{ PrintError => 1, RaiseError => 1 })
  or die "cannot connect to data source: $DBI::errstr";
  
my $reportParam = param('report');
my $reportName = "Duedate";
if($reportParam =~ m/^(\w+)$/) {
	$reportName = ucfirst($1);
}
my $reportPkg = 'Relais2::' . $reportName;
my $report = $reportPkg->new();

my $sth = $dbh->prepare($report->query());
$sth->execute();
my $rows = $report->rows($sth);

my $tt = Template->new({
	INCLUDE_PATH => ['templates', 'templates'],
}) or die "Template loading: $Template::ERROR\n";

$tt->process('report.tt', {
	rows => $rows,
	columns => $report->columns(),
	columnNames => $report->columnNames(),
}) or die "Template processing error: " . $tt->error() . "\n";

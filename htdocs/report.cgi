#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

use DBI;
use Template;
use Try::Tiny;

use lib './lib';

use Text::CSV;
use IO::Wrap;

use Relais2::Duedate;
use Relais2::Recall;
use Relais2::Exhausted;
use Relais2::Pending;
use Relais2::Review;
use Relais2::Search;
use Relais2::Books;

my $conn = 'xXxXxXxXxXx';

my $connections = {
	xXxXxXxXxXx => ['xXxXxXxXxXx', 'xXxXxXxXxXx',   'xXxXxXxXxXx'],
	xXxXxXxXxXx => ['xXxXxXxXxXx', 'xXxXxXxXxXx', 'xXxXxXxXxXx'],
};

my $q = CGI->new();
try {

	my $dbh = DBI->connect(
		@{$connections->{$conn}},
		{PrintError => 1, RaiseError => 1}
	) or die "cannot connect to data source: $DBI::errstr";

	my $reportID = "Duedate";
	if (defined $q->param('report') && $q->param('report') =~ m/^(\w+)$/) {
		$reportID = ucfirst($1);
	}
	my $reportPkg = 'Relais2::' . $reportID;
	my $report    = $reportPkg->new();

	my $rows = $report->execute($dbh, $q);

	my $reportFormat = 'html';
	if (defined $q->param('format') && $q->param('format') =~ m/^(\w+)$/) {
		$reportFormat = $1;
	}

	my $tt = Template->new({
			INCLUDE_PATH => ['templates', 'templates'],
		}) or die "Template loading: $Template::ERROR\n";

	if ($reportFormat eq 'html') {
		print $q->header();
		$tt->process(
			"html.tt",
			{
				id            => lc($reportID),
				rows          => $rows,
				report        => $report,
				columns       => $report->columns(),
				columnNames   => $report->columnNames(),
				columnClasses => $report->columnClasses(),
				parameters    => $report->parameters(),
				query         => $q,
			}) or die "Template processing error: " . $tt->error() . "\n";
	}
	if ($reportFormat eq 'csv') {
		print $q->header(
			-type       => 'application/octet-stream',
			-attachment => $reportID . ".csv"
		);
		$tt->process(
			"csv.tt",
			{
				rows          => $rows,
				name          => $report->name(),
				columns       => $report->columns(),
				columnNames   => $report->columnNames(),
				columnClasses => $report->columnClasses(),
			}) or die "Template export error: " . $tt->error() . "\n";
	}

}
catch {
	print $q->header();
	my $tt = Template->new({
			INCLUDE_PATH => ['templates', 'templates'],
		}) or die "Template loading: $Template::ERROR\n";

	$tt->process(
		'error.tt',
		{
			message => $_,
		}) or die "Template processing error: " . $tt->error() . "\n";
};

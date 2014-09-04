#!/usr/bin/perl

=head1 NAME

report.cgi - Reporting tool for Relais 

=cut

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

use Relais2::Duedate;
use Relais2::Recall;
use Relais2::Exhausted;
use Relais2::Pending;
use Relais2::Review;
use Relais2::Search;
use Relais2::Books;
use Relais2::Journals;
use Relais2::Lending;
use Relais2::Borrowing;

=head2 C<< $reportID = getReportID($cgi) >> 

Determine the requested report ID.

=cut

sub getReportID {
	my $q        = shift;
	my $reportID = "Duedate";
	if (defined $q->param('report') && $q->param('report') =~ m/^(\w+)$/) {
		$reportID = ucfirst($1);
	}
	return $reportID;
}

=head2 C<< $report = getReport($id) >>

Get the requested report object.

=cut

sub getReport {
	my $reportID  = shift;
	my $reportPkg = 'Relais2::' . $reportID;
	return $reportPkg->new();
}

=head2 C<< $format = getReportFormat($cgi) >>

Determine the requested report output format, which defaults to HTML.

=cut

sub getReportFormat {
	my $q            = shift;
	my $reportFormat = 'html';
	if (defined $q->param('format') && $q->param('format') =~ m/^(\w+)$/) {
		$reportFormat = $1;
	}
	return $reportFormat;
}

=head2 C<< $dbh = getCommection($name) >>

Connect to the named database. 

=cut

sub getConnection {
	my $id          = shift;
	my $connections = {
		xXxXxXxXxXx => ['xXxXxXxXxXx', 'xXxXxXxXxXx',   'xXxXxXxXxXx'],
		xXxXxXxXxXx => ['xXxXxXxXxXx', 'xXxXxXxXxXx', 'xXxXxXxXxXx'],
	};
	my $dbh = DBI->connect(
		@{$connections->{$id}},
		{PrintError => 1, RaiseError => 1}
	) or die "cannot connect to data source: $DBI::errstr";
	return $dbh;
}

my $q = CGI->new();
try {

	my $dbh = getConnection('xXxXxXxXxXx');
	my $reportID     = getReportID($q);
	my $report       = getReport($reportID);
	my $reportFormat = getReportFormat($q);
	my $rows         = $report->execute($dbh, $q);

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
				columns       => $report->columns($q),
				columnNames   => $report->columnNames($q),
				columnClasses => $report->columnClasses($q),
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
				columns       => $report->columns($q),
				columnNames   => $report->columnNames($q),
				columnClasses => $report->columnClasses($q),
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

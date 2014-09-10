package Relais2::Report;

=head1 NAME

Relais2::Report - Abstract base class for Relais reports

=head1 SYNOPSIS

  package Some::Report;
  use base 'Relais2::Report';

And then somewhere far far away...

  my $report = Some::Report->new();
  my $rows = $report->execute();
  
=cut

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

=head2 AUTOLOAD

Make blessed attributes automatically accessible.

=cut

sub AUTOLOAD {
	my ($name) = our $AUTOLOAD;
	$name =~ s/.*:://;
	my $method = sub {
		my $self = shift;

		if (!defined $self) {
			die
			  "Internal error: undefined \$self in Autoloaded $AUTOLOAD called from "
			  . join(":", caller()) . "\n";
		}

		if (!ref $self) {
			die
			  "Internal error: Unreferenced \$self in Autoloaded $AUTOLOAD / $self "
			  . join(":", caller()) . "\n";
		}

		if (!exists $self->{$name}) {
			die "Internal error: cannot find $name in $AUTOLOAD called from "
			  . join(":", caller()) . "\n";
		}
		if (@_) {
			return $self->{$name} = shift @_;
		} else {
			return $self->{$name};
		}
	};
	{
		no strict 'refs';
		*$AUTOLOAD = $method;
	}
	goto &$AUTOLOAD;
}

sub DESTROY {
	
}

=head2 C<< new() >>

Constructor. Automatically calls C<<$self->init()>>.

=cut

sub new {
	my $class = shift;
	my $self  = {};
	bless $self, $class;
	$self->init(@_);
	return $self;
}

=head2 C<< $report->init() >>

Initialize the report.

=cut

sub init {
	my $self = shift;
	$self->{query} = shift;
	$self->{parameters} = [];
	$self->{pagination} = 0;
	$self->{page} = 0;
	$self->{total_pages} = 0;
}

=head2 C<< $report->addParameter($parameter) >>

Add a L<Relais::Parameter> to the report.

=cut

sub addParameter {
	my $self  = shift;
	my $param = shift;
	push @{$self->{parameters}}, $param;
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {

}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {
	return "";
}

=head2 C<< $rowCount = $report->rowCount() >>

Count the rows in the report.

=cut

sub rowCountQuery {
	return '';
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {};
}

=head2 C<< $report->columnClasses >>

Return a hashref mapping SQL column names to HTML class attribute values.

=cut

sub columnClasses {
	return {};
}

=head2 C<< $row = $report->preprocess($row) >>

Strip out extraneous whitespace from row data

=cut

sub preprocess {
	my $self = shift;
	my $row  = shift;

	foreach my $key (keys %$row) {
		next unless defined $row->{$key};
		$row->{$key} =~ s/\r//g;
		$row->{$key} =~ s/\n//g;
		$row->{$key} =~ s/^\s*|\s*$//;
	}

	return $row;
}

=head2 C<< $row = $report->process($row) >>

Process a row before it is output. 

=cut

sub process {
	my $self = shift;
	my $row  = shift;

	return $row;
}

=head2 C<< $rows = $report->rows($sth) >>

Fetch the rows from a statement handle C<< $sth >> after 
the statment has been executed. Automatically calls
C<<preprocess>> and C<<process>> for each row.

=cut

sub rows {
	my $self = shift;
	my $sth  = shift;
	my @rows = ();

	while (my $row = $sth->fetchrow_hashref()) {
		$row = $self->preprocess($row);
		push @rows, $self->process($row);
	}
	return \@rows;
}

=head2 C<< $page = $reqport->page() >>

Get or set the curernt page.

=cut

sub page {
	my $self = shift;
	my $p = shift;
	if(defined $p) {
		$self->{page} = $p;
		return $p;
	}
	
	# get the page from the request parameters.
	foreach my $param ( @{ $self->parameters() } ) {
		if($param->name() eq 'page') {
			my $v = $param->value($self->{query});
			if(defined $v) {
				return $v;
			} else {
				return $param->default();
			}
		}
	}
	return 1;
}

=head2 C<< $rowCount = $report->rowCount($dbh) >>

Execute the rowCountQuery() if it is defined and return the count.

=cut

sub rowCount {
	my $self = shift;
	my $dbh  = shift;
	my $q    = shift;

	if( ! $self->rowCountQuery()) {
		return;
	}

	my $sth = $dbh->prepare($self->rowCountQuery($q));

	foreach my $param (@{$self->parameters()}) {
		if ($param->bind()) {
			my $value = $param->value($q);
			if (ref $param->bind() eq 'ARRAY') {
				foreach my $bnd ( @{ $param->bind() } ) {
					$sth->bind_param($bnd, $value);
				}
			} else {
				$sth->bind_param($param->bind(), $value);
			}
		}
	}
	$sth->execute();
	my $row = $sth->fetchrow_hashref();
	return $row->{CT};
}

=head2 C<< $rows = $report->execute($dbh) >>

Execute the report and return the cleaned rows. Any report parameters
are automatically bound.

=cut

sub execute {
	my $self = shift;
	my $dbh  = shift;
	my $q    = shift;

	my $sth = $dbh->prepare($self->query($q));

	foreach my $param (@{$self->parameters()}) {
		if ($param->bind()) {
			my $value = $param->value($q);
			if (ref $param->bind() eq 'ARRAY') {
				foreach my $bnd ( @{ $param->bind() } ) {
					$sth->bind_param($bnd, $value);
				}
			} else {
				$sth->bind_param($param->bind(), $value);
			}
		}
	}
	if($self->pagination()) {
		$sth->bind_param('page1', $self->page());
		$sth->bind_param('page2', $self->page());
	}
	$sth->execute();
	return $self->rows($sth);
}

1;

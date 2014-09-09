package Relais2::Borrowingtotals;

=head1 NAME

Relais2::Borrowingtotals - Report books requested more than once in a year.

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report->init() >>

Add start and end dates to the reports.

=cut

sub init {
	my $self = shift;
	$self->SUPER::init(@_);
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Start date',
				name        => 'startdate',
				bind        => ['startdateloans', 'startdatecopies'],
				description => '',
				type        => 'date',
			}));
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'End date',
				name        => 'enddate',
				bind        => ['enddateloans', 'enddatecopies'],
				description => '',
				type        => 'date',
			}));
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Borrowing totals";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {

	# PIVOT TABLES make my head hurt.
	return <<'ENDSQL;'
select 'loans' as TYPE, count(*) as CT 
from sfuv_request_delivery 
where 
      library_symbol='BVAS'
  and service_type='L'
  and delivery_date BETWEEN :startdateloans AND :enddateloans
union
select 'copies' as TYPE, count(*) as CT 
from sfuv_request_delivery 
where 
      library_symbol='BVAS'
  and service_type in ('R','X')
  and delivery_date BETWEEN :startdatecopies AND :enddatecopies;
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [
		qw(TYPE CT)
	];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		TYPE => 'Type',
		CT => 'Total',
	};
}

1;

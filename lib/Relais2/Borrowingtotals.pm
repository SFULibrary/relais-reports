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
				bind        => 'startdate',
				description => '',
				type        => 'date',
			}));
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'End date',
				name        => 'enddate',
				bind        => 'enddate',
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
SELECT
  KIND,
  COUNT(*) AS CT
FROM
  (
    SELECT
      CASE
        WHEN service_type IN ('R', 'X')
          THEN 'copies'
        WHEN service_type IN ('L')
          THEN 'loans'
        ELSE 'unknown'
      END AS KIND
    FROM (
        SELECT
            dbo.ID_REQUEST.SERVICE_TYPE,
            dbo.ID_DELIVERY.DELIVERY_DATE,
            dbo.ID_LIBRARY.LIBRARY_SYMBOL
        FROM
          dbo.ID_LIBRARY
        INNER JOIN dbo.ID_REQUEST
        ON
          dbo.ID_LIBRARY.LIBRARY_ID = dbo.ID_REQUEST.LIBRARY_ID
        LEFT OUTER JOIN dbo.ID_DELIVERY
        ON
          dbo.ID_REQUEST.REQUEST_NUMBER = dbo.ID_DELIVERY.REQUEST_NUMBER
      ) t2
    WHERE
      library_symbol ='BVAS'
    AND 	
      :startdate <= delivery_date AND delivery_date - 1 <= :enddate
  ) t1
GROUP BY kind
ORDER BY kind;
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [
		qw(KIND CT)
	];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		KIND => 'Type',
		CT => 'Total',
	};
}

1;

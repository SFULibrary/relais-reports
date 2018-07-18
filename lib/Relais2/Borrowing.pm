package Relais2::Borrowing;

=head1 NAME

Relais2::Borrowing - Statistics for institutional borrowing.

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report ->init() >>

Initialize the report by adding two parameters.

=cut

sub init {
  my $start = DateTime->today()->set_day(1);
  my $end = DateTime->today()->set_day(1)->add(months => 1)->subtract(days => 1);
	my $self = shift;
	$self->SUPER::init(@_);
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Start date',
				name        => 'startdate',
				bind        => ['startdate'],
				description => '',
				type        => 'date',
                                default => $start->ymd(),
			}));
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'End date',
				name        => 'enddate',
				bind        => ['enddate'],
				description => '',
				type        => 'date',
                                default => $end->ymd(),
			}));
}

=head2 C<< $report->name >>

Report name (Borrowing).

=cut

sub name {
	return "Borrowing";
}

=head2 C<< $report->query >>

Returns the text of the SQL query for the report.

=cut

sub query {

	return <<'ENDSQL;'
SELECT
  SUPPLIER_CODE_1,
  COALESCE([CPY], 0) + COALESCE([PNS], 0) AS PHOTOCOPIES,
  COALESCE([LON], 0)                      AS LOANS
FROM
  (
    SELECT
      SUPPLIER_CODE_1,
      COALESCE(EXCEPTION_CODE, 'CPY') AS EXCEPTION_CODE,
      COUNT(*)                        AS CT
    FROM
      (
        SELECT
          dbo.ID_DELIVERY.EXCEPTION_CODE,
          dbo.ID_DELIVERY.DELIVERY_DATE,
          dbo.ID_DELIVERY.SUPPLIER_CODE_OVR,
          dbo.ID_DELIVERY.SUPPLIER_CODE_1,
          dbo.ID_LIBRARY.LIBRARY_SYMBOL,
          dbo.ID_LIBRARY.LIBRARY
        FROM
          dbo.ID_LIBRARY 
          INNER JOIN  dbo.ID_REQUEST 
            ON dbo.ID_LIBRARY.LIBRARY_ID = dbo.ID_REQUEST.LIBRARY_ID
          LEFT OUTER JOIN dbo.ID_DELIVERY 
            ON dbo.ID_REQUEST.REQUEST_NUMBER = dbo.ID_DELIVERY.REQUEST_NUMBER
      )
      T1
    WHERE
      :startdate <= delivery_date AND delivery_date - 1 <= :enddate
    AND
      (
        EXCEPTION_CODE IS NULL
      OR EXCEPTION_CODE ='PNS'
      OR EXCEPTION_CODE ='LON'
      )
    AND LIBRARY_SYMBOL='BVAS'
    GROUP BY
      SUPPLIER_CODE_1,
      EXCEPTION_CODE
  )
  PS PIVOT ( MAX(CT) FOR EXCEPTION_CODE IN ([CPY], [PNS], [LON]) ) AS pvt
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(SUPPLIER_CODE_1 PHOTOCOPIES LOANS)];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		SUPPLIER_CODE_1 => 'Library symbol',
		PHOTOCOPIES     => 'Photocopies',
		LOANS           => 'Loans'
	};
}

1;

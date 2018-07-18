package Relais2::Lending;

=head1 NAME

Relais2::Lending - Lending statistics.

=cut

use DateTime;
use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report ->init() >>

Add start and end date parameters.

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

Return the name of the report.

=cut

sub name {
	return "Lending";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {

	# PIVOT TABLES make my head hurt.
	return <<'ENDSQL;'
SELECT
  library_symbol,
  coalesce([loanfilled],0)   AS loansfilled,
  coalesce([copyfilled], 0)   AS copiesfilled,
  coalesce([loanunfilled], 0) AS loansunfilled,
  coalesce([copyunfilled], 0) AS copiesunfilled,
  [unknown]      AS UNKNOWN
FROM (
    SELECT
      COUNT(*) ct, library_symbol, status
    FROM (
        SELECT
          library_symbol,
          CASE
            WHEN (exception_code = 'LON')
              THEN 'loanfilled'
            WHEN ((exception_code IS NULL) OR (exception_code = 'PNS'))
              THEN 'copyfilled'
            WHEN (service_type = 'L'AND ((exception_code != NULL) OR (exception_code NOT IN ('PNS', 'LON'))))
              THEN 'loanunfilled'
            WHEN (service_type = 'X' AND ((exception_code != NULL) OR ( exception_code NOT IN ('PNS', 'LON'))))
              THEN 'copyunfilled'
            ELSE 'unknown'
          END AS status
        FROM
          (
            SELECT
              dbo.ID_REQUEST.SERVICE_TYPE,
              dbo.ID_DELIVERY.EXCEPTION_CODE,
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
          )
          T1
        WHERE
          library_symbol != 'BVAS'
        AND 	
          :startdate <= delivery_date AND DATEADD(DAY, -1, delivery_date) <= :enddate
      )
      st
    GROUP BY
      library_symbol,
      status
  )
  ps pivot ( MAX(ct) FOR status IN ([loanfilled], [copyfilled], [loanunfilled],
  [copyunfilled], [unknown]) ) AS pvt
ORDER BY
  library_symbol;
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(library_symbol loansfilled copiesfilled loansunfilled copiesunfilled)];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		library_symbol => 'Library',
		loansfilled => 'Loans filled',
		copiesfilled => 'Copies filled',
		loansunfilled => 'Loans unfilled',
		copiesunfilled => 'Copies unfilled',
	};
}

=head2 C<< $report->process($row) >>

Process each row by turning the library_symbol data into an HTML link.

=cut

sub process {
	my $self = shift;
	my $row = shift;
	my $startdate = $self->{parameters}->[0]->value($self->{query});
	my $enddate = $self->{parameters}->[1]->value($self->{query});
	
	$row->{library_symbol} = qq[<a href="?report=lendingdetails&amp;loc=] . $row->{library_symbol} . qq[&amp;startdate=${startdate}&amp;enddate=${enddate}">] . $row->{library_symbol} . '</a>';
	return $row;
}

1;

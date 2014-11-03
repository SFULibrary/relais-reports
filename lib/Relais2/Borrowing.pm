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
	my $self = shift;
	$self->SUPER::init(@_);
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Start date',
				name        => 'startdate',
				bind        => ['startdate'],
				description => '',
				type        => 'date',
			}));
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'End date',
				name        => 'enddate',
				bind        => ['enddate'],
				description => '',
				type        => 'date',
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
    coalesce([CPY], 0) + coalesce([PNS], 0) as PHOTOCOPIES, 
    coalesce([LON], 0) as LOANS
FROM (		
	SELECT 
		SUPPLIER_CODE_1, coalesce(EXCEPTION_CODE, 'CPY') AS EXCEPTION_CODE, COUNT(*) as CT
	FROM 
		SFUV_REQUEST_DELIVERY
	WHERE 
		    DELIVERY_DATE BETWEEN :startdate AND :enddate
		AND ( EXCEPTION_CODE IS NULL OR EXCEPTION_CODE='PNS' OR EXCEPTION_CODE='LON' )
		AND LIBRARY_SYMBOL='BVAS'	
	GROUP BY 
		SUPPLIER_CODE_1, EXCEPTION_CODE
) PS
PIVOT (
  MAX(CT) FOR EXCEPTION_CODE IN ([CPY], [PNS], [LON])
) AS pvt
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

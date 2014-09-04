package Relais2::Borrowing;

=head1 NAME

Relais2::Books - Report books requested more than once in a year.

=cut

use Relais2::Parameter;
use parent 'Relais2::Report';

=head2 init()


=cut

sub init {
	my $self = shift;
	$self->SUPER::init();
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

sub name {
	return "Statistics";
}

sub query {

	# PIVOT TABLES make my head hurt.
	return <<'ENDSQL;'
SELECT 
	SUPPLIER_CODE_1, [PNS] as PHOTOCOPIES, [LON] as LOANS
FROM (		
	SELECT 
		SUPPLIER_CODE_1, EXCEPTION_CODE, COUNT(*) as CT
	FROM 
		SFUV_REQUEST_DELIVERY
	WHERE 
		    DELIVERY_DATE BETWEEN :startdate AND :enddate
		AND ( EXCEPTION_CODE='PNS' OR EXCEPTION_CODE='LON' )
		AND LIBRARY_SYMBOL='BVAS'	
	GROUP BY 
		SUPPLIER_CODE_1, EXCEPTION_CODE
) PS
PIVOT (
  MAX(CT) FOR EXCEPTION_CODE IN ([PNS], [LON])
) AS pvt
ENDSQL;
}

sub columns {
	return [qw(SUPPLIER_CODE_1 PHOTOCOPIES LOANS)];
}

sub columnNames {
	return {
		SUPPLIER_CODE_1 => 'Library symbol',
		PHOTOCOPIES     => 'Photocopies',
		LOANS           => 'Loans'
	};
}

1;

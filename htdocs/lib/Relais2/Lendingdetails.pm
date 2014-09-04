package Relais2::Lendingdetails;

=head1 NAME

Relais2::Books - Report books requested more than once in a year.

=cut

use Relais2::Parameter;
use parent 'Relais2::Report';

=head2 init()


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
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Location',
				name        => 'loc',
				bind        => 'loc',
				description => '',
				type        => "text",
			}));
}

sub name {
	return "Statistics";
}

sub query {

	# PIVOT TABLES make my head hurt.
	return <<'ENDSQL;'
SELECT 
	CASE  
		when (EXCEPTION_CODE is null OR EXCEPTION_CODE = 'PNS') then 'COPY'
		when (EXCEPTION_CODE = 'LON') then 'LOAN'
	END as TYPE,
	REQUEST_NUMBER, EXTERNAL_NUMBER, DELIVERY_DATE, TITLE
FROM
	SFUV_REQUEST_DELIVERY
WHERE
		delivery_date BETWEEN :startdate AND :enddate
	AND	LIBRARY_SYMBOL = :loc
	AND (EXCEPTION_CODE is null OR EXCEPTION_CODE IN ('PNS', 'LON'))
ENDSQL;
}

sub columns {
	return [
		qw(TYPE REQUEST_NUMBER EXTERNAL_NUMBER DELIVERY_DATE TITLE)
	];
}

sub columnNames {
	return {
		TYPE => 'Type',
		REQUEST_NUMBER => 'SFU ID',
		EXTERNAL_NUMBER => 'Requester ID',
		DELIVERY_DATE => 'Date Filled',
		TITLE => 'Title'
	};
}

sub columnClasses {
	return {
		REQUEST_NUMBER => "requestnum", 
		EXTERNAL_NUMBER => "requestnum",
		DELIVERY_DATE => "date",
	};
}


sub process {
	my $self = shift;
	my $row  = shift;
	$row->{DELIVERY_DATE} = substr($row->{DELIVERY_DATE}, 0, 10);
	return $row;
}

1;

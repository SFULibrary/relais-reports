package Relais2::Lendingdetails;

=head1 NAME

Relais2::Lendingdetails - Instutional lending details.

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report ->init() >>

Add start and end date, and location parameters.

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

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Lending Details";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

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

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [
		qw(TYPE REQUEST_NUMBER EXTERNAL_NUMBER DELIVERY_DATE TITLE)
	];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		TYPE => 'Type',
		REQUEST_NUMBER => 'SFU ID',
		EXTERNAL_NUMBER => 'Requester ID',
		DELIVERY_DATE => 'Date Filled',
		TITLE => 'Title'
	};
}

=head2 C<< $report->columnClasses() >>

Return the html classes for the columns in the report.

=cut

sub columnClasses {
	return {
		REQUEST_NUMBER => "requestnum", 
		EXTERNAL_NUMBER => "requestnum",
		DELIVERY_DATE => "date",
	};
}

=head2 C<< $report->process($row) >>

Process each row by limiting the DELIVERY_DATE column to 10 characters.

=cut

sub process {
	my $self = shift;
	my $row  = shift;
	$row->{DELIVERY_DATE} = substr($row->{DELIVERY_DATE}, 0, 10);
	return $row;
}

1;

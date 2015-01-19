package Relais2::Lendingoutdated;

=head1 NAME

Relais2::Lendingoutdated - Loans overdue

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report ->init() >>

Add start and end date parameters.

=cut

sub init {
	my $self = shift;
	$self->SUPER::init(@_);
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Days overdue',
				name        => 'days',
				bind        => ['days'],
				description => '',
				type        => 'number',
				default     => 7
			}));
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Lending Outdated";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {
	return <<'ENDSQL;'
		SELECT
		  event_id, request_number, external_number, library_symbol, date_entered
		FROM
		  IDV_REQUESTFLOW
		WHERE
		  DATE_PROCESSED                          IS NULL
		AND PATRON_ID                             IS NULL
		AND DATEDIFF(DAY, DATE_ENTERED, GETDATE()) > :days
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(request_number event_id external_number library_symbol date_entered)];
}

sub process {
	my $self = shift;
	my $row = shift;
	$row->{date_entered} = substr($row->{date_entered}, 0, 10);
	return $row;
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		library_symbol => 'Library',
		event_id => 'Event ID',
		request_number => 'Request Number',
		external_number => 'External Number',
		date_entered => 'Date Entered',
	};
}

sub columnClasses {
	return {
		request_number => "requestnum", 
		date_entered => "date",
	};
}


1;

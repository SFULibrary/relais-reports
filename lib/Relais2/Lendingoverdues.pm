package Relais2::Lendingoverdues;

=head1 NAME

Relais2::Lendingoutdated - Loans overdue

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

# use DateTime;

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
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Cutoff date',
				name        => 'cutoff',
				bind        => ['cutoff'],
				description => '',
				type        => 'date',
				# default     => DateTime->now()->subtract(years => 1)->ymd()
			}));
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Lending Overdues";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {
	return <<'ENDSQL;'
		SELECT
		  request_number, library_symbol, due_date, loan_status_desc
		FROM
		  IDV_LOAN_OVERDUE
		WHERE
		  DUE_DATE > :cutoff
	    AND DATEDIFF(DAY, DUE_DATE, GETDATE()) > :days
		AND LOAN_STATUS_DESC                <> 'Returned'
		AND LIBRARY_SYMBOL <> 'BVAS'
		ORDER BY DUE_DATE;
ENDSQL;
}

sub process {
	my $self = shift;
	my $row = shift;
	$row->{due_date} = substr($row->{due_date}, 0, 10);
	return $row;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(request_number library_symbol due_date loan_status_desc)];
}

sub columnClasses {
	return {
		request_number => "requestnum", 
		due_date => "date",
	};
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		library_symbol => 'Library',
		request_number => 'Request Number',
		due_date => 'Due Date',
		loan_status_desc => 'Loan Status',
	};
}

1;

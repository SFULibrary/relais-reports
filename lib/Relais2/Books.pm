package Relais2::Books;

=head1 NAME

Relais2::Books - Report books requested more than once in a year.

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report ->init() >>

Add Year as a report parameter

=cut

sub init {
	my $self = shift;
	$self->SUPER::init(@_);
	$self->addParameter(
		Relais2::Parameter->new({
			label => 'Year',
			name => 'year',
			bind => 'yr',
			description => '',
			type => 'number',
			default => (localtime())[5] + 1900,
		})
	);
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Book Report";	
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {

	return << 'ENDSQL;'	
SELECT 
	COUNT(*) CT, dbo.ID_REQUEST.TITLE, dbo.ID_REQUEST.AUTHOR, dbo.ID_REQUEST.PUBLISHER, 
	dbo.ID_REQUEST.PUBLICATION_YEAR, dbo.ID_REQUEST.EDITION, dbo.ID_REQUEST.ISBN
FROM 
	dbo.ID_REQUEST
WHERE 
		YEAR(dbo.ID_REQUEST.DATE_ENTERED) = :yr 
	and dbo.ID_REQUEST.PUBLICATION_TYPE IN ('B') 
	and dbo.ID_REQUEST.REQUEST_NUMBER like 'PAT%'
GROUP BY 
	dbo.ID_REQUEST.TITLE, dbo.ID_REQUEST.AUTHOR, dbo.ID_REQUEST.PUBLISHER, 
	dbo.ID_REQUEST.PUBLICATION_YEAR, dbo.ID_REQUEST.EDITION, dbo.ID_REQUEST.ISBN
HAVING 
	COUNT(*) >= 2;
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(
		CT TITLE AUTHOR PUBLISHER PUBLICATION_YEAR EDITION ISBN
	)];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		CT => 'Count',
		TITLE => 'Title', 
		AUTHOR => 'Author', 
		PUBLISHER => 'Publisher',
		PUBLICATION_YEAR => 'Pub Year',
		EDITION => 'Edition',
		ISBN => 'ISBN'
	};
}

1;

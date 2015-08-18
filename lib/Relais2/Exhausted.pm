package Relais2::Exhausted;

=head1 NAME

Relais2::Exhausted - Items which cannot be found for delivery

=cut

use base 'Relais2::Report';

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Exhausted";	
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {

	return << 'ENDSQL;'
	
SELECT
	dbo.IDV_REQUEST_INFO.REQUEST_NUMBER,
	dbo.IDV_REQUEST_INFO.TITLE, dbo.IDV_REQUEST_INFO.PATRON_NAME, dbo.IDV_REQUEST_INFO.PATRON_SURNAME, 
	dbo.IDV_REQUEST_INFO.PATRON_TYPE_DESC, dbo.IDV_REQUEST_INFO.NEED_BY_DATE, 
	dbo.IDV_REQUEST_INFO.BIBLIOGRAPHY_NUM
FROM
    dbo.IDV_REQUEST_INFO
    	INNER JOIN dbo.ID_QUEUE 
    		ON dbo.IDV_REQUEST_INFO.REQUEST_NUMBER = dbo.ID_QUEUE.REQUEST_NUMBER
WHERE
	dbo.IDV_REQUEST_INFO.SUPPLIER_CODE_1 = 'List Exhausted'
		AND
	dbo.ID_QUEUE.EVENT_ID IS NOT NULL
	 
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(
		REQUEST_NUMBER TITLE NAME PATRON_TYPE_DESC NEED_BY_DATE BIBLIOGRAPHY_NUM
	)];
}

=head2 C<< $row = $report->process($row) >>

Process a row before it is output. 

=cut

sub process {
	my $self = shift;
	my $row = shift;
	$row->{NEED_BY_DATE} = substr($row->{NEED_BY_DATE}, 0, 10);
	$row->{NAME} = $row->{PATRON_SURNAME} . ', ' . $row->{PATRON_NAME}; 
	return $row;
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		REQUEST_NUMBER => 'Request Number',
		TITLE => 'Title',
		NAME => 'Patron',
		PATRON_TYPE_DESC => 'Status',
		NEED_BY_DATE => 'Need By',
		BIBLIOGRAPHY_NUM => 'Tag',
	};
}

=head2 C<< $report->columnClasses >>

Return a hashref mapping SQL column names to HTML class attribute values.

=cut

sub columnClasses {
	return {
		REQUEST_NUMBER => "requestnum", 
		NEED_BY_DATE => "date",
	};
}


1;
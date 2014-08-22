package Relais2::Duedate;

use parent 'Relais2::Report';

sub name {
	return "Due date";
}

sub query {

	return << 'ENDSQL;'
SELECT     
	dbo.ID_REQUEST.REQUEST_NUMBER, dbo.ID_REQUEST.TITLE, dbo.ID_PATRON.PATRON_NAME, 
	dbo.ID_PATRON.PATRON_SURNAME, dbo.ID_PATRON.PATRON_TYPE, dbo.ID_LOAN_TRACKING.DUE_DATE, 
	dbo.ID_DELIVERY.SUPPLIER_CODE_1
FROM
    dbo.ID_REQUEST 
    	INNER JOIN dbo.ID_PATRON 
    		ON dbo.ID_REQUEST.PATRON_ID = dbo.ID_PATRON.PATRON_ID 
    	INNER JOIN dbo.ID_LOAN_TRACKING 
    		ON dbo.ID_REQUEST.REQUEST_NUMBER = dbo.ID_LOAN_TRACKING.REQUEST_NUMBER 
    		AND dbo.ID_LOAN_TRACKING.LOAN_STATUS = 'LON'
    	INNER JOIN dbo.ID_DELIVERY ON dbo.ID_REQUEST.REQUEST_NUMBER = dbo.ID_DELIVERY.REQUEST_NUMBER                      
ENDSQL;
}

sub columns {
	return [qw(
		REQUEST_NUMBER TITLE PATRON_NAME PATRON_SURNAME 
		PATRON_TYPE DUE_DATE SUPPLIER_CODE_1
	)];
}

sub process {
	my $self = shift;
	my $row = shift;
	$row->{DUE_DATE} = substr($row->{DUE_DATE}, 0, 10);
	return $row;
}

sub columnNames {
	return {
		REQUEST_NUMBER => "Request number", 
		TITLE => "Title",
		PATRON_NAME => "First name",
		PATRON_SURNAME => "Surname",		
		PATRON_TYPE => "Status",
		DUE_DATE => "Due date",
		SUPPLIER_CODE_1 => "Supplier"
	};
}

sub columnClasses {
	return {
		REQUEST_NUMBER => "requestnum", 
		DUE_DATE => "date",
	};
}


1;
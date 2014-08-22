package Relais2::Pending;

use parent 'Relais2::Report';

sub name {
	return "Pending";	
}

sub query {

	return << 'ENDSQL;'
	
SELECT
	dbo.IDV_REQUEST_INFO.REQUEST_NUMBER,
	dbo.IDV_REQUEST_INFO.TITLE, dbo.IDV_REQUEST_INFO.PATRON_NAME, dbo.IDV_REQUEST_INFO.PATRON_SURNAME, 
	dbo.IDV_REQUEST_INFO.PATRON_TYPE_DESC, dbo.IDV_REQUEST_INFO.SUPPLIER_CODE_1, 
	dbo.ID_QUEUE.SUPPLIER_DATE_SENT, 
	dbo.IDV_REQUEST_INFO.NEED_BY_DATE
FROM
    dbo.IDV_REQUEST_INFO
    	INNER JOIN dbo.ID_QUEUE 
    		ON dbo.IDV_REQUEST_INFO.REQUEST_NUMBER = dbo.ID_QUEUE.REQUEST_NUMBER
WHERE
	dbo.ID_QUEUE.EVENT_ID = 4001    		
ENDSQL;
}

sub columns {
	return [qw(
		REQUEST_NUMBER TITLE PATRON_NAME PATRON_SURNAME PATRON_TYPE_DESC SUPPLIER_CODE_1 
		SUPPLIER_DATE_SENT NEED_BY_DATE
	)];
}


sub process {
	my $self = shift;
	my $row = shift;
	$row->{SUPPLIER_DATE_SENT} = substr($row->{SUPPLIER_DATE_SENT}, 0, 10);
	$row->{NEED_BY_DATE} = substr($row->{NEED_BY_DATE}, 0, 10);
	return $row;
}


sub columnNames {
	return {
		REQUEST_NUMBER => 'Request Number',
		TITLE => 'Title',
		PATRON_NAME => 'First name',
		PATRON_SURNAME => 'Surname',
		PATRON_TYPE_DESC => 'Status',
		SUPPLIER_CODE_1 => 'Supplier',
		SUPPLIER_DATE_SENT => 'Sent',
		NEED_BY_DATE => 'Need By'
	};
}


sub columnClasses {
	return {
		REQUEST_NUMBER => "requestnum", 
		NEED_BY_DATE => "date",
		SUPPLIER_DATE_SENT => "date",
	};
}

1;
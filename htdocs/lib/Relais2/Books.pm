package Relais2::Books;

use parent 'Relais2::Report';

sub name {
	return "Pending";	
}

sub query {

	return << 'ENDSQL;'
	
SELECT COUNT(*) CT, TITLE, AUTHOR, PUBLISHER, PUBLICATION_YEAR, EDITION, ISBN
FROM ID_REQUEST
WHERE DATE_ENTERED like '%2013%' and PUBLICATION_TYPE IN ('B') and REQUEST_NUMBER like 'PAT%'
GROUP BY TITLE, AUTHOR, PUBLISHER, PUBLICATION_YEAR, EDITION, ISBN
HAVING COUNT(*) >= 2
ENDSQL;

}

sub columns {
	return [qw(
		CT TITLE AUTHOR PUBLISHER PUBLICATION_YEAR EDITION ISBN
	)];
}


sub process {
	my $self = shift;
	my $row = shift;
	return $row;
}


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


sub columnClasses {
	return {
	};
}

1;
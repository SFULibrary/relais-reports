package Relais2::Books;

use Relais2::Parameter;
use parent 'Relais2::Report';

sub init {
	my $self = shift;
	$self->SUPER::init();
	$self->addParameter(
		Relais2::Parameter->new({
			label => 'Year',
			name => 'year',
			bind => ':yr',
			description => '',
			type => 'number',
			default => (localtime())[5] + 1900,
		})
	);
}

sub name {
	return "Book Report";	
}

sub query {

	return << 'ENDSQL;'
	
SELECT COUNT(*) CT, TITLE, AUTHOR, PUBLISHER, PUBLICATION_YEAR, EDITION, ISBN
FROM ID_REQUEST
WHERE DATE_ENTERED like '%' + :year + '%' and PUBLICATION_TYPE IN ('B') and REQUEST_NUMBER like 'PAT%'
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
package Relais2::Lendingrequests;

=head1 NAME

Relais2::Lendingrequests - Lending statistics.

=cut

use Relais2::Parameter;
use base 'Relais2::Report';

=head2 C<< $report ->init() >>

Add start and end date parameters.

=cut

sub init {
	my $self = shift;
	$self->SUPER::init(@_);
	$self->pagination(1);
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Location',
				name        => 'loc',
				bind        => 'loc',
				description => '',
				type        => "text",
			}));
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Page',
				name        => 'page',
				bind        => undef,
				description => '',
				type        => 'pagination',
				default     => 1,
			}));
	$self->addParameter(
		Relais2::Parameter->new({
			label => 'Order by',
			name => 'order',
			bind => undef,
			description => '',
			type => 'select',
			default => 'DATE_SUBMITTED',
			options => $self->columnNames(),
		})
	);
	$self->addParameter(
		Relais2::Parameter->new({
			label => 'Direction',
			name => 'dir',
			bind => undef,
			description => '',
			type => 'select',
			default => 'DESC',
			options => {
				'DESC' => 'Descending',
				'ASC' => 'Ascending'
			}
		})
	);
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Lending View - Requests By Library";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {
	my $self = shift;
	my $q = shift;
	my $order = $self->getParameter('order')->default();
	if(defined $self->columnNames()->{$self->getParameter('order')->value($q)}) {
		$order = $self->getParameter('order')->value($q);
	}	
	
	my $dir = $self->getParameter('dir')->default();
	if($self->getParameter('dir')->value($q) =~ m/^(ASC|DESC)$/) {
		$dir = $1;
	}
	
	return <<"ENDSQL;"
SELECT * FROM (
	SELECT
		REQUEST_NUMBER, TITLE, REQUESTER, DATE_SUBMITTED, SERVICE_TYPE_DESC,
		ROW_NUMBER() OVER (ORDER BY $order $dir) as rn
	FROM
		IDV_REQUEST_INFO
	WHERE
		LIBRARY_SYMBOL = :loc
) tmp
WHERE rn BETWEEN ((:page1 - 1) * 100 + 1) AND ( :page2 * 100)
ORDER BY rn;
ENDSQL;
}

=head2 C<< $rowCount = $report->rowCount() >>

Count the rows in the report.

=cut

sub rowCountQuery {
	return <<'ENDSQL';
SELECT
	COUNT(*) as CT
FROM
	IDV_REQUEST_INFO
WHERE
	LIBRARY_SYMBOL = :loc
ENDSQL
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [
		qw(REQUEST_NUMBER TITLE REQUESTER DATE_SUBMITTED SERVICE_TYPE_DESC)];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		REQUEST_NUMBER    => 'Request number',
		TITLE             => 'Title',
		REQUESTER         => 'Requester',
		DATE_SUBMITTED    => 'Date submitted',
		SERVICE_TYPE_DESC => 'Type',
	};
}

=head2 C<< $report->process($row) >>

Process each row by turning the library_symbol data into an HTML link.

=cut

sub process {
	my $self = shift;
	my $row  = shift;
	$row->{DATE_SUBMITTED} = substr($row->{DATE_SUBMITTED}, 0, 10);
	return $row;
}

1;

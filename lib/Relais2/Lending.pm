package Relais2::Lending;

=head1 NAME

Relais2::Books - Lending statistics.

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
}

=head2 C<< $report->name >>

Return the name of the report.

=cut

sub name {
	return "Lending";
}

=head2 C<< $report->query >>

Return the SQL query.

=cut

sub query {

	# PIVOT TABLES make my head hurt.
	return <<'ENDSQL;'
select 
  library_symbol, [loanfilled] as loansfilled, [copyfilled] as copiesfilled, 
  [loanunfilled] as loansunfilled, [copyunfilled] as copiesunfilled,
  [unknown] as unknown
from (
	select 
		count(*) ct, library_symbol, status 
	from (
		select 
  			library_symbol, 
  			case 
    			when(exception_code = 'LON') then 'loanfilled'
    			when((exception_code is null) or (exception_code = 'PNS')) then 'copyfilled'
    			when(service_type = 'L' and ((exception_code != null) or (exception_code not in ('PNS', 'LON')))) then 'loanunfilled'
    			when(service_type = 'X' and ((exception_code != null) or (exception_code not in ('PNS', 'LON')))) then 'copyunfilled'
    			else 'unknown'
  			end as status
			from
				sfuv_request_delivery
			where 
					library_symbol != 'BVAS'
				and delivery_date BETWEEN :startdate AND :enddate
	) st
	group by
		library_symbol, status
) ps
pivot (
 	max(ct) for status in ([loanfilled], [copyfilled], [loanunfilled], [copyunfilled], [unknown])
) as pvt
order by 
	library_symbol;
ENDSQL;
}

=head2 C<< $report->columns >>

Return an arrayref of the SQL columns in the report, in the order they should appear.

=cut

sub columns {
	return [qw(library_symbol loansfilled copiesfilled loansunfilled copiesunfilled)];
}

=head2 C<< $report->columnNames >>

Return a hashref mapping SQL column names to human readable column names.

=cut

sub columnNames {
	return {
		library_symbol => 'Library',
		loansfilled => 'Loans filled',
		copiesfilled => 'Copies filled',
		loansunfilled => 'Loans unfilled',
		copiesunfilled => 'Copies unfilled',
	};
}

=head2 C<< $report->process($row) >>

Process each row by turning the library_symbol data into an HTML link.

=cut

sub process {
	my $self = shift;
	my $row = shift;
	my $startdate = $self->{parameters}->[0]->value($self->{query});
	my $enddate = $self->{parameters}->[1]->value($self->{query});
	
	$row->{library_symbol} = qq[<a href="?report=lendingdetails&amp;loc=] . $row->{library_symbol} . qq[&amp;startdate=${startdate}&amp;enddate=${enddate}">] . $row->{library_symbol} . '</a>';
	return $row;
}

1;

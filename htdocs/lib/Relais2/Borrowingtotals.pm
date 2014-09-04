package Relais2::Borrowingtotals;

=head1 NAME

Relais2::Books - Report books requested more than once in a year.

=cut

use Relais2::Parameter;
use parent 'Relais2::Report';

=head2 init()


=cut

sub init {
	my $self = shift;
	$self->SUPER::init(@_);
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'Start date',
				name        => 'startdate',
				bind        => ['startdateloans', 'startdatecopies'],
				description => '',
				type        => 'date',
			}));
	$self->addParameter(
		Relais2::Parameter->new({
				label       => 'End date',
				name        => 'enddate',
				bind        => ['enddateloans', 'enddatecopies'],
				description => '',
				type        => 'date',
			}));
}

sub name {
	return "Statistics";
}

sub query {

	# PIVOT TABLES make my head hurt.
	return <<'ENDSQL;'
select 
  'loans' as TYPE, count(*) as CT 
from 
  sfuv_request_delivery 
where 
      library_symbol='BVAS'
  and service_type='L'
  and delivery_date BETWEEN :startdateloans AND :enddateloans

union

select 
  'copies' as TYPE, count(*) as CT 
from 
  sfuv_request_delivery 
where 
      library_symbol='BVAS'
  and service_type in ('R','X')
  and delivery_date BETWEEN :startdatecopies AND :enddatecopies;
ENDSQL;
}

sub columns {
	return [
		qw(TYPE CT)
	];
}

sub columnNames {
	return {
		TYPE => 'Type',
		CT => 'Total',
	};
}

1;

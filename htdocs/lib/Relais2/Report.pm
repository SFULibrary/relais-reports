package Relais2::Report;

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->init();
    return $self;
}

sub name {
	
}

sub description {
	
}

sub init {
}

sub query {
}

sub columns {
}

sub columnNames {
}

sub rows {
	my $self = shift;
	my $sth = shift;
	my @rows = ();
	
	while(my $row = $sth->fetchrow_hashref()) {
		push @rows, $row;
	}
	return \@rows;
}

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

sub columnClasses {	
}

sub preprocess {
	my $self = shift;
	my $row = shift;
	
	foreach my $key (keys %$row) {
		$row->{$key} =~ s/\r//g;
		$row->{$key} =~ s/\n//g;
		$row->{$key} =~ s/^\s*|\s*$//;
	}
	
	return $row;
}

sub process {
	my $self = shift;
	my $row = shift;
	
	return $row;
}

sub rows {
	my $self = shift;
	my $sth = shift;
	my @rows = ();
	
	while(my $row = $sth->fetchrow_hashref()) {
		$row = $self->preprocess($row);
		push @rows, $self->process($row);
	}
	return \@rows;
}

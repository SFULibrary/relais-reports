package Relais2::Report;

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;

sub AUTOLOAD {
    my ($name) = our $AUTOLOAD;
    $name =~ s/.*:://;
    my $method = sub {
        my $self = shift;

        if (!defined $self) {
            die "Internal error: undefined \$self in Autoloaded $AUTOLOAD called from " . join(":", caller()) . "\n";
        }

        if (!ref $self) {
            die "Internal error: Unreferenced \$self in Autoloaded $AUTOLOAD / $self " . join(":", caller()) . "\n";
        }

        if (!exists $self->{$name}) {
            die "Internal error: cannot find $name in $AUTOLOAD called from " . join(":", caller()) . "\n";
        }
        if (@_) {
            return $self->{$name} = shift @_;
        } else {
            return $self->{$name};
        }
    };
    {
        no strict 'refs';
        *$AUTOLOAD = $method;
    }
    goto &$AUTOLOAD;
}

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init {
	my $self = shift;
	$self->{parameters} = [];
}

sub addParameter {
	my $self = shift;
	my $param = shift;
	push @{$self->{parameters}}, $param;
}

sub name {
	
}

sub description {
	
}

sub parameters {
	my $self = shift;
	return $self->{parameters};
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

sub execute {
	my $self = shift;
	my $dbh = shift;
	my $q = shift;
	
	my $sth = $dbh->prepare($self->query());
	
	foreach my $param (@{$self->parameters()}) {
		my $name = $param->name();
		my $value = $param->default();		
		if(defined $q->param($name)) {
			$value = $q->param($name);
		}
		print STDERR "binding $name to $value";
		$sth->bind_param($name, $value);		
	}
	$sth->execute();
	return $self->rows($sth);	
}

1;
package Relais2::Parameter;

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

sub AUTOLOAD {
	my ($name) = our $AUTOLOAD;
	$name =~ s/.*:://;
	my $method = sub {
		my $self = shift;

		if (!defined $self) {
			die
			  "Internal error: undefined \$self in Autoloaded $AUTOLOAD called from "
			  . join(":", caller()) . "\n";
		}

		if (!ref $self) {
			die
			  "Internal error: Unreferenced \$self in Autoloaded $AUTOLOAD / $self "
			  . join(":", caller()) . "\n";
		}

		if (!exists $self->{$name}) {
			die "Internal error: cannot find $name in $AUTOLOAD called from "
			  . join(":", caller()) . "\n";
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
	my $opts = shift;

	$self->{label} = defined $opts->{label} ? $opts->{label} : '';
	$self->{name}  = defined $opts->{name}  ? $opts->{name}  : '';
	$self->{bind}  = defined $opts->{bind}  ? $opts->{bind}  : '';
	$self->{description} =
	  defined $opts->{description} ? $opts->{description} : '';
	$self->{type}    = defined $opts->{type}    ? $opts->{type}    : '';
	$self->{default} = defined $opts->{default} ? $opts->{default} : '';
}

sub value {
	my $self = shift;
	my $q    = shift;
	if (defined $q->param($self->{name})) {
		return $q->param($self->{name});
	}
	return $self->{default};
}


package Relais2::Parameter;

=head1 NAME

Relais2::Parameter - A parameter in a report

=HEAD1 FIELDS

=over 4

=item label - The human-readable label for the parameter

=item name - the HTML name attribute value

=item bind - the SQL placeholder for the parameter

=item type - the HTML input type attribute value

=item default - the default value for the parameter

=back

=cut

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

=head2 AUTOLOAD

Make blessed attributes automatically accessible.

=cut

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

sub DESTROY {
	
}

=head2 C<< my $param = Relais::Parameter->new({ ... }); >>

Construct a new report parameter. Pass the options in a hash ref.

=cut

sub new {
	my $class = shift;
	my $self  = {};
	bless $self, $class;
	$self->init(@_);
	return $self;
}

=head2 C<< init( {...} ) >>

Initialize the report parameter.

=cut

sub init {
	my $self = shift;
	my $opts = shift;

	$self->{label} = defined $opts->{label} ? $opts->{label} : '';
	$self->{name}  = defined $opts->{name}  ? $opts->{name}  : '';
	$self->{bind}  = defined $opts->{bind}  ? $opts->{bind}  : '';
	$self->{type}    = defined $opts->{type}    ? $opts->{type}    : '';
	$self->{default} = defined $opts->{default} ? $opts->{default} : '';
	$self->{options} = defined $opts->{options} ? $opts->{options} : {};
}

=head2 C<< my $v = $parameter->value($cgi) >>

Get the value of the parameter from the CGI query object, or
the default value.

=cut

sub value {
	my $self = shift;
	my $q    = shift;
	
	my $v = $q->param($self->{name});
	
	if ((defined $v) && ($v ne '')) {
		return $q->param($self->{name});
	}
	return $self->{default};
}



=head1 NAME

Apache::OutputChain - chain stacked PERL handlers

=head1 SYNOPSIS

Inherit from this module to put a new one into the chain.

=head1 DESCRIPTION

This module allows chaining perl handlers in Apache, which enables to
make filter modules that take output from previous handlers, make some
modifications, and pass the output to the next handler.

I will try to explain how this module works, because I hope you could
help me to make it better and mature.

When the I<handler> function is called, it checks if it gets
a reference to a class. If this is true, the this function was called
from some other handler that wants to be put into the chain. If not,
it's probably an initialization (first call) of this package and we
will supply name of this package.

Now we check, where is STDOUT tied. If it is Apache, we are the first
one trying to be put into the chain. If it is not, there is somebody
in the chain already. We call tie on the STDOUT, steal it from anybody
who had it before -- either Apache or the other class.

When later anybody prints into STDOUT, it will call function I<PRINT>
of the first class in the chain (the last one that registered). If
there is not other class behind, the I<print> method of Apache will be
called. If this is not the last user defined handler in the chain, we
will call I<PRINT> method of the next class.

=head1 AUTHOR

(c) 1997 Jan Pazdziora, adelton@fi.muni.cz

at Faculty of Informatics, Masaryk University, Brno

=cut

package Apache::OutputChain;
$VERSION = '0.02';
use Apache::Constants ':common';
$DEBUG = 1;
sub DEBUG()	{ $DEBUG; }
sub handler
	{
	my $r = shift;
	my $class = shift;
	$class = 'Apache::OutputChain' unless defined $class;

	my $tied = tied *STDOUT;
	my $reftied = ref $tied;
	print STDERR "    Apache::OutputChain tied $class -> ",
		$reftied ? $reftied : STDOUT, "\n" if DEBUG;

	untie *STDOUT;
	tie *STDOUT, $class, $r;

	if ($reftied eq 'Apache')	{ tie *STDOUT, $class, $r; }
	else			{ tie *STDOUT, $class, $r, $tied; }
	return DECLINED;
	}
sub TIEHANDLE
	{
	my ($class, @opt) = @_;
	my $self = [ @opt ];
	print STDERR "    Apache::OutputChain::TIEHANDLE $self\n"
		if DEBUG;
	bless $self, $class;
	}
sub PRINT
	{
	my $self = shift;
	my @tmp = @_;
	print STDERR "    Apache::OutputChain::PRINT $self\n"
		if DEBUG;

	if (defined $self->[1])		{ $self->[1]->PRINT(@tmp); }
	elsif (defined $self->[0])	{ $self->[0]->print(@tmp); }
	}

1;


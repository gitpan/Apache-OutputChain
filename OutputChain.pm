
=head1 NAME

Apache::OutputChain - chain stacked Perl handlers

=head1 SYNOPSIS

Inherit from this module to put a new handler into the chain.

=head1 DESCRIPTION

This module allows chaining perl handlers in Apache, which allows you
to make filter modules that take output from previous handlers, make
some modifications, and pass the output to the next handler or out to
browser.

I will try to explain how this module works, because I hope you could
help me to make it better and mature.

When the I<handler> function is called, it checks if it gets
a reference to a class. If this is true, then this function was called
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

=head1 SEE ALSO

Apache::GzipChain by Andreas Koenig for solution that gzips the output
on the fly. Apache::SSIChain for a quick hack showing the use of
parsed html (SSI) module in the chain.

=head1 AUTHOR

(c) 1997--1998 Jan Pazdziora, adelton@fi.muni.cz,
http://www.fi.muni.cz/~adelton/ at Faculty of Informatics, Masaryk
University, Brno, Czech Republic

=cut

package Apache::OutputChain;
use 5.004;
use strict;
use vars qw( $VERSION $DEBUG );
$VERSION = 0.04;

use Apache::Constants ':common';
$DEBUG = 0;
sub DEBUG()	{ $DEBUG; }
sub handler
	{
	my $r = shift;
	my $class = shift;
	$class = __PACKAGE__ unless defined $class;

	my $tied = tied *STDOUT;
	my $reftied = ref $tied;
	print STDERR "    Apache::OutputChain tied $class -> ",
		$reftied ? $reftied : 'STDOUT', "\n" if DEBUG;

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
		# @opt should be set up to $r (request structure
		# reference) and optionally the next handler in the
		# row
	print STDERR "    Apache::OutputChain::TIEHANDLE $self\n"
		if DEBUG;
	bless $self, $class;
	}
sub PRINT
	{
	my $self = shift;
	print STDERR "    Apache::OutputChain::PRINT $self\n"
		if DEBUG;

	if (defined $self->[1])		{ $self->[1]->PRINT(@_); }
	elsif (defined $self->[0])	{ $self->[0]->print(@_); }
	}

1;


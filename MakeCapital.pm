
=head1 NAME

Apache::MakeCapital - convert to uppercase

=head1 SYNOPSIS

In the conf/access.conf file of your Apache installation add lines

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::MakeCapital Apache::PassHtml
	</Files>

=head1 DESCRIPTION

This is a module to show the use of module B<Apache::OutputChain>.
The function I<handler> simply inserts this module into the chain.
The second parameter must be a name of this class, so that
B<Apache::OutputChain> would know, whom to put into the chain.
(Currently I do not know about any better way, if you know, write me.)

The package also defines function I<PRINT>, that will be called in the
chain. In this example, it capitalized all output being sent. This
will mess up the links (A HREF's) so is really just for illustration.

=head1 AUTHOR

(c) 1997 Jan Pazdziora, adelton@fi.muni.cz

at Faculty of Informatics, Masaryk University, Brno

=cut

package Apache::MakeCapital;
use Apache::OutputChain;
@ISA = qw( Apache::OutputChain );
sub handler
	{
	Apache::OutputChain::handler($r, 'Apache::MakeCapital');
	}

sub PRINT
	{
	shift->Apache::OutputChain::PRINT(uc join '', @_);
	}
1;


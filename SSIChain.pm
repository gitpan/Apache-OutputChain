
=head1 NAME

Apache::SSIChain - do SSI on other modules' output

=head1 SYNOPSIS

In the conf/access.conf file of your Apache installation add lines

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::SSIChain Apache::PassHtml
	</Files>

=head1 DESCRIPTION

Another module demonstrating use of the B<Apache::OutputChain> module.
Please check the source code for how it works.

It's just an example. Let me know if you find a way to make the
$html_parser local in $r. Also, the end-of-output detection is pretty
weak. When should I do the as_HTML print?

To make more experiments, use following:

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::MakeCapital Apache::SSIChain Apache::PassHtml
	</Files>

It will do the SSI after that convert the output to uppercase. Or you
can do even more chaining, adding Apache::GzipChain.

=head1 AUTHOR

(c) 1998 Jan Pazdziora, adelton@fi.muni.cz,
http://www.fi.muni.cz/~adelton/ at Faculty of Informatics, Masaryk
University, Brno, Czech Republic

=cut

package Apache::SSIChain;
use Apache::SSI;
use Apache::OutputChain;

use vars qw( $VERSION @ISA );
$VERSION = 0.04;
@ISA = qw( Apache::OutputChain );

my $html_parser;
sub handler
	{
	my $r = shift;
	$html_parser = new Apache::SSI;
	Apache::OutputChain::handler($r, __PACKAGE__);
	}
sub PRINT {
	my $self = shift;
	my $line = join '', @_;
	$html_parser->parse($line);
	if ($line =~ m!</HTML>!i)
		{
		$self->Apache::OutputChain::PRINT($html_parser->as_HTML);
		}
	}
1;


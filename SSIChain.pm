
=head1 NAME

Apache::SSIChain - do SSI on other modules' output

=cut

package Apache::SSIChain;
use Apache::SSI;
use Apache::OutputChain;

use vars qw( $VERSION @ISA );
$VERSION = 0.05;
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
	if ($html_parser->can('as_HTML'))
		{
		$html_parser->parse($line);
		if ($line =~ m!</HTML>!i)
			{ $self->Apache::OutputChain::PRINT($html_parser->as_HTML); }
		}
	else
		{
		$html_parser->text($line);
		$html_parser->parse;
		$self->Apache::OutputChain::PRINT($html_parser->get_output);
		}
	}

1;

=head1 SYNOPSIS

In the conf/access.conf file of your Apache installation add lines
like

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::SSIChain Apache::PassHtml
	</Files>

=head1 DESCRIPTION

This module uses B<Apache::SSI> and B<Apache::OutputChain> modules to
create a filtering module that takes output from other modules
(B<Apache::PassHtml>, B<Apache::PassExec>), parses SSI tags and sends
the result to Apache, or maybe to other module
(B<Apache::GzipChain> by Andreas Koenig):

	<Files *.html>
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::GzipChain Apache::SSIChain Apache::PassHtml
	</Files>

Or you can do SSI on CGI's:

	<Files *.cgi>
	PerlSendHeader On
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::SSIChain Apache::PassExec
	Options ExecCGI
	</Files>

or even on modules processed by Apache::Registry:

	<Files *.pl>
	PerlSendHeader On
	SetHandler perl-script
	PerlHandler Apache::OutputChain Apache::SSIChain Apache::Registry
	Options ExecCGI
	</Files>

=head1 VERSION

0.05

=head1 AUTHOR

(c) 1998 Jan Pazdziora, adelton@fi.muni.cz,
http://www.fi.muni.cz/~adelton/ at Faculty of Informatics, Masaryk
University, Brno, Czech Republic

=head1 SEE ALSO

Apache::SSI(3); Apache::GzipChain(3); mod_perl(1); www.apache.org,
www.perl.com.

=cut



my @output_chain_libs = qw( OutputChain MakeCapital PassHtml );

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'Apache::OutputChain',
	VERSION_FROM	=> 'OutputChain.pm',
	PM		=> { map { ("$_.pm" => "\$(INST_LIBDIR)/$_.pm") } @output_chain_libs },
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	);


package resume;

use strict;
use warnings;

use nginx;
use Template;
use YAML::XS qw/LoadFile/;

my $CONFIG           = LoadFile "/usr/share/nginx/conf.yml";
   $CONFIG->{resume} = LoadFile "/usr/share/nginx/resume.yml";

sub _render
{
	my $CONTENT = shift;
	$CONTENT ||= "";
	my $header = qq@
	<div id="header">
		<p class="title"><a href="/">[% author %]</a></p>
		<p class="sub-title">[% sub_title %]</p>
	</div>
	@;

	my $footer = qq@
	<div id="footer">
		&copy; [% date.year %]
	</div>
	@;

	my $template = qq@
	<!DOCTYPE html>
	<html lang="en_US">
	<head>
		<meta http-equiv="Content-type" content="text/html; charset=utf-8" />
		<meta name="description" content="The personal website of Dan Molik" />
		<meta name="keywords" content="[% keywords.join(', ') %]" />
		<meta name="author" content="[% author %]" />
		<title>[% title %]</title>
		<link rel="stylesheet" href="/css/style.css" />
		<script type="text/javascript" src="/js/jquery-2.1.4.min.js"></script>
		<script type="text/javascript" src="/js/app.js"></script>
	</head>
	<body>
		<div id="container">
			$header
			<div id="mid">
				<div id="sidebar">
					<ul>
						<li><a href="/resume">Resume</a></li>
						<li><a href="/blog">Blog</a></li>
						<li><a href="/projects">Projects</a></li>
						<li><a href="/docs">Technical Links</a></li>
					</ul>
				</div>
				<div id="content">
					$CONTENT
				</div>
			</div>
			$footer
		</div>
	</body>
	</html>
	@;


	my $tt = Template->new;
	my $html;
	$tt->process(
		\$template,
		$CONFIG,
		\$html);
	# $html =~ s/[\t\n]//g;
	$html;
}

my $home_page   = _render;
my $resume_page = _render
qq@
<div id="skills" class="section">
	<span class="section_title">Skills</skills>
	[% FOR section IN resume.Skills %]
	<div class="sub_section skills">
		<span class="skill_type">[% section.key %]</span>
		<ul class="skills">
		[% FOR skills IN section.value %]
			[% FOR skill IN skills %]
			<li>[% skill %]</li>
			[% END %]
		[% END %]
		</ul>
	</div>
	[% END %]
</div>

<div id="experience" class="section">
<span class="section_title">Experience</skills>
	[% FOR job IN resume.Experience %]
	<div class="sub_section job">
		<span class="job_name">[% job.name %]</span>
		<span class="job_title">[% job.title %]</span>
		<span class="job_location">[% job.location    %]</span>
		<span class="job_duration">[% job.duration    %]</span>
		<p class="job_description">[% job.description %]</p>
	</div>
	[% END %]
</div>

<div id="education" class="section">
	<span class="section_title">Education</skills>
	[% FOR school IN resume.Education %]
	<p class="school">[% school %]</p>
	[% END %]
</div>

<div id="awards" class="section">
	<span class="section_title">Awards</skills>
	[% FOR award IN resume.Awards %]
	<p class="award">[% award %]</p>
	[% END %]
</div>
@;

use Data::Dumper;

sub handler
{
	my $r = shift;

	$r->send_http_header("text/html");
	return OK if $r->header_only;

	my $retval = OK;
	if ($r->uri =~ m/\/resume$/) {
		$r->print($resume_page);
	} elsif ($r->uri =~ m/\//) {
		$r->print($home_page);
	} else {
		$r->status(404);
		$r->print('<html><body>OH NOES!</body></html>');
		$r->flush;
		$retval = HTTP_NOT_FOUND;
	}
	$retval;
}

1;

__END__

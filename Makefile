NGX_CONF=/etc/nginx
NGX_SITE=$(NGX_CONF)/sites-available
NGX_DATA=/usr/share/nginx

install:
	test -d $(NGX_DATA) || mkdir -p $(NGX_DATA)
	cp -R static/ $(NGX_DATA)/
	test -d $(NGX_DATA)/perl || mkdir $(NGX_DATA)/perl
	cp -R lib/ $(NGX_DATA)/perl/
	cp conf/conf.yml $(NGX_DATA)/
	cp conf/resume.yml $(NGX_DATA)/
	cp conf/resume.ngx $(NGX_SITE)/resume
	ln -sf $(NGX_SITE)/resume $(NGX_CONF)/sites-enabled/resume
	service nginx restart

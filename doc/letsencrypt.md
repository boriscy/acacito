# How to setup Let's Encrypt for Nginx on Ubuntu 16.04 (including IPv6, HTTP/2 and A+ SLL rating)

There are two modes when you don't want Certbot to edit your configuration:
 - [Standalone](https://certbot.eff.org/docs/using.html#standalone): replaces the webserver to respond to ACME challenges
 - [Webroot](https://certbot.eff.org/docs/using.html#webroot): needs your webserver to serve challenges from a known folder.

**Webroot is better** because it doesn't need to replace Nginx (to bind to port 80) to renew certificates.

In the following, we're setting up `mydomain.com` to be served from `/var/www/mydomain`, and challenges will be served from `/var/www/letsencrypt`.

----

## Nginx snippets

First we create two snippets to avoid duplicating code in every virtual host configuration.

Create a file `/etc/nginx/snippets/letsencrypt.conf` containing:

	location ^~ /.well-known/acme-challenge/ {
		default_type "text/plain";
		root /var/www/letsencrypt;
	}


Create a file `/etc/nginx/snippets/ssl.conf` containing:

	ssl_session_timeout 1d;
	ssl_session_cache shared:SSL:50m;
	ssl_session_tickets off;

	ssl_protocols TLSv1.2;
	ssl_ciphers EECDH+AESGCM:EECDH+AES;
	ssl_ecdh_curve secp384r1;
	ssl_prefer_server_ciphers on;

	ssl_stapling on;
	ssl_stapling_verify on;

	add_header Strict-Transport-Security "max-age=15768000; includeSubdomains; preload";
	add_header X-Frame-Options DENY;
	add_header X-Content-Type-Options nosniff;


----

## Nginx virtual hosts (HTTP-only)

We don't have a certificate yet at this point, so the domain is served only as HTTP.

Create a file `/etc/nginx/sites-available/mydomain.conf` containing:

	server {
		listen 80 default_server;
		listen [::]:80 default_server ipv6only=on;
		server_name mydomain.com www.mydomain.com;

		include /etc/nginx/snippets/letsencrypt.conf;

		root /var/www/mydomain;
		index index.html;
		location / {
			try_files $uri $uri/ =404;
		}
	}

Enable the site:

	rm /etc/nginx/sites-enabled/default
	ln -s /etc/nginx/sites-available/mydomain.conf /etc/nginx/sites-enabled/mydomain.conf

And reload Nginx:

	sudo systemctl reload nginx


Note the line `include /etc/nginx/snippets/letsencrypt.conf;` that makes Nginx serve challenges for both `http://www.mydomain.com/.well-known/acme-challenge/` and `http://mydomain.com/.well-known/acme-challenge/`.

----

## Let's Encrypt client

Install the client:

	sudo apt-get install letsencrypt

Create a folder for the challenges:

	sudo mkdir -p /var/www/letsencrypt/.well-known/acme-challenge

And finally, get a certificate (don't forget to replace with your own email address):

	letsencrypt certonly --webroot -w /var/www/letsencrypt -d www.domain.com -d domain.com --email MY@EMAIL.COM --agree-tos

It will save the files in `/etc/letsencrypt/live/www.mydomain.com/`.


----

## Nginx virtual hosts (HTTPS-only)

Now that you have a certificate for the domain, switch to HTTPS by editing the file `/etc/nginx/sites-available/mydomain.conf` and replacing contents with:

	server {
		listen 80 default_server;
		listen [::]:80 default_server ipv6only=on;
		server_name mydomain.com www.mydomain.com;

		include /etc/nginx/snippets/letsencrypt.conf;

		location / {
			return 301 https://www.mydomain.com$request_uri;
		}
	}


	server {
		server_name www.mydomain.com;
		listen 443 ssl http2 default_server;
		listen [::]:443 ssl http2 default_server ipv6only=on;

		ssl_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/www.mydomain.com/privkey.pem;
		ssl_trusted_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
		include /etc/nginx/snippets/ssl.conf;

		root /var/www/mydomain.com;
		index index.html;
		location / {
			try_files $uri $uri/ =404;
		}
	}


	server {
		listen 443 ssl http2;
		listen [::]:443 ssl http2;
		server_name mydomain.com;

		ssl_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/www.mydomain.com/privkey.pem;
		ssl_trusted_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
		include /etc/nginx/snippets/ssl.conf;

		location / {
			return 301 https://www.mydomain.com$request_uri;
		}
	}

Then reload Nginx:

	sudo systemctl reload nginx

----

## Conclusion

You should now be able to see your website at `https://www.mydomain.com`. Congratulations :smiley:

You can test now also test that your domain has A+ SLL rating:
 - https://www.ssllabs.com/ssltest/analyze.html?d=mydomain.com
 - https://www.ssllabs.com/ssltest/analyze.html?d=www.mydomain.com

You can renew using `letsencrypt renew`: when called it will attempt to renew certificates expiring in less than 30 days, so you can put this command in cron to renew automatically.


If letsencrypt is useful to you, consider [donating to letsencrypt](https://letsencrypt.org/donate/) or [donating to the EFF](https://supporters.eff.org/donate/).

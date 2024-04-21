#!/usr/bin/env ksh

rcctl stop smtpd

rcctl stop dovecot

rcctl stop rspamd

rcctl start rspamd

rcctl start dovecot

rcctl start smtpd

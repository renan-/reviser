#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

$user = 'racurluser'
$passwd = 'racurlpwd'

# Connexion to the base + test
msg = `mysql --user=#{$user} --password=#{$passwd} racurl < bd_racurl.sql`

puts msg

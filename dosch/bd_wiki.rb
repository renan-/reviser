#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

$user = 'wikiadm'
$passwd = 'wikipwd'

# Connexion to the base + test
msg = `mysql --user=#{$user} --password=#{$passwd} wiki < bd_wiki.sql`

puts msg

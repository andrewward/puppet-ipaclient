[![Build Status](https://travis-ci.org/stbenjam/puppet-ipaclient.svg?branch=master)](https://travis-ci.org/stbenjam/puppet-ipaclient)


IPAclient
========

This module supports configuring clients to use FreeIPA.

Full documentation including examples and descriptions of
parameters are in manifests/init.pp.

Supported Platforms
-------------------

Tested on RHEL 6, CentOS 6, and Fedora 20.  It should work on any
Red Hat family OS that has IPA packages.


Examples
--------

Discovery register:


    class { 'ipaclient':
      join_pw => "rainbows"
    }

All features:

    class { 'ipaclient':
       manual_reigster => true,
       mkhomedir       => true,
       join_pw         => "unicorns",
       join_user       => "rainbows",
       enrollment_host => "ipa01.pixiedust.com",
       ipa_server      => "ipa.pixiedust.com",
       ipa_domain      => "pixiedust.com",
       ipa_realm       => "PIXEDUST.COM",
       replicas        => ["ipa01.pixiedust.com", "ipa02.pixiedust.com"]
       domain_dn       => "dc=pixiedust,dc=com",
       sudo_bindpw     => "sprinkles",
    }


Sudoers only:

    class { 'ipaclient::sudoers':
       replicas        => ["ipa01.pixiedust.com", "ipa02.pixiedust.com"]
       domain_dn       => "dc=pixiedust,dc=com",
       sudo_bindpw     => "sprinkles",
       ipa_domain      => "pixiedust.com",
    }

Load Balanced FreeIPA
---------------------

An optional featue of this module is supporting a virtual hostname if
you have more than one IPA server and cannot use the DNS service
records for discovery.

When using a virtualhost, registration *must* occur to the real hostname
of the IDM server ($enrollment\_host) then you can switch to using a 
virtual host without problems ($ipa\_server).  LDAP replicas
can be specified with the replicas parameter.

See manifests/init.pp for more info.

MIT License
-----------
Copyright (c) 2013 Stephen Benjamin

Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE.


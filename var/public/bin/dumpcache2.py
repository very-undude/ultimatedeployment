#!/usr/bin/env python
# -*- Mode: Python; tab-width: 4 -*-
#
# Boot Information Negotiation Layer - OpenSource Implementation
#
# Copyright (C) 2005-2006 Gianluigi Tiesi <sherpya@netfarm.it>
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# ======================================================================

from socket import socket, AF_INET, SOCK_DGRAM, getfqdn
from codecs import utf_16_le_decode, utf_16_le_encode, ascii_encode
from struct import unpack, pack
from sys import argv, exit as sys_exit
from time import sleep, time
from cPickle import load
from os import chdir, getpid
from getopt import getopt, error as getopt_error

__version__ = '0.8'
__usage__ = """Usage %s: [-h] [-d] [-l logfile] [-a address] [-p port] [devlist.cache]
-h, --help     : show this help
-s, --short    : short format, number of drivers only
"""

myfqdn = getfqdn()
myhostinfo = myfqdn.split('.', 1)
mydomain = myhostinfo.pop()
# workaround if hosts files is broken
try:
    myhostname = myhostinfo.pop()
except:
    myhostname = mydomain
    
devlist = None

count = 0

### Logger class wrapper
class Log:
    """file like for writes with auto flush after each write
    to ensure that everything is logged, even during an
    unexpected exit."""
    def __init__(self, f):
        self.f = f
    def write(self, s):
        self.f.write(s)
        self.f.flush()


def parse_arguments(params):
    ### Parse RQU arguments (like a cgi)
    if len(params) < 2: return {}
    arglist = params.split('\n')
    plist = {}
    for arg in arglist:
        try:
            key, value = arg.split('=', 1)
        except: continue
        plist[key] = value
    return plist

if __name__ == '__main__':
    ## Defaults
    devfile = '/etc/devlist.cache'

    ## Parse command line arguments.
    shortopts = 'hs'
    longopts = [ 'help' , 'short' ]

    try:
        opts, args = getopt(argv[1:], shortopts, longopts)
        if len(args) > 1:
            raise getopt_error, 'Too many device lists files specified %s' % ','.join(args)
    except getopt_error, errstr:
        print 'Error:', errstr
        print __usage__ % argv[0]
        sys_exit(-1)

    mymode="long"

    for opt, arg in opts:
        opt = opt.split('-').pop()

        if opt in ('h', 'help'):
            print __usage__ % argv[0]
            sys_exit(0)
        if opt in ('s', 'short'):
            mymode="short"

    if len(args):
        devfile = args[0]

    try:
        devlist = load(open(devfile))
    except:
        print 'Could not load %s as cache, build it with infparser.py' % devfile
        sys_exit(-1)

    print '<TABLE BORDER=1>';
    print '<TR CLASS=tableheader><TD>Device</TD><TD>description</TD><TD>char</TD><TD>svc</TD><TD>Bus Type</TD><TD>inf</TD><TD>driver</TD></TR>';
    for dev in devlist.keys():
        print '<TR>';
        print '<TD>%s</TD>' % dev;
        print '<TD>%s</TD>' % devlist[dev]['desc'];
        print '<TD>%s</TD>' % devlist[dev]['char'];
        print '<TD>%s</TD>' % devlist[dev]['svc'];
        print '<TD>%s</TD>' % devlist[dev]['btype'];
        print '<TD>%s</TD>' % devlist[dev]['inf'];
        print '<TD>%s</TD>' % devlist[dev]['drv'];
        print '</TR>';
    print '</TABLE>';


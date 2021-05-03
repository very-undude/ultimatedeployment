#!/usr/bin/env python
# -*- Mode: Python; tab-width: 4 -*-
#
# Boot Information Negotiation Layer - OpenSource Implementation
#
# Copyright (C) 2005-2007 Gianluigi Tiesi <sherpya@netfarm.it>
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

from socket import socket, AF_INET, SOCK_DGRAM, getfqdn, gethostbyname, gethostname
from codecs import utf_16_le_decode, utf_16_le_encode, ascii_encode
from struct import unpack, pack
from sys import argv, exit as sys_exit
from signal import signal, SIGINT, SIGTERM
from time import sleep, time
from datetime import datetime
from md5 import md5
from cPickle import load
from os import chdir, getpid, unlink, listdir, path, popen
from getopt import getopt, error as getopt_error

## NTML Auth Code from: NTLM Authorization Proxy Server
## Copyright 2001 Dmitry A. Rozmanov <dima@xenon.spb.ru>
crypto = True
try:
    from Crypto.Hash import MD4
    from Crypto.Cipher import DES
except:
    crypto = False

__version__ = '1.0'
__usage__ = """Usage %s: [-h] [-d] [-l logfile] [-a address] [-p port]
                    [--pid pidfile] [devlist.cache]
-h, --help     : show this help
-d, --daemon   : daemonize, unix only [false]
-l, --logfile= : logfile when used in daemon mode [/var/log/binlsrv.log]
-a, --address= : ip address to bind to [all interfaces]
-p, --port=    : port to bind to [4011]
    --pid=     : pid file to use instead of the default
devlist.cache  : device list cache file [devlist.cache in current dir]
"""

OSC_NOTFOUND="""<OSCML>
<META KEY=F3 ACTION="REBOOT">
<TITLE>  Client Installation Wizard</TITLE>
<FOOTER>  [F3] restart computer</FOOTER>
<BODY left=5 right=75>
<BR><BR>The requested file %s was not found on the server
</BODY>
</OSCML>
"""

#############
# Make sure there is the trailing / here
BASEPATH = '/mnt/disk/ris/OSChooser/English/'
WELCOME  = 'welcome.osc'
DUMPING  = False

#############

NTLM_NEGOTIATE    = 1
NTLM_CHALLENGE    = 2
NTLM_AUTHENTICATE = 3
NTLM_ANY          = 0

#define NTLMSSP_NEGOTIATE_UNICODE          0x00000001
#define NTLMSSP_NEGOTIATE_OEM              0x00000002
#define NTLMSSP_REQUEST_TARGET             0x00000004
#define NTLMSSP_NEGOTIATE_SIGN             0x00000010
#define NTLMSSP_NEGOTIATE_SEAL             0x00000020
#define NTLMSSP_NEGOTIATE_LM_KEY           0x00000080
#define NTLMSSP_NEGOTIATE_NTLM             0x00000200
#define NTLMSSP_NEGOTIATE_00001000         0x00001000
#define NTLMSSP_NEGOTIATE_00002000         0x00002000
#define NTLMSSP_NEGOTIATE_ALWAYS_SIGN      0x00008000
#define NTLMSSP_TARGET_TYPE_DOMAIN         0x00010000
#define NTLMSSP_TARGET_TYPE_SERVER         0x00020000
#define NTLMSSP_NEGOTIATE_NTLM2            0x00080000
#define NTLMSSP_NEGOTIATE_TARGET_INFO      0x00800000
#define NTLMSSP_NEGOTIATE_128              0x20000000
#define NTLMSSP_NEGOTIATE_KEY_EXCH         0x40000000

# NTLMSSP_REQUEST_TARGET | NTLMSSP_NEGOTIATE_OEM | NTLMSSP_NEGOTIATE_UNICODE
# NTLMSSP_NEGOTIATE_NTLM
#0x00000000
#      2 5

#0x00018206 ->
#         X -> NTLMSSP_REQUEST_TARGET | NTLMSSP_NEGOTIATE_OEM
#       X   -> NTLMSSP_NEGOTIATE_NTLM
#      X    -> NTLMSSP_NEGOTIATE_ALWAYS_SIGN
#     X     -> NTLMSSP_TARGET_TYPE_DOMAIN

#0x00808011 ->
#         X -> NTLMSSP_NEGOTIATE_UNICODE
#        X  -> NTLMSSP_NEGOTIATE_SIGN
#      X    -> NTLMSSP_NEGOTIATE_ALWAYS_SIGN
#    X      -> NTLMSSP_NEGOTIATE_TARGET_INFO

#0xa2898215 ->
#         X -> NTLMSSP_NEGOTIATE_UNICODE | NTLMSSP_REQUEST_TARGET
#        X  -> NTLMSSP_NEGOTIATE_SIGN
#       X   -> NTLMSSP_NEGOTIATE_NTLM
#      X    -> NTLMSSP_NEGOTIATE_ALWAYS_SIGN
#     X     -> NTLMSSP_NEGOTIATE_NTLM2 | NTLMSSP_TARGET_TYPE_DOMAIN
#   X       -> ???
#  X        -> ???


#0xC000006FL The user is not allowed to log on at this time.
#0xC0000070L The user is not allowed to log on from this workstation.
#0xC0000071L The password of this user has expired.
#0xC0000072L Account currently disabled.
#0xC0000193L This user account has expired.
#0xC0000224L The user.s password must be changed before logging on the first time.

AUTH_OK            = 0x00000000L
SEC_E_LOGON_DENIED = 0x8009030cL

MAGIC_COOKIE = '\x63\x82\x53\x63'
MAGIC_OFFSET = 0xec

MAGIC = 'KGS!@#$%'
C = '\x81'
S = '\x82'

FILEREQ   = C+'RQU' # 8152 5155 - OSC File request
FILEREPLY = S+'RSU' # 8252 5355 - OSC File reply

NEG       = C+'NEG' # 814e 4547 - NTLM Negotiate
CHL       = S+'CHL' # 8243 484c - NTLM Sending Challenge

AUT       = C+'AUT' # 8141 5554 - NTLM Autorize
RES       = S+'RES' # 8252 4553 - NTLM Auth reply

NCQ       = C+'NCQ' # 814e 4351 - Network Card Query
NCR       = S+'NCR' # 824e 4352 - Network Card Reply

REQ       = C+'REQ' # 8152 4551 - Unknown :(
RSP       = S+'RSP' # 8252 5350 - Unknown :(

OFF       = C+'OFF' # 814f 4646 - Reboot to new pxe rom

# Session expired, only works with code 0x1
UNR       = S+'UNR' # 8255 4e52

myfqdn = getfqdn()
myhostinfo = myfqdn.split('.', 1)
mydomain = myhostinfo.pop()
mynbdomain = 'RIS' # FIXME

# workaround if hosts file is misconfigured
try:
    myhostname = myhostinfo.pop()
except:
    myhostname = mydomain

server_data = {
    'nbname'     : myhostname.upper(),
    'nbdomain'   : mynbdomain,
    'dnshostname': myhostname,
    'dnsdomain'  : mydomain
    }

tr_table = {
    '%SERVERNAME%'        : server_data['nbname'],
    '%SERVERDOMAIN%'      : server_data['nbdomain'],
    '%MACHINENAME%'       : 'client',
    '%NTLMV2Enabled%'     : '0',
    '%ServerUTCFileTime%' : str(int(time()))
    }

users = {
    'Administrator': 'secret'
    }

bootp = {
     53: ['h', 'DHCP Request'],
     54: ['c', 'Server Identifier'],
     55: ['h', 'Paramter Request list'],
     57: ['h', 'Max DHCP message size'],
     60: ['s', 'Vendor'],
     93: ['h', 'Client Arch'],
     94: ['h', 'Client Network Device Interface'],
     97: ['h', 'Client GUID'],
    250: ['h', 'Private'],  # 01020006ff
    252: ['s', 'Boot Configuration Data File']
    }

flavordevlist = None

count = 0

regtype = [ 'REG_NONE', 'REG_SZ', 'REG_EXPAND_SZ', 'REG_BINARY', 'REG_DWORD', 'REG_MULTI_SZ' ]
codes   = [ 'None', 'NetBiosName', 'NetBiosDomain', 'DNSHostName', 'DNSDomain', 'DNSDomain2' ]

NULL = chr(0x0)
NTLM = 'NTLMSSP\x00'

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

def shutdown(signum, frame):
    global pidfile, s
    try:
        s.close()
    except:
        print 'Cannot shutdown the socket'
    try:
        unlink(pidfile)
    except:
        pass
    thistime = datetime.now()
    print thistime.strftime("%Y-%m-%d %H:%M:%S") + ' Shutdown done'
    sys_exit(0)

def dotted(data):
    res = ''
    for i in range(len(data)):
        if (ord(data[i]) < 32) or (ord(data[i]) > 127):
            res += '.'
        else:
            res += data[i]
    return res

def hexdump(data):
    data_len = len(data)
    off = 0
    base = 0
    while 1:
        start = off
        end = off + 8
        if end > data_len: end = data_len
        values1 = ' '.join([ '%02x' % ord(data[x]) for x in range(start, end) ])
        data1   = dotted(data[off:off+8])
        off += 8

        start = off
        if start > data_len: start = data_len
        end = off + 8
        if end > data_len: end = data_len

        values2 = ' '.join([ '%02x' % ord(data[x]) for x in range(start, end) ])
        data2   = dotted(data[off:off+8])
        off += 8

        print '%08x %-23s   %-23s  |%-8s%-8s|' % (base, values1, values2, data1, data2)
        base += 16
        if end - start < 8: break

def utf2ascii(text):
    return ascii_encode(utf_16_le_decode(text, 'ignore')[0], 'ignore')[0]

def byte2ip(data):
    return '%d.%d.%d.%d' % (ord(data[0]), ord(data[1]), ord(data[2]), ord(data[3]))

def ip2byte(ip):
    try:
        a, b, c, d = ip.split('.')
        return chr(int(a)) + chr(int(b)) + chr(int(c)) + chr(int(d))
    except:
        return '\x00' * 4

def get_packet(s):
    global pidfile
    try:
        data, addr = s.recvfrom(1024)
    except KeyboardInterrupt:
        print 'Server terminated by user request'
        shutdown(0, 0)

    # Binl packet
    if (data[0] == C) or (data[0] == S):
        pktype = data[:4]
        data = data[4:]
        l = unpack('<I', data[:4])[0]
        print 'Recv BINL %s len = %d' % (str(pktype[1:]), l)
        data = data[4:]
        return addr, pktype, data

    ## BOOTP WDS Packet
    if data[0xec:0xf0] == MAGIC_COOKIE:
        return addr, MAGIC_COOKIE, data

    ## Unknown
    return addr, None, data


def translate(text):
    for tr in tr_table.keys():
        text = tr_table[tr].join(text.split(tr))
    return text

def send_file(s, addr, u1, basepath, filename):
    reply = FILEREPLY
    fullpath = basepath + filename
    try:
        data = open(fullpath).read()
        print 'Sending', fullpath
    except:
        print 'Cannot find file', fullpath
        data = OSC_NOTFOUND % filename

    data = translate(data)

    l = pack('<I', len(data) + len(u1) + 1)
    reply = reply + l + u1 + data + NULL
    s.sendto(reply, addr)


def key56_to_key64(strkey):
    key_56 = []
    for i in strkey[:7]: key_56.append(ord(i))
    key = []
    for i in range(8): key.append(0)

    key[0] = key_56[0];
    key[1] = ((key_56[0] << 7) & 0xff) | (key_56[1] >> 1)
    key[2] = ((key_56[1] << 6) & 0xff) | (key_56[2] >> 2)
    key[3] = ((key_56[2] << 5) & 0xff) | (key_56[3] >> 3)
    key[4] = ((key_56[3] << 4) & 0xff) | (key_56[4] >> 4)
    key[5] = ((key_56[4] << 3) & 0xff) | (key_56[5] >> 5)
    key[6] = ((key_56[5] << 2) & 0xff) | (key_56[6] >> 6)
    key[7] =  (key_56[6] << 1) & 0xff

    for i in range(len(key)):
        for k in range(7):
            bit = 0
            t = key[i] >> k
            bit = (t ^ bit) & 0x1
        key[i] = (key[i] & 0xfe) | bit

    k = ''
    for i in range(len(key)):
        k = k + chr(key[i])
    return k

def do_des(key, chl):
    key = key56_to_key64(key)
    obj = DES.new(key)
    return obj.encrypt(chl)

def nt_response(password, challenge):
    md4 = MD4.new()
    md4.update(password.encode('utf-16le'))
    pw = md4.digest() + (NULL * 5)
    return do_des(pw[0:7], challenge) + do_des(pw[7:14], challenge) + do_des(pw[14:21], challenge)

def gen_challenge(addr):
    c = md5()
    c.update(addr[0])
    c.update(str(addr[1]))
    return c.digest()[:8]

def send_challenge(s, addr, sd):
    nbname      = sd['nbname'].encode('utf-16le')
    nbdomain    = sd['nbdomain'].encode('utf-16le')
    dnshostname = sd['dnshostname'].encode('utf-16le')
    dnsdomain   = sd['dnsdomain'].encode('utf-16le')

    payload = pack('<H', codes.index('NetBiosDomain')) + pack('<H', len(nbdomain))    + nbdomain    + \
              pack('<H', codes.index('NetBiosName'))   + pack('<H', len(nbname))      + nbname      + \
              pack('<H', codes.index('DNSDomain'))     + pack('<H', len(dnsdomain))   + dnsdomain   + \
              pack('<H', codes.index('DNSHostName'))   + pack('<H', len(dnshostname)) + dnshostname + \
              pack('<H', codes.index('DNSDomain2'))    + pack('<H', len(dnsdomain))   + dnsdomain   + \
              (NULL * 4)

    data = NTLM + pack('<I', NTLM_CHALLENGE)
    challenge = gen_challenge(addr)
    auth_u1   = '\x05\x02\xCE\x0E\x00\x00\x00\x0F'

    off = 0x38
    #flags = 0xa2898215L
    flags = 0x00010206L # NTLM v1

    data = data + encodehdr(nbdomain, off)
    off  = off + len(nbdomain)

    data = data + pack('<I', flags)

    data = data + challenge + (NULL*8)
    data = data + encodehdr(payload, off)
    data = data + auth_u1
    data = data + nbdomain + payload

    reply = CHL + pack('<I', len(data)) + data
    decode_ntlm('[S]', data)
    s.sendto(reply, addr)

def send_res(s, addr, data):
    res = decodehdr(data[20:], data)
    domain = decodehdr(data[28:], data)
    user = decodehdr(data[36:], data)

    result = SEC_E_LOGON_DENIED
    if crypto \
       and (domain == server_data['nbdomain']) \
       and users.has_key(user) \
       and (res == nt_response(users[user], gen_challenge(addr))):
        print '[S]', 'User Authenticated'
        result = AUTH_OK

    reply = RES
    data = pack('<I', result)
    l = pack('<I', len(data))
    reply = reply + l + data
    print 'Sending Reply 0x%x' % result
    s.sendto(reply, addr)

def dumphdr(data, pkt):
    return repr(utf2ascii(decodehdr(data, pkt)))

def decodehdr(data, pkt):
    slen, maxlen, off = unpack('<HHI', data[:8])
    value = pkt[off:off+slen]
    return value

def encodehdr(value, off):
    return pack('<HHI', len(value), len(value), off)


def format_hex(data):
    res = ''
    for i in range(len(data)):
        res += '%02x' % ord(data[i])
    return res

def bootp_dump(p, opt, value):
    t, name = bootp.get(opt, ['h', 'Unknown opt %d' % opt])
    if t == 'h': value = format_hex(value)
    if t == 'c': value = byte2ip(value)
    print p, 'DHCP option %s value: %s' % (name, value)

def decode_bootp(p, data):
    print p, '-' * 78
    print p, 'WDS Packet: Vista network client'

    info = {}

    packet = data[:]
    if len(data) < (2 + 0xe6): ## FIXME
        print p, 'Short packet'
        return info

    opts = data[MAGIC_OFFSET+4:]
    mt, ht = ord(data[0]), ord(data[1]) # ht == 1 -> Ethernet
    data = data[2:]

    if mt == 1:
        print p, 'Boot Request'
    elif mt == 2:
        print p, 'Boot Reply'
    else:
        print p, 'Unsupported BootP Type', mt
        hexdump(data)

    hl, hops = ord(data[0]), ord(data[1])
    print p, 'Hardware Len', hl
    data = data[2:]

    tid = unpack('>I', data[:4])[0]
    info['tid'] = tid
    print p, 'Transaction ID 0x%08x' % tid
    data = data[4:]

    sec = unpack('>H', data[:2])[0]
    print p, 'Seconds elapsed %d' % sec
    data = data[2:]

    bpf = unpack('>H', data[:2])[0]
    print p, 'BootP flags = 0x%04x' % bpf
    data = data[2:]

    clientip = data[:4]
    print p, 'Client IP', byte2ip(clientip)
    data = data[4:]

    yourip = data[:4]
    print p, 'Your IP', byte2ip(yourip)
    data = data[4:]

    next = data[:4]
    print p, 'Next Server IP', byte2ip(next)
    data = data[4:]

    ragent = data[:4]
    print p, 'Relay Agent IP', byte2ip(ragent)
    data = data[4:]

    hl = min(hl, 16)
    mac  = [ord(x) for x in data[:hl]]
    print p, 'Mac address', ':'.join(['%02x' % x for x in mac])
    info['mac'] = data[:16]
    data = data[16:]

    hostname = data[:64].replace(NULL, '').strip()
    print p, 'Hostname:', hostname
    data = data[64:]

    bootfile = data[:128].replace(NULL, '').strip()
    print p, 'Boot file:', bootfile
    data = data[128:]

    magic = data[:4]
    if magic != MAGIC_COOKIE:
        print p, 'Magic cookie is not on the right place', repr(magic)
        #open('bad_cookie.hex', 'wb').write(packet)
        return info
    data = data[4:]

    if opts != data:
        print p, 'Options not in the right place', repr(opts[:16]), repr(data[:16])
        return info

    while len(opts) > 1: # FIXME: there is always at least 1 byte padded?
        opt = ord(opts[0])
        if opt == 0xff: break # End packet
        length = ord(opts[1])
        opts = opts[2:]
        if len(opts) < length: break # Bad packet
        value = opts[:length]
        opts = opts[length:]
        ## FIXME
        if opt == 97: info['guid'] = value
        bootp_dump(p, opt, value)
    return info

def send_bootp(s, addr, info):
    #getipcmd='/sbin/ifconfig eth0 | grep "inet addr" | awk \'{print $2}\' | awk \'{print $2}\' FS=:'
    #getipcmd='/sbin/ifconfig eth0 | grep inet | grep -v inet6 | awk \'{print $2}\''
    getipcmd='/usr/sbin/ip -4 address show dev eth0 | grep inet | cut -f1 -d/ | awk \'{print $2}\''

    ipf=popen(getipcmd)
    hostip=ipf.readline().rstrip()
    ipf.close
    # hostip = gethostbyname(gethostname())
    # print 'hostip = ' + hostip
    p = chr(0x2)                       # Boot Reply
    p = p + chr(0x1)                   # hw type: ethernet
    p = p + chr(0x6)                   # hw addr len
    p = p + chr(0x0)                   # hops
    p = p + pack('>I', info['tid'])    # TID
    p = p + pack('>H', 4)              # seconds
    p = p + pack('>H', 0)              # flags 0 = unicast
    p = p + ip2byte(addr[0])           # client ip
    p = p + ip2byte('0.0.0.0')         # your ip
    p = p + ip2byte(hostip)            # next server
    p = p + ip2byte('0.0.0.0')         # relay agent ip
    p = p + info['mac']                # client mac addr

    mymac=[ord(x) for x in info['mac']]
    mymacstr = ':'.join(['%02x' % x for x in mymac])
    commandline='/var/public/bin/gettemplate.sh ' + addr[0] + ' ' + mymacstr
    f = popen(commandline)
    templateinfo = f.readline().rstrip().split(' ')
    f.close
    bootfile = 'pxelinux.cfg\\templates\\' + templateinfo[0] + '\\pxeboot.com'
    bcdpath='pxelinux.cfg\\templates\\' + templateinfo[0] + '\\' + templateinfo[1] + '\\bcd'
   
    hostname = myhostname + (NULL * (64 - len(myhostname)))
    p = p + hostname                   # hostname
    
    bf = bootfile + (NULL * (128 - len(bootfile)))
    p = p + bf                         # Boot File

    p = p + MAGIC_COOKIE

    p = p + '\x35\x01\x05'             # DHCP ACK
    p = p + chr(54) + chr(4) + ip2byte(hostip) # Server ID
    p = p + chr(97) + chr(len(info['guid'])) + info['guid']
    p = p + chr(60) + chr(9) + 'PXEClient'
    p = p + chr(252) + chr(len(bcdpath)) + bcdpath
    p = p + chr(0xff)
    decode_bootp('[S]', p)
    #open('out', 'wb').write(p)
    if s != -1: s.sendto(p, addr)

def decode_ntlm(p, data):
    global count
    pkt = data

    if DUMPING:
        filename = '/tmp/' + p[1:-1] + '.log'
        open(filename, 'wb').write(AUT + pack('<I', len(data)) + data)

    data = data[8:]

    hexdump(data)
    if DUMPING: open('/tmp/' + str(count) + '.hex', 'wb').write(data)
    count =+ 1

    t = unpack('<I', data[:4])[0]
    data = data[4:]

    if t == NTLM_NEGOTIATE:
        print p, 'Packet type is NTLM_NEGOTIATE'
        flags = unpack('<I', data[:4])[0]
        print p, 'Flags = 0x%x' % flags
        data = data[4:]
        print p, 'Host', dumphdr(data, pkt)
        data = data[8:]
        print p, 'Domain', dumphdr(data, pkt)
    elif t == NTLM_CHALLENGE:
        print p, 'Packet type is NTLM_CHALLENGE'

        print p, 'Domain', dumphdr(data, pkt)
        data = data[8:]

        flags = unpack('<I', data[:4])[0]
        data = data[4:]
        print p, 'Flags = 0x%x' % flags

        challenge = data[:8]
        print p, 'Challenge:', repr(challenge)
        data = data[8:]

        # NULL * 8
        data = data[8:]

        info = decodehdr(data, pkt)
        data = data[8:]

        while 1:
            if len(info) < 4:
                break
            t = unpack('<H', info[:2])[0]
            info = info[2:]
            l = unpack('<H', info[:2])[0]
            info = info[2:]
            value = utf2ascii(info[:l])
            info = info[l:]
            print p, '%s : %s' % (codes[t], repr(value))

        print p, 'u2 = %s' % repr(data[:8])
    elif t == NTLM_AUTHENTICATE:
        print p, 'Packet type is NTLM_AUTHENTICATE'

        print p, 'LANMAN challenge response', repr(decodehdr(data, pkt))
        data = data[8:]

        print p, 'NT challenge response', repr(decodehdr(data, pkt))
        data = data[8:]

        print p, 'Domain to auth', decodehdr(data, pkt)
        data = data[8:]

        print p, 'Username', decodehdr(data, pkt)
        data = data[8:]

        print p, 'Workstation', decodehdr(data, pkt)
        data = data[8:]

        print p, 'SessionKey', repr(decodehdr(data, pkt))
        data = data[8:]

        flags = unpack('<I', data[:4])[0]
        data = data[4:]
        print p, 'Flags = 0x%x' % flags
    elif t == NTLM_ANY:
        print p, 'Packet type is NTLM_ANY'

decode_aut = decode_ntlm

## Only PCI Cards are supported for now
def send_ncr(s, addr, vid, pid, subsys, flavor):
    global flavordevlist
    devlist=flavordevlist[flavor]
    #reply = open('vmware.hex', 'rb').read()
    #decode_ncr('[VmWare]', reply[8:])
    #s.sendto(reply, addr)
    #return

    #vid = 0x10b7
    #pid = 0x9200
    #subsys = 0x100010B7

    device = 'PCI\\VEN_%04X&DEV_%04X' % (vid, pid)
    device_sub = device + '&SUBSYS_%08X' % subsys

    dev = None
    try:
        print 'Checking', device_sub
        dev = devlist[device_sub]
        dev_uni = device_sub
    except:
        try:
            print 'Checking', device
            dev = devlist[device]
            dev_uni = device
        except: pass

    if dev is None:
        reply = NCR + pack('<I', 0x4) + pack('<I', 0xc000000dL)
        print 'Driver not found'
        s.sendto(reply, addr)
        return

    print 'Found', dev_uni, 'in', dev['inf']

    unidata = dev_uni.encode('utf-16le')    + (NULL * 2) + \
              dev['drv'].encode('utf-16le') + (NULL * 2) + \
              dev['svc'].encode('utf-16le') + (NULL * 2)

    drv_off = 0x24    + (len(dev_uni) + 1)    * 2
    svc_off = drv_off + (len(dev['drv']) + 1) * 2
    p_off   = svc_off + (len(dev['svc']) + 1) * 2

    parms = 'Description\x002\x00'     + dev['desc']  + '\x00' + \
            'Characteristics\x001\x00' + dev['char']  + '\x00' + \
            'BusType\x001\x00'         + dev['btype'] + '\x00\x00'

    plen = len(parms)

    # Now packet creation
    data = pack('<I', 0x0)            # Result: ok
    data = data + pack('<I', 0x2)     # Type
    data = data + pack('<I', 0x24)    # base offset
    data = data + pack('<I', drv_off) # Driver offset
    data = data + pack('<I', svc_off) # Service offset
    data = data + pack('<I', plen)    # params len
    data = data + pack('<I', p_off)   # params offset

    data = data + unidata
    data = data + parms

    decode_ncr('[S]', data)
    reply = NCR + pack('<I', len(data)) + data + (NULL*2)
    s.sendto(reply, addr)

def decode_ncr(p, data):
    result = unpack('<I', data[:4])[0]

    if result != 0x0:
        if result == 0xc000000dL:
            value = 'Driver not found'
        else:
            value = 'Unknown Error'
        print p, 'NCR Failed - %s (code 0x%x)' % (value, result)
        return

    pktlen = len(data)
    #pkt = data ## Not used
    print p, 'Packet len = 0x%x (%d)' % (pktlen, pktlen)
    print p, 'Result code: 0x%x' % result
    data = data[4:] # 0x0 = OK

    print p, 'type: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x2 - fixed (type?)

    b_off = unpack('<I', data[:4])[0]
    print p, 'base offset = 0x%x (%d)' % (b_off, b_off)
    data = data[4:] # 0x24 - fixed

    drv_off = unpack('<I', data[:4])[0]
    print p, 'drv_off = 0x%x (%d)' % (drv_off, drv_off)
    #print p, '---->', pkt[drv_off-8:].replace('\x00','.')
    data = data[4:] # 0x50 - offset to driver file, -8 from start of packet

    srv_off = unpack('<I', data[:4])[0]
    print p, 'srv_off: 0x%x (%d) -> %d from start' % (srv_off, srv_off, srv_off-8)
    #print p, '--->', pkt[srv_off-8:]
    #print p, '--->', data[srv_off-32:]
    data = data[4:] # 0x6a - offset for unicode string to service name

    plen = unpack('<I', data[:4])[0]
    print p, 'plen: 0x%x (%d)' % (plen, plen)
    data = data[4:] # 0xcc - size of params (wihout ending 2*NULL)

    p_off = unpack('<I', data[:4])[0]
    print p, 'p_off: 0x%x (%d) -> %d from start' % (p_off, p_off, p_off-8)
    #print p, '--->', pkt[p_off-8:].replace('\x00', '.')
    data = data[4:] # 0x76 - offset from start for params

    s1 = data.find('\x00\x00')
    hid = utf2ascii(data[:s1+1])
    data = data[s1+3:]
    print p, 'hid: %s - Len 0x%x (%d)' % (hid, len(hid), len(hid))

    s1 = data.find('\x00\x00')
    drv = utf2ascii(data[:s1+1])
    data = data[s1+3:]
    print p, 'drv: %s - Len 0x%x (%d)' % (drv, len(drv), len(drv))

    s1 = data.find('\x00\x00')
    srv = utf2ascii(data[:s1+1])
    data = data[s1+3:]
    print p, 'srv: %s - Len 0x%x (%d)' % (srv, len(srv), len(srv))

    sets = data.split(NULL)
    parms = 0
    for i in range(0, len(sets), 3):
        if sets[i] == '':
            break
        if sets[i+2] == '':
            continue
        name  = sets[i]
        try:
            t = int(sets[i+1])
        except:
            t = 0
        value = sets[i+2]
        print p, '%s (%s [%d]) = %s' % (name, regtype[t], t, value)
        parms = parms + 1
    print p, 'Total Params:', parms

def send_ncq(s, vid, pid, subsys, spath):
    #vid    = 0x1022
    #pid    = 0x2000
    #rev_u1 = 0x2
    #rev_u2 = 0x0
    #rev_u3 = 0x0
    #rev    = 0x10
    #rev2   = 0x88
    #subsys = 0x20001022
    #spath  = '\\\\Attila\\RemInst\\winpe'
    #vid     = 0x10b7
    #pid     = 0x9200
    rev_u1  = 0x2
    rev_u2  = 0x0
    rev_u3  = 0x0
    #rev_u4  = 0x0
    rev     = 0x0
    rev2    = 0x0
    #subsys  = 0x0
    #spath  = '\\\\Attila\RemInst\\Setup\\Italian\\IMAGES\\WINDOWS'

    data = pack('<I', 0x2)                # u1
    data = data + pack('<I', 0x0)         # u2
    data = data + pack('<I', 0x12345678L) # mac1/2
    data = data + pack('<I', 0x9abc)      # mac2/2
    data = data + pack('<I', 0x0)         # u3
    data = data + pack('<I', 0x0)         # u4
    data = data + pack('<I', 0x2)         # u5
    data = data + pack('<H', vid)
    data = data + pack('<H', pid)
    data = data + chr(rev_u1) + chr(rev_u2) + chr(rev_u3)
    data = data + chr(rev)
    data = data + pack('<I', rev2)
    data = data + pack('<I', subsys)
    data = data + pack('<H', len(spath)) + spath + (NULL *2)

    reply = NCQ + pack('<I', len(data)) + data
    decode_ncq('[R]', data)
    s.send(reply)

def decode_ncq(p, data):
    #print p, 'u1: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # always 0x2

    #print p, 'u2: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # always 0x0

    mac  = [ord(x) for x in data[:6]]
    print p, 'Mac address', ':'.join(['%02x' % x for x in mac])
    data = data[6:]

    data = data[2:] # Padding

    #print p, 'u3: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # always 0x0

    #print p, 'u4: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # always 0x0

    #print p, 'u5: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # always 0x2

    vid = unpack('<H', data[:2])[0]
    print p, 'Vid: 0x%x' % vid
    data = data[2:]
    pid = unpack('<H', data[:2])[0]
    print p, 'Pid: 0x%x' % pid
    data = data[2:]

    print p, 'rev_u1 = 0x%x' % unpack('<B', data[0])
    print p, 'rev_u2 = 0x%x' % unpack('<B', data[1])
    print p, 'rev_u3 = 0x%x' % unpack('<B', data[2])
    print p, 'rev    = 0x%x' % unpack('<B', data[3])
    data = data[4:]

    print p, 'rev2   = 0x%x' % unpack('<I', data[:4])
    data = data[4:]

    subsys = unpack('<I', data[:4])[0]
    print p, 'subsys = 0x%x' % subsys
    data = data[4:]

    l = unpack('<H', data[:2])[0]
    data = data[2:]

    data = data[:l]
    print p, 'Source path:', data.replace('\x00','')
    return vid, pid, subsys


def decode_req(p, data):
    print p, 'Decoding REQ:'

    print p, 'f1: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x1

    print p, 'f2: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x10001

    print p, 'f3: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x10

    print p, 'f4: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x1


    print p, 'u1: 0x%x' % unpack('<I', data[:4])
    data = data[4:]

    print p, 'u2: 0x%x' % unpack('<I', data[:4])
    data = data[4:]

    ### end of fixed data
    hexdump(data)

def send_req(s, addr):
    reply = open('data1.req', 'rb').read()
    reply = REQ + pack('<I', len(data))
    s.sendto(reply, addr)

def decode_rsp(p, data):
    print p, 'Decoding RSP:'

    print p, 'u1: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x1

    print p, 'u2: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x10001

    print p, 'u3: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x10

    print p, 'u4: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x1

    ### end of fixed data
    hexdump(data)

def decode_off(p, data):
    print p, 'Decoding OFF:'

    print p, 'u1: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x4

    print p, 'u2: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x10001

    print p, 'u3: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x10

    print p, 'u4: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x1

    print p, 'u5: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # Variable

    print p, 'u6: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # Variable

    print p, 'u7: 0x%x' % unpack('<I', data[:4])
    data = data[4:] # 0x3

def send_rsp(s, addr, data):
    data = open('data1.rsp', 'rb').read()[8:]
    reply = RSP
    l = pack('<I', len(data))
    reply = reply + l + data
    print 'Sending RSP'
    decode_rsp('[S]', data)
    s.sendto(reply, addr)

def send_unr(s, addr):
    reply = UNR
    data = pack('<I', 0x1)
    l = pack('<I', len(data))
    reply = reply + l + data
    print 'Sending UNR (Session Expired)'
    s.sendto(reply, addr)

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

def daemonize(logfile):
    try:
        from os import fork
        from posix import close
    except:
        print 'Daemon mode is not supported on this platform (missing fork() syscall or posix module)'
        sys_exit(-1)

    import sys
    if (fork()): sys_exit(0) # parent return to shell

    ### Child
    close(sys.stdin.fileno())
    sys.stdin  = open('/dev/null')
    close(sys.stdout.fileno())
    sys.stdout = Log(open(logfile, 'a+'))
    close(sys.stderr.fileno())
    sys.stderr = Log(open(logfile, 'a+'))
    chdir('/')

if __name__ == '__main__':
    ## Defaults
    global pidfile, s
    daemon  = False
    logfile = '/var/log/binlsrv.log'
    address = ''
    port    = 4011
    devfile = 'devlist.cache'
    pidfile = '/var/run/binlsrv.pid'

    ## Parse command line arguments
    shortopts = 'hdl:a:p:'
    longopts = [ 'help', 'daemon', 'logfile=', 'address=', 'port=' ]

    try:
        opts, args = getopt(argv[1:], shortopts, longopts)
        if len(args) > 1:
            raise getopt_error, 'Too many device lists files specified %s' % ','.join(args)
    except getopt_error, errstr:
        print 'Error:', errstr
        print __usage__ % argv[0]
        sys_exit(-1)

    for opt, arg in opts:
        opt = opt.split('-').pop()

        if opt in ('h', 'help'):
            print __usage__ % argv[0]
            sys_exit(0)

        if opt in ('d', 'daemon'):
            daemon = True
            continue
        if opt in ('l', 'logfile'):
            logfile = arg
            continue
        if opt in ('a', 'address'):
            address = arg
            continue
        if opt in ('p', 'port'):
            try:
                port = int(arg)
            except:
                port = -1
        if opt in ('pid'):
            pidfile = arg

    if (port <= 0) or (port >= 0xffff):
        print 'Port not in range 1-65534'
        sys_exit(-1)

    #if len(args):
    #    devfile = args[0]

    #try:
    #    devlist = load(open(devfile, 'rb'))
    #except:
    #    print 'Could not load %s as cache, build it with infparser.py' % devfile
    #    sys_exit(-1)
    thistime = datetime.now()
    print thistime.strftime("%Y-%m-%d %H:%M:%S") + ' Starting binlsrv'

    flavordevlist={}
    tftpdir='/var/public/tftproot/windows5'
    filelist=listdir(tftpdir)
    for x in filelist:
      if path.isdir(tftpdir + "/" + str(x)):
         if x.rfind('_extra') != -1:
           cachefile=tftpdir + "/" + str(x) + "/devlist.cache"
           if path.isfile(cachefile):
             flavor=x.replace("_extra","");
             #thistime = datetime.now()
             #print thistime.strftime("%Y-%m-%d %H:%M:%S") + ' Loading cache file for flavor %s' % flavor
             devlist=load(open(cachefile))
             #print thistime.strftime("%Y-%m-%d %H:%M:%S") + ' Succesfully loaded %d devices' % len(devlist)
             flavordevlist[flavor]=devlist

    if daemon: daemonize(logfile)
    thistime = datetime.now()
    print thistime.strftime("%Y-%m-%d %H:%M:%S") + ' Succesfully loaded %d flavors' % len(flavordevlist)

    s = socket(AF_INET, SOCK_DGRAM)
    s.bind((address, port))

    thistime = datetime.now()
    print thistime.strftime("%Y-%m-%d %H:%M:%S") + ' Binlserver started... pid %d' % getpid()

    if daemon:
        ## Install signal int handlers
        signal(SIGINT, shutdown)
        signal(SIGTERM, shutdown)
        try:
            fd = open(pidfile, 'w')
            fd.write('%d' % getpid() )
            fd.close()
        except:
            print 'Cannot write pidfile', pidfile

    while 1:
        addr, t, data = get_packet(s)
        if t == FILEREQ:
            u1 = data[:7*4]
            data = data[7*4:]
            if data == '\n':
                send_file(s, addr, u1, BASEPATH, WELCOME)
            else:
                filename, params = data.split('\n', 1)
                filename = filename.lower() + '.osc'
                params = parse_arguments(params)
                print 'Client requested:', filename
                if len(params): print 'Arguments:', repr(params)
                ## TODO: there are also other actions
                if filename.startswith('launch'):
                    send_file(s, addr, u1, BASEPATH, 'warning.osc')
                else:
                    send_file(s, addr, u1, BASEPATH, filename)
        elif t == NEG:
            decode_ntlm('[C]', data)
            print 'NEG request, sending CHALLENGE'
            send_challenge(s, addr, server_data)
            sleep(1)
        elif t == AUT:
            print 'AUT request'
            decode_ntlm('[C]', data)
            send_res(s, addr, data)
            sleep(1)
        elif t == NCQ:
            print 'NCQ Driver request'
            if DUMPING: open('/tmp/ncq.hex','wb').write(data)
            vid, pid, subsys = decode_ncq('[R]', data)
            send_ncr(s, addr, vid, pid, subsys, flavor)
        elif t == REQ:
            print 'REQ request, sending Session Expired (RSP not implemented)'
            decode_req('[C]', data)
            if DUMPING: open('/tmp/req.hex','wb').write(REQ+pack('<I',len(data))+data)
            send_unr(s, addr)
            #send_rsp(s, addr, data)
        elif t == MAGIC_COOKIE:
             info = decode_bootp('[C]', data)
             send_bootp(s, addr, info)
        else:
            print 'Unknown Packet: ', repr(data)
            if DUMPING: open('/tmp/unknown.hex','wb').write(data)


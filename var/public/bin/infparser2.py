#!/usr/bin/env python
# -*- Mode: Python; tab-width: 4 -*-
#
# Inf Driver parser
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

from codecs import utf_16_le_decode, BOM_LE, BOM_BE
from sys import argv, exit as sys_exit
from os.path import isfile
from glob import glob
from cPickle import dump
from traceback import format_exc

__version__ = '1.0'

### Compatibility with python 2.1
if getattr(__builtins__, 'True', None) is None:
    True=1
    False=0

class_guids = ['{4d36e972-e325-11ce-bfc1-08002be10318}']
classes = ['net']

exclude = ['layout.inf', 'drvindex.inf', 'netclass.inf']

debug = 0
dumpdev = 0

bustype = { 'USB'   :  1,
            'PCI'   :  5,
            'PCMCIA':  8,
            'ISAPNP': 14
            }

def csv2list(value):
    values = value.strip().split(',')
    for i in range(len(values)):
        values[i] = values[i].strip()
    return values

def str_lookup(dc, c_key):
    for key in dc.keys():
        if key.lower() == c_key.lower():
            if len(dc[key])>0:
                return dc[key].pop()
    return 'NoDesc'

def item_lookup(dc, c_key):
    for key in dc.keys():
        if key.lower() == c_key.lower():
            return dc[key]
    return None

def fuzzy_lookup(strlist, pattern, ends=None):
    for s in strlist:
        if ends is not None and not s.endswith('services'): continue
        if s.startswith(pattern): return s
    return None


def unquote(text):
    return ''.join(text.split('"'))

def skip_inf(line):
    ## Check if driver is requested
    if line.find('=') == -1: return False
    key, value = line.split('=', 1)
    key = key.strip().lower()
    value = value.strip().lower()
    if key == 'class' and value not in classes: return True
    if key == 'classguid' and value not in class_guids: return True
    return False

def parse_line(sections, secname, lineno, line):
    equal = line.find('=')
    comma = line.find(',')
    if equal + comma != -2:
        if equal == -1:
            equal = comma+1
        if comma == -1:
            comma = equal+1

    if debug > 2: print '[%d] [%s] equal = %d - comma = %d' % (lineno, secname, equal, comma)

    if len(line) + equal + comma == -1:
        if debug: print '[%d] [%s] Invalid line' % (lineno, secname)
        return True

    ### Values
    if equal < comma:
        if type(sections[secname]) != type({}):
            sections[secname] = {}
        section = sections[secname]
        key, value = line.split('=', 1)
        key = key.strip()

        ### SkipList
        if key == '0':return True

        if section.has_key(key):
            values = csv2list(value)
            ### SkipList
            if (len(values) < 2) or (value.find('VEN_') == -1) or (value.find('DEV_') == -1):
                return True
            oldkey = key
            key = key + '_dev_' + values[1]

            if debug > 1: print '[%d] [%s] Duplicate key %s will be renamed to %s' % \
               (lineno, secname, oldkey, key)

        if secname == 'manufacturer':
            mlist = value.strip().split(',')
            mf = mlist[0].strip().lower()
            if len(mlist) > 1:
                ml = []
                for m in mlist[1:]:
                    ml.append('.'.join([mf, m.strip().lower()]))
                mlist = [mf] + ml
            else:
                mlist = [mf]

            if debug > 0: print 'Preprocessing Manifacturers:', ', '.join(mlist)
            section[key] = mlist
            if debug > 0: print 'Manifacturer %s=%s' % (key, section[key])
            return True

        section[key] = csv2list(value)
        if debug > 1: print '[K] [%d] [%s] %s=%s' % (lineno, secname, key, section[key])
        return True

    values = csv2list(line)
    if debug > 1: print '[V] [%d] [%s] Values = %s' % (lineno, secname, ','.join(values))
    sections[secname] = values
    return True

def parse_inf(filename):
    lineno = 0
    name = ''
    sections = {}
    section = None
    data = open(filename).read()

    ## Cheap Unicode to ascii
    if data[:2] == BOM_LE or data[:2] == BOM_BE:
        data = utf_16_le_decode(data)[0]
        data = data.encode('ascii', 'ignore')

    ## De-inf fixer ;)
    data = 'Copy'.join(data.split(';Cpy'))
    data = '\n'.join(data.split('\r\n'))
    data = ''.join(data.split('\\\n'))

    for line in data.split('\n'):
        lineno = lineno + 1
        line = line.strip()
        line = line.split(';', 1)[0]
        line = line.strip()

        if len(line) < 1: continue # empty lines

        if line[0] == ';': continue # comment

        ## We only need network drivers
        if name == 'version' and skip_inf(line):
            if debug > 0: print 'Skipped %s not a network inf' % filename
            return None

        ## Section start
        if line.startswith('[') and line.endswith(']'):
            name = line[1:-1].lower()
            sections[name] = {}
            section = sections[name]
        else:
            if section is None: continue
            if not parse_line(sections, name, lineno, line):
                break
    return sections

def scan_inf(filename):
    if debug > 0: print 'Parsing ', filename
    inf = parse_inf(filename)
    if inf is None: return {}

    devices = {}
    if inf and inf.has_key('manufacturer'):
        devlist = []
        for sections in inf['manufacturer'].values():
            devlist = devlist + sections
        if debug > 0: print 'Devlist:', ', '.join(devlist)
        for devmap in devlist:
            devmap_k = unquote(devmap.lower())
            if not inf.has_key(devmap_k):
                if debug > 0: print 'Warning: missing [%s] driver section in %s, ignored' % (devmap, filename)
                continue
            devmap = devmap_k
            for dev in inf[devmap].keys():
                if dev.find('%') == -1: continue # bad infs

                device = dev.split('%')[1]
                desc = unquote(str_lookup(inf['strings'], device))

                sec = inf[devmap][dev][0]
                hid = inf[devmap][dev][1]
                sec = sec.lower()

                hid = hid.upper()

                if inf.has_key(sec):
                    mainsec = sec
                else:
                    mainsec = fuzzy_lookup(inf.keys(), sec)
                    if mainsec is None: continue

                if mainsec.endswith('.services') and inf.has_key(mainsec):
                    serv_sec = mainsec
                elif inf.has_key(mainsec + '.services'):
                    serv_sec = mainsec + '.services'
                else:
                    serv_sec = fuzzy_lookup(inf.keys(), mainsec.split('.')[0], '.services')
                    if serv_sec is None:
                        if debug > 0: print 'Service section for %s not found, skipping...' % mainsec
                        continue

                if devices.has_key(hid): continue # Multiple sections define same devices

                if dumpdev: print 'Desc:', desc
                if dumpdev: print 'hid:', hid

                tmp = item_lookup(inf[serv_sec], 'addservice')
                if tmp is None:
                    if debug > 0: print 'Warning: addservice not found %s' % serv_sec
                    continue
                service = tmp[0]
                sec_service = tmp[2]

                driver = None
                if (type(inf[mainsec]) == type({})
                    and inf[mainsec].has_key('copyfiles')):
                    sec_files = inf[mainsec]['copyfiles'][0].lower()
                    if type(inf[sec_files]) == type([]):
                        driver = inf[sec_files][0]

                if driver is None:
                    if not inf.has_key(sec_service.lower()):
                        print 'Warning missing ServiceBinary for %s' % sec_service
                        print 'Please report including this file: %s\n' % filename
                        continue
                    driver = inf[sec_service.lower()]['ServiceBinary'][0].split('\\').pop()

                if dumpdev: print 'Driver', driver

                try:
                    char = eval(inf[mainsec]['Characteristics'][0])
                except:
                    char = 132

                if dumpdev: print 'Characteristics', char
                try:
                    btype = int(inf[mainsec]['BusType'][0])
                except:
                    try:
                        btype = bustype[hid.split('\\')[0]]
                    except:
                        btype = 0

                if dumpdev: print 'BusType', btype
                if dumpdev: print 'Service', service
                if dumpdev: print '-'*78


                devices[hid] = { 'desc' : desc,
                                 'char' : str(char),
                                 'btype': str(btype),
                                 'drv'  : 'DRIVER.ALT/' + driver,
                                 'svc'  : service,
                                 'inf'  : filename.split('/').pop() }
    return devices


if __name__ == '__main__':
    if len(argv) != 2:
        print 'Usage %s: flavor' % argv[0]
        sys_exit(-1)

    flavor=argv[1]

    filelist = glob('/var/public/tftproot/windows5/'+flavor+'_inf/*.inf')

    devlist ={}

    print 'Processing '+flavor+' drivers'
    for inffile in filelist:
        if inffile.split('/').pop() not in exclude:
            devlist.update(scan_inf(inffile))
    print 'Compiled %d drivers' % len(devlist)
    fd = open('/var/public/tftproot/windows5/'+flavor+'_extra/devlist.cache','w')
    dump(devlist, fd)
    fd.close()

    file=open('/var/public/tftproot/windows5/'+flavor+'_extra/devlist.count','w')
    file.write('DEVCOUNT=%d' % len(devlist) )
    file.close()

    #fd = open('nics.txt', 'w')
    #drvhash = {}
    #for nic in devlist.items():
    #    entry = nic[0].split('&')
    #    if len(entry) < 2: continue # just to be sure
    #    if not entry[0].startswith('PCI'): continue # skip usb
    #    vid = entry[0].split('VEN_').pop().lower()
    #    pid = entry[1].split('DEV_').pop().lower()
    #    key = (vid, pid)
    #    line = '%4s %4s %s %s\n' % (vid, pid, nic[1]['drv'], nic[1]['svc'])
    #    drvhash[key] = line

    #drvlist = drvhash.values()
    #drvlist.sort()
    #fd.writelines(drvlist)
    #fd.close()
    #print 'generated nics.txt'

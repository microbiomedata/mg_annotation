#!/usr/bin/python

import sys
import json
import os
import hashlib



def get_md5(fn):
    md5f = fn + '.md5'
    if os.path.exists(md5f):
        with open(md5f) as f:
            md5 = f.read().rstrip()
    else:
        md5 = hashlib.md5(open(fn, 'rb').read()).hexdigest()
        with open(md5f, 'w') as f:
            f.write(md5)
            f.write('\n')
    return md5

def gen_id(gid, git_url, start_date, end_date):
    txt = "{}\n{}\n{}\n{}\n".format(gid, git_url, start_date, end_date)
    print("hash: "+txt)
    md5hash = hashlib.md5(txt.encode('utf-8')).hexdigest()
    print(md5hash)
    return 'nmdc:{}'.format(md5hash)

def gen_data_objects(fpath, url, name, gid):
        md5 = get_md5(fpath)
        fmeta = os.stat(fpath)

        obj = {
           'id': 'nmdc:{}'.format(md5),
           'name': '{}_{}'.format(gid, name),
           'description': '{} for {}'.format(name, gid),
           'md5_checksum': md5,
           'url': url,
           'file_size_bytes': fmeta.st_size
        }
        return obj

def main():
    typ = sys.argv[1]
    analysis_id = sys.argv[2] 
    proj = sys.argv[3]
    start_date = sys.argv[4]
    end_date = sys.argv[5]
    res = sys.argv[6]
    url_base = sys.argv[7]
    git_url = sys.argv[8]
    assembly = sys.argv[9]

    ins = ['nmdc:{}'.format(get_md5(assembly))]
    outs = []

    # Generate data objects
    data_objects = []
    item_list = sys.argv[10:]
    for i in range(0, len(item_list), 2):
        fn = item_list[i]
        name = item_list[i+1]
        url = '%s%s' % (url_base, fn.split('/')[-1])
        obj = gen_data_objects(fn, url, name, analysis_id)
        data_objects.append(obj)
        outs.append(obj['id'])
    activity_id = gen_id(analysis_id, git_url, start_date, end_date)
    meta = {
            "id": activity_id,
            "name": "{} annotation activity for {}".format(typ, analysis_id),
            "was_informed_by": analysis_id,
            "started_at_time": start_date,
            "ended_at_time": end_date,
            "type": "nmdc:{}AnnotationActivity".format(typ),
            "execution_resource": res,
            "git_url": git_url,
            "has_input": ins,
            "has_output": outs,
    }
    with open('activity.json', 'w') as f:
        f.write(json.dumps(meta, indent=2))
    with open('data_objects.json', 'w') as f:
        f.write(json.dumps(data_objects, indent=2))


if __name__ == '__main__':
    main()


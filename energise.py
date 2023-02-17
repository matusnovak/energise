#!/usr/bin/env python3

import os
import sys
import subprocess
import yaml
import copy
from tempfile import NamedTemporaryFile
from typing import List
from argparse import ArgumentParser, Namespace as Arguments


DIR = os.path.dirname(os.path.realpath(__file__))


def cmd(args: List[str]) -> str:
    env = os.environ.copy()
    subprocess.run(args, stdout=sys.stdout, stderr=sys.stderr, check=True, env=env)


def yaml_workaround(src: str, dst: str):
    with open(src, "r") as f:
        values = yaml.safe_load(f)

    for key, value in values.items():
        if key == 'global':
            continue
        values['global'][key] = copy.deepcopy(value)

    with open(dst, 'w') as f:
        yaml.dump(values, f)


def deploy(args: Arguments):
    src = os.path.join(DIR, 'energise.yml')
    with NamedTemporaryFile() as tf:
        yaml_workaround(src, tf.name)
        
        if args.dry_run:
            cmd([
                'helm',
                'template',
                '--values', 
                tf.name,
                '--release-name',
                'homelab',
                '--namespace', 
                'homelab',
                '--dry-run',
                '--debug',
                DIR])
        else:
            cmd([
                'helm',
                'upgrade',
                '--install',
                '--values', 
                tf.name,
                '--namespace', 
                'homelab',
                '--create-namespace',
                'homelab',
                DIR])


def main(argv):
    root = ArgumentParser(add_help=False)                                 
    root.add_argument('-d', '--debug',
        action='store_true',
        default=False)                     

    parser = ArgumentParser(add_help=False) 
    subparsers = parser.add_subparsers()                                             

    parser_deploy = subparsers.add_parser('deploy', parents = [root])
    parser_deploy.set_defaults(func=deploy)
    parser_deploy.add_argument('--dry-run',
        action='store_true',
        default=False)

    args = parser.parse_args(argv)
    args.func(args)


if __name__ == '__main__':
    main(sys.argv[1::])

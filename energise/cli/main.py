from argparse import ArgumentParser
from typing import List

from energise.cli.commands.deploy import action_args as command_deploy_args


def main(argv: List[str]):
    root = ArgumentParser(add_help=False)
    root.add_argument('-d,--debug', action='store_true', default=False, dest='debug')
    root.add_argument('--namespace', type=str, default='homelab')
    root.add_argument('--config', type=str, default='/etc/energise.yml', dest='config_path')

    parser = ArgumentParser(prog='energise', parents=[root])
    subparsers = parser.add_subparsers(title="action", required=True)
    command_deploy_args(subparsers.add_parser('deploy', parents=[root]))

    args = parser.parse_args(argv)
    args.func(args)

import sys
from argparse import ArgumentParser, Namespace as Args

from energise.cli.ansible import ansible_runner


def action_args(parser: ArgumentParser):
    parser.set_defaults(func=action_func)
    parser.add_argument('--ask-become-pass', action='store_true', default=False, help='Ask for sudo password')


def action_func(args: Args):
    if ansible_runner(args) != 0:
        sys.exit(1)

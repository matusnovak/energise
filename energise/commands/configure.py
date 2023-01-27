import click

from energise.input import input
from energise.manager import get_manager, Manager
from energise.utils.click import async_cmd


@click.command()
@async_cmd
async def configure():
    await do_configure()


async def do_configure():
    async with get_manager() as manager:
        # namespaces = await manager.core.list_namespace()
        # click.echo(namespaces)
        input.menu('Main menu', [
            ('Status', lambda: do_status(manager)),
            ('Setup homelab', lambda: do_setup(manager)),
            ('Install or edit an application', lambda: do_install(manager)),
            ('Exit', None),
        ])


def do_status(manager: Manager):
    click.echo('Status')


def do_setup(manager: Manager):
    click.echo('Setup')


def do_install(manager: Manager):
    click.echo('Install')

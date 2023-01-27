import click

from energise.commands.configure import configure
from energise.utils.click import async_cmd


@click.group()
@click.pass_context
@async_cmd
async def cli(ctx):
    pass


cli.add_command(configure)

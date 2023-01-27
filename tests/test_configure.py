from unittest.mock import patch

import pytest
from tests.fixtures.k8s import k8s_client, k8s_clean  # noqa

from energise.commands.configure import do_configure, input


@pytest.mark.asyncio
@patch.object(input, 'menu')
async def test_hello_world(mock_input_menu):
    mock_input_menu.side_effect = lambda title, items: items[0][1]()

    await do_configure()
    mock_input_menu.assert_called()

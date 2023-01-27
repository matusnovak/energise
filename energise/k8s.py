from contextlib import asynccontextmanager
from typing import AsyncContextManager

from kubernetes_asyncio import config
from kubernetes_asyncio.client import CoreV1Api
from kubernetes_asyncio.client.api_client import ApiClient


class K8sClient:
    def __init__(self, api: ApiClient):
        self.api = api
        self.core = CoreV1Api(self.api)


@asynccontextmanager
async def get_k8s_client() -> AsyncContextManager[K8sClient]:
    await config.load_kube_config()

    async with ApiClient() as api:
        client = K8sClient(api)
        yield client

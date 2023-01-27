from energise.k8s import K8sClient


class Manager:
    def __init__(self, client: K8sClient):
        self.client = client

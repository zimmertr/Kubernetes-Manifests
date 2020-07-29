import random
from locust import HttpUser, task, between

class QuickstartUser(HttpUser):
    wait_time = between(5, 9)
    @task(1)
    def index(self):
        self.client.get("/")
    @task(2)
    def items(self):
        self.client.get("/items")
    @task(3)
    def signin(self):
        self.client.get("/signin")
    @task(4)
    def create(self):
        self.client.get("/users/new")

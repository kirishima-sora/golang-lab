from locust import HttpUser, task, between

class QuickstartUser(HttpUser):
    # ユーザーが次のタスクを実行するまでの待ち時間を1秒から2.5秒の間でランダムに設定
    wait_time = between(1, 2.5)

    # 負荷テスト中に行われるタスク
    @task
    def index_page(self):
        self.client.get("/locust-test")
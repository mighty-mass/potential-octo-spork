gae_service = [{
    version = "v2"
    service = "email"
    runtime = "python311"
    entrypoint = "gunicorn -w 3 -k uvicorn.workers.UvicornWorker main:app"
    files = [
        {
            name = "main.py"
            source_url = "https://storage.googleapis.com/<bucket>/<path_prefix>/main.py"
        },
        {
            name = "requirements.txt"
            source_url = "https://storage.googleapis.com/<bucket>/<path_prefix>/main.py"
        }
    ]
    libraries = [
        {
            name = "boto3"
            version = "latest"
        }
    ]
    env_variables = {
        TEST_SECRET = "SUCCESS"
    }
}]

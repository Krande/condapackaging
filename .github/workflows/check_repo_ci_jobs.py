import pathlib
import shutil

import requests
import zipfile
import os

REPO_OWNER = os.environ.get("REPO_OWNER", "krande/condapackaging")
MY_WORKFLOW = os.environ.get("MY_WORKFLOW", "ci-force-fail")
TOKEN = os.environ.get("GITHUB_TOKEN", None)

SIGNS_OF_STOPPAGE = [
    "Error: The operation was canceled.",
    "fatal error C1060: compiler is out of heap space",
    "Something happened that triggers an exit 1",
    "Another thing happened to trigger a exit 143"
]


def start_request_session():
    s = requests.Session()
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if TOKEN:
        headers["Authorization"] = f"Bearer {TOKEN}"

    s.headers = headers
    return s


def get_ci_jobs(repo_name):
    url = f"https://api.github.com/repos/{repo_name}/actions/runs"
    s = start_request_session()
    response = s.get(url)
    jobs = response.json()
    return list(filter(lambda x: x["name"] == MY_WORKFLOW, jobs["workflow_runs"]))


def evaluate_log_file_for_abrupt_stop(log_file):
    with open(log_file) as f:
        for line in f:
            for sign in SIGNS_OF_STOPPAGE:
                if sign in line:
                    print(f"Found sign of stoppage: {sign}")
                    return True
    return False


def get_ci_specific_run_specific_failure_details(repo_name, run_id):
    url = f"https://api.github.com/repos/{repo_name}/actions/runs/{run_id}/attempts/1/logs"
    s = start_request_session()
    response = s.get(url)
    # SAVE zip file
    with open("logs.zip", "wb") as f:
        f.write(response.content)
    # unzip file

    with zipfile.ZipFile("logs.zip", "r") as zip_ref:
        zip_ref.extractall("logs")
    failed_logs = []
    for file in pathlib.Path("logs").iterdir():
        if file.is_dir():
            continue

        if evaluate_log_file_for_abrupt_stop(file):
            failed_logs.append(file)

    return failed_logs


def restart_job(repo_name, job_id):
    url = f"https://api.github.com/repos/{repo_name}/actions/runs/{job_id}/rerun-failed-jobs"
    s = start_request_session()
    response = s.post(url)
    return response.json()


def check_logs_for_status_code_143(logs):
    """Do something like this?"""
    for log in logs["lines"]:
        if log["name"] == "stderr":
            if "Error: The operation was canceled." in log["text"]:
                return True
            if "fatal error C1060: compiler is out of heap space" in log["text"]:
                return True
    return False


def get_failed_jobs():
    jobs = get_ci_jobs(REPO_OWNER)
    failed_jobs = []
    for job in filter(lambda x: x["name"] == MY_WORKFLOW, jobs):
        if job["name"] != MY_WORKFLOW:
            continue

        if job["status"] != "completed":
            continue
        if job["conclusion"] != "failure":
            continue

        failed_jobs.append(job)
    failed_jobs = list(sorted(failed_jobs, key=lambda x: x["run_number"]))
    return failed_jobs


def eval_jobs():
    failed_jobs = get_failed_jobs()

    last_job = failed_jobs[-1]
    logs = get_ci_specific_run_specific_failure_details(REPO_OWNER, last_job["id"])

    print(logs)
    print("restarting job", last_job["id"])

    r = restart_job(REPO_OWNER, last_job["id"])
    print(r)

    shutil.rmtree("logs")
    os.remove("logs.zip")


if __name__ == "__main__":
    eval_jobs()

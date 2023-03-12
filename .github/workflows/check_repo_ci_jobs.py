import requests
import os

REPO_OWNER = os.environ.get("REPO_OWNER", "krande/condapackaging")
MY_WORKFLOW = os.environ.get("MY_WORKFLOW", "ci-force-fail")
TOKEN = os.environ.get("GITHUB_TOKEN", None)


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
    return response.json()


def get_ci_specific_run_specific_failure_details(repo_name, run_id):
    url = f"https://api.github.com/repos/{repo_name}/actions/runs/{run_id}/attempts/1/logs"
    s = start_request_session()
    response = s.get(url)
    return response.json()


def restart_job(repo_name, job_id):
    url = f"https://api.github.com/repos/{repo_name}/actions/runs/{job_id}/rerun"
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


def eval_jobs():
    jobs = get_ci_jobs(REPO_OWNER)
    failed_jobs = []
    for job in jobs["workflow_runs"]:
        if job["name"] != MY_WORKFLOW:
            continue

        if job["status"] != "completed":
            continue
        if job["conclusion"] != "failure":
            continue

        if job["run_attempt"] > 1:
            continue
        failed_jobs.append(job)

    sorted_jobs = list(sorted(failed_jobs, key=lambda x: x["run_number"]))
    last_job = sorted_jobs[-1]
    logs = get_ci_specific_run_specific_failure_details(REPO_OWNER, last_job["id"])
    print(logs)
    print("restarting job", last_job["id"])

    r = restart_job(REPO_OWNER, last_job["id"])
    print(r)


if __name__ == "__main__":
    eval_jobs()

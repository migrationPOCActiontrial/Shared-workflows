import subprocess
import sys

SOURCE_BASE = "https://github.com/migrationPOCAction"
TARGET_BASE = "https://github.com/migrationPOCActiontrial"

REPOS = [
    "spring-boot-inventory-system",
    "payment-management-service",
    "unique-springboot-repo",
    "spring-boot-user-management",
    "notification-service"
]


def run_command(command):
    result = subprocess.run(
        command,
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        error = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(error)

    return result.stdout.strip()


def get_refs(repo_url, ref_type):
    output = run_command([
        "git",
        "ls-remote",
        repo_url,
        f"refs/{ref_type}/*"
    ])

    refs = {}

    for line in output.splitlines():
        sha, ref = line.split("\t")
        refs[ref] = sha

    return refs


def verify_repo(repo):
    source_url = f"{SOURCE_BASE}/{repo}.git"
    target_url = f"{TARGET_BASE}/{repo}.git"

    print(f"\nChecking repository: {repo}")

    source_branches = get_refs(source_url, "heads")
    target_branches = get_refs(target_url, "heads")

    source_tags = get_refs(source_url, "tags")
    target_tags = get_refs(target_url, "tags")

    success = True

    # Check branches
    if set(source_branches) != set(target_branches):
        print("Branches mismatch:")
        print(f"Source branches: {set(source_branches)}")
        print(f"Target branches: {set(target_branches)}")
        success = False

    # Check branch SHAs
    for branch in source_branches:
        source_sha = source_branches[branch]
        target_sha = target_branches.get(branch)

        if source_sha != target_sha:
            print(f"Branch mismatch: {branch}")
            print(f"Source SHA: {source_sha}")
            print(f"Target SHA: {target_sha}")
            success = False

    # Check tags
    if set(source_tags) != set(target_tags):
        print("Tags mismatch:")
        print(f"Source tags: {set(source_tags)}")
        print(f"Target tags: {set(target_tags)}")
        success = False

    # Check tag SHAs
    for tag in source_tags:
        source_sha = source_tags[tag]
        target_sha = target_tags.get(tag)

        if source_sha != target_sha:
            print(f"Tag mismatch: {tag}")
            print(f"Source SHA: {source_sha}")
            print(f"Target SHA: {target_sha}")
            success = False

    if success:
        print(f"Repository {repo} verified successfully.")
    else:
        print(f"Repository {repo} verification failed.")

    return success


def main():
    overall_success = True

    for repo in REPOS:
        try:
            if not verify_repo(repo):
                overall_success = False
        except Exception as error:
            print(f"Error verifying repository {repo}: {error}")
            overall_success = False

    if overall_success:
        print("\nMigration Verification passed.")
        sys.exit(0)
    else:
        print("\nMigration Verification failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()

import subprocess
import sys

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"

REPOS = [
    "repo1",
    "repo2"
]

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    
    return result.stdout.strip()

def get_refs(repo_url, ref_type):
    output = run_command([f"git", "ls-remote", repo_url, f"refs/{ref_type}/*"])
    
    refs={}
    
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
    
    if set(source_branches!=set(target_branches)):
        print(f"Branches mismatch in {repo}:")
        print(f"Source branches: {set(source_branches.keys())}")
        print(f"Target branches: {set(target_branches.keys())}")
        success = False
    
    if set(source_tags)!=set(target_tags):
        print(f"Tags mismatch in {repo}:")
        print(f"Source tags: {set(source_tags.keys())}")
        print(f"Target tags: {set(target_tags.keys())}")
        success = False
        
    for tag in source_tags:
        if source_tags[tag] != target_tags.get(tag):
            print(f"Tag {tag} mismatch in {repo}:")
            print(f"Source SHA: {source_tags[tag]}")
            print(f"Target SHA: {target_tags.get(tag)}")
            success = False
            
    if success:
        print(f"Repository {repo} verified successfully.")
    else:
        print(f"Repository {repo} verification failed.")
        
def  main():
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

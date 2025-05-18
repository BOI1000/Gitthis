# RepoRipper.sh

RepoRipper is a Bash script for cloning and restoring remote `.git` directories.

---

## Features

- Clone remote `.git` directories.
- Rebuild a valid git repository from the dump.
- Display repository history and status.
- Supports colored output and logging.

---

## Usage

```bash
./RepoRipper.sh [OPTIONS]
```

### Options

| Option                | Description                                               |
|-----------------------|-----------------------------------------------------------|
| `-u`, `--url`         | The URL of the remote `.git` directory to clone. **(required)** |
| `-f`, `--folder`      | Output directory for the restored repository. *(default: repo)* |
| `-lf`, `--log-file`   | Log file to write output to. *(default: repoRipper.log)*       |
| `-nc`, `--no-color`   | Disable colored output.                                   |
| `-h`, `--help`        | Show help message and exit.                               |
| `-gG`, `--grep`       | Run a git grep for comma-separated keywords like emails, usernames, etc. |

---

### Example

```bash
./RepoRipper.sh -u http://example.com/.git -f myrepo -lf mylog.log
```

---

## Requirements

- `wget`
- `git`

Make sure they are installed:

```bash
sudo apt install wget git -y
```

---

## Author

**@theRealHacker**

---

## Legal Disclaimer

This tool is intended for educational and authorized security research purposes only. Do not use it to access systems without permission.


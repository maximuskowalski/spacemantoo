# spacemantoo

## Overview

spacemantoo is a Bash script designed to monitor disk space on a server and send notifications via Discord when the space falls below a specified threshold.

## Setup Instructions

### Prerequisites

- Bash
- `curl` must be installed to send notifications to Discord.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/maximuskowalski/spacemantoo.git
   ```

2. Navigate to the cloned directory:

   ```bash
   cd spacemantoo
   ```

### Configuration

1. Copy the example configuration file:

   ```bash
   cp spaceman.cfg.example spaceman.cfg
   ```

2. Edit `spaceman.cfg` with your specific settings:
   - `WEBHOOK_URL`: Your Discord webhook URL.
   - `DIRECTORY_PATH`: The path to the directory you want to monitor.
   - `MIN_SPACE_GB`: The minimum free space threshold in GB.
   - `SERVER_NAME`: The name of your server.

### Usage

Run the script manually to check the disk space:

```bash
./spacemantoo.sh
```

For automatic monitoring, set up a cron job:

```bash
crontab -e
```

Example 1
Add the following line to run the script every day at 7 AM

```bash
0 7 * * * /path/to/spacemantoo/spacemantoo.sh
```

Example 2
Add the following line to run the script every 5 minutes for continual monitoring

```sh
*/5 * * * * "/opt/scripts/max/spacemantoo/spacemantoo.sh"
```

## Contributions

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

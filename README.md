# n8n Docker Setup

A simple Docker Compose setup for running [n8n](https://n8n.io) (workflow automation tool) with an easy-to-use Windows batch script for management.

> **Note**: This project provides a convenient Docker setup for n8n. For n8n-specific support, documentation, and features, please refer to the [official n8n resources](https://docs.n8n.io).

## Features

- **Docker Compose**: Simple container orchestration using the official [n8n Docker image](https://hub.docker.com/r/n8nio/n8n)
- **Windows Batch Script**: Easy management with `n8n.bat` - automatically starts Docker if needed
- **Auto-backup**: Creates timestamped backups before updates to protect your data
- **Auto-update**: Pulls latest n8n image and starts/updates containers
- **Persistent Data**: Docker volumes ensure your workflows are saved
- **Auto-restart**: Container restarts automatically unless stopped manually

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone https://github.com/AaronPriestPhoto/n8nStartDocker.git
   cd n8nStartDocker
   ```

2. **Create environment file**:
   ```bash
   copy .env.example .env
   ```
   Edit `.env` with your n8n configuration (see Configuration section).

3. **Run the setup**:
   - **Windows**: Double-click `n8n.bat` and choose option `[U]` to start
   - **Manual**: Run `docker compose up -d`

4. **Access n8n**: Open http://localhost:5678 in your browser

## Configuration

Create a `.env` file in the project root with your n8n settings. Example:

```env
# Timezone
TZ=America/New_York
GENERIC_TIMEZONE=America/New_York

# Encryption key (make this a random 32+ char string and keep it safe)
N8N_ENCRYPTION_KEY="your_random_32_plus_character_string_here"

# Optional: Basic authentication
# N8N_BASIC_AUTH_ACTIVE=true
# N8N_BASIC_AUTH_USER=admin
# N8N_BASIC_AUTH_PASSWORD=your_secure_password

# Optional: Custom host/port settings
# N8N_HOST=localhost
# N8N_PORT=5678
# N8N_PROTOCOL=http
# N8N_EDITOR_BASE_URL=http://localhost:5678/

# Optional: Database (defaults to SQLite if not specified)
# N8N_DATABASE_TYPE=postgresdb
# N8N_DATABASE_POSTGRESDB_HOST=postgres
# N8N_DATABASE_POSTGRESDB_PORT=5432
# N8N_DATABASE_POSTGRESDB_DATABASE=n8n
# N8N_DATABASE_POSTGRESDB_USER=n8n
# N8N_DATABASE_POSTGRESDB_PASSWORD=n8n_password
```

## Management Script (Windows)

The `n8n.bat` script provides an easy way to manage your n8n Docker setup:

- **`[U]` Backup + Update/Start**: Creates a timestamped backup, then pulls latest n8n image and starts/updates containers
- **`[D]` Shut Down**: Stops all containers (preserves data)
- **`[Q]` Quit**: Exit the script

The script also:
- Automatically starts Docker Desktop if needed
- Waits for Docker Engine to be ready
- Creates automatic backups before updates (saved as `n8n_backup_YYYYMMDD_HHMM.tar.gz`)
- Opens the n8n dashboard after starting
- Shows container status

## Docker Commands

For manual management without the batch script:

```bash
# Start n8n
docker compose up -d

# Stop n8n
docker compose down

# View logs
docker compose logs -f

# Update to latest image
docker compose pull
docker compose up -d

# Remove everything (including data volumes)
docker compose down -v
```

## Data Persistence & Backups

Your n8n workflows, credentials, and settings are stored in a Docker volume named `n8n_data`. This data persists between container restarts and updates.

### Automatic Backups

The `n8n.bat` script automatically creates timestamped backups before each update:
- **Backup files**: Saved as `n8n_backup_YYYYMMDD_HHMM.tar.gz`
- **Location**: Created in the same directory as the script
- **Contents**: Complete n8n data volume backup
- **Privacy**: Backup files are kept local-only (not synced to GitHub)

### Restoring from Backup

To restore from a backup file, use the included `restore_n8n.bat` script:
1. Ensure n8n is stopped: Run `n8n.bat` and choose `[D]`
2. Run `restore_n8n.bat` and follow the prompts
3. Select your backup file from the list
4. The script will restore your data and restart n8n

## Security Notes

- **Change default credentials**: Always set strong passwords in your `.env` file
- **Network access**: By default, n8n is accessible on localhost only
- **HTTPS**: For production use, consider setting up HTTPS with a reverse proxy

## Troubleshooting

### Docker not starting
- Ensure Docker Desktop is installed and running
- Check if the Docker service is running in Windows Services

### Port conflicts
- If port 5678 is in use, modify the port mapping in `docker-compose.yml`
- Update the `N8N_PORT` in your `.env` file to match

### Permission issues
- Run the batch script as Administrator if you encounter permission errors
- Check Docker Desktop settings for file sharing permissions

## Support

- **This Docker setup**: Open an issue in this repository for problems with the Docker configuration or batch script
- **n8n application**: For n8n-specific questions, features, or bugs, visit:
  - [Official n8n Documentation](https://docs.n8n.io)
  - [n8n Community Forum](https://community.n8n.io)
  - [n8n GitHub Repository](https://github.com/n8n-io/n8n)
  - [Official n8n Docker Hub](https://hub.docker.com/r/n8nio/n8n)

## License

This project is open source. n8n itself is licensed under the [Fair-code](https://faircode.io/) license.

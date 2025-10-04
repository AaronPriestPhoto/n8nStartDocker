# n8n Docker Setup

A simple Docker Compose setup for running n8n (workflow automation tool) with an easy-to-use Windows batch script for management.

## Features

- **Docker Compose**: Simple container orchestration for n8n
- **Windows Batch Script**: Easy management with `n8n.bat`
- **Persistent Data**: Docker volumes ensure your workflows are saved
- **Auto-restart**: Container restarts automatically unless stopped manually

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
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
# Basic n8n configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password

# Optional settings
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_EDITOR_BASE_URL=http://localhost:5678/

# Database (optional - defaults to SQLite)
# N8N_DATABASE_TYPE=postgresdb
# N8N_DATABASE_POSTGRESDB_HOST=postgres
# N8N_DATABASE_POSTGRESDB_PORT=5432
# N8N_DATABASE_POSTGRESDB_DATABASE=n8n
# N8N_DATABASE_POSTGRESDB_USER=n8n
# N8N_DATABASE_POSTGRESDB_PASSWORD=n8n_password
```

## Management Script (Windows)

The `n8n.bat` script provides an easy way to manage your n8n Docker setup:

- **`[U]` Update/Start**: Pulls latest n8n image and starts/updates containers
- **`[D]` Shut Down**: Stops all containers (preserves data)
- **`[Q]` Quit**: Exit the script

The script also:
- Automatically starts Docker Desktop if needed
- Waits for Docker Engine to be ready
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

## Data Persistence

Your n8n workflows, credentials, and settings are stored in a Docker volume named `n8n_data`. This data persists between container restarts and updates.

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

## License

This project is open source. n8n itself is licensed under the [Fair-code](https://faircode.io/) license.

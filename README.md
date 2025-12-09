# OSB Image

Run Open Study Builder using pre-built Docker images.

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available for containers

## Quick Start

1. **Create environment file**

   Copy the example environment file:
   ```bash
   cp env.example .env
   ```

2. **Configure environment variables**

   Edit `.env` with your settings (see [Configuration](#configuration) below).

3. **Start the services**

   ```bash
   docker compose up -d
   ```

4. **Access the application**

   - Frontend: http://localhost:5005
   - Neo4j Browser: http://localhost:5001
   - PocketBase Admin: http://localhost:8090/_/
   - NeoDash: http://localhost:5007

## Stopping Services

```bash
docker compose down
```

To also remove volumes (database data):
```bash
docker compose down -v
```

## Configuration

### Environment Variables

Create a `.env` file in the project root with the following variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `NEO4J_PASSWORD` | Password for Neo4j database | `changeme1234` |
| `FRONTEND_PORT` | Port for the frontend application | `5005` |
| `BIND_ADDRESS` | Network bind address | `0.0.0.0` |
| `POCKETBASE_PORT` | Port for PocketBase | `8090` |
| `POCKETBASE_PUBLIC_URL` | Public URL for PocketBase | `http://localhost:8090` |
| `POCKETBASE_CORS_ORIGINS` | Allowed CORS origins for PocketBase | `http://localhost:5005,http://localhost:5173` |
| `OAUTH_ENABLED` | Enable OAuth authentication | `false` |
| `OAUTH_RBAC_ENABLED` | Enable OAuth RBAC | `false` |
| `NEO4J_BOLT_PORT` | Neo4j Bolt protocol port | `5002` |
| `NEO4J_HTTP_PORT` | Neo4j HTTP port | `5001` |
| `NEODASH_PORT` | NeoDash port | `5007` |

### Backup Configuration (Optional)

For S3 backup functionality, add these variables:

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for S3 backups |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for S3 backups |
| `S3_BUCKET` | S3 bucket name for backups |

## Services

| Service | Description | Port |
|---------|-------------|------|
| `frontend` | Web application UI | 5005 |
| `api` | Main API service | (internal) |
| `consumerapi` | Consumer API service | (internal) |
| `database` | Neo4j graph database | 5001 (HTTP), 5002 (Bolt) |
| `documentation` | Documentation portal | (internal) |
| `neodash` | Neo4j dashboard | 5007 |
| `pocketbase` | PocketBase backend | 8090 |
| `neo4j-backup` | Database backup service | - |

## Backup

### Manual Backup

To run a backup manually from the host:

1. **Stop the database container** (required for consistent backup):
   ```bash
   docker compose stop database
   ```

2. **Run the backup script**:
   ```bash
   docker compose exec neo4j-backup sh /backup/backup.sh
   ```

3. **Start the database container**:
   ```bash
   docker compose start database
   ```

### Automated Backup with Cron

To schedule daily backups at 6:15 PM (after stopping the database at 6:00 PM), add these entries to your crontab:

```bash
crontab -e
```

Add the following lines:

```cron
# Stop Neo4j database at 6:00 PM
0 18 * * * cd /path/to/osb-image && docker compose stop database

# Run backup at 6:15 PM
15 18 * * * cd /path/to/osb-image && docker compose exec neo4j-backup sh /backup/backup.sh && docker compose start database
```

Replace `/path/to/osb-image` with the actual path to your project directory.

> **Note:** Ensure AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET`) are configured in your `.env` file for S3 backups to work.

## Troubleshooting

### Services not starting
Check logs for a specific service:
```bash
docker compose logs <service-name>
```

### Database health check failing
The Neo4j database may take up to 60 seconds to start. Check its status:
```bash
docker compose ps
docker compose logs database
```

### Reset everything
```bash
docker compose down -v
docker compose up -d
```

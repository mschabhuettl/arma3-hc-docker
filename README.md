# **Arma 3 Headless Client**

This repository provides a Docker image for deploying Arma 3 headless clients. It simplifies the setup and management of multiple headless clients, which are used to improve Arma 3 server performance by offloading AI and scripting calculations.

---

## **Features**
- Dockerized Arma 3 headless client for easy deployment.
- Compatible with multiple clients via `docker compose`.
- Fully configurable using environment variables.
- Automatically installs or updates Arma 3 server files and mods.
- Resilient retry mechanism for client reconnects in case of errors.

---

## **Getting Started**

### **Clone the Repository**
```bash
git clone https://github.com/mschabhuettl/arma3-headless-client-docker.git
cd arma3-headless-client-docker
```

---

## **Build Process**

### **Initial Setup**
1. **Build the Updater**  
   Run the following command to build the updater container:
   ```bash
   docker compose build updater
   ```

2. **Start the Updater**  
   This will start the updater container, which will download the required Arma 3 server files:
   ```bash
   docker compose up updater
   ```

3. **Edit the Configuration File**  
   Modify `arma3_hc_config.env` to suit your needs, including setting up mods, server details, and credentials.

4. **Start the Headless Clients**  
   Run the following command to start the headless clients using the updated configuration:
   ```bash
   docker compose up -d arma3-client-0 arma3-client-1
   ```

---

## **Usage**

### **Run Multiple Clients with Docker Compose**
You can define and run multiple clients using `docker compose`.

**`docker-compose.yml` Example:**
```yaml
services:
  updater:
    build:
      context: .
      dockerfile: Dockerfile.updater
    container_name: arma3-updater
    env_file:
      - ./arma3_hc_config.env
    volumes:
      - ./arma3_hc_config.env:/arma3/arma3_hc_config.env
      - arma3_data:/arma3
    command: /bin/bash -c "source /arma3/arma3_hc_config.env && /arma3/start_updater.sh"
    restart: "no"

  arma3-client-0:
    build:
      context: .
      dockerfile: Dockerfile.client
    container_name: arma3-client-0
    depends_on:
      - updater
    env_file:
      - ./arma3_hc_config.env
    volumes:
      - ./arma3_hc_config.env:/arma3/arma3_hc_config.env
      - arma3_data:/arma3:ro
      - logs:/logs
    command: /bin/bash -c "source /arma3/arma3_hc_config.env && /scripts/start_client.sh"
    restart: always

  arma3-client-1:
    build:
      context: .
      dockerfile: Dockerfile.client
    container_name: arma3-client-1
    depends_on:
      - updater
    env_file:
      - ./arma3_hc_config.env
    volumes:
      - ./arma3_hc_config.env:/arma3/arma3_hc_config.env
      - arma3_data:/arma3:ro
      - logs:/logs
    command: /bin/bash -c "source /arma3/arma3_hc_config.env && /scripts/start_client.sh"
    restart: always

volumes:
  arma3_data:
  logs:
```

**Environment File Example (`arma3_hc_config.env`):**
```env
# Steam credentials
STEAM_USER=your_steam_username
STEAM_PASS=your_steam_password

# Arma 3 server connection details
ARMA_HOST=your_server_address
ARMA_PORT=2302
ARMA_PASS=your_server_password

# Arma 3 Mods
ARMA_MODS="mod1;mod2;mod3"

# Headless Client parameters
HC_NAME_PREFIX=arma3_hc_  # Prefix for the headless client name

# Additional launch parameters
HC_ADDITIONAL_PARAMS="-nosplash -world=empty -nosound"
```

---

## **Retry Mechanism**

The included startup script implements an automatic retry mechanism for client restarts in case of:
- Kicks due to Steam authentication errors (e.g., `Invalid ticket`).
- Disconnections from the Arma 3 server.
- Any other issue preventing the client from staying connected.

---

## **Configuration**

### **Environment Variables**
The following variables can be configured via `.env` files:

| Variable               | Description                                  | Default                           |
|------------------------|----------------------------------------------|-----------------------------------|
| `STEAM_USER`           | Steam username for logging in.               | None                              |
| `STEAM_PASS`           | Steam password for logging in.               | None                              |
| `ARMA_HOST`            | IP address or hostname of the Arma 3 server. | None                              |
| `ARMA_PORT`            | Port for the Arma 3 server.                  | `2302`                            |
| `ARMA_PASS`            | Password for the Arma 3 server.              | None                              |
| `ARMA_MODS`            | List of mods separated by semicolons.        | None                              |
| `HC_NAME_PREFIX`       | Prefix for the headless client name.         | `arma3_hc_`                       |
| `HC_ADDITIONAL_PARAMS` | Additional launch parameters for Arma 3.     | `-nosplash -world=empty -nosound` |

---

## **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## **Contributing**

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

---

## **Acknowledgments**

Special thanks to [Dan Albert](https://github.com/DanAlbert) for the original implementation of the Arma 3 headless client Docker image. This project builds upon and improves the foundation provided by the original work.

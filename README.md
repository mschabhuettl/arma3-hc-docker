# 📦 **Arma 3 Headless Client Docker Image**

Welcome to the **Arma 3 Headless Client** repository! This project provides a Docker image to easily deploy and manage multiple Arma 3 headless clients, offloading AI and scripting calculations to boost your Arma 3 server's performance. 🎮💨

---

## ✨ **Features**
- 🐳 **Dockerized Deployment**: Effortlessly set up Arma 3 headless clients.
- 📦 **Multi-client Support**: Run multiple clients via `docker compose`.
- ⚙️ **Fully Configurable**: Customize using environment variables.
- 🔄 **Automatic Updates**: Auto-install and update server files and mods.
- 🔁 **Resilient Client Reconnects**: Built-in retry mechanism for reconnects.

---

## 🚀 **Getting Started**

### 1️⃣ **Clone the Repository**
```bash
git clone https://github.com/mschabhuettl/arma3-hc-docker.git
cd arma3-hc-docker
```

### 2️⃣ **Build the Updater**
Build the updater container:
```bash
docker compose build updater
```

### 3️⃣ **Configure Settings**
Edit `arma3_hc_config.env` to fit your needs (mods, server details, credentials, etc.).

### 4️⃣ **Start the Updater**
Start the updater to download the required Arma 3 server files:
```bash
docker compose up updater
```

### 5️⃣ **Run Headless Clients**
Start the headless clients using the updated configuration:
```bash
docker compose up -d arma3-client-0 arma3-client-1
```

---

## 🔧 **Usage**

### **Run Multiple Clients with Docker Compose**
With `docker compose`, you can easily define and manage multiple clients.

**Example `docker-compose.yml`**:
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

**Environment File Example (`arma3_hc_config.env`)**
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

## 🔄 **Retry Mechanism**

The startup script has an automatic retry feature to handle issues like:
- 🚫 **Steam Authentication Errors** (e.g., `Invalid ticket`).
- 🔌 **Server Disconnections**.
- ❗ **Unexpected Issues** preventing client connections.

---

## ⚙️ **Configuration**

### **Environment Variables**

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

## 📜 **License**

This project is licensed under the MIT License. See the `LICENSE` file for more details.

---

## 🤝 **Contributing**

Contributions are always welcome! Feel free to submit a pull request or open an issue to discuss changes. Let's make this project better together! 💡✨

---

## 🙏 **Acknowledgments**

Special thanks to [Dan Albert](https://github.com/DanAlbert) for the original Arma 3 headless client Docker image. This project builds upon and improves his foundation. 🙌🎉

---

Happy gaming, and may your FPS always be high! 🎮🔥🚀

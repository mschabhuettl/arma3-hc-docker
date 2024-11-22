# 📦 **Arma 3 Headless Client Docker Image**

Welcome to the **Arma 3 Headless Client** repository! This project provides a Docker image to easily deploy and manage multiple Arma 3 headless clients, offloading AI and scripting calculations to boost your Arma 3 server's performance. 🎮💨

---

## ✨ **Features**
- 🐳 **Dockerized Deployment**: Effortlessly set up Arma 3 headless clients.
- 📦 **Multi-client Support**: Run multiple clients via `docker compose`.
- ⚙️ **Fully Configurable**: Customize using environment variables.
- 🔄 **Automatic Updates**: Auto-install and update server files and mods.
- 🔁 **Resilient Client Reconnects**: Built-in retry mechanism for reconnects.
- 📂 **Persistent Data Storage**: Uses Docker volumes to store configuration and logs persistently.
- 🛠️ **Separate Dockerfiles for Flexibility**: Different Dockerfiles for the updater and clients for better management.
- 🤖 **Automated Mod Handling**: Automatically handles downloading and updating of mods.

---

## 🚀 **Getting Started**

### 🏗️ **Option 1: Using Prebuilt Images**
The simplest way to get started is to use the prebuilt images hosted on Docker Hub.

#### 1️⃣ **Clone the Repository**
```bash
git clone https://github.com/mschabhuettl/arma3-hc-docker.git
cd arma3-hc-docker
```

#### 2️⃣ **Create Configuration**
Edit the `arma3_hc_config.env` file to match your Arma 3 server setup.

#### 3️⃣ **Run Updater**
Run the updater to download the Arma 3 server files and mods:
```bash
docker compose up updater
```

#### 4️⃣ **Start Headless Clients**
Start the headless clients:
```bash
docker compose up -d arma3-client-0 arma3-client-1
```

#### **Prebuilt Images Used**
The following Docker Hub images are used:
- `mschabhuettl/arma3-hc-docker-updater:latest`
- `mschabhuettl/arma3-hc-docker-client:latest`

---

### 🛠️ **Option 2: Custom Building**
If you prefer to build the images locally:

#### 1️⃣ **Clone the Repository**
```bash
git clone https://github.com/mschabhuettl/arma3-hc-docker.git
cd arma3-hc-docker
```

#### 2️⃣ **Build the Updater**
Build the updater container:
```bash
docker compose -f docker-compose.custom-build.yml build updater
```

#### 3️⃣ **Create Configuration**
Edit `arma3_hc_config.env` to fit your needs (mods, server details, credentials, etc.).

#### 4️⃣ **Start the Updater**
Start the updater to download the required Arma 3 server files:
```bash
docker compose -f docker-compose.custom-build.yml up updater
```

#### 5️⃣ **Run Headless Clients**
Start the headless clients:
```bash
docker compose -f docker-compose.custom-build.yml up -d arma3-client-0 arma3-client-1
```

---

## 🔧 **Docker Compose Examples**

### **Prebuilt Image Compose File**
```yaml
services:
  updater:
    image: mschabhuettl/arma3-hc-docker-updater:latest
    container_name: arma3-updater
    env_file:
      - ./arma3_hc_config.env
    volumes:
      - ./arma3_hc_config.env:/arma3/arma3_hc_config.env
      - arma3_data:/arma3
      - arma3_mods:/arma3/steamapps/workshop/content/107410
      - arma3_mods_dir:/arma3/mods
    command: /bin/bash -c "source /arma3/arma3_hc_config.env && /arma3/start_updater.sh"
    restart: "no"

  arma3-client-0:
    image: mschabhuettl/arma3-hc-docker-client:latest
    container_name: arma3-client-0
    env_file:
      - ./arma3_hc_config.env
    volumes:
      - ./arma3_hc_config.env:/arma3/arma3_hc_config.env
      - arma3_data:/arma3
      - arma3_mods:/arma3/steamapps/workshop/content/107410
      - arma3_mods_dir:/arma3/mods
      - arma3_logs:/logs
    command: /bin/bash -c "source /arma3/arma3_hc_config.env && /scripts/start_client.sh"
    restart: always

  arma3-client-1:
    image: mschabhuettl/arma3-hc-docker-client:latest
    container_name: arma3-client-1
    env_file:
      - ./arma3_hc_config.env
    volumes:
      - ./arma3_hc_config.env:/arma3/arma3_hc_config.env
      - arma3_data:/arma3
      - arma3_mods:/arma3/steamapps/workshop/content/107410
      - arma3_mods_dir:/arma3/mods
      - arma3_logs:/logs
    command: /bin/bash -c "source /arma3/arma3_hc_config.env && /scripts/start_client.sh"
    restart: always

volumes:
  arma3_data:
  arma3_mods:
  arma3_mods_dir:
  arma3_logs:
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

## 📂 **File Overview**
- **`arma3_hc_config.env`**: Configuration file with server settings, mods, and credentials.
- **`docker-compose.yml`**: Defines the services for the updater and headless clients.
- **`Dockerfile.client`**: Dockerfile to create the container for the headless clients.
- **`Dockerfile.updater`**: Dockerfile to create the container for updating server files and mods.
- **`start_client.sh`**: Script executed to start the headless clients.
- **`start_updater.sh`**: Script executed to update server files and mods.

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

## 🛠️ **Dockerfile Details**
- **`Dockerfile.client`**: This Dockerfile creates the container for running headless clients. It ensures that the client connects to the specified Arma 3 server and joins as a headless client, improving AI handling.
- **`Dockerfile.updater`**: This Dockerfile creates the updater container, responsible for downloading and keeping the Arma 3 server files and mods up-to-date.

---

## ⚡ **Performance Tips**
- **Scale Clients**: You can add more headless clients by defining additional services in the `docker-compose.yml` file. This helps distribute the load more effectively.
- **Resource Allocation**: Ensure your server has enough CPU and RAM, as running multiple headless clients can be resource-intensive.
- **Use SSDs**: Using SSD storage for `arma3_data` can significantly improve loading times and reduce lag.

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

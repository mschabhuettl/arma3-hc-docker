# **Arma 3 Headless Client**

This repository provides a Docker image for deploying Arma 3 headless clients. It simplifies the setup and management of multiple headless clients, which are used to improve Arma 3 server performance by offloading AI and scripting calculations.

---

## **Features**
- Dockerized Arma 3 headless client for easy deployment.
- Compatible with multiple clients via `docker-compose`.
- Fully configurable using environment variables.
- Automatically installs or updates Arma 3 server files.

---

## **Getting Started**

### **Clone the Repository**
```bash
git clone https://github.com/mschabhuettl/arma3-headless-client-docker.git
cd arma3-headless-client-docker
```

---

## **Usage**

### **Run a Single Headless Client**
Use the following command to run a single headless client container:
```bash
docker run -it arma3-headless-client 
  -e STEAM_USER=<your_steam_username> 
  -e STEAM_PASS=<your_steam_password> 
  -e ARMA_HOST=<server_address> 
  -e ARMA_PORT=<server_port> 
  -e ARMA_PASS=<server_password>
```

Replace the placeholders (<...>) with your actual credentials and server details.

---

### **Run Multiple Clients with Docker Compose**
You can define and run multiple clients using `docker-compose`.

**`docker-compose.yml` Example:**
```yaml
services:
  arma3-client-0:
    image: arma3-headless-client
    container_name: arma3-client-0
    env_file: client0.env
    restart: always

  arma3-client-1:
    image: arma3-headless-client
    container_name: arma3-client-1
    env_file: client1.env
    restart: always
```

**Environment File Example (`client0.env`):**
```env
STEAM_USER=your_steam_username
STEAM_PASS=your_steam_password
ARMA_HOST=your_server_address
ARMA_PORT=2302
ARMA_PASS=your_server_password
```

**Start the Clients:**
```bash
docker-compose up -d
```

---

## **Building the Docker Image**

### **Build Locally**
You can build the Docker image with the following command:
```bash
docker build -t arma3-headless-client .
```

---

## **Configuration**

### **Environment Variables**
The following variables can be configured via `.env` files or directly in the `docker run` command:

| Variable     | Description                                  | Default |
|--------------|----------------------------------------------|---------|
| `STEAM_USER` | Steam username for logging in.               | None    |
| `STEAM_PASS` | Steam password for logging in.               | None    |
| `ARMA_HOST`  | IP address or hostname of the Arma 3 server. | None    |
| `ARMA_PORT`  | Port for the Arma 3 server.                  | `2302`  |
| `ARMA_PASS`  | Password for the Arma 3 server.              | None    |

---

## **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## **Contributing**

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

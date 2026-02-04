Read and run:
- `docker.sh` for Docker image creation and management
- `singularity.sh` for Docker to Singularity creation and running

If you are behind proxy make this changes so the container to work behind it
```
$ git diff
diff --git a/.bash_aliases b/.bash_aliases
index fbd6c0f..1acbe89 100644
--- a/.bash_aliases
+++ b/.bash_aliases
@@ -12,7 +12,7 @@ Without proxy:
 - .bash_aliases::Prevent from exporting, eg. `if [[ ! : ]]; then <proxy>; fi`
 EOF
 
-if [[ ! : ]]; then
+if [[ : ]]; then
 export https_proxy=http://proxy-us.intel.com:912
 export HTTPS_PROXY=$https_proxy
 export http_proxy=http://proxy-us.intel.com:911
diff --git a/Dockerfile b/Dockerfile
index 2f11928..d88034e 100644
--- a/Dockerfile
+++ b/Dockerfile
@@ -26,7 +26,7 @@ echo "${username}:${password}" | chpasswd
 EOF
 
 # This apt-conf includes the http proxy used in Intel. Run it only for Intel.
-#COPY apt.conf /etc/apt/
+COPY apt.conf /etc/apt/
 
 RUN set -e \
   && apt-get update -y \
```

require "resolv"

docker_host_ip = begin
                   Resolv.getaddress("host.docker.internal")
                 rescue
                   "127.0.0.1"
                 end

File.write(".env", "DOCKER_HOST_IP=#{docker_host_ip}", mode: "a")

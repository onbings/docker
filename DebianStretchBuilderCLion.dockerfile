# CLion remote docker environment (How to build docker container, run and stop it)
#
# Build and run:
#   docker build -t debian_builder_clion -f DebianStretchBuilderCLion.dockerfile .
#   docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 --name ssh_debian_builder_clion debian_builder_clion
#   ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
#
# stop:
#   docker stop clion_remote_env
# 
# ssh credentials (test user):
#   user@password 

FROM debian:stretch

RUN apt-get update \
  && apt-get install -y ssh \
      build-essential \
      gcc \
      g++ \
      gdb \
      clang \
      cmake \
      rsync \
      tar \
      python \
  && apt-get clean

RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd

RUN useradd -m bha \
  && yes password | passwd a

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]
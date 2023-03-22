FROM ubuntu:22.04 AS ubuntu-rippled-compile-pre
RUN apt update
RUN apt-get install -y
RUN apt install -y python3 python3-pip cmake gcc-10 g++-10
RUN pip3 install conan==1.59.0

COPY ["./rippled", "/XRP/rippled"]
WORKDIR '/XRP/rippled/'

RUN conan profile new default --detect
RUN conan profile update settings.compiler.cppstd=20 default
RUN conan profile update settings.compiler.libcxx=libstdc++11 default
RUN conan export external/snappy snappy/1.1.9@

FROM ubuntu-rippled-compile-pre as ubuntu-rippled-compile-node
RUN conan export external/cassandra-cpp-driver/all/conanfile.py 2.16.2@
RUN mkdir /build
RUN conan install . --output-folder /build --settings build_type=Release --options reporting=False --build=missing
RUN apt install -y git
WORKDIR '/build'
RUN cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=/build/build/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release /XRP/rippled/
RUN cmake --build /build

FROM ubuntu-rippled-compile-pre as ubuntu-rippled-compile-reporting
RUN conan export external/cassandra-cpp-driver/all/conanfile.py 2.16.2@
RUN mkdir /build
RUN conan install . --output-folder /build --settings build_type=Release --options reporting=True --build=missing
RUN apt install -y git
WORKDIR '/build'
RUN cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=/build/build/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release /XRP/rippled/
RUN cmake --build /build

FROM ubuntu:22.04 as ubuntu-rippled-node
COPY --from=ubuntu-rippled-compile-node /build /XRP/rippled
COPY ["rippled.cfg", "/XRP/rippled/rippled.cfg"]
COPY ["validators.cfg", "/XRP/rippled/validators.cfg"]
CMD ["/bin/bash"]

FROM ubuntu:22.04 as ubuntu-rippled-reporting
COPY --from=ubuntu-rippled-compile-reporting /build /XRP/rippled
COPY ["rippled-reporting.cfg", "/XRP/rippled/rippled-reporting.cfg"]
COPY ["validators.cfg", "/XRP/rippled/validators.cfg"]
CMD ["/bin/bash"]

FROM ubuntu:22.04 as ubuntu-rippled-both
COPY --from=ubuntu-rippled-compile-node /build /XRP/rippled
COPY ["rippled.cfg", "/XRP/rippled/rippled.cfg"]
COPY ["validators.cfg", "/XRP/rippled/validators.cfg"]
COPY --from=ubuntu-rippled-compile-reporting /build /XRP/rippled-reporting
COPY ["rippled-reporting.cfg", "/XRP/rippled-reporting/rippled-reporting.cfg"]
COPY ["validators.cfg", "/XRP/rippled-reporting/validators.cfg"]
CMD ["/bin/bash"]

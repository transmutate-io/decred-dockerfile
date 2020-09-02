FROM golang:1.15.0-alpine3.12 AS build

ENV DCRD_VERSION release-v1.5.2
ENV WALLET_VERSION wallet/v3.2.1

RUN apk add git && mkdir /src

RUN cd /src && \
    git clone https://github.com/decred/dcrd.git && \
    cd dcrd && \
    git checkout ${DCRD_VERSION} && \
    go build && \
    for b in addblock findcheckpoint gencerts promptsecret; do \
        go build github.com/decred/dcrd/cmd/$b ; \
    done

RUN cd /src && \
    git clone https://github.com/decred/dcrwallet.git && \
    cd dcrwallet && \
    git checkout ${WALLET_VERSION} && \
    go build && \
    for b in movefunds repaircfilters sweepaccount; do \
        go build github.com/decred/dcrwallet/cmd/$b ; \
    done

RUN cd /src && \
    git clone https://github.com/decred/dcrctl.git && \
    cd dcrctl && \
    go build

FROM alpine:3.12.0

RUN mkdir -p /opt/decred/bin

COPY --from=build \
    /src/dcrd/dcrd \
    /src/dcrd/addblock \
    /src/dcrd/findcheckpoint \
    /src/dcrd/gencerts \
    /src/dcrd/promptsecret \
    /src/dcrwallet/dcrwallet \
    /src/dcrwallet/movefunds \
    /src/dcrwallet/repaircfilters \
    /src/dcrwallet/sweepaccount \
    /src/dcrctl/dcrctl \
    /opt/decred/bin/

# COPY --from=build /src/dcrd/addblock /opt/decred/bin
# COPY --from=build /src/dcrd/findcheckpoint /opt/decred/bin
# COPY --from=build /src/dcrd/gencerts /opt/decred/bin
# COPY --from=build /src/dcrd/promptsecret /opt/decred/bin
# COPY --from=build /src/dcrwallet/dcrwallet /opt/decred/bin
# COPY --from=build /src/dcrwallet/movefunds /opt/decred/bin
# COPY --from=build /src/dcrwallet/repaircfilters /opt/decred/bin
# COPY --from=build /src/dcrwallet/sweepaccount /opt/decred/bin
# COPY --from=build /src/dcrctl/dcrctl /opt/decred/bin

COPY entrypoint.sh /
COPY wait-for-dcrd.sh /opt/decred/bin

ENV PATH /opt/decred/bin:$PATH

ENTRYPOINT ["/entrypoint.sh"]

CMD ["dcrd"]
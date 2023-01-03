FROM cupcakearmy/autorestic:1.7.4
FROM alpine:3.17.0
COPY --from=0 /usr/bin/autorestic /usr/bin/autorestic
CMD ["/bin/sh"]
FROM cupcakearmy/autorestic:1.7.4
FROM alpine:3.18.5
COPY --from=0 /usr/bin/autorestic /usr/bin/autorestic
CMD ["/bin/sh"]
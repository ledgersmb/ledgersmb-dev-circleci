#!/bin/bash


pgdata=${PGDATA:-/var/lib/postgresql/data}

sed -i -e '
s/^#fsync = on/fsync = off/;
s/^#synchronous_commit = on/synchronous_commit = off/;
' $pgdata/postgresql.conf

cat > "$pgdata/pg_hba.conf" <<'__END__'
local   all             postgres                                trust
host    all             postgres        127.0.0.1/32            trust
host    all             postgres        ::1/128                 trust
host    all             all             all                     md5
__END__

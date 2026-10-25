#!/usr/bin/env -S fish --no-config

# termux-unison
# starts with asking user
read -l -P "would you like to install Unison? [y/n] " response
if not string match -ri '^y(es)?$' -- "$response"
    echo "Aborted.";exit 0
end
echo "Continuing script..."
function on_error --on-event fish_cancel
    echo "Aborted."
    exit 1
end

set -gx OCAML_VERSION "5.3.0"
set -gx UNISON_VERSION "2.53.7"
set -gx API 28
set -gx TARGET "$(uname -m)-unknown-linux-android"
set -l TMP_DIR "$HOME/tmp"

pkg upgrade -y; or exit 1
pkg install -y binutils build-essential clang make git curl unzip libandroid-shmem; or exit 1

mkdir -p "$TMP_DIR"

set -l OCAML_TAR "$TMP_DIR/ocaml.tar.gz"
set -l OCAML_SRC "$TMP_DIR/ocaml-$OCAML_VERSION"

curl -L "https://github.com/ocaml/ocaml/archive/refs/tags/{$OCAML_VERSION}.tar.gz" -o "$OCAML_TAR"; or exit 1
tar xzf "$OCAML_TAR" -C "$TMP_DIR"; or exit 1

cd "$OCAML_SRC"; or exit 1

./configure \
    --prefix="$PREFIX" \
    --disable-warn-error \
    --without-afl \
    CC="clang --target=$TARGET$API" \
    LDFLAGS="-landroid-shmem"; or exit 1

make world; or exit 1
make install; or exit 1

ocaml --version
ocamlc --version

set -l UNISON_TAR "$TMP_DIR/unison.tar.gz"
set -l UNISON_SRC "$TMP_DIR/unison-$UNISON_VERSION"

curl -L "https://github.com/bcpierce00/unison/archive/refs/tags/v{$UNISON_VERSION}.tar.gz" -o "$UNISON_TAR"; or exit 1
tar xzf "$UNISON_TAR" -C "$TMP_DIR"; or exit 1

cd "$UNISON_SRC"; or exit 1

make NATIVE=false; or exit 1
make NATIVE=false install; or exit 1

cd "$HOME"
rm -rf "$OCAML_SRC" "$UNISON_SRC" "$OCAML_TAR" "$UNISON_TAR"

unison -version
echo "installation finished"

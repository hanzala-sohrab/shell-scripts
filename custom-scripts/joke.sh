#!/bin/zsh

set -eu

jokeRes="$(curl --silent 'https://v2.jokeapi.dev/joke/Programming,Dark,Pun,Spooky')"
errored="$(jq '.error' <<<"$jokeRes")"
if [ "$errored" == "false" ]; then
  jokeType="$(jq '.type' <<<"$jokeRes")"
  if [ "$jokeType" == "\"twopart\"" ]; then
    setup="$(jq '.setup' <<<"$jokeRes")"
    delivery="$(jq '.delivery' <<<"$jokeRes")"
    notify-send \
      --hint int:transient:1 \
      --icon "face-laugh-symbolic" \
      "Wait for it" "$setup"
    sleep 3
    notify-send \
      --hint int:transient:1 \
      --icon "face-laugh-symbolic" \
      "HAHAHA" "$delivery"
  else
    joke="$(jq '.joke' <<<"$jokeRes")"
    notify-send \
      --hint int:transient:1 \
      --icon "face-laugh-symbolic" \
      "HAHAHA" "$joke"
  fi
fi

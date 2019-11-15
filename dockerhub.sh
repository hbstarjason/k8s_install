#!/bin/bash

# Example for the Docker Hub V2 API
# Requires 'jq': https://stedolan.github.io/jq/

UNAME="hbstarjason"
UPASS=""
repo=hbstarjason
img_name=''
tag=''

# aquire token
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

# list all the images of my repo  (!!!!!I think this is not correct,it can't list all the images!!!!!!!)
curl -s https://hub.docker.com/v2/repositories/${repo}/?page_size=100 | jq -r .results[].name

# get all the tags of the image
curl -s https://hub.docker.com/v2/repositories/${repo}/${img_name}/tags/?page_size=1000 | jq -r '.results[].name'

# delete images and/or tags
curl -X DELETE -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${repo}/${img_name}/
curl -X DELETE -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${repo}/${img_name}/tags/${tag}/


# get single tag some info
curl -sL 'https://cloud.docker.com/v2/repositories/hbstarjason/sw-base/tags/6.1.0'   | jq .

{
  "name": "6.1.0",
  "full_size": 17499387,
  "images": [
    {
      "size": 17499387,
      "digest": "sha256:eed68e65f6f029baddf02f7e4bb1a78c42d020f36d779eb2abc97e96965e2ac9",
      "architecture": "amd64",
      "os": "linux",
      "os_version": null,
      "os_features": "",
      "variant": null,
      "features": ""
    }
  ],
  "id": 76285325,
  "repository": 8015433,
  "creator": 3115748,
  "last_updater": 3115748,
  "last_updater_username": "hbstarjason",
  "image_id": null,
  "v2": true,
  "last_updated": "2019-11-14T03:28:54.967174Z"
}

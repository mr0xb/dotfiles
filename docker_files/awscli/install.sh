
cat > ../bin/yq <<EOF
yq () {
  docker run \\
  --rm \\
  --net none \\
  --pid host \\
  --name yq \\
  --entrypoint "yq" \\
  -i \\
  \${DOCKER_REPO_PREFIX}/yq "\$@"
}

jq () {
  docker run \\
  --rm \\
  --net none \\
  --pid host \\
  --name yq \\
  --entrypoint "jq \\
  -i \\
  \${DOCKER_REPO_PREFIX}/yq "\$@"
}
EOF

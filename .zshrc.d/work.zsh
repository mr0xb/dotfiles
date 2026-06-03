[ -f $HOME/.config/.vault ] && source ~/.config/.vault
[ -f $HOME/.vault-token ] && source ~/.vault-token

export AWS_VAULT_BACKEND=keychain
export AWS_VAULT_KEYCHAIN_NAME="aws-vault.keychain-db"
export AWS_LOGIN_BROWSER="firefox"

export KUBECONFIG="${HOME}/.kube/teleport-kubeconfig:${HOME}/.kube/config:${HOME}/.kube/minikube"

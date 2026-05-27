export VAULT_ADDR=https://vault.immuta.io:8200
#export VAULT_ADDR=https://vault.infrastructure.immuta.io:8200
export VAULT_TOKEN=$(cat ~/.vault-token)

export AWS_VAULT_BACKEND=keychain
export AWS_VAULT_KEYCHAIN_NAME="aws-vault"
export AWS_LOGIN_BROWSER="firefox"

#export KUBECONFIG=/Users/steve.briggs/.kube/config:/Users/steve.briggs/.kube/minikube
export KUBECONFIG="${HOME}/.kube/teleport-kubeconfig:${HOME}/.kube/config:${HOME}/.kube/minikube"
export PATH=$PATH:/private/var/folders/ky/m6p32md91_n2q6z94fdn8fsw0000gq/T/AppTranslocation/F252CD76-5A71-4D7F-8826-12175DB43E32/d/Visual\ Studio\ Code.app/Contents/Resources/app/bin

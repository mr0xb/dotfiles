kimgs() {
    local context="${1:-$(kubectl config current-context 2>/dev/null)}"
    if [[ -z "$context" ]]; then
        echo "kimgs: no context specified and no current context set" >&2
        return 1
    fi
    kubectl --context="$context" get pods --all-namespaces \
        -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{"\t"}{.image}{"\n"}{end}{end}' \
        | column -t -s $'\t'
}
kutil () {
        for host in $(kubectl get nodes --no-headers | cut -d' ' -f1)
        do
                echo "$host - $(kubectl get nodes -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}' $host)"
                kubectl describe node "$host" | grep --color Allocated -A 5 | grep --color -ve Event -ve Allocated -ve percent -ve --
                echo
        done
}

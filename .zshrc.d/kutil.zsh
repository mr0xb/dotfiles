kutil () {
        for host in $(kubectl get nodes --no-headers | cut -d' ' -f1)
        do
                echo "$host - $(kubectl get nodes -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}' $host)"
                kubectl describe node "$host" | grep --color Allocated -A 5 | grep --color -ve Event -ve Allocated -ve percent -ve --
                echo
        done
}

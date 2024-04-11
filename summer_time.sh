date -s $(date --date=@$(($(date +%s) - 3600)) +%Y-%m-%dT%H:%M)



## Use:
```
http://grafana-host:3000/dashboard/script/nginx-script-dashboard.js?name=server-short-name-1
```

Dica:

* linhas 56 até 171: Importei uma row de um grafico qualquer gerado manualmente.
* linha 132: Alterei o "target", com a seriesName: 
```
s/server-short-name-1/" + seriesName + "/g
``` 


## Use:
```
http://grafana-host:3000/dashboard/script/nginx-script-dashboard.js?name=server-short-name-1
```

Dica:

* linhas 56 até 171: Importei uma row, a partir de um json após ter gerado um gráfico qualquer manualmente.
* linha 132: Alterei o "target" da row, mudando o hostname ali presente para "seriesName" uma variável: 
```
s/server-short-name-1/" + seriesName + "/g
``` 

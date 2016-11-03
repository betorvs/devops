
## Use:
```
http://grafana-host:3000/dashboard/script/nginx-script-dashboard.js?name=server-short-name-1
```

Dica (nginx-script-dashboard.js):

* linhas 56 até 171: Gerei um gráfico, uma única row, com as métricas do nginx, e exportei como json. Recortei a row e colei naquele trecho do código.
* linha 132: Alterei o "target" da row, mudando o hostname ali presente para "seriesName" uma variável: 
```
s/server-short-name-1/" + seriesName + "/g
``` 

* O outro arquivo vm.js é um exemplo antigo com vários gráficos no mesmo script dashboard.
* Novas rows são feitas com este trecho aqui:
```
  dashboard.rows.push(
// Cole a row aqui!!!!
  );
```

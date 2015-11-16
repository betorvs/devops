/* global _ */

/*
 * Complex scripted dashboard
 * This script generates a dashboard object that Grafana can load. It also takes a number of user
 * supplied URL parameters (in the ARGS variable)
 *
 * Return a dashboard object, or a function
 *
 * For async scripts, return a function, this function must take a single callback function as argument,
 * call this callback function with the dashboard object (look at scripted_async.js for an example)
 */



// accessible variables in this scope
var window, document, ARGS, $, jQuery, moment, kbn;

// Setup some variables
var dashboard;

// All url parameters are available via the ARGS object
var ARGS;

// Intialize a skeleton with nothing but a rows array and service object
dashboard = {
  rows : [],
};

// Set a title
dashboard.title = 'Scripted dash';

// Set default time
// time can be overriden in the url using from/to parameters, but this is
// handled automatically in grafana core during dashboard initialization
dashboard.time = {
  from: "now-6h",
  to: "now"
};

var rows = 1;
var seriesName = 'argName';

if(!_.isUndefined(ARGS.rows)) {
  rows = parseInt(ARGS.rows, 10);
}

if(!_.isUndefined(ARGS.name)) {
  seriesName = ARGS.name;
}

for (var i = 0; i < rows; i++) {

  dashboard.rows.push({
    title: 'DevOps Dash',
    height: '300px',
    panels: [
      {
        title: 'CPU',
        type: 'graph',
        span: 12,
        fill: 1,
        linewidth: 2,
        targets: [
          {
            'target': "" + seriesName + ".*.infra.cpu.*"
          },
        ],
      }
    ]
  });

  dashboard.rows.push({
    title: 'DevOps Dash',
    height: '300px',
    panels: [
      {
        title: 'Load Average',
        type: 'graph',
        span: 12,
        fill: 1,
        linewidth: 2,
        targets: [
          {
            'target': "" + seriesName + ".*.infra.load_avg.*"
          },
        ],
      }
    ]
  });

  dashboard.rows.push({
    title: 'DevOps Dash',
    height: '300px',
    panels: [
      {
        title: 'MEMORY',
        type: 'graph',
        span: 12,
        fill: 1,
        linewidth: 2,
        targets: [
        {
          'target': "" + seriesName + ".*.infra.memory.total"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.cached"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.free"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.used"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.buffers"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.dirty"
        },
        ],
      }
    ]
  });

  dashboard.rows.push({
    title: 'DevOps Dash',
    height: '300px',
    panels: [
      {
        title: 'SWAP',
        type: 'graph',
        span: 12,
        fill: 1,
        linewidth: 2,
        targets: [
        {
          'target': "" + seriesName + ".*.infra.memory.swapTotal"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.swapFree"
        },
        {
          'target': "" + seriesName + ".*.infra.memory.swapUsed"
        },
        ],
      }
    ]
  });

  dashboard.rows.push({
    title: 'DevOps Dash',
    height: '300px',
    panels: [
      {
        title: 'eth0 Interface',
        type: 'graph',
        span: 12,
        fill: 1,
        linewidth: 2,
        targets: [
          {
            'target': "" + seriesName + ".*.infra.interface.eth0.*"
          },
        ],
      }
    ]
  });

  dashboard.rows.push({
    title: 'DevOps Dash',
    height: '300px',
    panels: [
      {
        title: 'eth1 Interface',
        type: 'graph',
        span: 12,
        fill: 1,
        linewidth: 2,
        targets: [
          {
            'target': "" + seriesName + ".*.infra.interface.eth1.*"
          },
        ],
      }
    ]
  });

}


return dashboard;

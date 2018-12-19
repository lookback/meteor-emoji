var both = ['client', 'server'];

Package.describe({
  name: 'lookback:emoji',
  summary: 'Easily render and manage emojis in Meteor.',
  version: '0.5.0',
  git: 'https://github.com/lookback/meteor-emoji'
});

Package.onUse(function(api) {
  api.versionsFrom('1.6');

  api.use([
    'mongo',
    'coffeescript@2.0.2_1',
    'modules',
    'check',
    'underscore'
  ], both);

  api.use('templating@1.3.2', 'client');

  api.addFiles(['polyfill.js', 'emojis.coffee'], both);
  api.addFiles('template.coffee', 'client');
  api.addFiles('seed/seed.coffee', 'client');

  api.export('Emojis', both);
});

Package.onTest(function(api) {
  Npm.depends({
    chai: '4.1.2',
    sinon: '4.2.2'
  });

  api.use([
    'coffeescript',
    'meteortesting:mocha',
    'lookback:emoji'
  ]);

  api.addFiles([
    'spec/setup.coffee',
    'spec/emojis-spec.coffee',
    'spec/emojis-transforms-spec.coffee'
  ]);
});

var both = ['client', 'server'];

Package.describe({
  name: 'lookback:emoji',
  summary: 'Easily render and manage emojis in Meteor.',
  version: '0.3.2',
  git: 'https://github.com/lookback/meteor-emoji'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.4.2');

  api.use(['mongo', 'coffeescript', 'check', 'underscore'], both);
  api.use('templating', 'client');

  api.addAssets('seed/emojis.json', 'server');

  api.addFiles(['polyfill.js', 'emojis.coffee'], both);
  api.addFiles('template.coffee', 'client');
  api.addFiles('seed/seed.coffee', 'server');

  api.export('Emojis', both);
});

Package.onTest(function(api) {
  api.use([
    'coffeescript',
    'meteortesting:mocha',
    'practicalmeteor:chai',
    'practicalmeteor:sinon',
    'lookback:emoji'
  ]);

  api.addFiles([
    'spec/setup.coffee',
    'spec/emojis-spec.coffee',
    'spec/emojis-transforms-spec.coffee'
  ]);
});

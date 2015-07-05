var both = ['client', 'server'];

Package.describe({
  name: 'lookback:emoji',
  summary: 'Emoji collection for Meteor.',
  version: '0.1.0',
  git: 'https://github.com/lookback/meteor-emoji'
});

Package.onUse(function(api) {
  api.use(['mongo', 'coffeescript', 'underscore'], both);
  api.use('templating', 'client');

  api.addFiles('seed/emojis.json', 'server', {isAsset: true});
  
  api.addFiles('emojis.coffee', both);
  api.addFiles('template.coffee', 'client');
  api.addFiles('seed/seed.coffee', 'server');

  api.export('Emojis', both);
});

Package.onTest(function(api) {
  api.use([
    'coffeescript',
    'mike:mocha-package',
    'practicalmeteor:chai',
    'practicalmeteor:sinon',
    'respondly:test-reporter',
    'lookback:emoji'
  ]);

  api.addFiles('spec/emojis-spec.coffee');
  api.addFiles('spec/emojis-server-spec.coffee', 'server');
});

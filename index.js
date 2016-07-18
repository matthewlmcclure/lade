require('coffee-script/register');

module.exports = {
  PACKAGE_INFO: require('./package.json'),
  CLI:          require('./lib/cli'),
  LANGUAGES:    require('./lib/languages'),
  Project:      require('./lib/project'),
  Default:      require('./lib/styles/Default')
};

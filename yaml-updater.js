const { Updater } = require('release-please');

class YamlUpdater extends Updater {
   /**
   * Updates the version in the YAML descriptor file.
   */
  updateContent(content) {
    console.log('YamlUpdater called with content:');
    console.log(content);

    const versionRegex = /version:\s*["'](\d+\.\d+\.\d+)["']/;
    const updatedContent = content.replace(versionRegex, `version: "${this.version}"`);

    console.log('Updated content:');
    console.log(updatedContent);

    return updatedContent;
  }
}

module.exports = { YamlUpdater };






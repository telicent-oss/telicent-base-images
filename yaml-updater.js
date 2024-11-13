const { Updater } = require('release-please');

class CekitYamlUpdater extends Updater {
  /**
   * Updates the version in the YAML descriptor file.
   */
  updateContent(content) {
    const versionAnchorRegex = /version:\s*&version\s*["'](\d+\.\d+\.\d+)["']/;

    return content.replace(
      versionAnchorRegex,
      `version: &version "${this.version}"`
    );
  }
}

module.exports = { CekitYamlUpdater };

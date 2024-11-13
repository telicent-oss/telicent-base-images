const { Updater } = require('release-please');

class CekitYamlUpdater extends Updater {
  updateContent(content) {
    const versionRegex = /version:\s*["'](\d+\.\d+\.\d+)["']/;
    const updatedVersion = content.replace(versionRegex, `version: "${this.version}"`);

    const labelRegex = /labels:\n\s*version:\s*["'](\d+\.\d+\.\d+)["']/;
    const updatedContent = updatedVersion.replace(labelRegex, `labels:\n  version: "${this.version}"`);

    return updatedContent;
  }
}

module.exports = { CekitYamlUpdater };